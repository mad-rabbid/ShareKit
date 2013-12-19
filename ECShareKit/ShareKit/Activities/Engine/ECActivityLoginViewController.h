#import <Foundation/Foundation.h>

@class ECActivity;

typedef void (^ECActivityLoginViewControllerBlock)(BOOL isLoggedIn);

@interface ECActivityLoginViewController : UIViewController

@property (nonatomic, copy) ECActivityLoginViewControllerBlock completionBlock;

+ (void)presentFormViewController:(UIViewController *)controller withActivity:(ECActivity *)activity completionBlock:(ECActivityLoginViewControllerBlock)completionBlock;
@end