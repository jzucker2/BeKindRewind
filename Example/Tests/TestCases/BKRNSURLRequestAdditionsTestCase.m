//
//  BKRNSURLRequestAdditionsTestCase.m
//  BeKindRewind
//
//  Created by Jordan Zucker on 3/15/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <BeKindRewind/NSURLRequest+BKRAdditions.h>

@interface BKRNSURLRequestAdditionsTestCase : XCTestCase

@end

@implementation BKRNSURLRequestAdditionsTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCompareBasicRequestsWithEqualStringsAndNoOptions {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
    NSURLRequest *otherRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
    XCTAssertNotNil(request);
    XCTAssertNotNil(otherRequest);
    XCTAssertTrue([request BKR_isEquivalentToRequest:otherRequest options:nil]);
}

- (void)testCompareBasicRequestsWithUnequalStringsAndNoOptions {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://googles.com"]];
    NSURLRequest *otherRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
    XCTAssertNotNil(request);
    XCTAssertNotNil(otherRequest);
    XCTAssertFalse([request BKR_isEquivalentToRequest:otherRequest options:nil]);
}

- (void)testCompareRequestsWithDifferentQueryItemsOrder {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com/path?foo=bar&baz=qux"]];
    NSURLRequest *otherRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com/path?baz=qux&foo=bar"]];
    XCTAssertNotNil(request);
    XCTAssertNotNil(otherRequest);
    XCTAssertFalse([request BKR_isEquivalentToRequest:otherRequest options:nil]);
    NSDictionary *options = @{
                              kBKRShouldIgnoreQueryItemsOrder: @NO
                              };
    XCTAssertFalse([request BKR_isEquivalentToRequest:otherRequest options:options]);
    options = @{
                kBKRShouldIgnoreQueryItemsOrder: @YES
                };
    XCTAssertTrue([request BKR_isEquivalentToRequest:otherRequest options:options]);
}

- (void)testCompareRequestsAndIgnoreQueryItemsWithSpecificNames {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com/path?foo=bar&baz=qux"]];
    NSURLRequest *otherRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com/path?foo=what&baz=qux"]];
    XCTAssertNotNil(request);
    XCTAssertNotNil(otherRequest);
    XCTAssertFalse([request BKR_isEquivalentToRequest:otherRequest options:nil]);
    NSDictionary *options = @{
                              kBKRIgnoreQueryItemNames: @[@"foo"]
                              };
    XCTAssertTrue([request BKR_isEquivalentToRequest:otherRequest options:options]);
}

- (void)testCompareRequestsAndIgnoreQueryItemsWithSpecificNamesAndIgnoreQueryItemsOrder {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com/path?foo=bar&baz=qux&third=three"]];
    NSURLRequest *otherRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com/path?baz=qux&third=three&foo=what"]];
    XCTAssertNotNil(request);
    XCTAssertNotNil(otherRequest);
    XCTAssertFalse([request BKR_isEquivalentToRequest:otherRequest options:nil]);
    NSDictionary *options = @{
                              kBKRShouldIgnoreQueryItemsOrder: @YES,
                              kBKRIgnoreQueryItemNames: @[@"foo"]
                              };
    XCTAssertTrue([request BKR_isEquivalentToRequest:otherRequest options:options]);
}

- (void)testCompareRequestsAndIgnoreSpecificComponentsProperties {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com/foo/bar"]];
    NSURLRequest *otherRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com/bar/foo"]];
    XCTAssertNotNil(request);
    XCTAssertNotNil(otherRequest);
    XCTAssertFalse([request BKR_isEquivalentToRequest:otherRequest options:nil]);
    NSDictionary *options = @{};
    XCTAssertFalse([request BKR_isEquivalentToRequest:otherRequest options:options]);
    options = @{
                kBKRIgnoreNSURLComponentsProperties: @[@"path"],
                };
    XCTAssertTrue([request BKR_isEquivalentToRequest:otherRequest options:options]);
}

- (void)testCompareRequestsAndIgnoreSpecificComponentsPropertiesAndIgnoreQueryItemsWithSpecificNamesAndIgnoreQueryItemsOrder {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com/path?foo=bar&baz=qux&third=three"]];
    NSURLRequest *otherRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com/other_path?baz=qux&third=three&foo=what"]];
    XCTAssertNotNil(request);
    XCTAssertNotNil(otherRequest);
    XCTAssertFalse([request BKR_isEquivalentToRequest:otherRequest options:nil]);
    NSDictionary *options = @{
                              kBKRIgnoreNSURLComponentsProperties: @[@"path"],
                              kBKRShouldIgnoreQueryItemsOrder: @YES,
                              kBKRIgnoreQueryItemNames: @[@"foo"]
                              };
    XCTAssertTrue([request BKR_isEquivalentToRequest:otherRequest options:options]);
}

@end
