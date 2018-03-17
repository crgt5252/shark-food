//
//  SFPLightBoxViewController.m
//  SharkFood
//
//  Created by Christopher Taylor on 3/17/18.
//  Copyright © 2018 Christopher Taylor. All rights reserved.
//

#import "SFPLightBoxViewController.h"
#import "SFPImageCache.h"

@interface SFPLightBoxViewController () <UIGestureRecognizerDelegate>
@property (nonatomic,strong)  UIImageView *imageView;
@property (nonatomic, strong) SFPMasterPhoto *masterPhoto;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *downloadBtn;


@end

@implementation SFPLightBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.downloadBtn];

    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tapGR.delegate = self;
    [self.imageView addGestureRecognizer:tapGR];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)dismiss {
    [self.delegate dismiss:self];
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.titleLabel.frame = CGRectMake(30, self.view.frame.size.height - 100, self.view.frame.size.width - 60, 30);
    self.downloadBtn.frame =  CGRectMake(10, CGRectGetMaxY(self.titleLabel.frame) + 10, self.view.frame.size.width - 20, 30);
    self.imageView.frame = self.view.bounds;
}

#pragma mark - Accessors

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.userInteractionEnabled = YES;
        
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:.05];
    }
    return _titleLabel;
}

- (UIButton *)downloadBtn {
    if (!_downloadBtn) {
        _downloadBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_downloadBtn addTarget:self action:@selector(downloadPhoto) forControlEvents:UIControlEventTouchUpInside];
        [_downloadBtn setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
    }
    return _downloadBtn;
}

#pragma mark - Configuration

- (void)configureWithSPCPhoto:(SFPMasterPhoto *)photo {
    self.masterPhoto = photo;
    self.titleLabel.text = photo.title;
    [self.titleLabel bringSubviewToFront:self.titleLabel];
    
    //start with thumb since we have it
    __weak typeof(self) weakSelf = self;
    [[SFPImageCache sharedManager] imageForURL:photo.thumbnail.url completion:^(NSError *error, UIImage *image) {
        //thread-safe completion
        if (image) {
            if (weakSelf) {
                weakSelf.imageView.frame = self.view.bounds;
                weakSelf.imageView.image = image;
                [weakSelf loadFullImageForPhoto:weakSelf.masterPhoto];
            }
        }
    }];
}

#pragma mark - Private

- (void)loadFullImageForPhoto:(SFPMasterPhoto *)photo {
    __weak typeof(self) weakSelf = self;
    if (photo.cropped.url != nil) {
        [[SFPImageCache sharedManager] imageForURL:photo.cropped.url completion:^(NSError *error, UIImage *image) {
            if (image) {
                if (weakSelf) {
                    weakSelf.imageView.image = image;
                }
            }
        }];
    }
}

- (void)downloadPhoto {
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != NULL) {
        // TODO: handle error
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error saving image" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success!" message:@"Your shark image was saved to your photo roll" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
