#import "MRSocialLoginProviderManager.h"
#import "MRSocialLoginProvider.h"
#import "MRSocialLoginProviderOK.h"
#import "MRSocialLoginProviderVK.h"
#import "MRSocialLoginProviderMailRu.h"
#import "MRSocialLoginProviderYandex.h"
#import "MRSocialLoginProviderTwitter.h"
#import "MRSocialLoginProviderFacebook.h"

@interface MRSocialLoginProviderManager ()
@property (nonatomic, strong, readonly) NSMutableDictionary *providers;
@end

@implementation MRSocialLoginProviderManager {
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static MRSocialLoginProviderManager *_instance;
    dispatch_once(&once, ^{
        _instance = [MRSocialLoginProviderManager new];
    });
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _providers = [NSMutableDictionary dictionary];
        [self registerProvider:MRSocialLoginProviderOK.class];
        [self registerProvider:MRSocialLoginProviderVK.class];
        [self registerProvider:MRSocialLoginProviderMailRu.class];
        [self registerProvider:MRSocialLoginProviderYandex.class];
        [self registerProvider:MRSocialLoginProviderTwitter.class];
        [self registerProvider:MRSocialLoginProviderFacebook.class];
    }

    return self;
}

- (Class)providerWithType:(NSString *)type {
    return self.providers[type];
}

- (void)registerProvider:(Class)provider {
    NSString *type = [provider type];
    self.providers[type] = provider;
}

@end