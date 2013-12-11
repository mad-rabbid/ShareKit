#import <Foundation/Foundation.h>

typedef enum {
    MRAccountSexUndefined,
    MRAccountSexMan,
    MRAccountSexWoman
} MRAccountSex;

@interface MRSocialAccountInfo : NSObject

@property (nonatomic, strong, readonly) NSString *type;
@property (nonatomic, strong) NSString *identifier;

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, assign) MRAccountSex sex;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSDate *birthDate;

- (id)initWithType:(NSString *)type accessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken;

- (NSDictionary *)marshal;
+ (instancetype)unmarshal:(NSDictionary *)dictionary;
@end