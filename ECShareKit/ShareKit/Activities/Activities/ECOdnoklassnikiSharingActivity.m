#import "ECOdnoklassnikiSharingActivity.h"
#import "MRSocialProvidersFactory.h"


@implementation ECOdnoklassnikiSharingActivity {

}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Одноклассники", nil);
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"ECShareKit.bundle/icons/odnoklassniki.png"];
}

- (NSString *)activityType {
    return kMRSocialProviderTypeOdnoklassniki;
}

@end