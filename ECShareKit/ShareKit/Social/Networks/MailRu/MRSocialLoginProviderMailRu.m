#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "MRSocialLoginProviderMailRu.h"
#import "MRSocialHelper.h"
#import "MRSocialLogging.h"
#import "MRSocialAccountInfo.h"
#import "MRSocialLoginProviderFactory.h"

static NSString *const kMailRuSocialLoginProviderType = @"mailru";
static NSString *const kMailRuAppId = @"708114";

static NSString *const kMailRuPrivateKey = @"a8a9203bfd3a9bc461034f675e0ff815";
static NSString *const kMailRuPublicKey = @"277f80def05245252f75d7eebda75fb3";

static NSString *const kMailRuPermissionList = @"";
static NSString *const kMailRuRedirectURI = @"http://connect.mail.ru/oauth/success.html";
static NSString *const kMailRuAuthorizationURL = @"https://connect.mail.ru/oauth/authorize";
static NSString *const kMailRuAllowedURLPrefix = @"connect.mail.ru/oauth";

static NSString *const kMailRuApiBase = @"http://www.appsmail.ru/platform/api";
static NSString *const kMailRuApiMethodGetInfo = @"users.getInfo";

@implementation MRSocialLoginProviderMailRu {
}

- (NSString *)name {
    return NSLocalizedString(@"Мой Мир@Mail.Ru", nil);
}

- (NSURLRequest *)loginRequest {
    NSString *stringUrl = [NSString stringWithFormat:@"%@?%@", kMailRuAuthorizationURL, [MRSocialHelper parametersStringWithDictionary:@{
        @"client_id" : kMailRuAppId,
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
        @"app_id" : kMailRuAppId,
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
    [builder appendString:kMailRuPublicKey];
    MRLog(@"Signature source is: %@", builder);

    dictionary[@"sig"] = [MRSocialHelper md5:builder];
    MRLog(@"Dictionary is: %@", dictionary);
}
@end