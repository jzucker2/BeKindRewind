//
//  BKRPlayingTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 1/22/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRPlayer.h>
#import <BeKindRewind/BKRPlayableCassette.h>
#import <BeKindRewind/BKRScene.h>
#import <BeKindRewind/BKRDataFrame.h>
#import <BeKindRewind/BKRResponseFrame.h>
#import <BeKindRewind/BKRRequestFrame.h>
#import <BeKindRewind/BKRPlayheadMatcher.h>
#import <BeKindRewind/BKROHHTTPStubsWrapper.h>
#import "XCTestCase+BKRAdditions.h"
#import "BKRBaseTestCase.h"

@interface BKRPlayingTestCase : BKRBaseTestCase

@end

@implementation BKRPlayingTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPlayingOneGETRequest {
    BKRExpectedScenePlistDictionaryBuilder *sceneBuilder = [self standardGETRequestDictionaryBuilderForHTTPBinWithQueryItemString:@"test=test" contentLength:nil];
    __block NSDictionary *expectedCassetteDict = [self expectedCassetteDictionaryWithSceneBuilders:@[sceneBuilder]];
    __block BKRScene *scene = nil;
    BKRPlayableCassette *testCassette = [[BKRPlayableCassette alloc] initFromPlistDictionary:expectedCassetteDict];
    __block BKRPlayer *player = [BKRPlayer playerWithMatcherClass:[BKRPlayheadMatcher class]];
    player.currentCassette = testCassette;
    player.enabled = YES;
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNotNil(data);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        // ensure that result from network is as expected
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        
//        XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 200);
        NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
        XCTAssertEqual(castedResponse.statusCode, 200);
        XCTAssertEqualObjects(castedResponse.allHeaderFields[@"Date"], @"Fri, 22 Jan 2016 20:36:26 GMT", @"actual received response is different");
        
        // now current cassette in recoder should have one scene with data matching this
        
        XCTAssertNotNil(player.currentCassette);
        XCTAssertEqual(player.allScenes.count, 1);
        scene = (BKRScene *)player.allScenes.firstObject;
        XCTAssertTrue(scene.allFrames.count > 0);
        XCTAssertEqual(scene.allDataFrames.count, 1);
        BKRDataFrame *dataFrame = scene.allDataFrames.firstObject;
        [self assertData:dataFrame withData:data extraAssertions:nil];
        XCTAssertEqualObjects(dataFrame.JSONConvertedObject, dataDict, @"Deserialized data objects not equal. [[Data frame: %@]]. [[dataDict: %@]]",dataFrame.JSONConvertedObject, dataDict);
        XCTAssertNotNil(dataDict, @"dataDict: %@", dataDict.description);
        XCTAssertNotNil(dataFrame.JSONConvertedObject, @"dataFrame: %@", [dataFrame.JSONConvertedObject description]);
        XCTAssertNotNil(data, @"data: %@", data);
        XCTAssertNotNil(dataFrame.rawData, @"dataFrame: %@", dataFrame.rawData);
        XCTAssertEqual(scene.allResponseFrames.count, 1);
        BKRResponseFrame *responseFrame = scene.allResponseFrames.firstObject;
        XCTAssertEqual(responseFrame.statusCode, 200);
        [self assertResponse:responseFrame withResponse:response extraAssertions:nil];
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual(scene.allRequestFrames.count, 2);
        NSURLRequest *originalRequest = task.originalRequest;
        BKRRequestFrame *originalRequestFrame = scene.originalRequest;
        XCTAssertNotNil(originalRequestFrame);
        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
        XCTAssertNotNil(scene.currentRequest);
        [self assertRequest:scene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
        [self assertFramesOrder:scene extraAssertions:nil];
    }];
}

- (void)DISABLE_testPlayingOneCancelledGETRequest {
    NSString *taskUniqueIdentifier = [NSUUID UUID].UUIDString;
    BKRExpectedScenePlistDictionaryBuilder *sceneBuilder = [BKRExpectedScenePlistDictionaryBuilder builder];
    sceneBuilder.URLString = @"https://httpbin.org/delay/10";
    sceneBuilder.taskUniqueIdentifier = taskUniqueIdentifier;
    sceneBuilder.hasCurrentRequest = NO;
    sceneBuilder.hasResponse = NO;
    sceneBuilder.receivedJSON = nil;
    sceneBuilder.errorCode = -999;
    sceneBuilder.errorDomain = NSURLErrorDomain;
    sceneBuilder.errorUserInfo = @{
                                   NSURLErrorFailingURLErrorKey: @"https://httpbin.org/delay/10",
                                   NSURLErrorFailingURLStringErrorKey: @"https://httpbin.org/delay/10",
                                   NSLocalizedDescriptionKey: @"cancelled"
                                   };
    __block NSDictionary *expectedCassetteDict = [self expectedCassetteDictionaryWithSceneBuilders:@[sceneBuilder]];
    __block BKRScene *scene = nil;
    __block NSError *taskError = nil;
    __block BKRPlayableCassette *cassette = [[BKRPlayableCassette alloc] initFromPlistDictionary:expectedCassetteDict];
    BKRPlayer *player = [BKRPlayer playerWithMatcherClass:[BKRPlayheadMatcher class]];
    player.currentCassette = cassette;
    player.enabled = YES;
    [self cancellingGetTaskWithURLString:@"https://httpbin.org/delay/10" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        // ensure that result from network is as expected
        // now current cassette in recoder should have one scene with data matching this
        XCTAssertNotNil(cassette);
        XCTAssertEqual(cassette.allScenes.count, 1);
        scene = cassette.allScenes.firstObject;
        XCTAssertNotNil(scene);
        XCTAssertNotNil(error);
        taskError = error;
        XCTAssertEqual(error.code, -999);
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain);
        NSDictionary *expectedErrorUserInfo = @{
                                                NSURLErrorFailingURLErrorKey: [NSURL URLWithString:@"https://httpbin.org/delay/10"],
                                                NSURLErrorFailingURLStringErrorKey: @"https://httpbin.org/delay/10",
                                                NSLocalizedDescriptionKey: @"cancelled"
                                                };
        XCTAssertEqualObjects(error.userInfo, expectedErrorUserInfo);
        XCTAssertTrue(scene.allFrames.count > 0);
        XCTAssertEqual(scene.allDataFrames.count, 0);
        XCTAssertEqual(scene.allResponseFrames.count, 0);
        XCTAssertEqual(scene.allErrorFrames.count, 1); // need to fix timing, this should have already been recorded
        XCTAssertEqual(scene.allRequestFrames.count, 1);
        BKRErrorFrame *errorFrame = scene.allErrorFrames.firstObject;
        [self assertErrorFrame:errorFrame withError:taskError extraAssertions:nil];
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual(scene.allFrames.count, 2);
        XCTAssertEqual(scene.allRequestFrames.count, 1);
        NSURLRequest *originalRequest = task.originalRequest;
        BKRRequestFrame *originalRequestFrame = scene.originalRequest;
        XCTAssertNotNil(originalRequestFrame);
        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
        [self assertFramesOrder:scene extraAssertions:nil];
    }];
}

- (void)DISABLE_testPlayingOnePOSTRequest {
    NSString *taskUniqueIdentifier = [NSUUID UUID].UUIDString;
    BKRExpectedScenePlistDictionaryBuilder *sceneBuilder = [BKRExpectedScenePlistDictionaryBuilder builder];
    sceneBuilder.URLString = @"https://httpbin.org/post";
    sceneBuilder.taskUniqueIdentifier = taskUniqueIdentifier;
    //    sceneBuilder.currentRequestAllHTTPHeaderFields = @{
    //                                                       @"Accept": @"*/*",
    //                                                       @"Accept-Encoding": @"gzip, deflate",
    //                                                       @"Accept-Language": @"en-us"
    //                                                       };
    sceneBuilder.currentRequestAllHTTPHeaderFields = @{
                                                       @"Content-Length" : @"19"
                                                       };
    sceneBuilder.originalRequestAllHTTPHeaderFields = @{};
    sceneBuilder.receivedJSON = @{
                                  @"args": @{
                                          },
                                  @"data": @"",
                                  @"files": @{
                                          },
                                  @"form": @{
                                          @"{\n  \"foo\" : \"bar\"\n}": @""
                                          },
                                  @"headers": @{
                                          @"Accept": @"*/*",
                                          @"Accept-Encoding": @"gzip, deflate",
                                          @"Accept-Language": @"en-us",
                                          @"Host": @"httpbin.org",
                                          @"User-Agent": @"xctest (unknown version) CFNetwork/758.2.8 Darwin/15.3.0"
                                          },
                                  @"json": @"<null>",
                                  @"origin": @"67.180.11.233",
                                  @"url": @"https://httpbin.org/post"
                                  };
    sceneBuilder.sentJSON = @{
                              @"foo": @"bar"
                              };
    sceneBuilder.HTTPMethod = @"POST";
    sceneBuilder.responseAllHeaderFields = @{
                                             @"Access-Control-Allow-Origin": @"*",
                                             @"Content-Length": @"338",
                                             @"Content-Type": @"application/json",
                                             @"Date": @"Fri, 22 Jan 2016 20:36:26 GMT",
                                             @"Server": @"nginx",
                                             @"access-control-allow-credentials": @"true"
                                             };
    __block NSDictionary *expectedCassetteDict = [self expectedCassetteDictionaryWithSceneBuilders:@[sceneBuilder]];
    __block BKRScene *scene = nil;
    __block BKRPlayableCassette *cassette = [[BKRPlayableCassette alloc] initFromPlistDictionary:expectedCassetteDict];
    BKRPlayer *player = [BKRPlayer playerWithMatcherClass:[BKRPlayheadMatcher class]];
    player.currentCassette = cassette;
    player.enabled = YES;
    [self postJSON:sceneBuilder.sentJSON withURLString:@"https://httpbin.org/post" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(data);
        // ensure that data returned is same as data posted
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSDictionary *formDict = dataDict[@"form"];
        // for this service, need to fish out the data sent
        NSArray *formKeys = formDict.allKeys;
        NSString *rawReceivedDataString = formKeys.firstObject;
        NSDictionary *receivedDataDictionary = [NSJSONSerialization JSONObjectWithData:[rawReceivedDataString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        // ensure that result from network is as expected
        XCTAssertEqualObjects(sceneBuilder.sentJSON, receivedDataDictionary);
        
        // now current cassette in recoder should have one scene with data matching this
        XCTAssertNotNil(cassette);
        XCTAssertEqual(cassette.allScenes.count, 1);
        scene = cassette.allScenes.firstObject;
        XCTAssertTrue(scene.allFrames.count > 0);
        XCTAssertEqual(scene.allDataFrames.count, 1);
        BKRDataFrame *dataFrame = scene.allDataFrames.firstObject;
        [self assertData:dataFrame withData:data extraAssertions:nil];
        XCTAssertEqual(scene.allResponseFrames.count, 1);
        BKRResponseFrame *responseFrame = scene.allResponseFrames.firstObject;
        XCTAssertEqual(responseFrame.statusCode, 200);
        [self assertResponse:responseFrame withResponse:response extraAssertions:nil];
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual(scene.allRequestFrames.count, 2);
        NSURLRequest *originalRequest = task.originalRequest;
        BKRRequestFrame *originalRequestFrame = scene.originalRequest;
        XCTAssertNotNil(originalRequestFrame);
        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
        XCTAssertNotNil(scene.currentRequest);
        [self assertRequest:scene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
        [self assertFramesOrder:scene extraAssertions:nil];
    }];
}

- (void)DISABLE_testPlayingMultipleGetRequests {
    BKRExpectedScenePlistDictionaryBuilder *firstSceneBuilder = [self standardGETRequestDictionaryBuilderForHTTPBinWithQueryItemString:@"test=test" contentLength:nil];
    BKRExpectedScenePlistDictionaryBuilder *secondSceneBuilder = [self standardGETRequestDictionaryBuilderForHTTPBinWithQueryItemString:@"test=test2" contentLength:nil];
    
    __block NSDictionary *expectedCassetteDict = [self expectedCassetteDictionaryWithSceneBuilders:@[firstSceneBuilder, secondSceneBuilder]];
    __block BKRScene *firstScene = nil;
    __block BKRScene *secondScene = nil;
    __block BKRPlayableCassette *cassette = [[BKRPlayableCassette alloc] initFromPlistDictionary:expectedCassetteDict];
    XCTAssertEqual(cassette.allScenes.count, 2);
    BKRPlayer *player = [BKRPlayer playerWithMatcherClass:[BKRPlayheadMatcher class]];
    player.currentCassette = cassette;
    player.enabled = YES;
    
    [self getTaskWithURLString:firstSceneBuilder.URLString taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(data);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        // ensure that result from network is as expected
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 200);
        // now current cassette in recoder should have one scene with data matching this
        XCTAssertNotNil(cassette);
        XCTAssertEqual(cassette.allScenes.count, 2);
        firstScene = cassette.allScenes.firstObject;
        XCTAssertEqualObjects(firstScene.uniqueIdentifier, firstSceneBuilder.taskUniqueIdentifier);
        XCTAssertTrue(firstScene.allFrames.count > 0);
        XCTAssertEqual(firstScene.allDataFrames.count, 1);
        BKRDataFrame *dataFrame = firstScene.allDataFrames.firstObject;
        [self assertData:dataFrame withData:data extraAssertions:nil];
        XCTAssertEqual(firstScene.allResponseFrames.count, 1);
        BKRResponseFrame *responseFrame = firstScene.allResponseFrames.firstObject;
        XCTAssertEqual(responseFrame.statusCode, 200);
        [self assertResponse:responseFrame withResponse:response extraAssertions:nil];
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual(firstScene.allRequestFrames.count, 2);
        NSURLRequest *originalRequest = task.originalRequest;
        BKRRequestFrame *originalRequestFrame = firstScene.originalRequest;
        XCTAssertNotNil(originalRequestFrame);
        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
        XCTAssertNotNil(firstScene.currentRequest);
        [self assertRequest:firstScene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
        [self assertFramesOrder:firstScene extraAssertions:nil];
    }];
    
    [self getTaskWithURLString:secondSceneBuilder.URLString taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(data);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        // ensure that result from network is as expected
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test2"});
        XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 200);
        // now current cassette in recoder should have one scene with data matching this
        XCTAssertNotNil(cassette);
        XCTAssertEqual(cassette.allScenes.count, 2);
        secondScene = cassette.allScenes.lastObject;
        XCTAssertEqualObjects(secondScene.uniqueIdentifier, secondSceneBuilder.taskUniqueIdentifier);
        XCTAssertNotEqualObjects(firstScene.uniqueIdentifier, secondScene.uniqueIdentifier, @"The two scenes should not be identical");
        XCTAssertTrue(secondScene.allFrames.count > 0);
        XCTAssertEqual(secondScene.allDataFrames.count, 1);
        BKRDataFrame *dataFrame = secondScene.allDataFrames.firstObject;
        [self assertData:dataFrame withData:data extraAssertions:nil];
        XCTAssertEqual(secondScene.allResponseFrames.count, 1);
        BKRResponseFrame *responseFrame = secondScene.allResponseFrames.firstObject;
        XCTAssertEqual(responseFrame.statusCode, 200);
        [self assertResponse:responseFrame withResponse:response extraAssertions:nil];
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual(secondScene.allRequestFrames.count, 2);
        NSURLRequest *originalRequest = task.originalRequest;
        BKRRequestFrame *originalRequestFrame = secondScene.originalRequest;
        XCTAssertNotNil(originalRequestFrame);
        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
        XCTAssertNotNil(secondScene.currentRequest);
        [self assertRequest:secondScene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
        [self assertFramesOrder:secondScene extraAssertions:nil];
    }];
}

- (void)DISABLE_testPlayingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
    NSString *URLString = @"https://pubsub.pubnub.com/time/0";
    NSString *firstTaskUniqueIdentifier = [NSUUID UUID].UUIDString;
    BKRExpectedScenePlistDictionaryBuilder *firstSceneBuilder = [BKRExpectedScenePlistDictionaryBuilder builder];
    firstSceneBuilder.URLString = URLString;
    firstSceneBuilder.taskUniqueIdentifier = firstTaskUniqueIdentifier;
//    firstSceneBuilder.currentRequestAllHTTPHeaderFields = @{
//                                                            @"Accept": @"*/*",
//                                                            @"Accept-Encoding": @"gzip, deflate",
//                                                            @"Accept-Language": @"en-us"
//                                                            };
    firstSceneBuilder.currentRequestAllHTTPHeaderFields = @{};
    // technically the value returned is much larger, to save effort, using string so there's no math or rounding/casting issues
    NSString *firstTimetoken = @"1454015931.93";
    firstSceneBuilder.receivedJSON = @[firstTimetoken];
    firstSceneBuilder.responseAllHeaderFields = @{
                                                  @"Access-Control-Allow-Methods": @"GET",
                                                  @"Access-Control-Allow-Origin": @"*",
                                                  @"Cache-Control": @"no-cache",
                                                  @"Connection": @"keep-alive",
                                                  @"Content-Length": @"19",
                                                  @"Content-Type": @"text/javascript; charset=\"UTF-8\"",
                                                  @"Date": @"Wed, 27 Jan 2016 23:39:04 GMT",
                                                  };
    
    NSString *secondTaskUniqueIdentifier = [NSUUID UUID].UUIDString;
    BKRExpectedScenePlistDictionaryBuilder *secondSceneBuilder = [BKRExpectedScenePlistDictionaryBuilder builder];
    secondSceneBuilder.URLString = URLString;
    secondSceneBuilder.taskUniqueIdentifier = secondTaskUniqueIdentifier;
//    secondSceneBuilder.currentRequestAllHTTPHeaderFields = @{
//                                                             @"Accept": @"*/*",
//                                                             @"Accept-Encoding": @"gzip, deflate",
//                                                             @"Accept-Language": @"en-us"
//                                                             };
    secondSceneBuilder.currentRequestAllHTTPHeaderFields = @{};
    // technically the value returned is much larger, to save effort, using string so there's no math or rounding/casting issues
    NSString *secondTimeToken = @"1454015935.93";
    XCTAssertNotEqualObjects(firstTimetoken, secondTimeToken);
    secondSceneBuilder.receivedJSON = @[secondTimeToken];
    secondSceneBuilder.responseAllHeaderFields = @{
                                                   @"Access-Control-Allow-Methods": @"GET",
                                                   @"Access-Control-Allow-Origin": @"*",
                                                   @"Cache-Control": @"no-cache",
                                                   @"Connection": @"keep-alive",
                                                   @"Content-Length": @"19",
                                                   @"Content-Type": @"text/javascript; charset=\"UTF-8\"",
                                                   @"Date": @"Wed, 27 Jan 2016 23:39:07 GMT",
                                                   };
    
    __block NSDictionary *expectedCassetteDict = [self expectedCassetteDictionaryWithSceneBuilders:@[firstSceneBuilder, secondSceneBuilder]];
    __block BKRScene *firstScene = nil;
    __block BKRScene *secondScene = nil;
    __block BKRPlayableCassette *cassette = [[BKRPlayableCassette alloc] initFromPlistDictionary:expectedCassetteDict];
    XCTAssertEqual(cassette.allScenes.count, 2);
    BKRPlayer *player = [BKRPlayer playerWithMatcherClass:[BKRPlayheadMatcher class]];
    player.currentCassette = cassette;
    player.enabled = YES;
    [self getTaskWithURLString:firstSceneBuilder.URLString taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(data);
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        XCTAssertNotNil(dataArray);
        // ensure that result from network is as expected
        NSNumber *receivedTimeToken = dataArray.firstObject;
        XCTAssertEqualObjects(receivedTimeToken, firstTimetoken);
        XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 200);
        // now current cassette in recoder should have one scene with data matching this
        XCTAssertNotNil(cassette);
        XCTAssertEqual(cassette.allScenes.count, 2);
        firstScene = cassette.allScenes.firstObject;
        XCTAssertEqualObjects(firstScene.uniqueIdentifier, firstTaskUniqueIdentifier);
        XCTAssertTrue(firstScene.allFrames.count > 0);
        XCTAssertEqual(firstScene.allDataFrames.count, 1);
        BKRDataFrame *dataFrame = firstScene.allDataFrames.firstObject;
        [self assertData:dataFrame withData:data extraAssertions:nil];
        XCTAssertEqual(firstScene.allResponseFrames.count, 1);
        BKRResponseFrame *responseFrame = firstScene.allResponseFrames.firstObject;
        XCTAssertEqual(responseFrame.statusCode, 200);
        [self assertResponse:responseFrame withResponse:response extraAssertions:nil];
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual(firstScene.allRequestFrames.count, 2);
        NSURLRequest *originalRequest = task.originalRequest;
        BKRRequestFrame *originalRequestFrame = firstScene.originalRequest;
        XCTAssertNotNil(originalRequestFrame);
        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
        XCTAssertNotNil(firstScene.currentRequest);
        [self assertRequest:firstScene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
        [self assertFramesOrder:firstScene extraAssertions:nil];
    }];
    
    [self getTaskWithURLString:secondSceneBuilder.URLString taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(data);
        NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        XCTAssertNotNil(dataArray);
        // ensure that result from network is as expected
        NSNumber *receivedTimeToken = dataArray.firstObject;
        XCTAssertEqualObjects(receivedTimeToken, secondTimeToken);
        XCTAssertNotEqualObjects(receivedTimeToken, firstTimetoken);
        XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 200);
        // now current cassette in recoder should have one scene with data matching this
        XCTAssertNotNil(cassette);
        XCTAssertEqual(cassette.allScenes.count, 2);
        secondScene = cassette.allScenes.lastObject;
        XCTAssertEqualObjects(secondScene.uniqueIdentifier, secondTaskUniqueIdentifier);
        XCTAssertNotEqualObjects(firstScene.uniqueIdentifier, secondScene.uniqueIdentifier, @"The two scenes should not be identical");
        XCTAssertTrue(secondScene.allFrames.count > 0);
        XCTAssertEqual(secondScene.allDataFrames.count, 1);
        BKRDataFrame *dataFrame = secondScene.allDataFrames.firstObject;
        [self assertData:dataFrame withData:data extraAssertions:nil];
        XCTAssertEqual(secondScene.allResponseFrames.count, 1);
        BKRResponseFrame *responseFrame = secondScene.allResponseFrames.firstObject;
        XCTAssertEqual(responseFrame.statusCode, 200);
        [self assertResponse:responseFrame withResponse:response extraAssertions:nil];
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
        XCTAssertEqual(secondScene.allRequestFrames.count, 2);
        NSURLRequest *originalRequest = task.originalRequest;
        BKRRequestFrame *originalRequestFrame = secondScene.originalRequest;
        XCTAssertNotNil(originalRequestFrame);
        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
        XCTAssertNotNil(secondScene.currentRequest);
        [self assertRequest:secondScene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
        [self assertFramesOrder:secondScene extraAssertions:nil];
    }];
}

@end
