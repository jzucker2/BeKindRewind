//
//  BKRResponseFrame.h
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import "BKRFrame.h"
#import "BKRPlistSerializing.h"

/**
 *  Concrete subclass of BKRFrame representing NSURLResponse or NSHTTPURLResponse 
 *  associated with a network operation
 */
@interface BKRResponseFrame : BKRFrame <BKRPlistSerializing>

/**
 *  The URL associated with the response
 */
@property (nonatomic, copy, readonly) NSURL *URL;

/**
 *  The MIME type of the response object
 */
@property (nonatomic, copy, readonly) NSString *MIMEType;

/**
 *  This will be -1 if the response is of NSURLResponse but not an HTTP response.
 *  If the response is an actual HTTPResponse (Foundation represents this as an instance
 *  of NSHTTPURLResponse) then this will be the HTTP response status code returned from
 *  the server during the network operation
 */
@property (nonatomic, readonly) NSInteger statusCode;

/**
 *  Dictionary representing the header fields associated with the response
 *  received during the network operation.
 */
@property (nonatomic, copy, readonly) NSDictionary *allHeaderFields;

/**
 *  Add the response that this subclass of BKRFrame is meant to represent
 *
 *  @param response this is the HTTP response received from the server
 *         during a network operation. It can be of the NSURLResponse class
 *         or the NSHTTPURLResponse class
 */
- (void)addResponse:(NSURLResponse *)response;

@end
