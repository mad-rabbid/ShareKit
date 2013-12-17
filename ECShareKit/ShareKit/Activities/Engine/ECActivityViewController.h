#import <Foundation/Foundation.h>


@interface ECActivityViewController : UIViewController

- (id)initWithActivities:(NSArray *)activities;

- (void)presentFromRootViewController;

- (void)presentFromViewController:(UIViewController *)controller;
@end