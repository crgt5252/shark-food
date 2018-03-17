//
//  SFPLightBoxViewController.h
//  SharkFood
//
//  Created by Christopher Taylor on 3/17/18.
//  Copyright © 2018 Christopher Taylor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFPMasterPhoto.h"

@class SFPLightBoxViewController;

@protocol SFPLightBoxViewControllerDelegate <NSObject>
- (void)dismiss:(SFPLightBoxViewController *)lightBoxVC;
@end

@interface SFPLightBoxViewController : UIViewController
@property (nonatomic, weak) id <SFPLightBoxViewControllerDelegate> delegate;

- (void)configureWithSPCPhoto:(SFPMasterPhoto *)photo;


@end
