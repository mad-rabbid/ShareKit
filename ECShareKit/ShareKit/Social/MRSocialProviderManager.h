#import <Foundation/Foundation.h>

@protocol MRSocialProvider;


@interface MRSocialProviderManager : NSObject

+ (instancetype)sharedInstance;


- (Class)providerWithType:(NSString *)type;

- (void)registerProvider:(Class)provider;
@end