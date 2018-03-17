//
//  SFPViewController.m
//  SharkFood
//
//  Created by Christopher Taylor on 3/16/18.
//  Copyright © 2018 Christopher Taylor. All rights reserved.
//

#import "SFPViewController.h"

const CGFloat kLineSpacing = 2;
const CGFloat kInterItemSpacing = 2;

@interface SFPViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *contentArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation SFPViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat headerHeight = 80;
    self.collectionView.frame = CGRectMake(0, headerHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - headerHeight);
}


#pragma mark - Accessors

- (NSArray *)contentArray {
    if (!_contentArray){
        _contentArray = [NSArray array];
    }
    return _contentArray;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = kLineSpacing;
        layout.minimumInteritemSpacing = kInterItemSpacing;
        CGFloat itemSize = ([UIScreen mainScreen].bounds.size.width - (3 * kInterItemSpacing)) / 3;
        layout.itemSize = CGSizeMake(itemSize, itemSize);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor colorWithWhite:157.0f/255.0f alpha:1.0f];
        _collectionView.refreshControl = self.refreshControl;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    }
    return _collectionView;
}

- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refreshContent) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20; //self.contentArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"index path item %i",(int)indexPath.item);
}


#pragma mark - Private

- (void)reloadData {
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.refreshControl endRefreshing];
        [self.collectionView reloadData];
    });
}

- (void)refreshContent {
    //TODO: actually refresh the content
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:2];
}


@end
