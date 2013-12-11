#import "ECAbstractSharingActivity.h"


@implementation ECAbstractSharingActivity {

}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    NSLog(@"Preparing...");
}

- (UIViewController *)activityViewController {
    return nil;
}

- (void)performActivity {
    NSLog(@"Preforming...");
    [self activityDidFinish:YES];

}

- (void)activityDidFinish:(BOOL)completed {
    [super activityDidFinish:completed];
    NSLog(@"Finished");
}

@end