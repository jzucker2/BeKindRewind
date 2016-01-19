//
//  BKRData.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRData.h"

@interface BKRData ()
@property (nonatomic, copy) NSData *data;

@end

@implementation BKRData

//- (instancetype)initWithData:(NSData *)data {
//    self = [super init];
//    if (self) {
//        _data = data;
//    }
//    return self;
//}
//
//+ (instancetype)frameWithData:(NSData *)data {
//    return [[self alloc] initWithData:data];
//}

- (void)addData:(NSData *)data {
    self.data = data;
}

@end
