#import "MRSocialProviderBase.h"
#import "MRSocialLogging.h"
#import "AFHTTPRequestOperationManager.h"
#import "MRSocialAccountInfo.h"

@interface MRSocialProviderBase ()
@property (nonatomic, strong) AFHTTPRequestOperationManager *httpClient;

@property (nonatomic, copy) void (^successBlock)(MRSocialAccountInfo *accountInfo);
@property (nonatomic, copy) void (^failBlock)();
@end

@implementation MRSocialProviderBase {

}

- (void)dealloc {
    [self cancelNetworkOperation];
    [self resetWebView];
}

- (id)init {
    self = [super init];
    if (self) {
        self.httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[[NSURL alloc] initWithString:self.baseApiURL]];
        self.httpClient.securityPolicy.allowInvalidCertificates = YES;
    }
    return self;
}

- (void)resetWebView {
    if (self.webView) {
        self.webView.delegate = nil;
        [self.webView stopLoading];
        _webView = nil;
    }
}

- (void)cancelNetworkOperation {
    if (self.operation) {
        [self.operation cancel];
        [self resetNetworkOperation];
    }
}

- (void)resetNetworkOperation {
    self.operation = nil;
}

- (void)setSuccessBlock:(void (^)(MRSocialAccountInfo *accountInfo))successBlock failBlock:(void (^)())failBlock {
    self.successBlock = successBlock;
    self.failBlock = failBlock;
}

- (void)setWebView:(UIWebView *)webView {
    [self resetWebView];

    _webView = webView;
    _webView.delegate = self;
}

- (void)success:(MRSocialAccountInfo *)accountInfo {
    if (self.successBlock) {
        self.successBlock(accountInfo);
    }
    [self resetBlocks];
}

- (void)fail {
    if (self.failBlock) {
        MRLog(@"FAILED.");
        self.failBlock();
    }
    [self resetBlocks];
}

- (void)resetBlocks {
    self.successBlock = nil;
    self.failBlock = nil;
}

- (NSString *)baseApiURL {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:NSLocalizedString(@"baseApiURL method is not implemented", nil) userInfo:nil];
}

+ (NSString *)type {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:NSLocalizedString(@"type method is not implemented", nil) userInfo:nil];
}

- (void)clearCookiesForRequest:(NSURLRequest *)request {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [storage cookiesForURL:request.URL];
    for (NSHTTPCookie *cookie in cookies) {
        [storage deleteCookie:cookie];
    }
}

- (void)setSettings:(NSDictionary *)settings {
    _settings = settings;
}
@end