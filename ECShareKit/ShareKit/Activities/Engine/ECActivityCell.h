#import <Foundation/Foundation.h>

@class ECActivity;


@interface ECActivityCell : UICollectionViewCell

@property (nonatomic, copy) void (^actionBlock)(ECActivity *activity);
@property (nonatomic, assign) BOOL loggedIn;

- (void)setActivity:(ECActivity *)activity;
@end