#import "ECUserInterface.h"


@implementation ECUserInterface {

}

+ (BOOL)isFlatDesign {
    return UIDevice.currentDevice.systemVersion.floatValue >= 7.0;
}

@end