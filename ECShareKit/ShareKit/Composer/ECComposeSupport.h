#import <Foundation/Foundation.h>

@protocol ECComposeSupport <NSObject>

- (void)setImage:(UIImage *)image;
- (void)setText:(NSString *)text;
- (void)setPlaceholder:(NSString *)placeholder;
- (void)setImageUrl:(NSString *)imageUrl;

@end