#import <Foundation/Foundation.h>


@interface MRPostInfo : NSObject

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *pictureUrl;

- (id)initWithMessage:(NSString *)message pictureUrl:(NSString *)pictureUrl;

@end