//
//  BKRConfiguration.h
//  Pods
//
//  Created by Jordan Zucker on 2/23/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRRequestMatching.h"
#import "BKRVCRActions.h"

/**
 *  This is a configuration object for creating objects conforming to the BKRVCRActions protocol
 */
@interface BKRConfiguration : NSObject <BKRVCRRecording>

/**
 *  Initialize instance with a matcherClass conforming to the BKRRequestMatching protocol
 *
 *  @param matcherClass this is used for playing back network requests in the instance 
 *                      and must conform to BKRRequestMatching
 *
 *  @return newly initialized instance of BKRConfiguration
 */
- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;

/**
 *  Create an instance of BKRConfiguration with default options. The default matcher 
 *  class is BKRPlayheadMatcher
 *
 *  @return newly initialized instance of BKRConfiguration
 */
+ (instancetype)defaultConfiguration;

/**
 *  Convenience initializer that creates instance with a matcherClass conforming to 
 *  the BKRRequestMatching protocol
 *
 *  @param matcherClass this is used for playing back network requests in the instance
 *                      and must conform to BKRRequestMatching
 *
 *  @return newly initialized instance of BKRConfiguration
 */
+ (instancetype)configurationWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;

/**
 *  This is `YES` by default. When this is `NO`, an `eject:` command will not write an empty
 *  cassette to disk. When this is `YES`, an empty file is written to disk if no network
 *  requests are recorded.
 */
@property (nonatomic, assign) BOOL shouldSaveEmptyCassette;

/**
 *  Class conforming to BKRRequestMatching used to match requests to stubs when
 *  playing back network requests
 */
@property (nonatomic, assign) Class<BKRRequestMatching> matcherClass;

@end
