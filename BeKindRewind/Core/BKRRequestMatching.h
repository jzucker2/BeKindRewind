//
//  BKRRequestMatching.h
//  Pods
//
//  Created by Jordan Zucker on 1/22/16.
//
//

#import <Foundation/Foundation.h>

@class BKRPlayableScene;
@protocol BKRRequestMatching <NSObject>

+ (id<BKRRequestMatching>)matcher;

- (BOOL)hasMatchForRequest:(NSURLRequest *)request withPlayheadIdentifier:(NSString *)playheadIdentifier inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;

- (BKRPlayableScene *)matchForRequest:(NSURLRequest *)request withPlayheadIdentifier:(NSString *)playheadIdentifier inPlayableScenes:(NSArray<BKRPlayableScene *> *)scenes;

@optional

- (NSDictionary *)queryItemsForRequest:(NSURLRequest *)request;
- (NSString *)hostForRequest:(NSURLRequest *)request;

@end
