#import <Foundation/Foundation.h>


@interface MRPostInfo : NSObject

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *pictureUrl;
@property (nonatomic, strong) UIImage *image;

- (id)initWithMessage:(NSString *)message pictureUrl:(NSString *)pictureUrl image:(UIImage *)image;

@end