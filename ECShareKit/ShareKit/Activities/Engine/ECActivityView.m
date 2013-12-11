#import "ECActivityView.h"

@interface ECActivityView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, weak) UICollectionView *collectionView;
@end

@implementation ECActivityView {

}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

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
    [collectionView registerClass:[CVGGallleryCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self addSubview:collectionView];
}

- (void)setActivities:(NSArray *)activities {
    _activities = activities;
    [self setNeedsDisplay];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end