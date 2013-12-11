#import "ECYandexSharingActivity.h"
#import "MRSocialLoginProviderFactory.h"


@implementation ECYandexSharingActivity {

}

- (NSString *)activityTitle {
    return NSLocalizedString(@"Яndex", nil);
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"ECShareKit.bundle/icons/yandex.png"];
}

- (NSString *)activityType {
    return kMRSocialProviderTypeYandex;
}
@end