#import <Foundation/Foundation.h>

@class MRPostInfo;
@class MRSocialAccountInfo;


@interface MRSocialVKWallPostCommand : NSObject

@property (nonatomic, copy) void (^completionBlock)(BOOL isSuccess);
@property (nonatomic, strong) MRSocialAccountInfo *account;

- (instancetype)initWithHttpClient:(AFHTTPRequestOperationManager *)httpClient postInfo:(MRPostInfo *)postInfo;

- (void)execute;
@end