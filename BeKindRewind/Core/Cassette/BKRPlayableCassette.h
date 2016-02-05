//
//  BKRPlayableCassette.h
//  Pods
//
//  Created by Jordan Zucker on 1/21/16.
//
//

#import "BKRCassette.h"
#import "BKRPlistSerializing.h"
#import "BKRConstants.h"

@interface BKRPlayableCassette : BKRCassette <BKRPlistDeserializer>

- (void)executeAfterAddingStubsBlock:(BKRAfterAddingStubs)afterStubsBlock;

@end
