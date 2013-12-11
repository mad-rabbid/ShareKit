#import "ECComposeRuledView.h"
#import "ECUserInterface.h"


@implementation ECComposeRuledView {
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupControl];
    }

    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupControl];
    }

    return self;
}


- (void)setupControl {
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeRedraw;
    self.userInteractionEnabled = NO;

    _rowHeight = 20.0f;
    _lineWidth = 1.0f;
    _lineColor = [UIColor colorWithWhite:0.5f alpha:0.15f];
}

- (void)drawRect:(CGRect)rect {
    if ([ECUserInterface isFlatDesign]) {
        return;
    }

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineWidth(context, self.lineWidth);
    CGFloat strokeOffset = (self.lineWidth / 2);

    if (self.rowHeight) {
        CGRect rowRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, self.rowHeight);

        for (NSInteger rowNumber = 1; rowRect.origin.y < self.frame.size.height + 100.0f; rowNumber++) {
            CGContextMoveToPoint(context, rowRect.origin.x + strokeOffset, rowRect.origin.y + strokeOffset);
            CGContextAddLineToPoint(context, rowRect.origin.x + rowRect.size.width + strokeOffset, rowRect.origin.y + strokeOffset);
            CGContextDrawPath(context, kCGPathStroke);

            rowRect.origin.y += self.rowHeight;
        }
    }
}

@end