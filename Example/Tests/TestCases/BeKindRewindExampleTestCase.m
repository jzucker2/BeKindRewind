//
//  BeKindRewindExampleTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/28/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <BeKindRewind/BKRTestCase.h>

@interface BeKindRewindExampleTestCase : BKRTestCase
@end

@implementation BeKindRewindExampleTestCase

- (BOOL)isRecording {
    return YES;
}

- (void)testSimpleNetworkCall {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://httpbin.org/get?test=test"]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    
    // don't forget to create a test expectation
    XCTestExpectation *networkExpectation = [self expectationWithDescription:@"network"];
    NSURLSessionDataTask *basicGetTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertNotNil(data);
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        XCTAssertNil(error);
        XCTAssertEqualObjects(dataDict[@"args"], @{@"test" : @"test"});
        // fulfill the expectation
        [networkExpectation fulfill];
    }];
    [basicGetTask resume];
    // explicitly wait for the expectation
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            // Assert fail if timeout encounters an error
            XCTAssertNil(error);
        }
    }];
}

@end
