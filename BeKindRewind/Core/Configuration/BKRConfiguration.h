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

@interface BKRConfiguration : NSObject <BKRVCRRecording>

- (instancetype)initWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;
+ (instancetype)defaultConfiguration;
+ (instancetype)configurationWithMatcherClass:(Class<BKRRequestMatching>)matcherClass;

@property (nonatomic, assign) BOOL shouldSaveEmptyCassette; // no by default
@property (nonatomic, assign) Class<BKRRequestMatching> matcherClass;

@end
