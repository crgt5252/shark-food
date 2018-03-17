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
@property (nonatomic, strong) SFPPhoto *currPhoto;
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
}


#pragma mark - Configuration

- (void)configureWithPhoto:(SFPPhoto *)photo {
    self.currPhoto = photo;

    //thread-safe completion
    __weak typeof(self) weakSelf = self;
    [[SFPImageCache sharedManager] imageForURL:photo.url completion:^(NSError *error, UIImage *image) {
        if (image) {
            if (weakSelf) {
                //confirm we are still looking for this image
                //that we havent i.e. dequeued & been reused before completing
                if ([photo.url.absoluteString isEqualToString:weakSelf.currPhoto.url.absoluteString]) {
                    weakSelf.imageView.image = image;
                }
            }
        }
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
