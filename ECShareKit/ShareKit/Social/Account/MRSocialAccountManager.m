#import "MRSocialAccountManager.h"
#import "FXKeychain.h"
#import "MRSocialAccountInfo.h"
#import "MRSocialLogging.h"

static NSString *const kMRKeychainService = @"mad.rabbid.social.login";
static NSString *const kMRKeychainKeySocialAccount = @"mad.rabbid.general.social.account";

@interface MRSocialAccountManager ()
@property (nonatomic, strong) FXKeychain *keychain;
@property (nonatomic, strong) NSMutableDictionary *accountsCache;
@end

@implementation MRSocialAccountManager {
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
        self.keychain = [[FXKeychain alloc] initWithService:kMRKeychainService accessGroup:nil];
        self.accountsCache = [NSMutableDictionary new];
    }

    return self;
}

- (BOOL)isLoggedInWithType:(NSString *)type {
    return [self accountWithType:type] != nil;
}

- (MRSocialAccountInfo *)accountWithType:(NSString *)type {
    MRSocialAccountInfo *info = self.accountsCache[type];
    if (!info) {
        NSDictionary *dictionary = self.keychain[type];
        if ([dictionary isKindOfClass:NSDictionary.class]) {
            @try {
                info = [MRSocialAccountInfo unmarshal:dictionary];
            } @catch (NSException *exception) {
                MRLog(@"Unmarshalling of an instance of MRSocialAccountInfo failed: %@", [exception description]);
            }
        }

        if (info) {
            self.accountsCache[type] = info;
        }
    }
    return info;
}

- (void)setAccount:(MRSocialAccountInfo *)account withType:(NSString *)type {
    if (account) {
        self.keychain[type] = [account marshal];
        self.accountsCache[type] = account;
    } else {
        [self removeAccountWithType:type];
    }
}

- (void)removeAccountWithType:(NSString *)type {
    [self.keychain removeObjectForKey:type];
    [self.accountsCache removeObjectForKey:type];
}
@end