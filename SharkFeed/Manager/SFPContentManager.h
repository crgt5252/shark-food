//
//  SFPContentManager.h
//  SharkFood
//
//  Created by Christopher Taylor on 3/16/18.
//  Copyright © 2018 Christopher Taylor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFPMasterPhoto.h"

@interface SFPContentManager : NSObject

+ (id)sharedManager;

- (void)contentForPage:(NSInteger)page completion:(void(^)(NSError *error, NSArray<SFPMasterPhoto *> *contentArray))completion;
- (void)clearCachedContent;

@end
