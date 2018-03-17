//
//  SFPMasterPhoto.m
//  SharkFood
//
//  Created by Christopher Taylor on 3/16/18.
//  Copyright © 2018 Christopher Taylor. All rights reserved.
//

#import "SFPMasterPhoto.h"

@interface SFPMasterPhoto ()

@property (nonatomic, strong) NSString *remoteId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) SFPPhoto *thumbnail;
@property (nonatomic, strong) SFPPhoto *original;
@property (nonatomic, strong) SFPPhoto *landscape;

@end

@implementation SFPMasterPhoto

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        _remoteId   = attributes[@"id"] != nil ? attributes[@"id"]  : nil;
        _title      = attributes[@"title"] != nil ? attributes[@"title"]  : nil;
        _thumbnail  = [self photoForType:@"t" inFullAttributes:attributes];
        _original   = [self photoForType:@"o" inFullAttributes:attributes];
        _landscape  = [self photoForType:@"l" inFullAttributes:attributes];
    }
    return self;
}

- (SFPPhoto *)photoForType:(NSString *)type inFullAttributes:(NSDictionary *)attributes {
    
    NSString *urlKey    = [@"url_" stringByAppendingString:type];
    NSString *heightKey = [@"height_" stringByAppendingString:type];
    NSString *widthKey  = [@"width_" stringByAppendingString:type];
    
    NSMutableDictionary *photoAttributes = [NSMutableDictionary dictionary];
    if (attributes[urlKey] != nil) {
        photoAttributes[@"url"] = attributes[urlKey];
    }
    if (attributes[heightKey] != nil) {
        photoAttributes[@"height"] = attributes[heightKey];
    }
    if (attributes[widthKey] != nil) {
        photoAttributes[@"width"] = attributes[widthKey];
    }
    return [[SFPPhoto alloc] initWithAttributes:photoAttributes];
}

@end
