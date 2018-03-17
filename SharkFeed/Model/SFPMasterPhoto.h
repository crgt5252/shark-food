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
@property (nonatomic, readonly) SFPPhoto *medium;
@property (nonatomic, readonly) SFPPhoto *large;
@property (nonatomic, readonly) SFPPhoto *original;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

@end
