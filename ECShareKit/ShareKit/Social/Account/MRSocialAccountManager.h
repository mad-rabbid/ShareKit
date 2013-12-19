#import <Foundation/Foundation.h>

@class MRSocialAccountInfo;


@interface MRSocialAccountManager : NSObject

+ (instancetype)sharedInstance;

- (BOOL)isLoggedInWithType:(NSString *)type;
- (MRSocialAccountInfo *)accountWithType:(NSString *)type;
- (void)setAccount:(MRSocialAccountInfo *)account withType:(NSString *)type;
- (void)removeAccountWithType:(NSString *)type;

@end