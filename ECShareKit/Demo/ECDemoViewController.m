#import "ECDemoViewController.h"
#import "ECComposeViewController.h"
#import "ECFacebookSharingActivity.h"
#import "ECTwitterSharingActivity.h"
#import "ECVKSharingActivity.h"
#import "ECOdnoklassnikiSharingActivity.h"
#import "ECMailRuSharingActivity.h"
#import "ECYandexSharingActivity.h"
#import "ECActivityViewController.h"
#import "MRSocialProvidersFactory.h"
#import "JSONKit.h"

#define kECButtonWidth 150
#define kECButtonHeight 50

@interface ECDemoViewController () <ECActivityViewControllerDelegate>
@end

@implementation ECDemoViewController {

}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 0, kECButtonWidth, kECButtonHeight);
    button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [button setTitle:NSLocalizedString(@"Show", nil) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didTouchButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    button.center = self.view.center;

    [self loadSocialSettings];
}

- (void)loadSocialSettings {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ECDemo.bundle/ECShareKit.json" ofType:nil];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    [MRSocialProvidersFactory setSettings:[[NSString stringWithContentsOfFile:path usedEncoding:&encoding error:nil] objectFromJSONString]];
}

- (void)didTouchButton:(id)sender {
    [self showSharingActivities];
}

- (void)showComposer {
    ECComposeViewController *controller = [ECComposeViewController new];
    controller.title = NSLocalizedString(@"Facebook", nil);
    controller.text = NSLocalizedString(@"Пример текста...", nil);
    controller.placeholder = NSLocalizedString(@"Введите текст поста", nil);
    controller.image = [UIImage imageNamed:@"ECDemo.bundle/image.jpg"];

    __weak typeof (self) myself = self;
    controller.completionBlock = ^(ECComposeViewController *composeViewController, ECComposeResult result) {
        [composeViewController dismissViewControllerAnimated:YES completion:nil];
    };
    [controller presentFromRootViewController];
}

- (void)showSharingActivities {
    NSString *textItem = @"Товарное предложение";
    UIImage *imageToShare = [UIImage imageNamed:@"ECDemo.bundle/image.jpg"];

    ECActivityViewController *controller = [[ECActivityViewController alloc] initWithActivities:@[
                                                                                     [ECFacebookSharingActivity new],
                                                                                     [ECTwitterSharingActivity new],
                                                                                     [ECVKSharingActivity new],
                                                                                     [ECOdnoklassnikiSharingActivity new],
                                                                                     [ECMailRuSharingActivity new],
                                                                                     [ECYandexSharingActivity new]
                                                                             ]];
    controller.delegate = self;
    controller.title = NSLocalizedString(@"Поделиться товарным предложением", nil);
    [controller presentFromRootViewController];
}

- (NSDictionary *)activityViewControllerShareInfo:(ECActivityViewController *)activityViewController {
    return @{
        @"message" : @"Сотовый телефон Apple iPhone 5S 16GB",
        @"image" : @"ECDemo.bundle/image.jpg",
        @"placeholder" : @"Введите текст поста здесь",
        @"imageUrl" : @"http://torg12.imgsmail.ru/model/165/13900954/1-230.jpg"
    };
}

@end