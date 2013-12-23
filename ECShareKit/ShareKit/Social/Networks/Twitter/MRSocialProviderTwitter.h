#import <Foundation/Foundation.h>
#import <Social/Social.h>
#import "MRSocialProvider.h"
#import "MRSocialProviderBase.h"

@protocol MRGenericTwitterRequest
- (void)performRequestWithHandler:(SLRequestHandler)handler;
- (void)setAccount:(ACAccount *)account;
@end

@interface MRSocialProviderTwitter : MRSocialProviderBase<MRSocialProvider>
@end