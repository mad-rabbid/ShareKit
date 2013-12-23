#import <Foundation/Foundation.h>

@class MRSocialProviderBase;
@class AFHTTPRequestOperation;
@class AFHTTPRequestOperationManager;
@class MRSocialAccountInfo;

extern NSTimeInterval const kMRTimeoutInterval;
extern NSString *const kMRSocialHTTPMethodGET;
extern NSString *const kMRSocialHTTPMethodPOST;

@interface MRSocialProviderBase : NSObject<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong, readonly) AFHTTPRequestOperationManager *httpClient;
@property (nonatomic, strong) AFHTTPRequestOperation *operation;
@property (nonatomic, strong, readonly) NSDictionary *settings;

+ (NSString *)type;

- (void)cancelNetworkOperation;
- (void)resetNetworkOperation;

- (void)setSuccessBlock:(void (^)(MRSocialAccountInfo *accountInfo))successBlock failBlock:(void (^)())failBlock;
- (void)success:(MRSocialAccountInfo *)accountInfo;
- (void)fail;

- (void)resetBlocks;

- (NSString *)baseApiURL;

- (void)clearCookiesForRequest:(NSURLRequest *)request;
@end