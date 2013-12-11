#import "ECTwitterSharingActivity.h"
#import "MRSocialLoginProviderFactory.h"


@implementation ECTwitterSharingActivity {

}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Twitter", nil);
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"ECShareKit.bundle/icons/twitter.png"];
}

- (NSString *)activityType {
    return kMRSocialProviderTypeTwitter;
}
@end