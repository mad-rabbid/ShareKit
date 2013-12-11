#import <Foundation/Foundation.h>
#import "ECComposeSupport.h"

@class ECComposeViewController;

typedef enum {
    ECComposeResultCancelled,
    ECComposeResultPosted
} ECComposeResult;

typedef void (^ECComposeViewControllerCompletionBlock)(ECComposeViewController *composeViewController, ECComposeResult result);

@interface ECComposeViewController : UIViewController<ECComposeSupport>

@property (nonatomic, copy) ECComposeViewControllerCompletionBlock completionBlock;

- (void)presentFromRootViewController;
- (void)presentFromViewController:(UIViewController *)controller;

@end