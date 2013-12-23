#import <Foundation/Foundation.h>

@interface MRSocialTwitterRequestBuilder : NSObject

@property (nonatomic, strong) NSMutableDictionary *headers;

- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret;

- (void)setMethod:(NSString *)method;
- (void)setSecret:(NSString *)secret;
- (void)setApiPath:(NSString *)apiPath;

- (void)addHeader:(NSString *)headerName value:(NSString *)value;

- (void)addParameter:(NSString *)parameterName value:(id)value;

- (NSMutableURLRequest *)buildRequestWithHttpClient:(AFHTTPRequestOperationManager *)client;

- (NSMutableURLRequest *)buildMultipartRequestWithHttpClient:(AFHTTPRequestOperationManager *)client;
@end