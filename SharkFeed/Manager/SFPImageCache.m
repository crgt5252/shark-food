//
//  SFPImageCache.m
//  SharkFood
//
//  Created by Christopher Taylor on 3/16/18.
//  Copyright © 2018 Christopher Taylor. All rights reserved.
//

#import "SFPImageCache.h"

@interface SFPImageCache ()
@property (nonatomic, strong) NSMutableDictionary *imageDict;
@end

@implementation SFPImageCache

#pragma mark - Lifecycle

+ (id)sharedManager {
    static SFPImageCache *sharedImageCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedImageCache = [[self alloc] init];
    });
    return sharedImageCache;
}

- (id)init {
    if (self = [super init]) {
        self.imageDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)imageForURL:(NSURL *)url completion:(void(^)(NSError *error, UIImage *image))completion {
    // return the image immediately if we have it in our cache
    if (self.imageDict[url.absoluteString] != nil) {
        completion(nil, self.imageDict[url.absoluteString]);
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //process on background thread
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            if (imageData) {
                //handle UIKit on the main thread
                dispatch_async(dispatch_get_main_queue(),^ {
                    UIImage *image = [UIImage imageWithData:imageData];
                    [self cacheImage:image forURL:url];
                    completion(nil,image);
                });
            }
            else {
                NSInteger errCode = 111;
                NSDictionary *errMsg =  @{@"message" : @"error processing image"};
                NSError *error = [[NSError alloc] initWithDomain:@"SPFErrorDomain" code:errCode userInfo:errMsg];
                dispatch_async(dispatch_get_main_queue(),^ {
                    completion(error,nil);
                });
            }
        });
    }
}

- (void)cacheImage:(UIImage *)image forURL:(NSURL *)url {
    NSInteger maxPhotosToCache = 100;
    @synchronized (self.imageDict) {
        // naive cache cap
        if (self.imageDict.allKeys.count > maxPhotosToCache) {
            [self.imageDict removeAllObjects];
        }
        self.imageDict[url.absoluteString] = image;
    }
}

@end
