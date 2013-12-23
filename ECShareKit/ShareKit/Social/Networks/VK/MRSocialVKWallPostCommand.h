#import <Foundation/Foundation.h>

@class MRPostInfo;


@interface MRSocialVKWallPostCommand : NSObject

@property (nonatomic, copy) void (^completionBlock)(BOOL isSuccess);

- (instancetype)initWithHttpClient:(AFHTTPRequestOperationManager *)httpClient postInfo:(MRPostInfo *)postInfo;

- (void)execute;
@end