#import "ECComposeTextView.h"
#import "ECComposeRuledView.h"
#import "ECUserInterface.h"

#define kECPlaceholderLabelTag 0xbeaf

@interface ECComposeTextView ()
@property (nonatomic, weak, readonly) ECComposeRuledView *ruledView;
@end

@implementation ECComposeTextView {
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    self.clipsToBounds = NO;

    ECComposeRuledView *ruledView = [[ECComposeRuledView alloc] initWithFrame:[self ruledViewFrame]];
    ruledView.lineColor = [UIColor colorWithWhite:0.5f alpha:0.15f];
    ruledView.lineWidth = 1.0f;
    ruledView.rowHeight = self.font.lineHeight;
    [self insertSubview:ruledView atIndex:0];
    _ruledView = ruledView;

    [self setPlaceholder:@""];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

#pragma mark - Superclass Overrides

- (void)layoutSubviews {
    [super layoutSubviews];
    self.ruledView.frame = [self ruledViewFrame];
}


- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    self.ruledView.frame = [self ruledViewFrame];
}


- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.ruledView.rowHeight = self.font.lineHeight;
}


#pragma mark - Private

- (CGRect)ruledViewFrame {
    CGFloat extraForBounce = 200.0f;  // Extra added to top and bottom so it's visible when the user drags past the bounds.
    CGFloat width = 1024.0f;  // Needs to be at least as wide as we might make the Tweet sheet.
    CGFloat textAlignmentOffset = -2.0f;  // To center the text between the lines. May want to find a way to determine this procedurally eventually.

    return CGRectMake(0.0f, -extraForBounce + textAlignmentOffset, width, self.contentSize.height + (2 * extraForBounce));
}


#pragma mark - Placeholder Text

- (void)textChanged:(NSNotification *)notification {
    if (!self.placeholder.length) {
        return;
    }

    [[self viewWithTag:kECPlaceholderLabelTag] setAlpha:!self.text.length ? 1.0 : 0.0];
}


- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}


- (void)drawRect:(CGRect)rect {
    if (self.placeholder.length) {
        UILabel *label = (UILabel *)[self viewWithTag:kECPlaceholderLabelTag];
        if (!label) {
            label = [[UILabel alloc] initWithFrame:CGRectMake([ECUserInterface isFlatDesign] ? 5 : 8, 8, self.bounds.size.width - 16, 0)];
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.numberOfLines = 0;
            label.font = self.font;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor lightGrayColor];
            label.alpha = 0;
            label.tag = kECPlaceholderLabelTag;
            [self addSubview:label];
        }

        label.text = self.placeholder;
        [label sizeToFit];
        [self sendSubviewToBack:label];
    }

    [[self viewWithTag:kECPlaceholderLabelTag] setAlpha:(!self.text.length && self.placeholder.length) ? 1.0 : 0.0];
    [super drawRect:rect];
}
@end