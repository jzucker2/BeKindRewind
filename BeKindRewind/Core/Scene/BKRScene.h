//
//  BKRScene.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>

@interface BKRScene : NSObject

- (instancetype)initWithTask:(NSURLSessionTask *)task;
+ (instancetype)sceneWithTask:(NSURLSessionTask *)task;

@property (nonatomic, copy) NSString *uniqueIdentifier;

@end
