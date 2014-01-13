#import "MRSocialOKSignaturesHelper.h"
#import "MRSocialAccountInfo.h"
#import "MRSocialHelper.h"
#import "MRSocialLogging.h"


@implementation MRSocialOKSignaturesHelper {

}

+ (void)signRequest:(NSMutableDictionary *)dictionary account:(MRSocialAccountInfo *)account key:(NSString *)key {
    NSMutableString *builder = [[MRSocialHelper sortedParameters:dictionary excludes:@[@"access_token"]] mutableCopy];

    NSString *secretSource = [account.accessToken stringByAppendingString:key;
    NSString *secret = [MRSocialHelper md5:secretSource];
    [builder appendString:secret];

    dictionary[@"sig"] = [MRSocialHelper md5:builder];
    MRLog(@"Dictionary is: %@", dictionary);
}

@end