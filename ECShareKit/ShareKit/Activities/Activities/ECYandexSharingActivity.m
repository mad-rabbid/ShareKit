#import "ECYandexSharingActivity.h"
#import "MRSocialProvidersFactory.h"


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