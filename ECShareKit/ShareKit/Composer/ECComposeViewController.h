#import <Foundation/Foundation.h>
#import "ECComposeSupport.h"

@class ECComposeViewController;
@class ECActivity;

typedef enum {
    ECComposeResultCancelled,
    ECComposeResultPosted,
    ECComposeResultError
} ECComposeResult;

typedef void (^ECComposeViewControllerCompletionBlock)(ECComposeViewController *composeViewController, ECComposeResult result);

@interface ECComposeViewController : UIViewController<ECComposeSupport>

@property (nonatomic, copy) ECComposeViewControllerCompletionBlock completionBlock;
@property (nonatomic, strong) ECActivity *activity;

- (void)showSpinner;

- (void)hideSpinner;

- (void)presentFromRootViewController;
- (void)presentFromViewController:(UIViewController *)controller;

@end