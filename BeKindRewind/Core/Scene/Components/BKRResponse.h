//
//  BKRResponse.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "BKRFrame.h"

@interface BKRResponse : BKRFrame

@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSString *MIMEType;
@property (nonatomic, readonly) NSInteger statusCode;
@property (nonatomic, copy, readonly) NSDictionary *allHeaderFields;

- (void)addResponse:(NSURLResponse *)response;

@end
