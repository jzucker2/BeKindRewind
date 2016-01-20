//
//  BKRDataFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import "BKRFrame.h"
#import "BKRSerializer.h"

@interface BKRDataFrame : BKRFrame <BKRSerializer>

- (void)addData:(NSData *)data;

- (NSData *)rawData;

- (id)JSONConvertedObject;

@end
