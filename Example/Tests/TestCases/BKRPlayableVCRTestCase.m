//
//  BKRPlayableVCRTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/11/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRPlayableVCR.h>
#import <BeKindRewind/BKRFilePathHelper.h>
#import <BeKindRewind/BKRPlayheadMatcher.h>
#import "BKRBaseTestCase.h"
#import "XCTestCase+BKRAdditions.h"

@interface BKRPlayableVCRTestCase : BKRBaseTestCase
@property (nonatomic, copy) NSString *testRecordingFilePath;
@property (nonatomic, strong) BKRPlayableVCR *vcr;
@end

@implementation BKRPlayableVCRTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSString *fileName = [NSStringFromSelector(self.invocation.selector) stringByAppendingPathExtension:@"plist"];
    XCTAssertNotNil(fileName);
    self.testRecordingFilePath = [BKRFilePathHelper findPathForFile:fileName inBundleForClass:self.class];
    XCTAssertNotNil(self.testRecordingFilePath);
    XCTAssertTrue([BKRFilePathHelper filePathExists:self.testRecordingFilePath]);
    
    NSDictionary *cassetteDictionary = [BKRFilePathHelper dictionaryForPlistFilePath:self.testRecordingFilePath];
    XCTAssertNotNil(cassetteDictionary);
    
    self.vcr = [BKRPlayableVCR vcrWithMatcherClass:[BKRPlayheadMatcher class]];
    XCTAssertNotNil(self.vcr);
    __block XCTestExpectation *stubsExpectation;
    self.vcr.beforeAddingStubsBlock = ^void(void) {
        stubsExpectation = [self expectationWithDescription:@"setting up stubs"];
    };
    self.vcr.afterAddingStubsBlock = ^void(void) {
        [stubsExpectation fulfill];
    };
    
    __block XCTestExpectation *insertExpectation = [self expectationWithDescription:@"insert expectation"];
    NSLog(@"insert expectation create");
    XCTAssertTrue([self.vcr insert:self.testRecordingFilePath completionHandler:^(BOOL result, NSString *filePath) {
        NSLog(@"insert expectation fulfill");
        [insertExpectation fulfill];
    }]);
    NSLog(@"insert wait");
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        NSLog(@"insert expire");
        XCTAssertNil(error);
    }];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.vcr reset];
    [super tearDown];
}

- (void)testPlayingOneGETRequest {
//    BKRExpectedScenePlistDictionaryBuilder *sceneBuilder = [self standardGETRequestDictionaryBuilderForHTTPBinWithQueryItemString:@"test=test" contentLength:nil];
//    NSDictionary *expectedCassetteDict = [self expectedCassetteDictionaryWithSceneBuilders:@[sceneBuilder]];
//    __block BKRScene *scene = nil;
//    BKRPlayableCassette *testCassette = [[BKRPlayableCassette alloc] initFromPlistDictionary:expectedCassetteDict];
//    XCTAssertEqual(testCassette.allScenes.count, 1, @"testCassette should have one valid scene right now");
//    XCTAssertEqual(testCassette.allScenes.firstObject.allFrames.count, 4, @"testCassette should have 4 frames for it's 1 scene");
//    __block BKRPlayer *player = [BKRPlayer playerWithMatcherClass:[BKRPlayheadMatcher class]];
//    [self setWithExpectationsPlayableCassette:testCassette inPlayer:player];
    
//    player.enabled = YES;
    [self.vcr play];
    BKRWeakify(self);
    [self getTaskWithURLString:@"https://httpbin.org/get?test=test" taskCompletionAssertions:^(NSURLSessionTask *task, NSData *data, NSURLResponse *response, NSError *error) {
        BKRStrongify(self);
        XCTAssertNotNil(data);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        // ensure that result from network is as expected
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test": @"test"});
        
        //        XCTAssertEqual([(NSHTTPURLResponse *)response statusCode], 200);
        NSHTTPURLResponse *castedResponse = (NSHTTPURLResponse *)response;
        XCTAssertEqual(castedResponse.statusCode, 200);
//        XCTAssertEqualObjects(castedResponse.allHeaderFields[@"Date"], @"Fri, 22 Jan 2016 20:36:26 GMT", @"actual received response is different");
        
        // now current cassette in recorder should have one scene with data matching this
        
//        XCTAssertNotNil(self.vcr.currentCassette);
//        scene = (BKRScene *)player.allScenes.firstObject;
//        XCTAssertTrue(scene.allFrames.count > 0);
//        XCTAssertEqual(scene.allDataFrames.count, 1);
//        BKRDataFrame *dataFrame = scene.allDataFrames.firstObject;
//        [self assertData:dataFrame withData:data extraAssertions:nil];
//        XCTAssertEqualObjects(dataFrame.JSONConvertedObject, dataDict, @"Deserialized data objects not equal. [[Data frame: %@]]. [[dataDict: %@]]",dataFrame.JSONConvertedObject, dataDict);
//        XCTAssertNotNil(dataDict, @"dataDict: %@", dataDict.description);
//        XCTAssertNotNil(dataFrame.JSONConvertedObject, @"dataFrame: %@", [dataFrame.JSONConvertedObject description]);
//        XCTAssertNotNil(data, @"data: %@", data);
//        XCTAssertNotNil(dataFrame.rawData, @"dataFrame: %@", dataFrame.rawData);
//        XCTAssertEqual(scene.allResponseFrames.count, 1);
//        BKRResponseFrame *responseFrame = scene.allResponseFrames.firstObject;
//        XCTAssertEqual(responseFrame.statusCode, 200);
//        [self assertResponse:responseFrame withResponse:response extraAssertions:nil];
    } taskTimeoutAssertions:^(NSURLSessionTask *task, NSError *error) {
//        XCTAssertEqual(scene.allRequestFrames.count, 2);
//        NSURLRequest *originalRequest = task.originalRequest;
//        BKRRequestFrame *originalRequestFrame = scene.originalRequest;
//        XCTAssertNotNil(originalRequestFrame);
//        [self assertRequest:originalRequestFrame withRequest:originalRequest extraAssertions:nil];
//        XCTAssertNotNil(scene.currentRequest);
//        [self assertRequest:scene.currentRequest withRequest:task.currentRequest extraAssertions:nil];
//        [self assertFramesOrder:scene extraAssertions:nil];
    }];
}

- (void)testPlayingOneCancelledGETRequest {
    
}

- (void)testPlayingOnePOSTRequest {
    
}

- (void)testPlayingMultipleGETRequests {
    
}

- (void)testPlayingTwoConsecutiveGETRequestsWithSameRequestURLAndDifferentResponses {
    
}

@end
