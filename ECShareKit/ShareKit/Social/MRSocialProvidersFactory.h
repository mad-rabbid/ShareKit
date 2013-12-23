#import <Foundation/Foundation.h>

extern NSString *const kMRSocialProviderTypeOdnoklassniki;
extern NSString *const kMRSocialProviderTypeVKontakte;
extern NSString *const kMRSocialProviderTypeMailRu;
extern NSString *const kMRSocialProviderTypeYandex;
extern NSString *const kMRSocialProviderTypeFacebook;
extern NSString *const kMRSocialProviderTypeTwitter;

@protocol MRSocialProvider;


@interface MRSocialProvidersFactory : NSObject

+ (void)setSettings:(NSDictionary *)settings;

+ (id<MRSocialProvider>)providerWithType:(NSString *)type;

@end