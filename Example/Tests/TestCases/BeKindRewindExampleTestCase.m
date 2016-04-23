//
//  BeKindRewindExampleTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 2/28/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

//  keep this simple to test the import,
//  this test case is used in the README
#import <BeKindRewind/BeKindRewind.h>

@interface BeKindRewindExampleTestCase : BKRTestCase
@end

@implementation BeKindRewindExampleTestCase

- (BOOL)isRecording {
    return YES;
}

- (void)testSimpleNetworkCall {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://httpbin.org/get?test=test"]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    
    // Don't forget to create a test expectation, this has the __block annotation to avoid a retain cycle
    // XCTestExpectation is necessary for asynchronous network activity, BeKindRewind will take care of everything else
    __block XCTestExpectation *networkExpectation = [self expectationWithDescription:@"network"];
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
        // Assert fail if timeout encounters an error
        XCTAssertNil(error);
    }];
}

@end
