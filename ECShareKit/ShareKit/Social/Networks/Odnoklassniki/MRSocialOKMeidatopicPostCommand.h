#import <Foundation/Foundation.h>

@class MRSocialAccountInfo;
@class AFHTTPRequestOperationManager;
@class MRPostInfo;


@interface MRSocialOKMeidatopicPostCommand : NSObject

@property (nonatomic, copy) void (^completionBlock)(BOOL isSuccess);
@property (nonatomic, strong) MRSocialAccountInfo *account;
@property (nonatomic, strong) NSString *key;

- (instancetype)initWithHttpClient:(AFHTTPRequestOperationManager *)httpClient postInfo:(MRPostInfo *)postInfo;

- (void)execute;
@end