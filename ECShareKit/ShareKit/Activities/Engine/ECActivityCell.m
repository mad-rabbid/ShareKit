#import "ECActivityCell.h"
#import "ECActivity.h"

@interface ECActivityCell ()
@property (nonatomic, weak, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) ECActivity *activity;
@end

@implementation ECActivityCell {
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCell];
    }

    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.activity = nil;
    self.actionBlock = nil;
    self.imageView.image = nil;
}

- (void)setupCell {
    self.backgroundColor = UIColor.clearColor;

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:imageView];
    _imageView = imageView;
}

- (void)setLoggedIn:(BOOL)loggedIn {
    _loggedIn = loggedIn;
    [self updateImageAlpha];
}

- (void)setActivity:(ECActivity *)activity {
    _activity = activity;
    [self.imageView setImage:activity.activityImage];
}

- (void)updateImageAlpha {
    self.imageView.alpha = self.highlighted ? 0.7 : (self.loggedIn ? 1.0 : 0.8);
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self updateImageAlpha];
}

- (void)customAction:(id)sender {
    NSLog(@"Hello");

    if (self.actionBlock) {
        self.actionBlock(self.activity);
    }
}
@end