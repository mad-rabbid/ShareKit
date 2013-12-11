#import "ECDemoViewController.h"
#import "ECComposeViewController.h"
#import "ECFacebookSharingActivity.h"
#import "ECTwitterSharingActivity.h"
#import "ECVKSharingActivity.h"
#import "ECOdnoklassnikiSharingActivity.h"
#import "ECMailRuSharingActivity.h"
#import "ECYandexSharingActivity.h"

#define kECButtonWidth 150
#define kECButtonHeight 50

@interface ECDemoViewController ()
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

    NSArray *items = [NSArray arrayWithObjects:textItem, imageToShare, nil];

    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                             applicationActivities:@[
                                                                                     [ECFacebookSharingActivity new],
                                                                                     [ECTwitterSharingActivity new],
                                                                                     [ECVKSharingActivity new],
                                                                                     [ECOdnoklassnikiSharingActivity new],
                                                                                     [ECMailRuSharingActivity new],
                                                                                     [ECYandexSharingActivity new]
                                                                             ]];

    controller.excludedActivityTypes = @[UIActivityTypePostToFacebook,
            UIActivityTypePostToTwitter,
            UIActivityTypePostToWeibo,
            UIActivityTypeMessage,
            UIActivityTypeMail,
            UIActivityTypePrint,
            UIActivityTypeCopyToPasteboard,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo,
            UIActivityTypeAirDrop
    ];
    controller.navigationController.toolbar.barTintColor = [UIColor orangeColor];
    controller.completionHandler = ^(NSString *activityType, BOOL completed) {
        NSLog(@" activityType: %@", activityType);
        NSLog(@" completed: %i", completed);
    };

    [self presentViewController:controller animated:YES completion:nil];
}
@end