#import "MRSocialAbstractLoginProvider.h"
#import "MRSocialHelper.h"
#import "MRSocialAccountInfo.h"
#import "MRSocialLogging.h"

NSTimeInterval const kMRTimeoutInterval = 30.0;

NSString *const kMRSocialHTTPMethodGET = @"GET";
NSString *const kMRSocialHTTPMethodPOST = @"POST";

@interface MRSocialAbstractLoginProvider () <UIWebViewDelegate>
@end

@implementation MRSocialAbstractLoginProvider {

}

- (void)loginWithSuccessBlock:(void (^)(MRSocialAccountInfo *accountInfo))successBlock failBlock:(void (^)())failBlock {
    [self setSuccessBlock:successBlock failBlock:failBlock];

    NSURLRequest *request = self.loginRequest;
    [self clearCookiesForRequest:request];
    [self.webView loadRequest:self.loginRequest];
}

- (NSURLRequest *)loginRequest {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:NSLocalizedString(@"loginRequest method is not overidden", nil) userInfo:nil];
}

- (NSString *)redirectURI {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:NSLocalizedString(@"redirectURI method is not overidden", nil) userInfo:nil];
}

- (BOOL)isAllowedToProcessUrlString:(NSString *)urlString {
    return YES;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;
    MRLog(@"Requesting a page loading at URL: %@", urlString);

    if ([urlString hasPrefix:self.redirectURI]) {
        MRLog(@"Callback is handling for URL: %@", request.URL);

        NSString *parameterString = request.URL.query;
        if (!parameterString.length) {
            parameterString = request.URL.fragment;
        }

        NSDictionary *parameters = [MRSocialHelper parseParameterString:parameterString];
        MRLog(@"Parameters are: %@", parameters);

        if ([self parametersContainSuccessCriteria:parameters]) {
            [self handleSuccessfulResult:parameters];
        } else {
            [self fail];
        }
        return NO;
    }

    return [self isAllowedToProcessUrlString:urlString];
}

- (BOOL)parametersContainSuccessCriteria:(NSDictionary *)parameters {
    return [parameters[@"access_token"] length] > 0;
}

- (void)loadUserInfo:(MRSocialAccountInfo *)account {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:NSLocalizedString(@"loadUserInfo method is not overidden", nil) userInfo:nil];
}

- (void)handleSuccessfulResult:(NSDictionary *)parameters {
    MRSocialAccountInfo *accountInfo = [self createAccountWithDictionary:parameters];
    [self loadUserInfo:accountInfo];
    //[self success];
}

- (MRSocialAccountInfo *)createAccountWithDictionary:(NSDictionary *)dictionary {
    return [[MRSocialAccountInfo alloc] initWithType:[self.class type] accessToken:dictionary[@"access_token"] refreshToken:dictionary[@"refresh_token"]];
}
@end