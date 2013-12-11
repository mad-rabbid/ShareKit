#import "ECMailRuSharingActivity.h"
#import "MRSocialLoginProviderFactory.h"


@implementation ECMailRuSharingActivity {

}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Мой Мир@Mail.Ru", nil);
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"ECShareKit.bundle/icons/facebook.png"];
}

- (NSString *)activityType {
    return kMRSocialProviderTypeMailRu;
}
@end