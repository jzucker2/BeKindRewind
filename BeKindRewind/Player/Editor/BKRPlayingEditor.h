//
//  BKRPlayingEditor.h
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKRConstants.h"
#import "BKREditor.h"
#import "BKRRequestMatching.h"

/**
 *  This subclass is for turning cassettes into stubs in a thread-safe manner
 *
 *  @since 1.0.0
 */
@interface BKRPlayingEditor : BKREditor

/**
 *  Designated initializer with a class for determining how to build playing sessions.
 *
 *  @param matcher this must conform to BKRRequestMatching
 *
 *  @return newly-initialized instance of BKRPlayingEditor
 *
 *  @since 1.0.0
 */
- (instancetype)initWithMatcher:(id<BKRRequestMatching>)matcher DEPRECATED_ATTRIBUTE;

/**
 *  Convenience initializer with a class for determining how to build playing sessions.
 *
 *  @param matcher this must conform to BKRRequestMatching
 *
 *  @return newly-initialized instance of BKRPlayingEditor
 *
 *  @since 1.0.0
 */
+ (instancetype)editorWithMatcher:(id<BKRRequestMatching>)matcher DEPRECATED_ATTRIBUTE;

/**
 *  This block is executed after a NSURLRequest fails to be matched
 *
 *  @since 2.1.0
 */
@property (nonatomic, copy, readonly) BKRRequestMatchingFailedBlock requestMatchingFailedBlock;

/**
 *  This is the matcher passed in during initialization. It is read-only
 *
 *  @since 1.0.0
 */
@property (nonatomic, strong, readonly) id<BKRRequestMatching>matcher;

@end
