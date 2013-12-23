#import "ECActivityViewController.h"
#import "ECActivityView.h"
#import "MRSocialAccountManager.h"
#import "ECActivity.h"
#import "ECComposeViewController.h"
#import "ECActivityLoginViewController.h"
#import "Toast+UIView.h"

@interface ECActivityViewController ()
@property(nonatomic, weak, readonly) UIViewController *hostController;
@property(nonatomic, weak, readonly) UIView *backgroundView;
@property(nonatomic, weak, readonly) ECActivityView *activityView;
@property(nonatomic, strong, readonly) NSArray *activities;


@end

@implementation ECActivityViewController {

}

- (void)loadView {
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    self.view = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (id)initWithActivities:(NSArray *)activities {
    self = [super init];
    if (self) {
        _activities = activities;

        [self createBackgroundView];
        ECActivityView *activityView = [[ECActivityView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.view.frame.size.width, [ECActivityView activityViewHeight])];

        _activityView = activityView;
        activityView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        activityView.activities = self.activities;

        __weak typeof(self) myself = self;
        activityView.performActivityBlock = ^(ECActivity *activity) {
            [myself performActivity:activity];
        };
        [self.view addSubview:activityView];
    }
    return self;
}

- (void)createBackgroundView {
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    _backgroundView = backgroundView;

    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0;
    backgroundView.userInteractionEnabled = YES;
    [self.view addSubview:backgroundView];

    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureRecognizer:)];
    recognizer.numberOfTapsRequired = 1;
    recognizer.numberOfTouchesRequired = 1;
    [backgroundView addGestureRecognizer:recognizer];
}

- (void)handleGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    [self dismissActivityViewControllerAnimated:YES completion:nil];
}

- (void)dismissActivityViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    __weak typeof (self) myself = self;

    void (^block)() = ^() {
        [myself.view removeFromSuperview];
        [myself removeFromParentViewController];
        if (completion) {
            completion();
        }
    };

    if (flag) {
        [UIView animateWithDuration:0.4 animations:^{
            myself.backgroundView.alpha = 0.0;
            CGRect frame = myself.activityView.frame;
            frame.origin.y = [UIScreen mainScreen].bounds.size.height;
            myself.activityView.frame = frame;
        } completion:^(BOOL finished) {
            block();
        }];
    } else {
        block();
    }
}

- (void)presentFromRootViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [self presentFromViewController:rootViewController];
}

- (void)presentFromViewController:(UIViewController *)controller {
    _hostController = controller;
    [controller addChildViewController:self];
    [controller.view addSubview:self.view];
    [self didMoveToParentViewController:controller];

    [self show];
}

- (void)show {
    self.backgroundView.frame = self.hostController.view.bounds;
    self.activityView.title = self.title;

    __weak typeof(self) myself = self;
    [UIView animateWithDuration:0.4 animations:^{
        myself.backgroundView.alpha = 0.3;

        CGRect frame = myself.activityView.frame;
        frame.origin.y = myself.hostController.view.frame.size.height - self.activityView.bounds.size.height;
        myself.activityView.frame = frame;
    }];
    
}

- (void)performActivity:(ECActivity *)activity {
    __weak typeof (self) myself = self;

    BOOL isAlreadyLoggedIn = [[MRSocialAccountManager sharedInstance] isLoggedInWithType:activity.activityType];
    if (isAlreadyLoggedIn) {
        [self presentComposerWithActivity:activity];
    } else {
        [ECActivityLoginViewController presentFormViewController:self withActivity:activity completionBlock:^(BOOL hasJustLoggedIn) {
            [myself dismissViewControllerAnimated:YES completion:nil];
            NSLog(@"Is logged in: %d", hasJustLoggedIn);
            if (hasJustLoggedIn) {
                [myself presentComposerWithActivity:activity];
            } else {
                [myself.view makeToast:NSLocalizedString(@"Попытка логина не удалась.", nil)];
            }
            [myself.activityView reload];
        }];
    }
}

- (void)presentComposerWithActivity:(ECActivity *)activity {
    ECComposeViewController *controller = [ECComposeViewController new];
    controller.title = activity.activityTitle;
    controller.activity = activity;

    if ([self.delegate respondsToSelector:@selector(activityViewControllerShareInfo:)]) {
        NSDictionary *info = [self.delegate activityViewControllerShareInfo:self];
        controller.text = info[@"message"] ?: @"";
        controller.placeholder = info[@"placeholder"] ?: @"";

        NSString *imageName = info[@"image"];
        if (imageName.length) {
            controller.image = [UIImage imageNamed:imageName];
        }

        controller.imageUrl = info[@"imageUrl"];
    }


    __weak typeof(self) myself = self;
    controller.completionBlock = ^(ECComposeViewController *composeViewController, ECComposeResult result) {
        if (result != ECComposeResultError) {
            [composeViewController dismissViewControllerAnimated:YES completion:^() {
                __weak UIView *superview = myself.view.superview;
                [myself dismissActivityViewControllerAnimated:YES completion:^() {
                    if (result == ECComposeResultPosted) {
                        [superview makeToast:@"Сообщение успешно опубликовано!"];
                    }
                }];
            }];
        } else {
            [myself.view makeToast:@"Не удалось опубликовать сообщение. Попробуйте повторить позднее." duration:2.0 position:@"center"];
        }
    };
    [controller presentFromRootViewController];
}


#pragma mark -
#pragma mark Orientation

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return YES;
}
@end