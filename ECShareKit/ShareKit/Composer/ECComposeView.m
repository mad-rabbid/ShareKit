#import "ECComposeView.h"
#import "ECUserInterface.h"
#import "ECComposeTextView.h"

#define kECNavigationBarHeight 44.0
#define kECImageDimension 72.0
#define kECTextViewVerticalOffset 3.0

@interface ECComposeView ()
@property (nonatomic, weak, readonly) UINavigationItem *navigationItem;

@property (nonatomic, weak, readonly) UINavigationBar *navigationBar;
@property (nonatomic, weak, readonly) UIView *textViewContainer;
@property (nonatomic, weak, readonly) UIImageView *imageView;
@property (nonatomic, weak, readonly) ECComposeTextView *textView;
@end

@implementation ECComposeView {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        BOOL isFlatMode = [ECUserInterface isFlatDesign];

        UINavigationBar *navigationBar = [self createNavigationBarWithFrame:frame];
        _navigationBar = navigationBar;

        UIView *textViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(navigationBar.frame), frame.size.width - (isFlatMode ? 20 : 0), frame.size.height - CGRectGetMaxY(navigationBar.frame))];
        _textViewContainer = textViewContainer;

        textViewContainer.clipsToBounds = YES;
        textViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        ECComposeTextView *textView = [[ECComposeTextView alloc] initWithFrame:CGRectZero];
        textView.backgroundColor = [UIColor clearColor];
        textView.font = [UIFont systemFontOfSize:isFlatMode ? 17 : 21];
        textView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
        textView.bounces = YES;

        [textViewContainer addSubview:textView];
        _textView = textView;

        [self addSubview:textViewContainer];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - kECImageDimension, 54, kECImageDimension, kECImageDimension)];
        _imageView = imageView;

        if (!isFlatMode) {
            imageView.layer.cornerRadius = 3.0f;
            imageView.layer.shadowColor = [UIColor blackColor].CGColor;
            imageView.layer.shadowOffset = CGSizeMake(1, 1);
            imageView.layer.shadowOpacity = 0.8;
            imageView.layer.shadowRadius = 1.5;
            imageView.layer.masksToBounds = NO;
        } else {
            imageView.layer.masksToBounds = YES;
        }
        [self addSubview:imageView];
        [self addSubview:navigationBar];
    }
    return self;
}

- (UINavigationBar *)createNavigationBarWithFrame:(CGRect)frame {
    BOOL isFlatMode = [ECUserInterface isFlatDesign];

    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, kECNavigationBarHeight)];
    navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;

    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@""];
    navigationBar.items = @[navigationItem];

    _navigationItem = navigationItem;

    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed)];

    UIBarButtonItem *postButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Post", nil) style:isFlatMode ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered target:self action:@selector(postButtonPressed)];

    if (!isFlatMode) {
        _navigationItem.leftBarButtonItem = cancelButtonItem;
        _navigationItem.rightBarButtonItem = postButtonItem;
    } else {
        _navigationItem.leftBarButtonItems = @[[self createSeperator], cancelButtonItem];
        _navigationItem.rightBarButtonItems = @[[self createSeperator], postButtonItem];
    }

    return navigationBar;
}


- (UIBarButtonItem *)createSeperator {
    UIBarButtonItem *seperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    seperator.width = 5.0;
    return seperator;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_delegate) {
        UIViewController *delegate = _delegate;
        _navigationItem.title = delegate.title;
    }


    [self.navigationBar sizeToFit];

    BOOL hasImage = self.imageView.image != nil;
    self.imageView.hidden = !hasImage;

    CGFloat imageOffset = [ECUserInterface isFlatDesign] ? 4 : 4;
    CGRect frame = self.imageView.frame;
    frame.origin.x = self.frame.size.width - kECImageDimension - imageOffset;
    frame.origin.y = self.navigationBar.frame.size.height + 10;
    self.imageView.frame = frame;

    frame = self.textViewContainer.frame;
    frame.origin.y = CGRectGetMaxY(self.navigationBar.frame);
    frame.size.height = self.frame.size.height - frame.origin.y;
    self.textViewContainer.frame = frame;

    frame = self.textView.frame;
    frame.origin.x = [ECUserInterface isFlatDesign] ? 8 : 0;
    frame.origin.y = kECTextViewVerticalOffset;

    frame.size.width = !hasImage ? self.frame.size.width : self.imageView.frame.origin.x;
    frame.size.width -= [ECUserInterface isFlatDesign] ? 14 : 0;

    frame.size.height = self.textViewContainer.frame.size.height - kECTextViewVerticalOffset * 2;
    self.textView.frame = frame;
    self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, hasImage ? -(kECImageDimension + 1) : 0);


}

- (void)cancelButtonPressed {
    id <ECComposeViewDelegate> localDelegate = _delegate;
    if ([localDelegate respondsToSelector:@selector(cancelButtonPressed)]) {
        [localDelegate cancelButtonPressed];
    }
}

- (void)postButtonPressed {
    id <ECComposeViewDelegate> localDelegate = _delegate;
    if ([localDelegate respondsToSelector:@selector(postButtonPressed)]) {
        [localDelegate postButtonPressed];
    }
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    [self setNeedsLayout];
}

- (void)setText:(NSString *)text {
    self.textView.text = text;
}

- (void)setPlaceholder:(NSString *)placeholder {
    self.textView.placeholder = placeholder;
}

- (BOOL)isFirstResponder {
    return [self.textView isFirstResponder];
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    return [self.textView resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
    return [self.textView becomeFirstResponder];
}

@end