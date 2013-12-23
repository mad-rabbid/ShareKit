#import <Foundation/Foundation.h>

@class MRSocialAccountInfo;
@class MRPostInfo;

@protocol MRSocialProvider <NSObject>

@property (nonatomic, strong, readonly) NSString *name;

- (void)setWebView:(UIWebView *)webView;
- (void)setSettings:(NSDictionary *)settings;

- (void)loginWithSuccessBlock:(void (^)(MRSocialAccountInfo *accountInfo))successBlock failBlock:(void (^)())failBlock;

- (void)publish:(MRPostInfo *)postInfo account:(MRSocialAccountInfo *)accountInfo completionBlock:(void (^)(BOOL isSuccess))completionBlock;
@end