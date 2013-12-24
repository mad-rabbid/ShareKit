#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "MRSocialVKWallPostCommand.h"
#import "MRPostInfo.h"
#import "MRSocialLogging.h"
#import "MRSocialAccountInfo.h"

static NSString *const kVKApiHTTPMethodPost = @"POST";
static NSString *const kVKApiMethodWallPost = @"wall.post";
static NSString *const kVKApiMethodPhotosGetWallUploadServer = @"photos.getWallUploadServer";
static NSString *const kVKApiMethodPhotosSaveWallPhoto = @"photos.saveWallPhoto";

@interface MRSocialVKWallPostCommand ()
@property (nonatomic, strong) AFHTTPRequestOperation *operation;
@property (nonatomic, strong) AFHTTPRequestOperationManager *httpClient;
@property (nonatomic, strong) MRPostInfo *postInfo;

@end

@implementation MRSocialVKWallPostCommand {

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
    return (operation.response.statusCode == 200 && [responseObject isKindOfClass:NSDictionary.class] && responseObject[@"response"]) ? responseObject[@"response"] : nil;
}

- (void)obtainPhotoUploadUrl {
    [self cancelOperation];

    NSMutableDictionary *parameters = [@{
        @"access_token" : self.account.accessToken
    } mutableCopy];

    __weak typeof(self) myself = self;
    self.operation = [self.httpClient GET:kVKApiMethodPhotosGetWallUploadServer parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        NSDictionary *response = [myself validOperationResponse:operation responseObject:responseObject];
        if (response) {
            NSString *uploadUrl = response[@"upload_url"];
            if ([uploadUrl isKindOfClass:NSString.class]) {
                [myself uploadPhotoWithUrl:uploadUrl];
                return;
            }
        }
        [myself fail];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [myself failWithError:error];
    }];
}

- (void)uploadPhotoWithUrl:(NSString *)targetUrl {
    __weak typeof(self) myself = self;
    NSMutableURLRequest *request = [self.httpClient.requestSerializer multipartFormRequestWithMethod:kVKApiHTTPMethodPost
                                                                                           URLString:targetUrl
                                                                                          parameters:nil
                                                                           constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
                                                                               NSData *data = UIImageJPEGRepresentation(myself.postInfo.image, 0.85);
                                                                               [formData appendPartWithFileData:data name:@"photo" fileName:@"image.jpg" mimeType:@"image/jpeg"];
                                                                           }];


    self.operation = [self.httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        MRLog(@"Response: %@", [operation responseString]);
        NSDictionary *response = (operation.response.statusCode == 200 && [responseObject isKindOfClass:NSDictionary.class]) ? responseObject : nil;
        if (response) {
            [myself savePhotoWithDescriptor:response];
            return;
        }
        [myself fail];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [myself failWithError:error];
    }];
    [self.httpClient.operationQueue addOperation:self.operation];
}

- (void)savePhotoWithDescriptor:(NSDictionary *)descriptor {
    NSDictionary *parameters = @{
        @"server" : descriptor[@"server"],
        @"photo" : descriptor[@"photo"],
        @"hash" : descriptor[@"hash"],
        @"access_token" : self.account.accessToken
    };

    __weak typeof(self) myself = self;
    self.operation = [self.httpClient POST:kVKApiMethodPhotosSaveWallPhoto parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        MRLog(@"Response: %@", [operation responseString]);
        id response = [myself validOperationResponse:operation responseObject:responseObject];
        if ([response isKindOfClass:NSArray.class] && [(NSArray *)response count]) {
            NSString *identifier = ((NSArray *)response).lastObject[@"id"];
            [myself postMessageWithPhotoIdentifier:identifier];
            return;
        }
        [myself fail];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [myself failWithError:error];
    }];
}

- (void)postMessageWithPhotoIdentifier:(NSString *)identifier {
    NSDictionary *parameters = @{
        @"owner_id" : self.account.identifier,
        @"access_token" : self.account.accessToken,
        @"message" : self.postInfo.message ?: @"",
        @"attachments" : identifier ?: @""
    };

    __weak typeof(self) myself = self;
    self.operation = [self.httpClient POST:kVKApiMethodWallPost parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        NSDictionary *response = [myself validOperationResponse:operation responseObject:responseObject];
        if (response && [response[@"post_id"] isKindOfClass:NSNumber.class]) {
            [myself success];
            return;
        }
        [myself fail];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [myself failWithError:error];
    }];
}

@end