//
//  SFPContentManager.m
//  SharkFood
//
//  Created by Christopher Taylor on 3/16/18.
//  Copyright © 2018 Christopher Taylor. All rights reserved.
//

#import "SFPContentManager.h"

@interface SFPContentManager ()
@property (nonatomic, strong) NSMutableDictionary *contentDictionary;
@end

@implementation SFPContentManager

NSString *const SPFErrorDomain = @"SPFErrorDomain";

#pragma mark - Lifecycle

+ (id)sharedManager {
    static SFPContentManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - Accessors

- (NSMutableDictionary *)contentDictionary {
    if (!_contentDictionary) {
        _contentDictionary = [NSMutableDictionary dictionary];
    }
    return _contentDictionary;
}


#pragma mark - Public

- (void)contentForPage:(NSInteger)page completion:(void(^)(NSError *error, NSArray *contentArray))completion {

    //return content immediately for this page if we've already fetched it
    if (self.contentDictionary[@(page)] != nil) {
        completion(nil,self.contentDictionary[@(page)]);
    }
    else {
        [self fetchContentForPage:page completion:completion];
    }
}

- (void)clearCachedContent {
    @synchronized (self.contentDictionary) {
        [self.contentDictionary removeAllObjects];
    }
}


#pragma mark - Private

- (NSString *)constructURLForPage:(NSInteger)page {
    NSString *baseURLString     = @"https://api.flickr.com/services/rest/";
    NSString *method            = @"flickr.photos.search";
    NSString *apiKey            = @"99685be3c9f3976e4e2db1763ca62022";
    NSString *text              = @"shark";
    NSString *format            = @"json";
    NSString *extras            =  @"url_t,url_c,url_l,url_o";
    
    NSString *methodComponent = [NSString stringWithFormat:@"?method=%@",method];
    NSString *keyComponent = [NSString stringWithFormat:@"&api_key=%@",apiKey];
    NSString *textComponent = [NSString stringWithFormat:@"&text=%@",text];
    NSString *formatComponent = [NSString stringWithFormat:@"&format=%@",format];
    NSString *pageComponent = [NSString stringWithFormat:@"&page=%i",(int)page];
    NSString *nojsoncallbackComponent = [NSString stringWithFormat:@"&nojsoncallback=%i",(int)page];
    NSString *extrasComponent = [NSString stringWithFormat:@"&extras=%@",extras];

    return [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",baseURLString,methodComponent,keyComponent,textComponent,formatComponent,nojsoncallbackComponent,pageComponent,extrasComponent];
}

- (void)fetchContentForPage:(NSInteger)page completion:(void(^)(NSError *error, NSArray *contentArray))completion {
 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //fetch json
        NSString *finalURLString =  [self constructURLForPage:page];
        NSURL *url = [NSURL URLWithString:finalURLString];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            //error?
            if (error) {
                completion(error,nil);
            }
            else {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                if (json) {
                    [self parseJSON:json forPage:page completion:completion];
                }
                else {
                    NSError *error = [[NSError alloc] initWithDomain:SPFErrorDomain code:1001 userInfo:@{@"message" : @"JSON deserialization failure"}];
                    completion(error,nil);
                }
            }
        }] resume];
    });
}

- (void)parseJSON:(NSDictionary *)jsonDict forPage:(NSInteger)page completion:(void(^)(NSError *error, NSArray *contentArray))completion {

    //error in the status message?
    if (jsonDict[@"stat"] != nil && [jsonDict[@"stat"] isEqualToString:@"fail"]) {
        NSInteger errCode = jsonDict[@"code"] != nil ? [jsonDict[@"code"] integerValue] : 0;
        NSDictionary *errMsg = jsonDict[@"message"] != nil ? jsonDict[@"message"] : @{@"message" : @"unknown error"};
        NSError *error = [[NSError alloc] initWithDomain:SPFErrorDomain code:errCode userInfo:errMsg];
        completion(error,nil);
    }
    
    //parse json
    NSLog(@"raw jsonDict %@",jsonDict);

        //cache content
            //return the parsed content in our completion handler
    
        //fail?
            //return error
}

- (void)cacheContent:(NSArray *)content forPage:(NSInteger)page {
    @synchronized (self.contentDictionary) {
        self.contentDictionary[@(page)] = content;
    }
}

@end
