//
//  SFPViewController.m
//  SharkFood
//
//  Created by Christopher Taylor on 3/16/18.
//  Copyright © 2018 Christopher Taylor. All rights reserved.
//

#import "SFPViewController.h"

//model
#import "SFPMasterPhoto.h"

//view
#import "SFPThumbnailCollectionViewCell.h"

//manager
#import "SFPContentManager.h"


const CGFloat kLineSpacing = 2;
const CGFloat kInterItemSpacing = 2;

@interface SFPViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *contentArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isFetchingContent;

@end

@implementation SFPViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    self.currentPage = 1;
    [self refreshContent];
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
        _collectionView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 10.0, *)) {
            _collectionView.refreshControl = self.refreshControl;
        } else {
            [_collectionView addSubview:self.refreshControl];
        }
        [_collectionView registerClass:[SFPThumbnailCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([SFPThumbnailCollectionViewCell class])];
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
    return self.contentArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SFPThumbnailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SFPThumbnailCollectionViewCell class]) forIndexPath:indexPath];
    SFPMasterPhoto *mPhoto = self.contentArray[indexPath.item];
    [cell configureWithPhoto:mPhoto.thumbnail];
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SFPMasterPhoto *mPhoto = self.contentArray[indexPath.item];
    // TODO: IMPLEMENT LIGHTBOX (!) & TRANSITION ANIMATION (?)
    NSLog(@"item title %@",mPhoto.title);
    // NSLog(@"item id %@",mPhoto.remoteId);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // lazily trigger fetch of upcoming content as user scrolls towards bottom of existing content
    if (self.collectionView.isTracking) {
        if (self.collectionView.contentOffset.y >= self.collectionView.contentSize.height - 3 * self.collectionView.frame.size.height && self.collectionView.contentSize.height > 0) {
            [self refreshContent];
        }
    }
}


#pragma mark - Private

- (void)refreshContent {
    
    if (!self.isFetchingContent) {
        self.isFetchingContent = YES;
        __weak typeof(self) weakSelf = self;
         [[SFPContentManager sharedManager] contentForPage:self.currentPage completion:^(NSError *error, NSArray *contentArray) {
            if (weakSelf) {
               
                //TODO: add error handling

                //append any fresh content
                if (!error && contentArray.count > 0) {

                    //increment our page
                    weakSelf.currentPage = weakSelf.currentPage + 1;
                    
                    // Update our collection view on the main thread
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        
                        // note our current count for our batch update
                        NSInteger previousSection0Count = [weakSelf collectionView:weakSelf.collectionView numberOfItemsInSection:0];
                        
                        // update the collection view data source
                        weakSelf.contentArray = [weakSelf.contentArray arrayByAddingObjectsFromArray:contentArray];
                        NSInteger section0Count = weakSelf.contentArray.count;
                        
                        // insert our newly fetched content into our collection view
                        void (^sectionUpdateBlock)(NSUInteger section, NSUInteger previousPhotoCount, NSUInteger photoCount) = ^void(NSUInteger section, NSUInteger previousPhotoCount, NSUInteger photoCount) {
                            if (previousPhotoCount != photoCount) {
                                NSMutableArray *newIndexPaths = [NSMutableArray array];
                                for (NSUInteger index = previousPhotoCount; index < photoCount; ++index) {
                                    [newIndexPaths addObject:[NSIndexPath indexPathForItem:index inSection:section]];
                                }
                                [weakSelf.collectionView insertItemsAtIndexPaths:newIndexPaths];
                            }
                        };
                        // perform the batch update to our collection view
                        [weakSelf.collectionView performBatchUpdates:^{
                            sectionUpdateBlock(0, previousSection0Count, section0Count);
                        } completion:nil];
                     });
                }
                
                // finish up
                dispatch_async(dispatch_get_main_queue(), ^(){
                    weakSelf.isFetchingContent = NO;
                    [weakSelf.refreshControl endRefreshing];
                });
            }
        }];
    }
}



@end
