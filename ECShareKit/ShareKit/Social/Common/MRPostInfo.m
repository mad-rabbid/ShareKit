#import "MRPostInfo.h"


@implementation MRPostInfo {

}

- (id)initWithMessage:(NSString *)message pictureUrl:(NSString *)pictureUrl image:(UIImage *)image {
    self = [super init];
    if (self) {
        _message = message;
        _pictureUrl = pictureUrl;
        _image = image;
    }
    return self;
}

@end