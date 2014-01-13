#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <JSONKit/JSONKit.h>
#import "MRSocialProviderOK.h"
#import "MRSocialHelper.h"
#import "MRSocialAccountInfo.h"
#import "MRSocialLogging.h"
#import "MRSocialProvidersFactory.h"
#import "MRPostInfo.h"
#import "MRSocialOKSignaturesHelper.h"
#import "MRSocialOKMeidatopicPostCommand.h"

static NSString *const kOKAppIdKey = @"appId";

static NSString *const kOKPrivateKey = @"appSecret";
static NSString *const kOKPublicKey = @"appPublic";

static NSString *const kOKRedirectURIKey = @"redirectUrl";

static NSString *const kOKScope = @"VALUABLE_ACCESS";

static NSString *const kOKAuthorizationURL = @"http://www.odnoklassniki.ru/oauth/authorize";
static NSString *const kOKBaseApiURL = @"http://api.odnoklassniki.ru";

static NSString *const kOKApiPathToken = @"oauth/token.do";
static NSString *const kOKApiGetCurrentUser = @"api/users/getCurrentUser";
static NSString *const kOKApiGetStreamPublish = @"api/stream/publish";

@interface MRSocialProviderOK ()
@property (nonatomic, strong) MRSocialOKMeidatopicPostCommand *mediatopicPostCommand;
@end

@implementation MRSocialProviderOK {

}

- (NSString *)name {
    return NSLocalizedString(@"Одноклассники", nil);
}

- (NSURLRequest *)loginRequest {
    NSString *stringUrl = [NSString stringWithFormat:@"%@?%@", kOKAuthorizationURL, [MRSocialHelper parametersStringWithDictionary:@{
            @"client_id" : self.settings[kOKAppIdKey],
            @"scope" : kOKScope,
            @"response_type" : @"code",
            @"redirect_uri" : self.redirectURI,
            @"layout" : @"m"
    }]];

    NSURL *url = [[NSURL alloc] initWithString:stringUrl];
    return [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kMRTimeoutInterval];
}

+ (NSString *)type {
    return kMRSocialProviderTypeOdnoklassniki;
}

- (NSString *)baseApiURL {
    return kOKBaseApiURL;
}

- (NSString *)redirectURI {
    return self.settings[kOKRedirectURIKey];
}

- (BOOL)parametersContainSuccessCriteria:(NSDictionary *)parameters {
    return [parameters[@"code"] length] > 0;
}

- (void)handleSuccessfulResult:(NSDictionary *)parameters {
    __weak typeof(self) myself = self;
    self.operation = [self.httpClient POST:kOKApiPathToken parameters:@{
            @"code" : parameters[@"code"],
            @"redirect_uri" : self.redirectURI,
            @"grant_type" : @"authorization_code",
            @"client_id" : self.settings[kOKAppIdKey],
            @"client_secret" : self.settings[kOKPrivateKey]
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        [myself handleApiTokenResult:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [myself resetNetworkOperation];
        [myself fail];
    }];
}

- (void)handleApiTokenResult:(NSDictionary *)result {
    MRLog(@"Authorization token result is: %@", result);
    if ([result[@"access_token"] length]) {
        [self loadUserInfo:[self createAccountWithDictionary:result]];
    } else {
        [self fail];
    }
}

- (void)signRequest:(NSMutableDictionary *)dictionary account:(MRSocialAccountInfo *)account {
    [MRSocialOKSignaturesHelper signRequest:dictionary account:account key:self.settings[kOKPrivateKey]];
}

- (void)loadUserInfo:(MRSocialAccountInfo *)account {
    NSMutableDictionary *parameters = [@{
        @"application_key" : self.settings[kOKPublicKey],
        @"access_token" : account.accessToken,
        @"format" : @"JSON"
    } mutableCopy];
    [self signRequest:parameters account:account];

    __weak typeof(self) myself = self;
    self.operation = [self.httpClient POST:kOKApiGetCurrentUser parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        [myself handleUserInfoResponse:operation.response result:responseObject account:account];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [myself resetNetworkOperation];
        [myself fail];
    }];
}

- (void)handleUserInfoResponse:(NSHTTPURLResponse *)response result:(NSDictionary *)result account:(MRSocialAccountInfo *)info {
    if (response.statusCode == 200 &&
            !response.allHeaderFields[@"invocation-error"]) {
        MRLog(@"User info is: %@", result);
        [self updateAccountInfo:info fromUserInfo:result];
        [self success:info];
    } else {
        [self fail];
    }
}

- (void)updateAccountInfo:(MRSocialAccountInfo *)account fromUserInfo:(NSDictionary *)userInfo {
    account.firstName = userInfo[@"first_name"];
    account.lastName = userInfo[@"last_name"];

    account.sex = [userInfo[@"gender"] isEqualToString:@"male"] ? MRAccountSexMan : MRAccountSexWoman;

    NSString *dateString = userInfo[@"birthday"];
    if (dateString) {
        account.birthDate = [MRSocialHelper.dateFormatter dateFromString:dateString];
    }
    account.avatar = userInfo[@"pic_2"];
    account.identifier = userInfo[@"uid"];
    MRLog(@"Account is: %@", account);
}

- (void)publish:(MRPostInfo *)postInfo account:(MRSocialAccountInfo *)accountInfo completionBlock:(void (^)(BOOL isSuccess))completionBlock {
    __weak typeof(self) myself = self;
    MRSocialOKMeidatopicPostCommand *command = [[MRSocialOKMeidatopicPostCommand alloc] initWithHttpClient:self.httpClient postInfo:postInfo];
    command.account = accountInfo;
    command.key = self.settings[kOKPrivateKey];
    command.completionBlock = ^(BOOL isSuccess) {
        if (completionBlock) {
            completionBlock(isSuccess);

            myself.mediatopicPostCommand = nil;
        }
    };

    self.mediatopicPostCommand = command;
    [self.mediatopicPostCommand execute];
}

@end