//
//  BKRDataFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import "BKRFrame.h"
#import "BKRPlistSerializing.h"

/**
 *  Concrete subclass of BKRFrame representing NSData associated with a network operation
 */
@interface BKRDataFrame : BKRFrame <BKRPlistSerializing>

/**
 *  Add the data that this subclass of BKRFrame is meant to represent
 *
 *  @param data received from server response
 */
- (void)addData:(NSData *)data;

/**
 *  These are the bytes representing the data received from a server request/response
 *
 *  @return plain bytes wrapped in an NSData object
 */
- (NSData *)rawData;

/**
 *  If there is data stored in the rawData property, this method attempts to return
 *  a JSON converted representation of that data. If the data cannot be converted into
 *  JSON, then the serialization error is logged to the console.
 *
 *  @return a JSON representation of the data, or nil if the data cannot be serialized into JSON
 */
- (id)JSONConvertedObject;

@end
