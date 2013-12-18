#import "ECActivityView.h"
#import "ECActivityCell.h"

static CGFloat kECCellDimension = 76;
static NSString *const kECCellIdentifier = @"cellIdentifier";

@interface ECActivityView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, weak) UICollectionView *collectionView;
@end

@implementation ECActivityView {

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
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    _collectionView = collectionView;

    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[ECActivityCell class] forCellWithReuseIdentifier:kECCellIdentifier];
    [self addSubview:collectionView];
}

- (void)setupMenu {
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Выйти", nil) action:@selector(customAction:)];
    [UIMenuController sharedMenuController].menuItems = @[menuItem];
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

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kECCellDimension, kECCellDimension);
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {

}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Check if a user is logged in into an account at indexPath and then return YES;
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(customAction:);
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {

}

@end