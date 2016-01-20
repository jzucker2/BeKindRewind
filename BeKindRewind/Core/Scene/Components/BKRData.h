//
//  BKRData.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRFrame.h"
#import "BKRSerializer.h"

@interface BKRData : BKRFrame <BKRSerializer>

- (void)addData:(NSData *)data;

- (NSData *)rawData;

- (id)JSONConvertedObject;

@end
