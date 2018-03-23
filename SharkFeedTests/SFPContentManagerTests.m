//
//  SFPContentManagerTests.m
//  SharkFeedTests
//
//  Created by Christopher Taylor on 3/22/18.
//  Copyright © 2018 Christopher Taylor. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SFPContentManager.h"

@interface SFPContentManager (Test)
- (NSString *)constructURLForPage:(NSInteger)page;
- (void)parseJSON:(NSDictionary *)jsonDict forPage:(NSInteger)page completion:(void(^)(NSError *error, NSArray<SFPMasterPhoto *> *contentArray))completion;
@end

@interface SFPContentManagerTests : XCTestCase
@end

@implementation SFPContentManagerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testURLConstruction {
    //given
    NSString *expected = @"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=99685be3c9f3976e4e2db1763ca62022&text=shark&format=json&nojsoncallback=1&page=1&extras=url_t,url_c,url_l,url_o";
    //when
    NSString *res = [[SFPContentManager sharedManager] constructURLForPage:1];
    //then
    XCTAssertTrue([expected isEqualToString:res]);
}

- (void)testParseJSONShouldReturnEmptyWithJunkJSON {
    //given
    NSDictionary *jsonDict  = @{@"junk" : @"fake"};
    NSInteger pageNum       = 1;
    //when
    XCTestExpectation *expectation = [self expectationWithDescription:@"parse json called, should return empty"];
    [[SFPContentManager sharedManager] parseJSON:jsonDict forPage:pageNum completion:^(NSError *error, NSArray<SFPMasterPhoto *> *contentArray) {
        //then
        [expectation fulfill];
        XCTAssertEqual(0, contentArray.count);
    }];
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testParseJSONShouldReturnContentWithValidJSON {
    //given
    NSString *dummyTitle = @"Shark Print Skinny Leggings";
    NSDictionary *jsonDict  = @{ @"photos" :
                                     @{ @"photo" :
                                            @[ @{ @"height_o" : @(400),
                                                  @"height_t" : @(100),
                                                  @"id" : @"26093857827",
                                                  @"title" : dummyTitle,
                                                  @"url_o" : @"https://farm5.staticflickr.com/4785/26093857827_16c798364a_o.jpg",
                                                  @"url_t" : @"https://farm5.staticflickr.com/4785/26093857827_833c5c05aa_t.jpg",
                                                  @"width_o" : @(400),
                                                  @"width_t" : @(100),
                                                  }]
                                        }
                                 };
    NSInteger pageNum       = 1;
    
    //when
    XCTestExpectation *expectation = [self expectationWithDescription:@"parse json called, should return SPFMasterPhoto"];
    [[SFPContentManager sharedManager] parseJSON:jsonDict forPage:pageNum completion:^(NSError *error, NSArray<SFPMasterPhoto *> *contentArray) {
        //then
        [expectation fulfill];
        SFPMasterPhoto *mPhoto = contentArray[0];
        XCTAssertTrue([mPhoto isKindOfClass:[SFPMasterPhoto class]]);
        XCTAssertTrue([mPhoto.title isEqualToString:dummyTitle]);
        XCTAssertNotNil(mPhoto.thumbnail);
        XCTAssertNotNil(mPhoto.original);
    }];
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

@end
