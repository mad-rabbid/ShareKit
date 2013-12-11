#import <Foundation/Foundation.h>

@class MRSocialAccountInfo;


@interface MRSocialAccountManager : NSObject


+ (instancetype)sharedInstance;

- (void)reloadAccount;
- (MRSocialAccountInfo *)account;
- (void)setAccount:(MRSocialAccountInfo *)account;

@end