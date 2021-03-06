#import <Foundation/Foundation.h>
#import "MRSocialProvider.h"
#import "MRSocialProviderBase.h"

@class AFHTTPRequestOperation;
@class MRSocialAccountInfo;

@interface MRSocialAbstractProvider : MRSocialProviderBase<MRSocialProvider>

- (void)loginWithSuccessBlock:(void (^)(MRSocialAccountInfo *accountInfo))successBlock failBlock:(void (^)())failBlock;

- (NSURLRequest *)loginRequest;
- (NSString *)redirectURI;

- (BOOL)isAllowedToProcessUrlString:(NSString *)urlString;

- (BOOL)parametersContainSuccessCriteria:(NSDictionary *)parameters;

- (void)loadUserInfo:(MRSocialAccountInfo *)account;

- (void)handleSuccessfulResult:(NSDictionary *)parameters;

- (MRSocialAccountInfo *)createAccountWithDictionary:(NSDictionary *)dictionary;
@end