#import "ECComposeBackgroundView.h"
#import "ECUserInterface.h"


@implementation ECComposeBackgroundView {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    if ([ECUserInterface isFlatDesign]) {
        return;
    }

    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    if (!CGSizeEqualToSize(self.centerOffset, CGSizeZero)) {
        center.x += self.centerOffset.width;
        center.y += self.centerOffset.height;
    }

    CGContextRef currentContext = UIGraphicsGetCurrentContext();

    size_t locationsNumber = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 0.0, 0.0, 0.0, 0.7, 0.0, 0.0, 0.0, 0.85 };

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, locationsNumber);
    CGGradientDrawingOptions options = kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation;
    CGFloat endRadius = [UIApplication sharedApplication].keyWindow.bounds.size.height / 2;
    CGContextDrawRadialGradient(currentContext, gradient, center, 20.0f, center, endRadius, options);

    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)setCenterOffset:(CGSize)offset {
    if (!CGSizeEqualToSize(_centerOffset, offset)) {
        _centerOffset = offset;
        [self setNeedsDisplay];
    }
}
@end