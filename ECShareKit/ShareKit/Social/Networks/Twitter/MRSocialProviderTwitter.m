#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "MRSocialProviderTwitter.h"
#import "MRSocialLogging.h"
#import "MRSocialProvidersFactory.h"
#import "MRSocialHelper.h"
#import "MRSocialTwitterRequestBuilder.h"
#import "MRSocialAccountInfo.h"
#import "MRPostInfo.h"

static NSString *const kTwitterConsumerIdKey = @"appId";
static NSString *const kTwitterConsumerSecretKey = @"appSecret";

static NSString *const kTwitterCallbackUrlKey = @"redirectUrl";
static NSString *const kTwitterBaseApiUrl = @"https://api.twitter.com";

@interface MRSocialProviderTwitter ()

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccount *twitterAccount;
@end

@implementation MRSocialProviderTwitter {
}

- (id)init {
    self = [super init];
    if (self) {
        self.httpClient.responseSerializer = [AFHTTPResponseSerializer new];
        self.httpClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", nil];
    }

    return self;
}

- (NSString *)name {
    return NSLocalizedString(@"Twitter", nil);
}

- (void)loginWithSuccessBlock:(void (^)(MRSocialAccountInfo *accountInfo))successBlock failBlock:(void (^)())failBlock {
    [self setSuccessBlock:successBlock failBlock:failBlock];

    self.accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    __weak MRSocialProviderTwitter *myself = self;
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *arrayOfAccounts = [myself.accountStore accountsWithAccountType:accountType];
            if (arrayOfAccounts.count) {
                myself.twitterAccount = [arrayOfAccounts lastObject];
                [myself reverseAuth];
            } else {
                [myself fallbackLogin];
            }
        } else {
            [myself fallbackLogin];
        }
    };

    if ([_accountStore respondsToSelector:@selector(requestAccessToAccountsWithType:options:completion:)]) {
        [_accountStore requestAccessToAccountsWithType:accountType options:nil completion:handler];
    } else {
        [_accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:handler];
    }

}

- (void)fallbackLogin {
    MRSocialTwitterRequestBuilder *builder = [self createRequestBuilder];

    [builder setMethod:kMRSocialHTTPMethodPOST];
    [builder setApiPath:@"oauth/request_token"];
    [builder addHeader:@"oauth_callback" value:self.settings[kTwitterCallbackUrlKey]];

    NSURLRequest *request = [builder buildRequestWithHttpClient:self.httpClient];
    [self clearCookiesForRequest:request];
    MRLog(@"Request: %@", [request description]);

    __weak MRSocialProviderTwitter *myself = self;
    [self executeRequest:request completion:^(NSString *responseString) {
        [myself handleRequestTokenResponse:responseString];
    }];
}

- (void)handleRequestTokenResponse:(NSString *)response {
    NSDictionary *parameters = [MRSocialHelper parseParameterString:response];
    if ([parameters[@"oauth_token"] length] &&
            [parameters[@"oauth_token_secret"] length] &&
            [[parameters[@"oauth_callback_confirmed"] lowercaseString] isEqualToString:@"true"]) {
        NSURLRequest *request = [self.httpClient.requestSerializer requestWithMethod:kMRSocialHTTPMethodGET
                                                                           URLString:[self.httpClient.baseURL.absoluteString stringByAppendingFormat:@"/%@", @"oauth/authorize"]
                                                                          parameters:@{@"oauth_token" : parameters[@"oauth_token"]}];
        [self clearCookiesForRequest:request];
        [self.webView loadRequest:request];
    } else {
        [self fail];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;
    if ([urlString hasPrefix:self.settings[kTwitterCallbackUrlKey]]) {
        NSString *parameterString = request.URL.query;
        if (!parameterString.length) {
            parameterString = request.URL.fragment;
        }

        NSDictionary *parameters = [MRSocialHelper parseParameterString:parameterString];
        if ([parameters[@"oauth_token"] length] &&
                [parameters[@"oauth_verifier"] length]) {
            [self obtainToken:parameters];
        } else {
            [self fail];
        }
        return NO;
    }

    return [self isAllowedToProcessUrlString:urlString];
}

- (MRSocialTwitterRequestBuilder *)createRequestBuilder {
    return  [[MRSocialTwitterRequestBuilder alloc] initWithConsumerKey:self.settings[kTwitterConsumerIdKey]
                                                        consumerSecret:self.settings[kTwitterConsumerSecretKey]];
}

- (void)obtainToken:(NSDictionary *)parameters {
    MRSocialTwitterRequestBuilder *builder = [self createRequestBuilder];

    [builder setMethod:kMRSocialHTTPMethodPOST];
    [builder setApiPath:@"oauth/access_token"];
    [builder addHeader:@"oauth_token" value:parameters[@"oauth_token"]];
    [builder addParameter:@"oauth_verifier" value:parameters[@"oauth_verifier"]];

    NSURLRequest *request = [builder buildRequestWithHttpClient:self.httpClient];
    MRLog(@"Request: %@", [request description]);

    __weak MRSocialProviderTwitter *myself = self;
    [self executeRequest:request completion:^(NSString *responseString) {
        [myself handleAccessTokenResponse:responseString];
    }];
}

- (void)handleAccessTokenResponse:(NSString *)response {
    NSDictionary *parameters = [MRSocialHelper parseParameterString:response];
    if ([parameters[@"oauth_token"] length] &&
            [parameters[@"oauth_token_secret"] length]) {
        MRSocialAccountInfo *info = [[MRSocialAccountInfo alloc] initWithType:[self.class type]
                                                                  accessToken:parameters[@"oauth_token"]
                                                                 refreshToken:parameters[@"oauth_token_secret"]];
        info.identifier = parameters[@"user_id"];
        [self getUserInfo:info];
    } else {
        [self fail];
    }
}

- (void)getUserInfo:(MRSocialAccountInfo *)info {
    MRSocialTwitterRequestBuilder *builder = [self createRequestBuilder];

    [builder setMethod:kMRSocialHTTPMethodGET];
    [builder setApiPath:@"1.1/users/show.json"];
    [builder setSecret:info.refreshToken];
    [builder addHeader:@"oauth_token" value:info.accessToken];
    [builder addParameter:@"user_id" value:info.identifier];

    NSURLRequest *request = [builder buildRequestWithHttpClient:self.httpClient];
    MRLog(@"Request: %@", [request description]);

    __weak MRSocialProviderTwitter *myself = self;
    [self executeRequest:request completion:^(NSString *responseString) {
        [myself handleGetUserInfoResponse:responseString accountInfo:info];
    }];
}

- (void)handleGetUserInfoResponse:(NSString *)response accountInfo:(MRSocialAccountInfo *)info {
    NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    MRLog(@"UserInfo: %@", userInfo);
    [self success:info];
}

- (void)reverseAuth {
    MRSocialTwitterRequestBuilder *builder = [self createRequestBuilder];

    [builder setMethod:kMRSocialHTTPMethodPOST];
    [builder setApiPath:@"oauth/request_token"];
    [builder addParameter:@"x_auth_mode" value:@"reverse_auth"];

    NSURLRequest *request = [builder buildRequestWithHttpClient:self.httpClient];
    MRLog(@"Request: %@", [request description]);

    __weak MRSocialProviderTwitter *myself = self;
    [self executeRequest:request completion:^(NSString *responseString) {
        [myself handleReverseAuth:responseString];
    }];
}

- (void)handleReverseAuth:(NSString *)response {
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", kTwitterBaseApiUrl, @"oauth/access_token"];
    NSURL *url = [[NSURL alloc] initWithString:urlString];

    NSDictionary *dictionary = @{
        @"x_reverse_auth_target" : self.settings[kTwitterConsumerIdKey],
        @"x_reverse_auth_parameters" : response
    };
    MRLog(@"Dictionary: %@", dictionary);

    id<MRGenericTwitterRequest> request = [self requestWithUrl:url parameters:dictionary requestMethod:SLRequestMethodPOST];
    [request setAccount:self.twitterAccount];
    MRLog(@"Request: %@", request);

    __weak MRSocialProviderTwitter *myself = self;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSString *source = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"The user's info for your server:\n%@", source);
        if (!error) {
            [myself handleAccessTokenResponse:source];
        } else {
            [myself fail];
        }
    }];
}


- (void)executeRequest:(NSURLRequest *)request completion:(void (^)(NSString *responseString))completion {
    __weak typeof(self) myself = self;
    self.operation = [self.httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        MRLog(@"Response: %@", [operation responseString]);
        if (operation.response.statusCode == 200) {
            if (completion) {
                completion(operation.responseString);
            }
        } else {
            [myself fail];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MRLog(@"Error: %@\n%@", [error localizedDescription], operation.responseString);
        [myself resetNetworkOperation];
        [myself fail];
    }];
    [self.httpClient.operationQueue addOperation:self.operation];
}

- (id<MRGenericTwitterRequest>)requestWithUrl:(NSURL *)url parameters:(NSDictionary *)dict requestMethod:(SLRequestMethod )requestMethod {
    if ([SLRequest class]) {
        MRLog(@"Using request class: SLRequest\n");
        return (id<MRGenericTwitterRequest>) [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:requestMethod URL:url parameters:dict];
    } else {
        MRLog(@"Using request class: TWRequest\n");
        return (id<MRGenericTwitterRequest>) [[TWRequest alloc] initWithURL:url parameters:dict requestMethod:requestMethod];
    }
}

- (BOOL)isAllowedToProcessUrlString:(NSString *)urlString {
    return YES;
}

+ (NSString *)type {
    return kMRSocialProviderTypeTwitter;
}

- (NSString *)baseApiURL {
    return kTwitterBaseApiUrl;
}

- (void)resetBlocks {
    self.twitterAccount = nil;
    self.accountStore = nil;
}

- (void)publish:(MRPostInfo *)postInfo account:(MRSocialAccountInfo *)accountInfo completionBlock:(void (^)(BOOL isSuccess))completionBlock {

//    MRSocialTwitterRequestBuilder *builder = [self createRequestBuilder];
//
//    [builder setMethod:kMRSocialHTTPMethodGET];
//    [builder setApiPath:@"1.1/account/verify_credentials.json"];
//    [builder setSecret:accountInfo.refreshToken];
//    [builder addHeader:@"oauth_token" value:accountInfo.accessToken];
//
//    NSURLRequest *request = [builder buildRequestWithHttpClient:self.httpClient];
//    MRLog(@"Request: %@", [request description]);
//
//    __weak typeof(self) myself = self;
//    self.operation = [self.httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        [myself resetNetworkOperation];
//        MRLog(@"Response: %@", [operation responseString]);
//        if (completionBlock) {
//            completionBlock(operation.response.statusCode == 200);
//        }
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        MRLog(@"Error: %@\n%@", [error localizedDescription], operation.responseString);
//        [myself resetNetworkOperation];
//        if (completionBlock) {
//            completionBlock(NO);
//        };
//    }];
//    [self.httpClient.operationQueue addOperation:self.operation];


    MRSocialTwitterRequestBuilder *builder = [self createRequestBuilder];

    [builder setMethod:kMRSocialHTTPMethodPOST];
    [builder setApiPath:@"/1.1/statuses/update_with_media.json"];
    [builder setSecret:accountInfo.refreshToken];
    [builder addHeader:@"oauth_token" value:accountInfo.accessToken];

    [builder addParameter:@"status" value:postInfo.message];
    [builder addParameter:@"media[]" value:@{
        @"image" : UIImageJPEGRepresentation(postInfo.image, 0.9f) ?: [NSNull null],
        @"mime-type" : @"image/jpeg",
        @"name" : @"image.jpg"
    }];

    NSURLRequest *request = [builder buildMultipartRequestWithHttpClient:self.httpClient];
    MRLog(@"Request: %@", [request description]);

    __weak typeof(self) myself = self;
    self.operation = [self.httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        MRLog(@"Response: %@", [operation responseString]);
        if (completionBlock) {
            completionBlock(operation.response.statusCode == 200);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MRLog(@"Error: %@\n%@", [error localizedDescription], operation.responseString);
        [myself resetNetworkOperation];
        if (completionBlock) {
            completionBlock(NO);
        };
    }];
    [self.httpClient.operationQueue addOperation:self.operation];
}

@end