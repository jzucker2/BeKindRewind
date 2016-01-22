//
//  BKRDataFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import "BKRFrame.h"
#import "BKRPlistSerializing.h"

@interface BKRDataFrame : BKRFrame <BKRPlistSerializing>

- (void)addData:(NSData *)data;

- (NSData *)rawData;

- (id)JSONConvertedObject;

@end
