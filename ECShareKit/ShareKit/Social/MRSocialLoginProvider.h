#import <Foundation/Foundation.h>

@class MRSocialAccountInfo;

@protocol MRSocialLoginProvider <NSObject>

@property (nonatomic, strong, readonly) NSString *name;

- (void)setWebView:(UIWebView *)webView;
- (void)loginWithSuccessBlock:(void (^)(MRSocialAccountInfo *accountInfo))successBlock failBlock:(void (^)())failBlock;

@end