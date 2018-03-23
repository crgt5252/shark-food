//
//  SFPImageCacheTests.m
//  SharkFeedTests
//
//  Created by Christopher Taylor on 3/23/18.
//  Copyright © 2018 Christopher Taylor. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SFPImageCache.h"

@interface SFPImageCache (Test)
- (void)imageForURL:(NSURL *)url completion:(void(^)(NSError *error, UIImage *image))completion;
- (void)cacheImage:(UIImage *)image forURL:(NSURL *)url;
@end

@interface SFPImageCacheTests : XCTestCase

@end

@implementation SFPImageCacheTests

- (void)setUp {
    [super setUp];
}


- (void)testCacheImageForURLFailsWithNilURL {
    
    //given
    UIImage *image = [[UIImage alloc] init];
    
    //when
    [[SFPImageCache sharedManager] cacheImage:image forURL:nil];
    
    //then
    XCTestExpectation *expectation = [self expectationWithDescription:@"imageForURL should error when nil passed for url"];
    
    [[SFPImageCache sharedManager] imageForURL:nil completion:^(NSError *error, UIImage *image) {
        [expectation fulfill];
        XCTAssertNotNil(error);
        XCTAssertNil(image);
    }];
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testCacheImageForURLFailsCleanlyWithNilImage {

    //given
    NSURL *url = [NSURL URLWithString:@"http://flickr.com"];
    
    //when
    [[SFPImageCache sharedManager] cacheImage:nil forURL:url];
    
    //then
    XCTestExpectation *expectation = [self expectationWithDescription:@"cacheImageForURL should return nil it we tried to cache nil"];

    [[SFPImageCache sharedManager] imageForURL:url completion:^(NSError *error, UIImage *image) {
        [expectation fulfill];
        XCTAssertNil(image);
    }];
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}


- (void)testCacheImageForURLReturnsImage {
    
    //given
    NSURL *url = [NSURL URLWithString:@"http://flickr.com"];
    UIImage *image = [[UIImage alloc] init];
    
    //when
    [[SFPImageCache sharedManager] cacheImage:image forURL:url];
    
    //then
    XCTestExpectation *expectation = [self expectationWithDescription:@"should return an image if we cached one"];
    
    [[SFPImageCache sharedManager] imageForURL:url completion:^(NSError *error, UIImage *image) {
        [expectation fulfill];
        XCTAssertNotNil(image);
        XCTAssertTrue([image isKindOfClass:[UIImage class]]);
    }];
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

@end
