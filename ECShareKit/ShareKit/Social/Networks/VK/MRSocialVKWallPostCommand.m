#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "MRSocialVKWallPostCommand.h"
#import "MRPostInfo.h"
#import "MRSocialLogging.h"
#import "MRSocialAccountInfo.h"
#import "MRSocialAccountManager.h"
#import "MRSocialProvidersFactory.h"

static NSString *const kVKApiHTTPMethodPost = @"POST";
static NSString *const kVKApiMethodWallPost = @"wall.post";
static NSString *const kVKApiMethodPhotosGetWallUploadServer = @"photos.getWallUploadServer";
static NSString *const kVKApiMethodPhotosSaveWallPhoto = @"photos.saveWallPhoto";

@interface MRSocialVKWallPostCommand ()
@property (nonatomic, strong) AFHTTPRequestOperation *operation;
@property (nonatomic, strong) AFHTTPRequestOperationManager *httpClient;
@property (nonatomic, strong) MRPostInfo *postInfo;
@property (nonatomic, strong) MRSocialAccountInfo *account;
@end

@implementation MRSocialVKWallPostCommand {

}

- (instancetype)initWithHttpClient:(AFHTTPRequestOperationManager *)httpClient postInfo:(MRPostInfo *)postInfo {
    self = [super init];
    if (self) {
        _httpClient = httpClient;
        _postInfo = postInfo;
        _account = [[MRSocialAccountManager sharedInstance] accountWithType:kMRSocialProviderTypeVKontakte];
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

- (void)obtainPhotoUploadUrl {
    [self cancelOperation];

    NSMutableDictionary *parameters = [@{
        @"user_id" : self.account.identifier,
        @"access_token" : self.account.accessToken
    } mutableCopy];

    __weak typeof(self) myself = self;
    self.operation = [self.httpClient GET:kVKApiMethodPhotosGetWallUploadServer parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        if (operation.response.statusCode == 200) {
            NSString *uploadUrl = responseObject[@"upload_url"];
            if ([uploadUrl isKindOfClass:NSString.class]) {
                [myself uploadPhotoWithUrl:uploadUrl];
            }
            return;
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
        if (operation.response.statusCode == 200 && [responseObject isKindOfClass:NSDictionary.class]) {
            [myself savePhotoWithDescriptor:responseObject];
            return;
        }
        [myself fail];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [myself failWithError:error];
    }];
    [self.httpClient.operationQueue addOperation:self.operation];
}

- (void)savePhotoWithDescriptor:(NSDictionary *)descriptor {
    NSMutableDictionary *parameters = [descriptor mutableCopy];
    parameters[@"user_id"] = self.account.identifier;
    parameters[@"access_token"] = self.account.accessToken;

    __weak typeof(self) myself = self;
    self.operation = [self.httpClient POST:kVKApiMethodPhotosSaveWallPhoto parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        if (operation.response.statusCode == 200) {
            NSString *identifier = responseObject[@"id"];

            return;
        }
        [myself fail];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [myself failWithError:error];
    }];
}

- (void)postMessageWithPhotoIdentifier:(NSString *)identifier {

}

@end