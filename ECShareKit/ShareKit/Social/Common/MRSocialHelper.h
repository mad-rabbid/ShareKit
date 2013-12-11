#import <Foundation/Foundation.h>


@interface MRSocialHelper : NSObject

+ (NSString *)encodeToPercentEscapeString:(NSString *)string;

+ (NSString *)decodeFromPercentEscapeString:(NSString *)string;


+ (NSDictionary *)parseParameterString:(NSString *)parameterString;

+ (NSString *)parametersStringWithDictionary:(NSDictionary *)parameters;

+ (NSString *)sortedParameters:(NSMutableDictionary *)dictionary excludes:(NSArray *)excludes;

+ (NSString *)sortedParameters:(NSMutableDictionary *)dictionary excludes:(NSArray *)excludes encode:(BOOL)encode ampersand:(BOOL)ampersand;

+ (NSString *)md5:(NSString *)input;

+ (NSDateFormatter *)dateFormatter;
@end