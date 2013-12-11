#import "MRSocialAccountManager.h"
#import "FXKeychain.h"
#import "MRSocialAccountInfo.h"

static NSString *const kMRKeychainService = @"mad.rabbid.social.login";
static NSString *const kMRKeychainAccessGroup = @"mad.rabbid.access.group.general";
static NSString *const kMRKeychainKeySocialAccount = @"mad.rabbid.general.social.account";

@interface MRSocialAccountManager ()
@property (nonatomic, strong) FXKeychain *keychain;
@end

@implementation MRSocialAccountManager {
    __strong MRSocialAccountInfo *_account;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static MRSocialAccountManager *_instance;
    dispatch_once(&once, ^{
        _instance = [MRSocialAccountManager new];
    });
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.keychain = [[FXKeychain alloc] initWithService:kMRKeychainService accessGroup:kMRKeychainAccessGroup];
    }

    return self;
}

- (void)checkLogin {

}

- (void)reloadAccount {
    _account = [MRSocialAccountInfo unmarshal:self.keychain[kMRKeychainKeySocialAccount]];
}

- (MRSocialAccountInfo *)account {
    return _account;
}

- (void)setAccount:(MRSocialAccountInfo *)account {
    _account = account;
    self.keychain[kMRKeychainKeySocialAccount] = [account marshal];
}

@end