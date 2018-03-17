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

//controller
#import "SFPLightBoxViewController.h"

@interface SFPViewController () <UICollectionViewDelegate, UICollectionViewDataSource, SFPLightBoxViewControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSArray *contentArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isFetchingContent;
@property (weak, nonatomic) IBOutlet UIImageView *oceanImageView;
@property (weak, nonatomic) IBOutlet UIView *logoContainerView;
@property (weak, nonatomic) IBOutlet UILabel *swipePrompt;
@property (weak, nonatomic) IBOutlet UIView *ptrContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *fishImage;
@property (weak, nonatomic) IBOutlet UIImageView *hookImageView;
@property (weak, nonatomic) IBOutlet UIImageView *gridHeader;
@property (nonatomic, assign) CGFloat bobble;
@property (nonatomic, strong) SFPLightBoxViewController *lightBoxViewController;
@property (nonatomic, assign) CGPoint swipeStartPoint;

@end

@implementation SFPViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view insertSubview:self.collectionView belowSubview:self.oceanImageView];
    self.currentPage = 1;
    [self refreshContent];
    self.lightBoxViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(isPanningAtStart:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self.oceanImageView addGestureRecognizer:panRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Layout

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.collectionView.frame = CGRectMake(0, CGRectGetMaxY(self.gridHeader.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.gridHeader.frame));
    CGFloat inset = [self needsIphoneXInsetAdjustment] ?  40 : 20;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(inset, inset, 0, inset);
    self.oceanImageView.frame = self.view.bounds;
}


#pragma mark - Accessors

- (NSArray *)contentArray {
    if (!_contentArray){
        _contentArray = [NSArray array];
    }
    return _contentArray;
}

- (SFPLightBoxViewController *)lightBoxViewController {
    if (!_lightBoxViewController) {
        _lightBoxViewController = [[SFPLightBoxViewController  alloc] init];
        _lightBoxViewController.delegate = self;
    }
    return _lightBoxViewController;
}

- (BOOL)needsIphoneXInsetAdjustment {
    return ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) &&
           (((int)[[UIScreen mainScreen] nativeBounds].size.height) == 2436) &&
        [UIScreen mainScreen].bounds.size.width >  [UIScreen mainScreen].bounds.size.height;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat inset = [self needsIphoneXInsetAdjustment] ?  40 : 20;
        CGFloat minSpacing = 8;
        self.flowLayout.sectionInset = UIEdgeInsetsMake(inset, inset, 0, inset);
        self.flowLayout.minimumLineSpacing = minSpacing;
        self.flowLayout.minimumInteritemSpacing = minSpacing;

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
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
        _refreshControl.tintColor = [UIColor clearColor];
        [_refreshControl addTarget:self action:@selector(beginPullToRefresh) forControlEvents:UIControlEventValueChanged];
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
    [self.lightBoxViewController configureWithSPCPhoto:mPhoto];
    [self presentViewController:self.lightBoxViewController animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // lazily trigger fetch of upcoming content as user scrolls towards bottom of existing content
    if (self.collectionView.isTracking) {
        if (self.collectionView.contentOffset.y >= self.collectionView.contentSize.height - 3 * self.collectionView.frame.size.height && self.collectionView.contentSize.height > 0) {
            [self refreshContent];
        }
    }
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat inset = [self needsIphoneXInsetAdjustment] ?  40 : 20;
    CGFloat minSpacing = 8;
    NSInteger numColumnns = [UIScreen mainScreen].bounds.size.width <  [UIScreen mainScreen].bounds.size.height ? 3 : 5;
    CGFloat contentSize = [UIScreen mainScreen].bounds.size.width - (2 * inset) - (numColumnns * minSpacing);
    CGFloat itemSize = round(contentSize / numColumnns);
    return CGSizeMake(itemSize, itemSize);
}


#pragma mark - SFPLightBoxViewControllerDelegate

- (void)dismiss:(SFPLightBoxViewController *)lightBoxVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

-(void)isPanningAtStart:(UIPanGestureRecognizer*)panGR {

        if (panGR.state == UIGestureRecognizerStateBegan) {
            self.swipeStartPoint = [panGR translationInView:self.oceanImageView];
        }
        else if (panGR.state == UIGestureRecognizerStateChanged) {
            CGPoint currPoint = [panGR translationInView:self.oceanImageView];
            float deltaX = fabs(self.swipeStartPoint.x - currPoint.x);
            float requiredDelta = CGRectGetWidth(self.view.frame) * 0.6f;
            float swipeAlpha = 1 - (deltaX / requiredDelta);
            if (deltaX > 0) {
                self.oceanImageView.alpha = swipeAlpha;
                self.logoContainerView.alpha = swipeAlpha;
                self.swipePrompt.alpha = swipeAlpha;
            }
        }
        if (panGR.state == UIGestureRecognizerStateEnded) {
            CGPoint endPoint = [panGR translationInView:self.oceanImageView];
            float deltaX = fabs(self.swipeStartPoint.x - endPoint.x);
            float endAlpha = deltaX < 70 ? 1 : 0;
            self.oceanImageView.alpha = endAlpha;
            self.logoContainerView.alpha = endAlpha;
            self.swipePrompt.alpha = endAlpha;
            if (endAlpha == 0) {
                self.oceanImageView.userInteractionEnabled = false;
            }
        }
}

- (void)beginPullToRefresh {
    self.ptrContainerView.alpha = 1;
    self.bobble = .1;
    [self.view bringSubviewToFront:self.collectionView];
    [self animatePTR];
    [self refreshContent];
}

- (void)endPullToRefresh {
    self.ptrContainerView.alpha = 0;
    [self.refreshControl endRefreshing];
}

-(void)animatePTR {
    
    self.bobble = -1 * self.bobble;
    dispatch_async(dispatch_get_main_queue(), ^(){
         [UIView animateWithDuration:.1 animations:^{
             self.hookImageView.center = CGPointMake(self.hookImageView.center.x, self.hookImageView.center.y + 10 * self.bobble);
             self.fishImage.transform = CGAffineTransformMakeRotation(self.bobble);
         } completion:^(BOOL finished) {
              if (self.isFetchingContent) {
                  [self animatePTR];
              }
          }];
    });
}

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
                    [weakSelf endPullToRefresh];

                });
            }
        }];
    }
}



@end
