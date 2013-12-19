#import "ECActivityViewController.h"
#import "ECActivityView.h"
#import "MRSocialAccountManager.h"
#import "ECActivity.h"
#import "ECComposeViewController.h"
#import "ECActivityLoginViewController.h"

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
    [UIView animateWithDuration:0.4 animations:^{
        myself.backgroundView.alpha = 0.0;
        CGRect frame = myself.activityView.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height;
        myself.activityView.frame = frame;
    } completion:^(BOOL finished) {
        [myself.view removeFromSuperview];
        [myself removeFromParentViewController];
        if (completion) {
            completion();
        }
    }];
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

    BOOL isLoggedIn = [[MRSocialAccountManager sharedInstance] isLoggedInWithType:activity.activityType];
    if (isLoggedIn) {
        ECComposeViewController *controller = [ECComposeViewController new];
        controller.title = NSLocalizedString(@"Facebook", nil);
        controller.text = NSLocalizedString(@"Пример текста...", nil);
        controller.placeholder = NSLocalizedString(@"Введите текст поста", nil);
        controller.image = [UIImage imageNamed:@"ECDemo.bundle/image.jpg"];


        controller.completionBlock = ^(ECComposeViewController *composeViewController, ECComposeResult result) {
            [composeViewController dismissViewControllerAnimated:YES completion:nil];
        };
        [controller presentFromRootViewController];
    } else {
        [ECActivityLoginViewController presentFormViewController:self withActivity:activity completionBlock:^(BOOL loggedIn) {
            [myself dismissViewControllerAnimated:YES completion:nil];
            NSLog(@"Is Logged in: %d", loggedIn);
        }];
    }
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