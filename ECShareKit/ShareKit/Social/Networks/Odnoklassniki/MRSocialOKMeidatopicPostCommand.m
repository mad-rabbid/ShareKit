#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <JSONKit/JSONKit.h>
#import "MRSocialOKMeidatopicPostCommand.h"
#import "MRSocialAccountInfo.h"
#import "MRPostInfo.h"
#import "MRSocialLogging.h"
#import "MRSocialOKSignaturesHelper.h"


static NSString *const kOKApiHTTPMethodPost = @"POST";
static NSString *const kOKApiMethodMediatopicPost = @"mediatopic.post";
static NSString *const kOKApiMethodPhotosV2GetUploadUrl = @"photosV2.getUploadUrl";
static NSString *const kOKApiMethodPhotosSaveWallPhoto = @"photosV2.commit";

@interface MRSocialOKMeidatopicPostCommand ()
@property (nonatomic, strong) AFHTTPRequestOperation *operation;
@property (nonatomic, strong) AFHTTPRequestOperationManager *httpClient;
@property (nonatomic, strong) MRPostInfo *postInfo;
@end

@implementation MRSocialOKMeidatopicPostCommand {

}

- (instancetype)initWithHttpClient:(AFHTTPRequestOperationManager *)httpClient postInfo:(MRPostInfo *)postInfo {
    self = [super init];
    if (self) {
        _httpClient = httpClient;
        _postInfo = postInfo;
    }
    return self;
}


- (void)dealloc {
    [self cancelOperation];
}

- (void)cancelOperation {
    if (self.operation) {
        [self.operation cancel];
        [self resetNetworkOperation];
    }
}

- (void)resetNetworkOperation {
    self.operation = nil;
}


- (void)execute {
    [self obtainPhotoUploadUrl];
}

- (void)success {
    if (self.completionBlock) {
        self.completionBlock(YES);
    }
}

- (void)failWithError:(NSError *)error {
    MRLog(@"Error: %@", [error localizedDescription]);
    [self resetNetworkOperation];
    [self fail];
}

- (void)fail {
    if (self.completionBlock) {
        self.completionBlock(NO);
    }
}

- (NSDictionary *)validOperationResponse:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject {
    return (operation.response.statusCode == 200 && [responseObject isKindOfClass:NSDictionary.class]) ? responseObject : nil;
}

- (void)obtainPhotoUploadUrl {
    [self cancelOperation];

    NSMutableDictionary *parameters = [@{
        @"access_token" : self.account.accessToken
    } mutableCopy];

    [MRSocialOKSignaturesHelper signRequest:parameters account:self.account key:self.key];
    __weak typeof(self) myself = self;
    self.operation = [self.httpClient GET:kOKApiMethodPhotosV2GetUploadUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        NSDictionary *response = [myself validOperationResponse:operation responseObject:responseObject];
        if (response) {
            NSString *uploadUrl = response[@"upload_url"];
            NSArray *photos = response[@"photo_ids"];
            if ([uploadUrl isKindOfClass:NSString.class] && [photos isKindOfClass:NSDictionary.class] && photos.count && [photos[0] isKindOfClass:NSString.class]) {
                [myself uploadPhotoWithUrl:uploadUrl photoId:photos[0]];
                return;
            }
        }
        [myself fail];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [myself failWithError:error];
    }];
}

- (void)uploadPhotoWithUrl:(NSString *)targetUrl photoId:(NSString *)photoId {
    __weak typeof(self) myself = self;
    NSMutableURLRequest *request = [self.httpClient.requestSerializer multipartFormRequestWithMethod:kOKApiHTTPMethodPost
                                                                                           URLString:targetUrl
                                                                                          parameters:nil
                                                                           constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
                                                                               NSData *data = UIImageJPEGRepresentation(myself.postInfo.image, 0.85);
                                                                               [formData appendPartWithFileData:data name:@"pic1" fileName:@"image.jpg" mimeType:@"image/jpeg"];
                                                                           }];


    self.operation = [self.httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        MRLog(@"Response: %@", [operation responseString]);
        NSDictionary *response = [myself validOperationResponse:operation responseObject:responseObject];
        if (response) {
            NSDictionary *photos = response[@"photos"];
            if ([photos isKindOfClass:NSDictionary.class]) {
                __block BOOL isFound = NO;
                [photos enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *token, BOOL *stop) {
                    if ([key isEqualToString:photoId]) {
                        isFound = YES;
                        *stop = YES;
                    }
                }];

                if (isFound) {
                    [myself savePhotoWithToken:photos[photoId] photoId:photoId];
                    return;
                }
            }
        }
        [myself fail];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [myself failWithError:error];
    }];
    [self.httpClient.operationQueue addOperation:self.operation];
}

- (void)savePhotoWithToken:(NSString *)token photoId:(NSString *)photoId {
    NSMutableDictionary *parameters = [@{
        @"photo_id" : photoId,
        @"token" : token,
        @"access_token" : self.account.accessToken
    } mutableCopy];

    [MRSocialOKSignaturesHelper signRequest:parameters account:self.account key:self.key];

    __weak typeof(self) myself = self;
    self.operation = [self.httpClient POST:kOKApiMethodPhotosSaveWallPhoto parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        MRLog(@"Response: %@", [operation responseString]);
        NSDictionary *response = [myself validOperationResponse:operation responseObject:responseObject];
        if (response) {
            NSArray *photos = response[@"photos"];
            if ([photos isKindOfClass:NSArray.class] && photos.count) {
                NSDictionary *photo = photos.lastObject;
                if ([photo isKindOfClass:NSDictionary.class] && [[photo[@"status"] lowercaseString] isEqualToString:@"success"]) {
                    [myself postMessageWithPhotoIdentifier:token];
                    return;
                }
            }
        }
        [myself fail];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [myself failWithError:error];
    }];
}

- (void)postMessageWithPhotoIdentifier:(NSString *)token {
    NSDictionary *attachment = @{
        @"media" : @[
            @{
                @"type" : @"photo",
                @"list" : @[
                    @{ @"id" : token }
                ]
            },
            @{
                @"type" : @"text",
                @"text" : self.postInfo.message
            }
        ]
    };

    NSMutableDictionary *parameters = [@{
        @"type" : @"USER",
        @"access_token" : self.account.accessToken,
        @"media" : [attachment JSONString]
    } mutableCopy];

    [MRSocialOKSignaturesHelper signRequest:parameters account:self.account key:self.key];

    __weak typeof(self) myself = self;
    self.operation = [self.httpClient POST:kOKApiMethodMediatopicPost parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        NSString *responseString = operation.responseString;
        if (responseString.length) {
            NSDecimalNumber *postIdentifier = [NSDecimalNumber decimalNumberWithString:responseString];
            if (postIdentifier) {
                MRLog(@"A post has been posted and has id %@", postIdentifier);
                [myself success];
                return;
            }
        }
        [myself fail];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [myself failWithError:error];
    }];
}

@end