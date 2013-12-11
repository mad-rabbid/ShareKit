#import <Foundation/Foundation.h>

extern NSString *const kMRSocialProviderTypeOdnoklassniki;
extern NSString *const kMRSocialProviderTypeVKontakte;
extern NSString *const kMRSocialProviderTypeMailRu;
extern NSString *const kMRSocialProviderTypeYandex;
extern NSString *const kMRSocialProviderTypeFacebook;
extern NSString *const kMRSocialProviderTypeTwitter;

@protocol MRSocialLoginProvider;


@interface MRSocialLoginProviderFactory : NSObject

+ (id<MRSocialLoginProvider>)loginProviderWithType:(NSString *)type;

@end