#import "ECActivityLoginViewController.h"
#import "ECActivity.h"
#import "MRSocialLoginProvider.h"
#import "MRSocialLoginProviderFactory.h"
#import "MRSocialAccountManager.h"

@interface ECActivityLoginViewController ()
@property (nonatomic, strong, readonly) ECActivity *activity;
@property (nonatomic, weak, readonly) UIWebView *webView;
@property (nonatomic, strong) id<MRSocialLoginProvider> provider;
@end

@implementation ECActivityLoginViewController {
}

+ (void)presentFormViewController:(UIViewController *)controller withActivity:(ECActivity *)activity completionBlock:(ECActivityLoginViewControllerBlock)completionBlock{
    ECActivityLoginViewController *loginController = [[ECActivityLoginViewController alloc] initWithActivity:activity];
    loginController.completionBlock = completionBlock;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginController];

    [controller presentViewController:navigationController animated:YES completion:nil];
}


- (id)initWithActivity:(ECActivity *)activity {
    self = [super init];
    if (self) {
        _activity = activity;
        if (UIDevice.currentDevice.systemVersion.floatValue >= 7.0) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:webView];
    _webView = webView;

    UIBarButtonItemStyle style = UIDevice.currentDevice.systemVersion.floatValue >= 7.0 ? UIBarButtonItemStyleBordered : UIBarButtonItemStyleDone;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Закрыть", nil) style:style target:self action:@selector(didTouchButtonClose:)];

    _provider = [MRSocialLoginProviderFactory loginProviderWithType:self.activity.activityType];
    [_provider setWebView:self.webView];

    __weak typeof(self) myself = self;
    [_provider loginWithSuccessBlock:^(MRSocialAccountInfo *accountInfo) {
        [[MRSocialAccountManager sharedInstance] setAccount:accountInfo withType:myself.activity.activityType];
        [myself performCompletionBlockWithResult:YES];
    } failBlock:^{
        [myself performCompletionBlockWithResult:NO];
    }];
}

- (void)didTouchButtonClose:(id)sender {
    [self performCompletionBlockWithResult:NO];
}

- (void)performCompletionBlockWithResult:(BOOL)result {
    if (self.completionBlock) {
        self.completionBlock(result);
    }
}
@end