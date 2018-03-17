//
//  SFPMasterPhoto.h
//  SharkFood
//
//  Created by Christopher Taylor on 3/16/18.
//  Copyright © 2018 Christopher Taylor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFPPhoto.h"

@interface SFPMasterPhoto : NSObject

@property (nonatomic, readonly) NSString *remoteId;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) SFPPhoto *thumbnail;
@property (nonatomic, readonly) SFPPhoto *original;
@property (nonatomic, readonly) SFPPhoto *landscape;
@property (nonatomic, readonly) SFPPhoto *cropped;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

@end
