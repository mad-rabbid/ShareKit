#import <Foundation/Foundation.h>
#import "ECComposeSupport.h"

@protocol ECComposeViewDelegate;


@interface ECComposeView : UIView<ECComposeSupport>

@property (nonatomic, weak) UIViewController<ECComposeViewDelegate> *delegate;


@end

@protocol ECComposeViewDelegate <NSObject>
- (void)cancelButtonPressed;
- (void)postButtonPressed;
@end