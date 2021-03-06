//
//  SFPThumbnailCollectionViewCell.h
//  SharkFood
//
//  Created by Christopher Taylor on 3/16/18.
//  Copyright © 2018 Christopher Taylor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFPPhoto.h"

@interface SFPThumbnailCollectionViewCell : UICollectionViewCell

- (void)configureWithPhoto:(SFPPhoto *)photo;

@end
