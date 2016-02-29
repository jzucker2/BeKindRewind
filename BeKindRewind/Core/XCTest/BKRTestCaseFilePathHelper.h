//
//  BKRTestCaseFilePathHelper.h
//  Pods
//
//  Created by Jordan Zucker on 1/26/16.
//
//

#import "BKRFilePathHelper.h"

@class XCTestCase;

/**
 *  This is a subclass of BKRFilePathHelper tailored to help fetch and store network mocking
 *  information associated with a XCTestCase
 */
@interface BKRTestCaseFilePathHelper : BKRFilePathHelper

/**
 *  Default function for returning a dictionary of objects for creating a BKRPlayableCassette instance.
 *  Expects the plist to have a name matching testCase and in a NSBundle with a name matching
 *  `testCase.class` (the test suite).
 *
 *  @note if the NSBundle containing the fixture data is in the project but cannot be found 
 *        by this method, ensure it is still included in the testing target. See ____ for more details
 *  @note if there is not plist matching the expected location or the plist at the expected location
 *        does not have a NSDictionary as its root object, then an NSInternalInconsistencyException is thrown
 *
 *  @param testCase used to find the plist contained within the testing target for stubbing 
 *                  requests for the test run session.
 *
 *  @return dictionary that can be passed directly into a BKRPlayableCassette constructor
 */
+ (NSDictionary *)dictionaryForTestCase:(XCTestCase *)testCase;

/**
 *  This finds (if it already exists) or creates a NSBundle instance with a name matching
 *  `testCase.class` (the test suite) that can be used for storing (and later retrieving) 
 *  plists containing recordings for test case runs.
 *
 *  @note if the NSBundle instance is created, it must be added (dragged into the Xcode project). 
 *        See _____ for more details
 *
 *  @param testCase usually the currently executing test (during a test run this would be `self`). Exception
 *                  is thrown if this is nil
 *  @param filePath full path of directory to store or find NSBundle with name matching test suite. 
 *                  This is typically the result of documentsDirectory or fixtureWriteDirectoryInProject
 *
 *  @return valid NSBundle (created if one cannot be found) for saving network activity during a testing session
 */
+ (NSBundle *)writingBundleForTestCase:(XCTestCase *)testCase inDirectory:(NSString *)filePath; // possibly modify tests for this

/**
 *  This is used internally by other methods to build full file paths
 *
 *  @param testCase      XCTestCase instance to use for building the full path
 *  @param writingBundle NSBundle instance to search within
 *
 *  @return full path to write .plist in the file system
 */
+ (NSString *)writingFinalPathForTestCase:(XCTestCase *)testCase inBundle:(NSBundle *)writingBundle; //write tests for this

/**
 *  This method assumes the .plist of recordings is within an NSBundle named after the test suite
 *
 *  @param testCase XCTestCase instance to use for building the full path
 *  @param filePath file path that contains the NSBundle named after the test suite
 *
 *  @return full path to write .plist in the file system
 */
+ (NSString *)writingFinalPathForTestCase:(XCTestCase *)testCase inTestSuiteBundleInDirectory:(NSString *)filePath; // write tests for this

/**
 *  This should be the default method used to save recordings created during a test session. It finds and 
 *  creates intermediate directories to save the network recordings for a testing session. It
 *  saves the recordings in a NSBundle instance (created automatically if it does not already exist)
 *  that has a name matching `testCase.class` (the testCase instance's suite) and stores all the recordings in a
 *  single plist with a name matching testCase. This will overwrite any existing plist file matching testCase at
 *  full path location that starts at the directory specified by directoryPath.
 *
 *  @note if the NSBundle instance is created, it must be added (dragged into the Xcode project).
 *        See _____ for more details.
 *
 *  @param dictionary    dictionary of encodable plist objects
 *  @param testCase      usually the currently executing test (during a test run this would be `self`). Exception
 *                  is thrown if this is nil
 *  @param directoryPath full path of directory to store or find NSBundle with name matching test suite.
 *                  This is typically the result of documentsDirectory or fixtureWriteDirectoryInProject
 *
 *  @return YES if write succeeds and NO if write fails
 */
+ (BOOL)writeDictionary:(NSDictionary *)dictionary forTestCase:(XCTestCase *)testCase toDirectory:(NSString *)directoryPath;

@end
