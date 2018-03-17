//
//  SFPImageCache.h
//  SharkFood
//
//  Created by Christopher Taylor on 3/16/18.
//  Copyright © 2018 Christopher Taylor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SFPImageCache : NSObject

+ (id)sharedManager;

- (void)imageForURL:(NSURL *)url completion:(void(^)(NSError *error, UIImage *image))completion;

@end
