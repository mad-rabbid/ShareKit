#import "ECComposeViewController.h"
#import "ECComposeBackgroundView.h"
#import "ECUserInterface.h"
#import "ECComposeView.h"

static NSInteger const kECComposeContainerHeight = 202;
static NSInteger const kECBackViewOffset = 4;

@interface ECComposeViewController () <ECComposeViewDelegate>
@property(nonatomic, weak, readonly) UIViewController *hostViewController;

@property(nonatomic, assign, readonly) CGFloat cornerRadius;
@property(nonatomic, strong, readonly) UIColor *tintColor;

@property(nonatomic, weak, readonly) UIView *backgroundView;
@property(nonatomic, weak, readonly) UIView *containerView;
@property(nonatomic, weak, readonly) UIView *backView;
@property(nonatomic, weak, readonly) UIView *composeView;
@property(nonatomic, weak, readonly) UIImageView *paperclipView;
@end

@implementation ECComposeViewController {
}

- (id)init {
    self = [super init];
    if (self) {
        _cornerRadius = ([ECUserInterface isFlatDesign]) ? 6 : 10;
        _tintColor = [UIColor colorWithWhite:247.0 / 255.0 alpha:1.0];
    }

    return self;
}

- (void)loadView {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.view = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createBackground];

    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, kECComposeContainerHeight)];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:containerView];
    _containerView = containerView;

    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(kECBackViewOffset, 0, self.currentWidth - 2 * kECBackViewOffset, kECComposeContainerHeight)];
    [containerView addSubview:backView];
    _backView = backView;

    backView.layer.cornerRadius = _cornerRadius;
    if (![ECUserInterface isFlatDesign]) {
        backView.layer.shadowOpacity = 0.7;
        backView.layer.shadowColor = [UIColor blackColor].CGColor;
        backView.layer.shadowOffset = CGSizeMake(3, 5);
        backView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:backView.frame cornerRadius:_cornerRadius].CGPath;
        backView.layer.shouldRasterize = YES;
    }
    backView.layer.rasterizationScale = [UIScreen mainScreen].scale;

    ECComposeView *composeView = [[ECComposeView alloc] initWithFrame:backView.bounds];
    composeView.delegate = self;
    [backView addSubview:composeView];
    _composeView = composeView;

    composeView.frame = backView.bounds;
    composeView.layer.cornerRadius = _cornerRadius;
    composeView.clipsToBounds = YES;
    composeView.delegate = self;
    if ([ECUserInterface isFlatDesign]) {
        composeView.backgroundColor = self.tintColor;
    }

    if (![ECUserInterface isFlatDesign]) {
        UIImage *paperclipImage = [UIImage imageNamed:@"ECShareKit.bundle/paper-clip.png"];
        CGSize imageSize = paperclipImage.size;
        UIImageView *paperclipView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - imageSize.width + 2, 60, imageSize.width, imageSize.height)];
        _paperclipView = paperclipView;
        paperclipView.image = paperclipImage;
        [containerView addSubview:paperclipView];
        paperclipView.hidden = YES;
    }
}

- (void)createBackground {

    ECComposeBackgroundView *backgroundView = [[ECComposeBackgroundView alloc] initWithFrame:self.view.bounds];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundView.centerOffset = CGSizeMake(0, -self.view.frame.size.height / 2);
    backgroundView.alpha = 0.0;
    if ([ECUserInterface isFlatDesign]) {
        backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    }

    [self.view addSubview:backgroundView];
    _backgroundView = backgroundView;
}

- (CGFloat)currentWidth {
    UIScreen *screen = [UIScreen mainScreen];
    return (!UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) ? screen.bounds.size.width : screen.bounds.size.height;
}

- (void)layoutWithOrientation:(UIInterfaceOrientation)interfaceOrientation width:(CGFloat)width height:(CGFloat)height {
    NSInteger offset = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60 : 4;
    CGRect frame = _containerView.frame;
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            offset *= 2;
        }

        NSInteger verticalOffset = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 316 : 216;

        CGFloat containerHeight = _containerView.frame.size.height;
        frame.origin.y = MAX((height - verticalOffset - containerHeight) / 2, 20);
        _containerView.frame = frame;

        _containerView.clipsToBounds = YES;
        _backView.frame = CGRectMake(offset, 0, width - offset * 2, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? kECComposeContainerHeight : 140);
    } else {
        frame.origin.y = MAX((height - 216 - _containerView.frame.size.height) / 2, 20);
        _containerView.frame = frame;
        _backView.frame = CGRectMake(offset, 0, width - offset * 2, kECComposeContainerHeight);
    }
    self.composeView.frame = _backView.bounds;

    CGRect paperclipFrame = _paperclipView.frame;
    paperclipFrame.origin.x = width - 73 - offset;
    _paperclipView.frame = paperclipFrame;
    _paperclipView.hidden = NO;
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self.composeView resignFirstResponder];
    __weak typeof (self) weakSelf = self;

    [UIView animateWithDuration:0.4 animations:^{
        if ([ECUserInterface isFlatDesign]) {
            weakSelf.containerView.alpha = 0;
        } else {
            CGRect frame = weakSelf.containerView.frame;
            frame.origin.y = weakSelf.hostViewController.view.frame.size.height;
            weakSelf.containerView.frame = frame;
        }
    }];

    [UIView animateWithDuration:0.4
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         weakSelf.backgroundView.alpha = 0.0;
                     } completion:^(BOOL finished) {
        [weakSelf.view removeFromSuperview];
        [weakSelf removeFromParentViewController];
        if (completion) {
            completion();
        }
    }];
}

- (void)presentFromRootViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [self presentFromViewController:rootViewController];
}

- (void)presentFromViewController:(UIViewController *)controller {
    _hostViewController = controller;
    [controller addChildViewController:self];
    [controller.view addSubview:self.view];
    [self present];
}

- (void)present {
    _backgroundView.frame = self.hostViewController.view.bounds;

    if ([ECUserInterface isFlatDesign]) {
        [self layoutWithOrientation:self.interfaceOrientation width:self.view.frame.size.width height:self.view.frame.size.height];
        self.containerView.alpha = 0.0;
        [self.composeView becomeFirstResponder];
    } else {
        [UIView animateWithDuration:0.4 animations:^{
            [self.composeView becomeFirstResponder];
            [self layoutWithOrientation:self.interfaceOrientation width:self.view.frame.size.width height:self.view.frame.size.height];
        }];
    }

    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if ([ECUserInterface isFlatDesign]) {
                             self.containerView.alpha = 1.0;
                         }
                         self.backgroundView.alpha = 1.0;
                     } completion:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewOrientationDidChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return YES;
}

- (void)viewOrientationDidChanged:(NSNotification *)notification {
    [self layoutWithOrientation:self.interfaceOrientation width:self.view.frame.size.width height:self.view.frame.size.height];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    if (selector == @selector(setImage:) ||
            selector == @selector(setText:) ||
            selector == @selector(setPlaceholder:)) {
        if (!self.composeView) {
            [self view];
        }
        return self.composeView;
    }
    return [super forwardingTargetForSelector:selector];
}

- (void)cancelButtonPressed {
    if (self.completionBlock) {
        self.completionBlock(self, ECComposeResultCancelled);
    }
}

- (void)postButtonPressed {
    if (self.completionBlock) {
        self.completionBlock(self, ECComposeResultPosted);
    }
}


@end