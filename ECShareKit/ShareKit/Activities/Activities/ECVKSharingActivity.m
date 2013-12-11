#import "ECVKSharingActivity.h"
#import "MRSocialLoginProviderFactory.h"


@implementation ECVKSharingActivity {

}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Вконтакте", nil);
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"ECShareKit.bundle/icons/vk.png"];
}

- (NSString *)activityType {
    return kMRSocialProviderTypeVKontakte;
}
@end