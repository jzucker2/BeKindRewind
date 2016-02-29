//
//  BKRScene+Playable.h
//  Pods
//
//  Created by Jordan Zucker on 2/12/16.
//
//

#import "BKRScene.h"
#import "BKRPlistSerializing.h"

/**
 *  This category handles the data associated with a network
 *  request and is intended to be used for stubbing.
 */
@interface BKRScene (Playable) <BKRPlistDeserializer>

/**
 *  Data associated with a network request
 *
 *  @return object representing serialized data returned from the network request
 */
- (NSData *)responseData;

/**
 *  Status code returned from server
 *
 *  @return integer value for HTTP status code
 */
- (NSInteger)responseStatusCode;

/**
 *  Headers contained in server response
 *
 *  @return headers as dictionary
 */
- (NSDictionary *)responseHeaders;

/**
 *  Error returned representing any potential networking issues
 *
 *  @return object should contain the elements included in a
 *  NSURLErrorDomain error
 */
- (NSError *)responseError;

@end
