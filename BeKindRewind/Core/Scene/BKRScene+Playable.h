//
//  BKRScene+Playable.h
//  Pods
//
//  Created by Jordan Zucker on 2/12/16.
//
//

#import "BKRScene.h"
#import "BKRPlistSerializing.h"

@class BKRResponseStub;

/**
 *  This category handles the data associated with a network
 *  request and is intended to be used for stubbing.
 */
@interface BKRScene (Playable) <BKRPlistDeserializer>

- (NSUInteger)numberOfRedirects;
- (BOOL)hasRedirects;
- (NSString *)originalRequestURLAbsoluteString;
- (BKRResponseStub *)finalResponseStub;

- (BKRResponseStub *)responseStubForRedirectFrame:(BKRRedirectFrame *)redirectFrame;

- (BKRRequestFrame *)requestFrameForRedirect:(NSUInteger)redirectNumber;
- (BKRRedirectFrame *)redirectFrameForRedirect:(NSUInteger)redirectNumber;
- (NSString *)requestURLAbsoluteStringForRedirect:(NSUInteger)redirectNumber;
- (BKRResponseStub *)responseStubForRedirect:(NSUInteger)redirectNumber;

@end
