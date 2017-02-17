/*
 OLEContainerScrollView
 
 Copyright (c) 2014 Ole Begemann.
 https://github.com/ole/OLEContainerScrollView
 */

#import "MultipleCollectionsViewController.h"
#import "JHSContainerScrollView.h"

@interface MultipleCollectionsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) JHSContainerScrollView *containerScrollView;
@property (nonatomic) NSMutableArray *collectionViews;
@property (nonatomic) NSMutableArray *numberOfItemsPerCollectionView;
@property (nonatomic) NSMutableArray *cellColorPerCollectionView;

@end

@implementation MultipleCollectionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    
    [self.view addSubview:self.containerScrollView];
    
    NSInteger numberOfCollectionViews = 1;
    self.collectionViews = [NSMutableArray new];
    self.numberOfItemsPerCollectionView = [NSMutableArray new];
    self.cellColorPerCollectionView = [NSMutableArray new];
    
//    for (NSInteger collectionViewIndex = 0; collectionViewIndex < numberOfCollectionViews; collectionViewIndex++) {
//        UIView *collectionView = [self preconfiguredCollectionView];
//        NSInteger randomNumberOfItemsInCollectionView = 0; //arc4random_uniform(50) + 10;
//        [self.collectionViews addObject:collectionView];
//        [self.numberOfItemsPerCollectionView addObject:@(randomNumberOfItemsInCollectionView)];
//        [self.cellColorPerCollectionView addObject:[UIColor colorWithHue:arc4random_uniform(256)/255.0 saturation:1.0 brightness:1.0 alpha:1.0]];
//        [self.containerScrollView.contentView addSubview:collectionView];
//    }
//    
    
    UIView *view  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 100)];
    [view setBackgroundColor:[UIColor redColor]];
    [self.containerScrollView.contentView addSubview:view];
    
//    [self performSelector:@selector(preconfiguredCollectionView) withObject:nil afterDelay:5];
}

- (void)preconfiguredCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"MyCell"];
    collectionView.backgroundColor = [UIColor whiteColor];
    
    [[self.containerScrollView.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.containerScrollView.contentView addSubview:collectionView];
}


- (JHSContainerScrollView *)containerScrollView
{
    if (nil == _containerScrollView) {
        _containerScrollView = [[JHSContainerScrollView alloc] initWithFrame:self.view.bounds];
        [_containerScrollView setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height + 100)];
        [_containerScrollView setAlwaysBounceVertical:YES];
        [_containerScrollView setDelegate:self];
        [_containerScrollView setSpaceHeaderHeight:380];
    }
    
    return _containerScrollView;
}

#pragma mark - UICollectionViewDataSource


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCell" forIndexPath:indexPath];
    NSUInteger collectionViewIndex = [self.collectionViews indexOfObject:collectionView];
    UIColor *cellColor = [UIColor redColor];
    cell.backgroundColor = cellColor;
    return cell;
}

@end
