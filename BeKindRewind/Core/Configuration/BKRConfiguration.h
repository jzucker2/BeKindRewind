//
//  BKRConfiguration.h
//  Pods
//
//  Created by Jordan Zucker on 2/23/16.
//
//

#import "BKRConstants.h"
#import "BKRRequestMatching.h"
#import "BKRVCRActions.h"

typedef NS_ENUM(NSInteger, BKRMatchingStrictness) {
    BKRMatchingStrictnessNone = 0,
    BKRMatchingStrictnessFailForFinished,
    BKRMatchingStrictnessDefault = BKRMatchingStrictnessNone,
};

/**
 *  This is a configuration object for creating objects conforming to the BKRVCRActions protocol
 *
 *  @since 1.0.0
 */
@interface BKRConfiguration : NSObject <BKRVCRRecording>

/**
 *  Initialize instance with a matcherClass conforming to the BKRRequestMatching protocol
 *
 *  @param matcherClass this is used for playing back network requests in the instance 
 *                      and must conform to BKRRequestMatching
 *
 *  @return newly initialized instance of BKRConfiguration
 *
 *  @since 1.0.0
 */
- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;

/**
 *  Create an instance of BKRConfiguration with default options. The default matcher 
 *  class is BKRPlayheadMatcher
 *
 *  @return newly initialized instance of BKRConfiguration
 *
 *  @since 1.0.0
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
 *
 *  @since 1.0.0
 */
+ (instancetype)configurationWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;

/**
 *  This is `YES` by default. When this is `NO`, an `eject:` command will not write an empty
 *  cassette to disk. When this is `YES`, an empty file is written to disk if no network
 *  requests are recorded.
 *
 *  @since 1.0.0
 */
@property (nonatomic, assign) BOOL shouldSaveEmptyCassette;

/**
 *  Class conforming to BKRRequestMatching used to match requests to stubs when
 *  playing back network requests
 *
 *  @since 1.0.0
 */
@property (nonatomic, assign) Class<BKRRequestMatching> matcherClass;

/**
 *  This block is executed after a NSURLRequest fails to be matched
 *
 *  @since 2.1.0
 */
@property (nonatomic, copy) BKRRequestMatchingFailedBlock requestMatchingFailedBlock;

/**
 *  This determines how to handle 
 *
 *  @since 2.4.0
 */
@property (nonatomic, assign) BKRMatchingStrictness matchingStrictness;

@end
