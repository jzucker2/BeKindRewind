//
//  RecorderTestCase.swift
//  SwiftTests-iOS
//
//  Created by Jordan Zucker on 8/24/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import BeKindRewind

class RecorderTestCase: XCTestCase {
    
    let recorder = Recorder()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        XCTAssertNotNil(recorder)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasicRecorder() {
        XCTAssertTrue(true)
    }
    
}
