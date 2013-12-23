#import "MRSocialProvidersFactory.h"
#import "MRSocialProvider.h"
#import "MRSocialProviderManager.h"

NSString *const kMRSocialProviderTypeOdnoklassniki = @"odnoklassniki";
NSString *const kMRSocialProviderTypeVKontakte = @"vkontakte";
NSString *const kMRSocialProviderTypeMailRu = @"mailru";
NSString *const kMRSocialProviderTypeFacebook = @"facebook";
NSString *const kMRSocialProviderTypeTwitter = @"twitter";
NSString *const kMRSocialProviderTypeYandex = @"yandex";

@implementation MRSocialProvidersFactory {
}

static NSDictionary *_settings;

+ (void)setSettings:(NSDictionary *)settings {
    _settings = settings;
}

+ (id <MRSocialProvider>)providerWithType:(NSString *)type {
    Class clazz = [MRSocialProviderManager.sharedInstance providerWithType:type];
    if (clazz) {
        id <MRSocialProvider> instance = [[clazz alloc] init];

        if (!_settings || !_settings[type]) {
            @throw [NSException exceptionWithName:@"MRSocialProviderSettingsAreNotSetException" reason:@"Settings are not set" userInfo:nil];
        }

        [instance setSettings:_settings[type]];
        return instance;
    } else {
        return nil;
    }
}

@end