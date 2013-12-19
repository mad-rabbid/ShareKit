#import <NSData+Base64/NSData+Base64.h>
#import <CommonCrypto/CommonHMAC.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "MRSocialTwitterRequestBuilder.h"
#import "MRSocialLogging.h"
#import "MRSocialHelper.h"

static NSInteger const kTwitterNonceLength = 32;

@interface MRSocialTwitterRequestBuilder ()
@property (nonatomic, strong) NSString *consumerKey;
@property (nonatomic, strong) NSString *consumerSecret;

@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *apiPath;
@property (nonatomic, strong) NSString *secret;


@property (nonatomic, strong) NSMutableDictionary *parameters;
@end

@implementation MRSocialTwitterRequestBuilder {

}

- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret {
    self = [super init];
    if (self) {
        self.consumerKey = consumerKey;
        self.consumerSecret = consumerSecret;
        self.headers = [self createHeaders];
        self.parameters = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addHeader:(NSString *)headerName value:(NSString *)value {
    self.headers[headerName] = value;
}

- (void)addParameter:(NSString *)parameterName value:(NSString *)value {
    self.parameters[parameterName] = value;
}

- (NSMutableURLRequest *)buildRequestWithHttpClient:(AFHTTPRequestOperationManager *)client {
    NSMutableURLRequest *request = [client.requestSerializer requestWithMethod:self.method
                                                                     URLString:[client.baseURL.absoluteString stringByAppendingFormat:@"/%@", self.apiPath]
                                                                    parameters:self.parameters];

    NSString *urlString = request.URL.absoluteString;
    NSRange range = [urlString rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        urlString = [urlString substringToIndex:range.location];
    }
    [request addValue:[self signWithUrlString:urlString] forHTTPHeaderField:@"Authorization"];
    return request;
}

- (NSString *)signWithUrlString:(NSString *)urlString {
    NSMutableDictionary *source = [NSMutableDictionary dictionaryWithDictionary:self.headers];
    [source addEntriesFromDictionary:self.parameters];

    NSString *parameterString = [MRSocialHelper sortedParameters:source excludes:nil encode:YES ampersand:YES];
    MRLog(@"Parameter string is: %@", parameterString);

    NSString *signatureBase = [NSString stringWithFormat:@"%@&%@&%@",
                                                         [self.method uppercaseString],
                                                         [MRSocialHelper encodeToPercentEscapeString:urlString],
                                                         [MRSocialHelper encodeToPercentEscapeString:parameterString]];
    MRLog(@"Signature base is: %@", signatureBase);

    NSString *signingKey = [[MRSocialHelper encodeToPercentEscapeString:self.consumerSecret] stringByAppendingString:@"&"];
    if (self.secret.length) {
        signingKey = [signingKey stringByAppendingString:[MRSocialHelper encodeToPercentEscapeString:self.secret]];
    }
    MRLog(@"Signing key is: %@", signingKey);

    NSString *signature = [self HMACSHA1:signatureBase secret:signingKey];
    MRLog(@"Signature is: %@", signature);
    self.headers[@"oauth_signature"] = signature;

    return [self createAuthorizationHeaderValue];
}

- (NSString *)createAuthorizationHeaderValue {
    NSMutableString *builder = [NSMutableString new];
    [self.headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        if (builder.length) {
            [builder appendString:@", "];
        }
        [builder appendFormat:@"%@=\"%@\"", [MRSocialHelper encodeToPercentEscapeString:key], [MRSocialHelper encodeToPercentEscapeString:value]];
    }];

    [builder insertString:@"OAuth " atIndex:0];
    MRLog(@"Authorization header is: %@", builder);
    return builder;
}

- (NSMutableDictionary *)createHeaders {
    NSMutableDictionary *result = [@{
        @"oauth_signature_method" : @"HMAC-SHA1",
        @"oauth_timestamp" : [NSString stringWithFormat:@"%.0f", [[NSDate new] timeIntervalSince1970]],
        @"oauth_version": @"1.0",
        @"oauth_consumer_key" : self.consumerKey,
        @"oauth_nonce" : [self createNonce]
    } mutableCopy];
    MRLog(@"Headers are: %@", result);
    return result;
}

- (NSString *)createNonce {
    NSMutableData *result = [NSMutableData dataWithCapacity:kTwitterNonceLength];
    for (NSUInteger i = 0; i < kTwitterNonceLength / 4; i++) {
        u_int32_t randomBits = arc4random();
        [result appendBytes:(void*)&randomBits length:4];
    }
    NSString *encoded = [result base64EncodedString];

    NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    return [[encoded componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
}

- (NSString *)HMACSHA1:(NSString *)data secret:(NSString *)key {
    const char *workKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *workData = [data cStringUsingEncoding:NSASCIIStringEncoding];

    unsigned char buffer[CC_SHA1_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA1, workKey, strlen(workKey), workData, strlen(workData), buffer);
    NSData *result = [[NSData alloc] initWithBytes:buffer length:sizeof(buffer)];

    return [result base64EncodedString];
}
@end