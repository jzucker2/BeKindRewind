//
//  BKRPlayingEditor.h
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKREditor.h"
#import "BKRRequestMatching.h"

/**
 *  This subclass is for turning cassettes into stubs in a thread-safe manner
 */
@interface BKRPlayingEditor : BKREditor

/**
 *  Designated initializer with a class for determining how to build playing sessions.
 *
 *  @param matcher this must conform to BKRRequestMatching
 *
 *  @return newly-initialized instance of BKRPlayingEditor
 */
- (instancetype)initWithMatcher:(id<BKRRequestMatching>)matcher;

/**
 *  Convenience initializer with a class for determining how to build playing sessions.
 *
 *  @param matcher this must conform to BKRRequestMatching
 *
 *  @return newly-initialized instance of BKRPlayingEditor
 */
+ (instancetype)editorWithMatcher:(id<BKRRequestMatching>)matcher;

/**
 *  This is the matcher passed in during initialization. It is read-only
 */
@property (nonatomic, strong, readonly) id<BKRRequestMatching>matcher;

@end
