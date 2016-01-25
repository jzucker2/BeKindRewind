//
//  BKRPlayableScene.h
//  Pods
//
//  Created by Jordan Zucker on 1/21/16.
//
//

#import "BKRScene.h"
#import "BKRPlistSerializing.h"

@interface BKRPlayableScene : BKRScene <BKRPlistDeserializer>

- (NSData *)responseData;
- (NSInteger)responseStatusCode;
- (NSDictionary *)responseHeaders;
- (NSError *)responseError;

@end
