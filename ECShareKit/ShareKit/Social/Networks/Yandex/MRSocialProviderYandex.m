#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "MRSocialProviderYandex.h"
#import "MRSocialHelper.h"
#import "MRSocialProvidersFactory.h"
#import "MRSocialAccountInfo.h"
#import "MRSocialLogging.h"

static NSString *const kYandexAppId = @"4b2bb9f9ea2e40d8a8dd53c6ca3d2618";
//static NSString *const kYandexAppPassword = @"be1e9a5383e547b2a2b0a1362100c5d4";

// Need to be set inside application entry at Yandex
static NSString *const kYandexRedirectURI = @"https://fishbyte.ru/blank.html";

static NSString *const kYandexAuthorizationURL = @"https://m.oauth.yandex.ru/authorize";
static NSString *const kYandexAllowedURLPrefix = @"https://m.oauth.yandex.ru";

static NSString *const kYandexApiBase = @"https://login.yandex.ru";
static NSString *const kYandexApiMethodInfo = @"info";


@implementation MRSocialProviderYandex {
}

- (NSString *)name {
    return NSLocalizedString(@"Яндекс", nil);
}

- (NSURLRequest *)loginRequest {
    NSString *stringUrl = [NSString stringWithFormat:@"%@?%@", kYandexAuthorizationURL, [MRSocialHelper parametersStringWithDictionary:@{
        @"client_id" : kYandexAppId,
        @"response_type" : @"token"
    }]];

    NSURL *url = [[NSURL alloc] initWithString:stringUrl];
    return [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kMRTimeoutInterval];
}

+ (NSString *)type {
    return kMRSocialProviderTypeYandex;
}

- (NSString *)baseApiURL {
    return kYandexApiBase;
}

- (NSString *)redirectURI {
    return kYandexRedirectURI;
}

- (BOOL)isAllowedToProcessUrlString:(NSString *)urlString {
    if ([urlString rangeOfString:@"passport.yandex.ru/passport?mode=auth"].location != NSNotFound ||
            [urlString rangeOfString:@"passport-ckicheck.yandex.ru/passport"].location != NSNotFound ||
            [urlString hasPrefix:kYandexAllowedURLPrefix]) {
        return YES;
    }

    NSURL *targetUrl = [[NSURL alloc] initWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:targetUrl]) {
        [[UIApplication sharedApplication] openURL:targetUrl];
    }
    return NO;
}

- (void)loadUserInfo:(MRSocialAccountInfo *)account {
    NSMutableDictionary *parameters = [@{
        @"format" : @"json",
        @"oauth_token" : account.accessToken
    } mutableCopy];

    __weak typeof(self) myself = self;
    self.operation = [self.httpClient GET:kYandexApiMethodInfo parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        [myself handleUserInfoResponse:operation.response result:responseObject account:account];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MRLog(@"Error: %@", [error localizedDescription]);
        [myself resetNetworkOperation];
        [myself fail];
    }];
}

- (void)handleUserInfoResponse:(NSHTTPURLResponse *)response result:(NSDictionary *)result account:(MRSocialAccountInfo *)info {
    if (response.statusCode == 200 && [result isKindOfClass:NSDictionary.class]) {
        MRLog(@"User info is: %@", result);
        [self updateAccountInfo:info fromUserInfo:result];
        [self success:info];
    } else {
        [self fail];
    }
}

- (void)updateAccountInfo:(MRSocialAccountInfo *)account fromUserInfo:(NSDictionary *)userInfo {
    NSString *realName = userInfo[@"real_name"];
    if (realName.length) {
        NSArray *components = [realName componentsSeparatedByString:@" "];
        if (components.count > 1) {
            account.lastName = components[0];
            account.firstName = components[1];
        } else if (components.count) {
            account.firstName = components[0];
        }
    } else {
        account.firstName = userInfo[@"display_name"];
    }

    account.email = userInfo[@"default_email"];

    id sex = userInfo[@"sex"];
    if (sex && sex != [NSNull null]) {
        account.sex = [sex isEqualToString:@"male"] ? MRAccountSexMan : MRAccountSexWoman;
    } else {
        account.sex = MRAccountSexUndefined;
    }

    id dateString = userInfo[@"birthday"];
    if (dateString && dateString != [NSNull null]) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy-MM-dd";
        account.birthDate = [formatter dateFromString:dateString];
    }

    account.identifier = userInfo[@"id"];
    MRLog(@"AccountInfo is %@", account);
}

@end