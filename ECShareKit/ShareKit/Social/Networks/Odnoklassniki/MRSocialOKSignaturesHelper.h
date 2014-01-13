#import <Foundation/Foundation.h>

@class MRSocialAccountInfo;


@interface MRSocialOKSignaturesHelper : NSObject
+ (void)signRequest:(NSMutableDictionary *)dictionary account:(MRSocialAccountInfo *)account key:(NSString *)key;
@end