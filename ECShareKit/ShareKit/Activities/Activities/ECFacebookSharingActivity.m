#import "ECFacebookSharingActivity.h"
#import "MRSocialProvidersFactory.h"


@implementation ECFacebookSharingActivity {

}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Facebook", nil);
}

- (UIImage *)activityImage {
    UIImage *result = [UIImage imageNamed:@"ECShareKit.bundle/icons/facebook.png"];

    return result;
}

- (NSString *)activityType {
    return kMRSocialProviderTypeFacebook;
}

@end