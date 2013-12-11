#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import "MRSocialLoginProvider.h"
#import "MRSocialProviderBase.h"

@protocol MRGenericTwitterRequest
- (void)performRequestWithHandler:(SLRequestHandler)handler;
- (void)setAccount:(ACAccount *)account;
@end

@interface MRSocialLoginProviderTwitter : MRSocialProviderBase<MRSocialLoginProvider>
@end