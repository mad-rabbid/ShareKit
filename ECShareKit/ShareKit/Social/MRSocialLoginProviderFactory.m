#import "MRSocialLoginProviderFactory.h"
#import "MRSocialLoginProvider.h"
#import "MRSocialLoginProviderManager.h"

NSString *const kMRSocialProviderTypeOdnoklassniki = @"odnoklassniki";
NSString *const kMRSocialProviderTypeVKontakte = @"vkontakte";
NSString *const kMRSocialProviderTypeMailRu = @"mailru";
NSString *const kMRSocialProviderTypeFacebook = @"facebook";
NSString *const kMRSocialProviderTypeTwitter = @"twitter";
NSString *const kMRSocialProviderTypeYandex = @"yandex";

@implementation MRSocialLoginProviderFactory {
}

+ (id <MRSocialLoginProvider>)loginProviderWithType:(NSString *)type {
    Class clazz = [MRSocialLoginProviderManager.sharedInstance providerWithType:type];
    if (clazz) {
        id <MRSocialLoginProvider> instance = [[clazz alloc] init];
        return instance;
    } else {
        return nil;
    }
}

@end