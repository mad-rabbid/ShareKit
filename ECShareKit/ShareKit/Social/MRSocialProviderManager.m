#import "MRSocialProviderManager.h"
#import "MRSocialProvider.h"
#import "MRSocialProviderOK.h"
#import "MRSocialProviderVK.h"
#import "MRSocialProviderMailRu.h"
#import "MRSocialProviderYandex.h"
#import "MRSocialProviderTwitter.h"
#import "MRSocialProviderFacebook.h"

@interface MRSocialProviderManager ()
@property (nonatomic, strong, readonly) NSMutableDictionary *providers;
@end

@implementation MRSocialProviderManager {
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static MRSocialProviderManager *_instance;
    dispatch_once(&once, ^{
        _instance = [MRSocialProviderManager new];
    });
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _providers = [NSMutableDictionary dictionary];
        [self registerProvider:MRSocialProviderOK.class];
        [self registerProvider:MRSocialProviderVK.class];
        [self registerProvider:MRSocialProviderMailRu.class];
        [self registerProvider:MRSocialProviderYandex.class];
        [self registerProvider:MRSocialProviderTwitter.class];
        [self registerProvider:MRSocialProviderFacebook.class];
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