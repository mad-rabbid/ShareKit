#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "MRSocialProviderMailRu.h"
#import "MRSocialHelper.h"
#import "MRSocialLogging.h"
#import "MRSocialAccountInfo.h"
#import "MRSocialProvidersFactory.h"
#import "MRPostInfo.h"

static NSString *const kMailRuAppIdKey = @"appId";

static NSString *const kMailRuPrivateKey = @"appSecret";
static NSString *const kMailRuPublicKey = @"appPublic";

static NSString *const kMailRuPermissionList = @"stream";
static NSString *const kMailRuRedirectURI = @"http://connect.mail.ru/oauth/success.html";
static NSString *const kMailRuAuthorizationURL = @"https://connect.mail.ru/oauth/authorize";
static NSString *const kMailRuAllowedURLPrefix = @"connect.mail.ru/oauth";

static NSString *const kMailRuApiBase = @"http://www.appsmail.ru/platform/api";
static NSString *const kMailRuApiMethodGetInfo = @"users.getInfo";
static NSString *const kMailRuApiMethodStreamPost = @"stream.post";

@implementation MRSocialProviderMailRu {
}

- (NSString *)name {
    return NSLocalizedString(@"Мой Мир@Mail.Ru", nil);
}

- (NSURLRequest *)loginRequest {
    NSString *stringUrl = [NSString stringWithFormat:@"%@?%@", kMailRuAuthorizationURL, [MRSocialHelper parametersStringWithDictionary:@{
        @"client_id" : self.settings[kMailRuAppIdKey],
        @"scope" : kMailRuPermissionList,
        @"response_type" : @"token",
        @"redirect_uri" : self.redirectURI,
        @"display" : @"mobile"
    }]];

    NSURL *url = [[NSURL alloc] initWithString:stringUrl];
    return [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kMRTimeoutInterval];
}

+ (NSString *)type {
    return kMRSocialProviderTypeMailRu;
}

- (NSString *)baseApiURL {
    return kMailRuApiBase;
}

- (NSString *)redirectURI {
    return kMailRuRedirectURI;
}

- (BOOL)isAllowedToProcessUrlString:(NSString *)urlString {
    if ([urlString rangeOfString:kMailRuAllowedURLPrefix].location != NSNotFound ||
            [urlString rangeOfString:@"auth.mail.ru/sdc"].location != NSNotFound ||
            [urlString rangeOfString:@"connect.mail.ru/sdc"].location != NSNotFound ||
            [urlString hasPrefix:@"https://auth.mail.ru/cgi-bin/auth"]) {
        return YES;
    }

    NSURL *targetUrl = [[NSURL alloc] initWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:targetUrl]) {
        [[UIApplication sharedApplication] openURL:targetUrl];
    }
    return NO;
}

- (MRSocialAccountInfo *)createAccountWithDictionary:(NSDictionary *)dictionary {
    MRSocialAccountInfo *account = [super createAccountWithDictionary:dictionary];
    account.identifier = dictionary[@"x_mailru_vid"];
    return account;
}

- (void)loadUserInfo:(MRSocialAccountInfo *)account {
    NSMutableDictionary *parameters = [@{
        @"app_id" : self.settings[kMailRuAppIdKey],
        @"method" : kMailRuApiMethodGetInfo,
        @"session_key" : account.accessToken
    } mutableCopy];
    [self signRequest:parameters account:account];

    __weak typeof(self) myself = self;
    self.operation = [self.httpClient GET:@"" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        [myself handleUserInfoResponse:operation.response result:responseObject account:account];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MRLog(@"Error: %@", [error localizedDescription]);
        [myself resetNetworkOperation];
        [myself fail];
    }];
}

- (void)handleUserInfoResponse:(NSHTTPURLResponse *)response result:(id)result account:(MRSocialAccountInfo *)info {
    if (response.statusCode == 200 && [result isKindOfClass:NSArray.class] && [result count]) {
        MRLog(@"User info is: %@", result);
        [self updateAccountInfo:info fromUserInfo:result[0]];
        [self success:info];
    } else {
        [self fail];
    }
}

- (void)updateAccountInfo:(MRSocialAccountInfo *)account fromUserInfo:(NSDictionary *)userInfo {
    account.firstName = userInfo[@"first_name"];
    account.lastName = userInfo[@"last_name"];
    account.email = userInfo[@"email"];

    account.sex = ![userInfo[@"sex"] intValue] ? MRAccountSexMan : MRAccountSexWoman;

    NSString *dateString = userInfo[@"birthday"];
    if (dateString) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"dd.MM.yyyy";
        account.birthDate = [formatter dateFromString:dateString];
    }
    account.avatar = userInfo[@"pic"];
    account.identifier = userInfo[@"uid"];
    MRLog(@"AccountInfo is %@", account);
}

- (void)signRequest:(NSMutableDictionary *)dictionary account:(MRSocialAccountInfo *)account {
    NSMutableString *builder = [NSMutableString stringWithString:account.identifier];
    [builder appendString:[MRSocialHelper sortedParameters:dictionary excludes:nil]];
    [builder appendString:self.settings[kMailRuPublicKey]];
    MRLog(@"Signature source is: %@", builder);

    dictionary[@"sig"] = [MRSocialHelper md5:builder];
    MRLog(@"Dictionary is: %@", dictionary);
}

- (void)publish:(MRPostInfo *)postInfo account:(MRSocialAccountInfo *)accountInfo completionBlock:(void (^)(BOOL isSuccess))completionBlock {
    NSMutableDictionary *parameters = [@{
        @"app_id" : self.settings[kMailRuAppIdKey],
        @"method" : kMailRuApiMethodStreamPost,
        @"text" : postInfo.message ?: @"",
        @"img_url" : postInfo.pictureUrl ?: @"",
        @"session_key" : accountInfo.accessToken
    } mutableCopy];
    [self signRequest:parameters account:accountInfo];

    __weak typeof(self) myself = self;
    self.operation = [self.httpClient GET:@"" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        if (completionBlock) {
            completionBlock(operation.response.statusCode == 200);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MRLog(@"Error: %@", [error localizedDescription]);
        [myself resetNetworkOperation];
        if (completionBlock) {
            completionBlock(NO);
        }
    }];
}

@end