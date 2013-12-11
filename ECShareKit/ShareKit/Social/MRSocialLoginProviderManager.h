#import <Foundation/Foundation.h>

@protocol MRSocialLoginProvider;


@interface MRSocialLoginProviderManager : NSObject

+ (instancetype)sharedInstance;


- (Class)providerWithType:(NSString *)type;

- (void)registerProvider:(Class)provider;
@end