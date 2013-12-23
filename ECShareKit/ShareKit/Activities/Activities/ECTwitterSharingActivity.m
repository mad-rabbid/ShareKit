#import "ECTwitterSharingActivity.h"
#import "MRSocialProvidersFactory.h"


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