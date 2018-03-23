//
//  SFPThumbnailCollectionViewCell.m
//  SharkFood
//
//  Created by Christopher Taylor on 3/16/18.
//  Copyright © 2018 Christopher Taylor. All rights reserved.
//

#import "SFPThumbnailCollectionViewCell.h"
#import "SFPImageCache.h"

@interface SFPThumbnailCollectionViewCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) SFPMasterPhoto *currPhoto;
@end

@implementation SFPThumbnailCollectionViewCell

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
        self.contentView.backgroundColor = [UIColor colorWithWhite:252.0f/255.0f alpha:1.0f];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.currPhoto = nil;
    self.imageView.image = nil;
}


#pragma mark - Configuration

- (void)configureWithPhoto:(SFPMasterPhoto *)photo {
    self.currPhoto = photo;

    __weak typeof(self) weakSelf = self;
    //start with thhumbnail
    [self loadPhoto:photo.thumbnail completion:^(NSError *error, UIImage *image) {
        if (weakSelf.currPhoto != nil && [photo.thumbnail.url.absoluteString isEqualToString:weakSelf.currPhoto.thumbnail.url.absoluteString]) {
            weakSelf.imageView.image = image;
            //load higher res
            [weakSelf loadPhoto:photo.medium completion:^(NSError *error, UIImage *image) {
                if (weakSelf.currPhoto != nil && [photo.medium.url.absoluteString isEqualToString:weakSelf.currPhoto.medium.url.absoluteString]) {
                    weakSelf.imageView.image = image;
                }
            }];
        }
    }];
}

- (void)loadPhoto:(SFPPhoto *)photo completion:(void(^)(NSError *error, UIImage *image))completion {
    [[SFPImageCache sharedManager] imageForURL:photo.url completion:^(NSError *error, UIImage *image) {
        if (image) { completion(nil,image); }
        else if (error) { completion(error,nil); }
        else { completion(nil,nil); }
    }];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
}


#pragma mark - Accessors

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

@end
