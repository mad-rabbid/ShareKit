#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "MRSocialProviderVK.h"
#import "MRSocialHelper.h"
#import "MRSocialProvidersFactory.h"
#import "MRSocialAccountInfo.h"
#import "MRSocialLogging.h"
#import "MRSocialVKWallPostCommand.h"
#import "MRPostInfo.h"

#define kVKSexMan  2
#define kVKSexWoman 1

static NSString *const kVKAppIdKey = @"appId";

static NSString *const kVKRedirectURI = @"https://oauth.vk.com/blank.html";
static NSString *const kVKAuthorizationURL = @"https://oauth.vk.com/authorize";
static NSString *const kVKErrorPageURLPrefix = @"https://oauth.vk.com/error";

static NSString *const kVKPermissionList = @"status,wall,photos";
static NSString *const kVKApiBase = @"https://api.vk.com/method";

static NSString *const kVKApiMethodUsersGet = @"users.get";
static NSString *const kVKApiMethodUsersGetFields = @"uid,first_name,last_name,sex,bdate,photo";

@interface MRSocialProviderVK ()
@property (nonatomic, strong) MRSocialVKWallPostCommand *wallPostCommand;
@end

@implementation MRSocialProviderVK {
}

- (id)init {
    self = [super init];
    if (self) {
        self.httpClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", nil];
    }

    return self;
}

- (NSString *)name {
    return NSLocalizedString(@"ВКонтакте", nil);
}

- (NSURLRequest *)loginRequest {
    NSString *stringUrl = [NSString stringWithFormat:@"%@?%@", kVKAuthorizationURL, [MRSocialHelper parametersStringWithDictionary:@{
        @"client_id" : self.settings[kVKAppIdKey],
        @"scope" : kVKPermissionList,
        @"response_type" : @"token",
        @"redirect_uri" : self.redirectURI,
        @"display" : @"touch"
    }]];

    NSURL *url = [[NSURL alloc] initWithString:stringUrl];
    return [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kMRTimeoutInterval];
}

+ (NSString *)type {
    return kMRSocialProviderTypeVKontakte;
}

- (NSString *)baseApiURL {
    return kVKApiBase;
}

- (NSString *)redirectURI {
    return kVKRedirectURI;
}

- (BOOL)isAllowedToProcessUrlString:(NSString *)urlString {
    if ([urlString hasPrefix:kVKErrorPageURLPrefix]) {
        [self fail];
        return NO;
    }

    return YES;
}

- (MRSocialAccountInfo *)createAccountWithDictionary:(NSDictionary *)dictionary {
    MRSocialAccountInfo *account = [super createAccountWithDictionary:dictionary];
    account.identifier = dictionary[@"user_id"];
    return account;
}

- (void)loadUserInfo:(MRSocialAccountInfo *)account {
    NSMutableDictionary *parameters = [@{
        @"uids" : account.identifier,
        @"fields" : kVKApiMethodUsersGetFields,
        @"access_token" : account.accessToken
    } mutableCopy];

    __weak typeof(self) myself = self;
    self.operation = [self.httpClient GET:kVKApiMethodUsersGet parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [myself resetNetworkOperation];
        [myself handleUserInfoResponse:operation.response result:responseObject account:account];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MRLog(@"Error: %@", [error localizedDescription]);
        [myself resetNetworkOperation];
        [myself fail];
    }];
}

- (void)handleUserInfoResponse:(NSHTTPURLResponse *)response result:(id)result account:(MRSocialAccountInfo *)info {
    if (response.statusCode == 200 && [result isKindOfClass:NSDictionary.class]) {
        MRLog(@"User info is: %@", result);

        NSArray *infos = result[@"response"];
        if ([infos isKindOfClass:NSArray.class] && infos.count) {
            [self updateAccountInfo:info fromUserInfo:infos[0]];
            [self success:info];
            return;
        }
    }
    [self fail];
}

- (void)updateAccountInfo:(MRSocialAccountInfo *)account fromUserInfo:(NSDictionary *)userInfo {
    account.firstName = userInfo[@"first_name"];
    account.lastName = userInfo[@"last_name"];
    switch ([userInfo[@"sex"] intValue]) {
        case kVKSexWoman:
            account.sex = MRAccountSexWoman;
            break;
        case kVKSexMan:
            account.sex = MRAccountSexMan;
            break;
        default:
            account.sex = MRAccountSexUndefined;
            break;

    }

    NSString *dateString = userInfo[@"bdate"];
    if (dateString) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"dd.MM.yyyy";
        account.birthDate = [formatter dateFromString:dateString];
    }
    account.avatar = userInfo[@"photo"];
    account.identifier = userInfo[@"uid"];
    MRLog(@"AccountInfo is %@", account);
}

- (void)publish:(MRPostInfo *)postInfo account:(MRSocialAccountInfo *)accountInfo completionBlock:(void (^)(BOOL isSuccess))completionBlock {
    __weak typeof(self) myself = self;
    MRSocialVKWallPostCommand *command = [[MRSocialVKWallPostCommand alloc] initWithHttpClient:self.httpClient postInfo:postInfo];
    command.account = accountInfo;
    command.completionBlock = ^(BOOL isSuccess) {
        if (completionBlock) {
            completionBlock(isSuccess);

            myself.wallPostCommand = nil;
        }
    };

    self.wallPostCommand = command;
    [self.wallPostCommand execute];
}

@end