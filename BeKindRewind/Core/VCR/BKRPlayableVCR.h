//
//  BKRPlayableVCR.h
//  Pods
//
//  Created by Jordan Zucker on 2/9/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRVCRActions.h"
#import "BKRRequestMatching.h"

@interface BKRPlayableVCR : NSObject <BKRVCRActions, BKRVCRPlaying>

/**
 *  Designated intializer for creating a BKRVCR instance. Must provide a
 *  matcherClass so that play back can occur. Once a BKRVCR instance is initialized,
 *  the matcher created by matcherClass cannot be changed.
 *
 *
 *  @param matcherClass class must conform to BKRRequestMatching and will be
 *                      used to construct stubs for playing back network operations. Throws
 *                      NSInternalInconsistency exception if this is nil
 *
 *
 *  @return newly initialized instance of BKRVCR
 */
- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;

/**
 *  Convenience constructor for creating a BKRVCR instance. Must provide a
 *  matcherClass so that play back can occur. Once a BKRVCR instance is initialized,
 *  the matcher created by matcherClass cannot be changed.
 *
 *  @param matcherClass class must conform to BKRRequestMatching and will be used to
 *                      construct stubs for playing back network operations. Throws
 *                      NSInternalInconsistency exception if this is nil
 *
 *  @return newly initialized instance of BKRVCR
 */
+ (instancetype)vcrWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;

/**
 *  This is the matcher object created during class initialization. It is
 *  used internally by the internal BKRPlayer instance to create the stubs
 *  used in playing back network operations.
 */
@property (nonatomic, strong, readonly) id<BKRRequestMatching> matcher;

@end
