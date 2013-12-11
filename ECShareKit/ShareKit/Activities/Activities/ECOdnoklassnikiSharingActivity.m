#import "ECOdnoklassnikiSharingActivity.h"
#import "MRSocialLoginProviderFactory.h"


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