//
//  SFPPhoto.h
//  SharkFood
//
//  Created by Christopher Taylor on 3/16/18.
//  Copyright © 2018 Christopher Taylor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SFPPhoto : NSObject

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, readonly) CGFloat width;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

@end
