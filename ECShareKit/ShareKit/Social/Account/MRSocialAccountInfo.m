#import "MRSocialAccountInfo.h"
#import "MRSocialHelper.h"
#import "MRPostInfo.h"

static NSString *const kMRAccountInfoVersion = @"1.0.0";

static NSString *const kMRKeyVersion = @"version";
static NSString *const kMRKeyType = @"type";
static NSString *const kMRKeyIdentifier = @"identifier";

static NSString *const kMRKeyAccessToken = @"access.token";
static NSString *const kMRKeyRefreshToken = @"refresh.token";

static NSString *const kMRKeyFirstName = @"first.name";
static NSString *const kMRKeyLastName = @"last.name";
static NSString *const kMRKeySex = @"sex";
static NSString *const kMRKeyEmail = @"email";
static NSString *const kMRKeyAvatar = @"avatar";
static NSString *const kMRKeyBirthDate = @"birth.date";

static NSString *const kMRSexUndefined = @"undefined";
static NSString *const kMRSexMan = @"man";
static NSString *const kMRSexWoman = @"woman";

@implementation MRSocialAccountInfo {

}

- (id)initWithType:(NSString *)type accessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken {
    self = [super init];
    if (self) {
        _type = type;
        _accessToken = accessToken;
        _refreshToken = refreshToken;
    }
    return self;
}

- (NSDictionary *)marshal {
    NSMutableDictionary *result = [@{
        kMRKeyVersion : kMRAccountInfoVersion,
        kMRKeyType: self.type,
        kMRKeyIdentifier : self.identifier ?: @"",
        kMRKeyAccessToken: self.accessToken ?: @"",
        kMRKeyRefreshToken: self.refreshToken ?: @"",
        kMRKeyFirstName: self.firstName ?: @"",
        kMRKeyLastName: self.lastName ?: @"",
        kMRKeyEmail: self.email ?: @"",
        kMRKeyAvatar: self.avatar ?: @"",
        kMRKeySex: [self sexString]
    } mutableCopy];

    if (self.birthDate) {
        result[kMRKeyBirthDate] = [[MRSocialHelper dateFormatter] stringFromDate:self.birthDate];
    }
    return result;
}

+ (instancetype)unmarshal:(NSDictionary *)dictionary {
    if (![dictionary[kMRKeyVersion] isEqualToString:kMRAccountInfoVersion]) {
        return nil;
    }

    MRSocialAccountInfo *account = [MRSocialAccountInfo new];

    account->_type = dictionary[kMRKeyType];
    account.identifier = dictionary[kMRKeyIdentifier];
    account.accessToken = dictionary[kMRKeyAccessToken];
    account.refreshToken = dictionary[kMRKeyRefreshToken];
    account.firstName = dictionary[kMRKeyFirstName];
    account.lastName = dictionary[kMRKeyLastName];
    account.email = dictionary[kMRKeyEmail];
    account.avatar = dictionary[kMRKeyAvatar];

    account.sex = [self sexFromString:dictionary[kMRKeySex]];
    NSString *dateString = dictionary[kMRKeyBirthDate];
    if (dateString) {
        account.birthDate = [[MRSocialHelper dateFormatter] dateFromString:dateString];
    }
    return account;
}

+ (MRAccountSex)sexFromString:(NSString *)source {
    if ([source isEqualToString:kMRSexMan]) {
        return MRAccountSexMan;
    } else if ([source isEqualToString:kMRSexWoman]) {
        return MRAccountSexWoman;
    } else {
        return MRAccountSexUndefined;
    }
}

- (NSString *)sexString {
    switch (self.sex) {
        case MRAccountSexUndefined:
            return kMRSexUndefined;
        case MRAccountSexMan:
            return kMRSexMan;
        case MRAccountSexWoman:
            return kMRSexWoman;
    }
    return self.sex == MRAccountSexMan ? kMRSexMan : kMRSexWoman;
}
- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.type=%@", self.type];
    [description appendFormat:@", self.identifier=%@", self.identifier];
    [description appendFormat:@", self.accessToken=%@", self.accessToken];
    [description appendFormat:@", self.refreshToken=%@", self.refreshToken];
    [description appendFormat:@", self.firstName=%@", self.firstName];
    [description appendFormat:@", self.lastName=%@", self.lastName];
    [description appendFormat:@", self.sex=%@", [self sexString]];
    [description appendFormat:@", self.email=%@", self.email];
    [description appendFormat:@", self.avatar=%@", self.avatar];
    [description appendFormat:@", self.birthDate=%@", self.birthDate];
    [description appendString:@">"];
    return description;
}


@end