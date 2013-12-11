#import "MRSocialHelper.h"
#import "MRSocialLogging.h"
#import <CommonCrypto/CommonDigest.h>

#define kMRKeyValueItemsCount 2

static NSString *const kMRSocialDateFormat = @"yyyy-MM-dd";

@implementation MRSocialHelper {

}

+ (NSString *)encodeToPercentEscapeString:(NSString *)string {
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) string, NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}

+ (NSString *)decodeFromPercentEscapeString:(NSString *)string {
    return (__bridge NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef) string, CFSTR(""), kCFStringEncodingUTF8);
}

+ (NSDictionary *)parseParameterString:(NSString *)parameterString {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    NSArray *parts = [parameterString componentsSeparatedByString:@"&"];
    if (!parts.count) {
        return result;
    }

    for (NSString *part in parts) {
        NSArray *items = [part componentsSeparatedByString:@"="];
        if (items.count != kMRKeyValueItemsCount) {
            continue;
        }

        NSString *value = [self decodeFromPercentEscapeString:items[1]];
        result[items[0]] = value;
    }

    return result;
}

+ (NSString *)parametersStringWithDictionary:(NSDictionary *)parameters {
    NSMutableString *result = [NSMutableString new];

    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        if (result.length) {
            [result appendString:@"&"];
        }
        [result appendFormat:@"%@=%@", key, [self encodeToPercentEscapeString:value]];
    }];
    return result;
}

+ (NSString *)sortedParameters:(NSMutableDictionary *)dictionary excludes:(NSArray *)excludes  {
    return [self sortedParameters:dictionary excludes:excludes encode:NO ampersand:NO];
}

+ (NSString *)sortedParameters:(NSMutableDictionary *)dictionary excludes:(NSArray *)excludes encode:(BOOL)encode ampersand:(BOOL)ampersand {
    NSArray *sortedKeys = [dictionary.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *key1, NSString *key2) {
        return [key1 compare:key2];
    }];
    MRLog(@"Sorted keys are: %@", sortedKeys);

    static NSString *kMRParametersFormat = @"%@=%@";
    NSMutableString *builder = [NSMutableString new];
    for (NSString *key in sortedKeys) {
        if (ampersand && builder.length) {
            [builder appendString:@"&"];
        }

        if (![excludes containsObject:key]) {
            if (!encode) {
                [builder appendFormat:kMRParametersFormat, key, dictionary[key]];
            } else {
                [builder appendFormat:kMRParametersFormat,
                                [self encodeToPercentEscapeString:key],
                                [self encodeToPercentEscapeString:dictionary[key]]];
            }

        }
    }

    return builder;
}

+ (NSString *)md5:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }

    return  output;

}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:kMRSocialDateFormat];
    return formatter;
}
@end