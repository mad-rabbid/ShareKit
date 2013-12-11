#import "ECAppDelegate.h"
#import "ECDemoViewController.h"

@implementation ECAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [ECDemoViewController new];
    [self.window makeKeyAndVisible];
    return YES;
}

@end