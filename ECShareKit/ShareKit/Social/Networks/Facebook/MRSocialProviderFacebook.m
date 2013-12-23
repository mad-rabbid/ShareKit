#import <Accounts/Accounts.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "MRSocialProviderFacebook.h"
#import "MRSocialHelper.h"
#import "MRSocialProvidersFactory.h"
#import "MRSocialLogging.h"
#import "MRSocialAccountInfo.h"
#import "MRPostInfo.h"

static NSString *const kFacebookAppIdKey = @"appId";
static NSString *const kFacebookRedirectURIKey = @"redirectUrl";

static NSString *const kFacebookReadPermissionsList = @"user_birthday,email,basic_info";
static NSString *const kFacebookWritePermissionsList = @"publish_actions";
static NSString *const kFacebookAuthorizationURL = @"https://graph.facebook.com/oauth/authorize";
static NSString *const kFacebookApiBaseURL = @"https://graph.facebook.com";

static NSString *const kFacebookPermissionsSeparator = @",";

@implementation MRSocialProviderFacebook {
}

- (NSString *)name {
    return NSLocalizedString(@"Facebook", nil);
}

- (NSString *)baseApiURL {
    return kFacebookApiBaseURL;
}

- (void)loginWithSuccessBlock:(void (^)(MRSocialAccountInfo *accountInfo))successBlock failBlock:(void (^)())failBlock {
    if ([UIDevice currentDevice].systemVersion.floatValue >= 6.0) {
        [self setSuccessBlock:successBlock failBlock:failBlock];
        [self internalLogin];
    } else {
        [super loginWithSuccessBlock:successBlock failBlock:failBlock];
    }
}

- (void)internalLogin {
    ACAccountStore *accountStore = [ACAccountStore new];
    ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];

    NSMutableDictionary *options = [@{
        ACFacebookAppIdKey : self.settings[kFacebookAppIdKey],
        ACFacebookAudienceKey : ACFacebookAudienceOnlyMe,
        ACFacebookPermissionsKey : [kFacebookReadPermissionsList componentsSeparatedByString:kFacebookPermissionsSeparator]
    } mutableCopy];

    __weak MRSocialProviderFacebook *myself = self;
    [accountStore requestAccessToAccountsWithType:facebookAccountType options:options completion:^(BOOL granted, NSError *error) {
        if (granted) {
            //TODO: remove these lines after debugging is finished
            error = [[NSError alloc] initWithDomain:@"domain" code:ACErrorAccountNotFound userInfo:nil];
            [myself handleNativeLoginError:error];
            return;

            options[ACFacebookPermissionsKey] = [kFacebookWritePermissionsList componentsSeparatedByString:kFacebookPermissionsSeparator];

            [accountStore requestAccessToAccountsWithType:facebookAccountType options:options completion:^(BOOL grantedWriting, NSError *errorWriting) {
                if (grantedWriting) {
                    NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
                    ACAccount *facebookAccount = [accounts lastObject];
                    ACAccountCredential *credential = [facebookAccount credential];

                    NSString *accessToken = [credential oauthToken];
                    MRLog(@"Facebook Access Token: %@", accessToken);

                    [myself handleSuccessfulResult:@{@"access_token" : accessToken }];
                } else {
                    [myself handleNativeLoginError:errorWriting];
                };
            }];
        } else {
            [myself handleNativeLoginError:error];
        }
    }];
}

- (void)handleNativeLoginError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@",error.description);
        if (error.code == ACErrorAccountNotFound) {
            NSURLRequest *request = self.loginRequest;
            [self clearCookiesForRequest:request];
            [self.webView loadRequest:self.loginRequest];
        } else {
            [self fail];
        }
    });
}

- (NSURLRequest *)loginRequest {
    NSString *stringUrl = [NSString stringWithFormat:@"%@?%@", kFacebookAuthorizationURL, [MRSocialHelper parametersStringWithDictionary:@{
        @"client_id" : self.settings[kFacebookAppIdKey],
        @"scope" : [NSString stringWithFormat:@"%@,%@", kFacebookReadPermissionsList, kFacebookWritePermissionsList],
        @"response_type" : @"token",
        @"redirect_uri" : self.redirectURI,
        @"display" : @"touch"
    }]];

    NSURL *url = [[NSURL alloc] initWithString:stringUrl];
    return [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kMRTimeoutInterval];
}

+ (NSString *)type {
    return kMRSocialProviderTypeFacebook;
}

- (NSString *)redirectURI {
    return self.settings[kFacebookRedirectURIKey];
}

- (void)loadUserInfo:(MRSocialAccountInfo *)account {
    NSDictionary *parameters = @{
        @"fields" : @"id,name,first_name,last_name,email,birthday,picture,gender",
        @"access_token" : account.accessToken
    };

    __weak typeof(self) myself = self;
    self.operation = [self.httpClient GET:@"me" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        [myself handleUserInfoResponse:operation.response result:responseObject account:account];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MRLog(@"Error: %@", [error localizedDescription]);
        [myself resetNetworkOperation];
        [myself fail];
    }];
}

- (void)handleUserInfoResponse:(NSHTTPURLResponse *)response result:(id)result account:(MRSocialAccountInfo *)info {
    if (response.statusCode == 200 && [result isKindOfClass:NSDictionary.class]) {
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
    account.email = userInfo[@"email"];

    NSString *gender = userInfo[@"gender"];
    if (gender.length) {
        account.sex = [userInfo[@"gender"] isEqualToString:@"male"] ? MRAccountSexMan : MRAccountSexWoman;
    }

    NSString *dateString = userInfo[@"birthday"];
    if (dateString) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"dd/MM/yyyy";
        account.birthDate = [formatter dateFromString:dateString];
    }

    id pictureInfo = userInfo[@"picture"];
    if ([pictureInfo isKindOfClass:NSDictionary.class] && [pictureInfo[@"data"] isKindOfClass:NSDictionary.class]) {
        account.avatar = pictureInfo[@"data"][@"url"];
    }

    account.identifier = userInfo[@"id"];
    MRLog(@"AccountInfo is %@", account);
}

- (BOOL)isAllowedToProcessUrlString:(NSString *)urlString {
    NSLog(@"URL: %@", urlString);

    NSArray *allowedUrls = @[
        kFacebookApiBaseURL,
        @"https://www.facebook.com/dialog/oauth",
        @"https://m.facebook.com/login.php",
        @"https://m.facebook.com/dialog/oauth"
    ];

    for (NSString *url in allowedUrls) {
        if (![urlString rangeOfString:url].location) {
            return YES;
        }
    }

    NSURL *targetUrl = [[NSURL alloc] initWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:targetUrl]) {
        [[UIApplication sharedApplication] openURL:targetUrl];
    }
    return NO;
}

- (void)publish:(MRPostInfo *)postInfo account:(MRSocialAccountInfo *)account completionBlock:(void (^)(BOOL isSuccess))completionBlock {
    NSDictionary *parameters = @{
        @"message" : postInfo.message ?: @"",
        @"picture" : postInfo.pictureUrl ?: @"",
        @"access_token" : account.accessToken
    };

    __weak typeof(self) myself = self;
    self.operation = [self.httpClient POST:@"me/feed" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        [myself handlePublishResponse:operation.response result:responseObject completionBlock:completionBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MRLog(@"Error: %@", [error localizedDescription]);
        [myself resetNetworkOperation];
        if (completionBlock) {
            completionBlock(NO);
        }
    }];
}

- (void)handlePublishResponse:(NSHTTPURLResponse *)response result:(id)result completionBlock:(void (^)(BOOL isSuccess))completionBlock {
    BOOL isSuccess = (response.statusCode == 200);
    MRLog(@"User info is: %@", result);
    if (completionBlock) {
        completionBlock(isSuccess);
    }
}
@end