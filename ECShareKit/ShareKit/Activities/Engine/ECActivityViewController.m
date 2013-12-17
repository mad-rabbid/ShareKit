#import "ECActivityViewController.h"
#import "ECActivityView.h"

#define kECActivityViewHeight 80

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

        UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        _backgroundView = backgroundView;

        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.alpha = 0;
        [self.view addSubview:backgroundView];


        ECActivityView *activityView = [[ECActivityView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.view.frame.size.width, kECActivityViewHeight)];

        _activityView = activityView;
        activityView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        activityView.activities = self.activities;
        [self.view addSubview:activityView];
    }
    return self;
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
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

    __weak typeof(self) myself = self;
    [UIView animateWithDuration:0.4 animations:^{
        myself.backgroundView.alpha = 0.4;

        CGRect frame = myself.activityView.frame;
        frame.origin.y = myself.hostController.view.frame.size.height - self.activityView.bounds.size.height;
        myself.activityView.frame = frame;

    }];
    
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