//
//  SFPPhoto.m
//  SharkFood
//
//  Created by Christopher Taylor on 3/16/18.
//  Copyright © 2018 Christopher Taylor. All rights reserved.
//

#import "SFPPhoto.h"

@interface SFPPhoto ()
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;
@end

@implementation SFPPhoto

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        _url = attributes[@"url"] != nil ? [NSURL URLWithString:attributes[@"url"]] : nil;
        _height = attributes[@"height"] != nil ? [attributes[@"height"] floatValue] : 0;
        _width = attributes[@"width"] != nil ? [attributes[@"width"] floatValue] : 0;
    }
    return self;
}

@end
