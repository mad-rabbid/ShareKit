#import <Foundation/Foundation.h>

@protocol ECActivityViewControllerDelegate;


@interface ECActivityViewController : UIViewController

@property (nonatomic, weak) id<ECActivityViewControllerDelegate> delegate;

- (id)initWithActivities:(NSArray *)activities;

- (void)presentFromRootViewController;

- (void)presentFromViewController:(UIViewController *)controller;
@end


@protocol ECActivityViewControllerDelegate<NSObject>
@optional
- (NSDictionary *)activityViewControllerShareInfo:(ECActivityViewController *)activityViewController;
@end