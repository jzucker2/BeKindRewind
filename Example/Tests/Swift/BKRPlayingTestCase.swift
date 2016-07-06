//
//  BKRPlayingTestCase.swift
//  BeKindRewind
//
//  Created by Jordan Zucker on 6/29/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

import XCTest
import BeKindRewind

class BKRPlayingTestCase: BKRTestCase {
    
    override func isRecording() -> Bool {
        return false
    }
    
    override func setUp() {
        super.setUp()
        XCTAssertNotNil(self.currentVCR)
    }
    
    func testPlayingOneGETRequest() {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
        guard let requestURL = NSURL(string: "https://httpbin.org/get?test=test") else {
            XCTFail("Failed to create requestURL")
            return
        }
        
        let request = NSURLRequest(URL: requestURL)
        let expectation = self.expectationWithDescription("get request")
        let task = session.dataTaskWithRequest(request) { (data, rawResponse, error) in
//            defer {
//                expectation.fulfill()
//            }
            guard let response = rawResponse as? NSHTTPURLResponse else {
                expectation.fulfill()
                XCTFail("Failed to parse raw response")
                return
            }
            
//            guard let headers: [String: AnyObject] = response.allHeaderFields else {
//                expectation.fulfill()
//                XCTFail("Failed to convert headers")
//                return
//            }
            
            
//            guard let responseDateString: String = headers["date"] else {
//                expectation.fulfill()
//                XCTFail("Failed to find a date")
//                return
//            }
            
            let playbackDateString = "Thu, 18 Feb 2016 18:18:46 GMT"
            
//            XCTAssertEqual(responseDateString, playbackDateString)
            expectation.fulfill()
        }
        task.resume()
        self.waitForExpectationsWithTimeout(5) { (error) in
            XCTAssertNil(error)
        }
    }
    
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//    
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//    
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
