#import <Foundation/Foundation.h>

@class ECActivity;


@interface ECActivityView : UIView

@property (nonatomic, strong) NSArray *activities;
@property (nonatomic, copy) void (^performActivityBlock)(ECActivity *activity);

+ (CGFloat)activityViewHeight;

- (void)setTitle:(NSString *)title;
@end