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
@property (nonatomic, strong) SFPPhoto *medium;
@property (nonatomic, strong) SFPPhoto *large;
@property (nonatomic, strong) SFPPhoto *original;

@end

@implementation SFPMasterPhoto

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        _remoteId   = attributes[@"id"] != nil ? attributes[@"id"]  : @"";
        _title      = attributes[@"title"] != nil ? attributes[@"title"]  : @"";
        _thumbnail  = [self photoForType:@"t" inFullAttributes:attributes];
        _medium     = [self photoForType:@"c" inFullAttributes:attributes];
        _large      = [self photoForType:@"l" inFullAttributes:attributes];
        _original   = [self photoForType:@"o" inFullAttributes:attributes];
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
