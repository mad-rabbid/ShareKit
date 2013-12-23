#import "ECActivityView.h"
#import "ECActivityCell.h"
#import "MRSocialAccountManager.h"
#import "ECActivity.h"
#import "ECComposeViewController.h"
#import "MRSocialProvidersFactory.h"
#import "MRSocialLogging.h"

static CGFloat kECCellDimension = 76;
static CGFloat kECTitleHeight = 40;
static CGFloat kECSpacing = 10;
static CGFloat kECStrokeLineHeight = 1.0;

static NSString *const kECCellIdentifier = @"cellIdentifier";

@interface ECActivityView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UILabel *labelTitle;
@end

@implementation ECActivityView {

}

+ (CGFloat)activityViewHeight {
    return kECCellDimension + kECTitleHeight + kECStrokeLineHeight + 2 * kECSpacing;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupControl];
        [self setupMenu];
    }
    return self;
}

- (void)setupControl {
    self.backgroundColor = [UIColor whiteColor];

    [self createTitleView];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:kECSpacing];
    [flowLayout setMinimumLineSpacing:kECSpacing];
    [flowLayout setSectionInset:UIEdgeInsetsMake(kECSpacing, kECSpacing, kECSpacing, kECSpacing)];

    CGRect frame = (CGRect) {
        .origin.y = CGRectGetMaxY(self.labelTitle.frame),
        .size.width = self.bounds.size.width,
        .size.height = self.bounds.size.height - CGRectGetMaxY(self.labelTitle.frame),
    };
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    _collectionView = collectionView;

    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[ECActivityCell class] forCellWithReuseIdentifier:kECCellIdentifier];
    [self addSubview:collectionView];
}

- (void)createTitleView {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, kECStrokeLineHeight, self.bounds.size.width, kECTitleHeight)];
    label.backgroundColor = [UIColor colorWithWhite:239.0 / 255.0 alpha:1.0];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
    label.textColor = [UIColor darkGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    _labelTitle = label;
}

- (void)setupMenu {
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Выйти", nil) action:@selector(customAction:)];
    [UIMenuController sharedMenuController].menuItems = @[menuItem];
}

- (void)setTitle:(NSString *)title {
    self.labelTitle.text = title;
}

- (void)setActivities:(NSArray *)activities {
    _activities = activities;
    [self setNeedsDisplay];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.activities.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ECActivityCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kECCellIdentifier forIndexPath:indexPath];

    ECActivity *activity = self.activities[indexPath.row];
    cell.activity = activity;
    cell.loggedIn = [[MRSocialAccountManager sharedInstance] isLoggedInWithType:activity.activityType];

    __weak typeof(self) myself = self;
    cell.actionBlock = ^(ECActivity *current) {
        [myself logoutWithActivity:current];
    };
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kECCellDimension, kECCellDimension);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    ECActivity *activity = self.activities[indexPath.row];
    return [[MRSocialAccountManager sharedInstance] isLoggedInWithType:activity.activityType];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(customAction:);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ECActivity *activity = self.activities[indexPath.row];
    [self performActivity:activity];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    NSLog(@"!!!!");
}

- (void)performActivity:(ECActivity *)activity {
    if (self.performActivityBlock) {
        self.performActivityBlock(activity);
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextSetLineWidth(context, kECStrokeLineHeight);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);
}

- (void)reload {
    [self.collectionView reloadData];
}

- (void)logoutWithActivity:(ECActivity *)activity {
    MRLog(@"Logging out from an activity with type: %@", activity.activityType);
    [[MRSocialAccountManager sharedInstance] removeAccountWithType:activity.activityType];
    [self reload];
}
@end