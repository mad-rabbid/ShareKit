#import "MRPostInfo.h"


@implementation MRPostInfo {

}

- (id)initWithMessage:(NSString *)message pictureUrl:(NSString *)pictureUrl {
    self = [super init];
    if (self) {
        _message = message;
        _pictureUrl = pictureUrl;
    }
    return self;
}

@end