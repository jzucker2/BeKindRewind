//
//  BKRRawFrame+Recordable.m
//  Pods
//
//  Created by Jordan Zucker on 2/12/16.
//
//

#import "BKRRawFrame+Recordable.h"
#import "BKRDataFrame.h"
#import "BKRResponseFrame.h"
#import "BKRRequestFrame.h"
#import "BKRErrorFrame.h"

@implementation BKRRawFrame (Recordable)

- (BKRFrame *)editedRecording {
    if ([self.item isKindOfClass:[NSData class]]) {
        BKRDataFrame *dataFrame = [BKRDataFrame frameFromFrame:self];
        [dataFrame addData:self.item];
        return dataFrame;
    } else if ([self.item isKindOfClass:[NSURLResponse class]]) {
        BKRResponseFrame *responseFrame = [BKRResponseFrame frameFromFrame:self];
        [responseFrame addResponse:self.item];
        return responseFrame;
    } else if ([self.item isKindOfClass:[NSURLRequest class]]) {
        BKRRequestFrame *requestFrame = [BKRRequestFrame frameFromFrame:self];
        [requestFrame addRequest:self.item];
        return requestFrame;
    } else if ([self.item isKindOfClass:[NSError class]]) {
        BKRErrorFrame *errorFrame = [BKRErrorFrame frameFromFrame:self];
        [errorFrame addError:self.item];
        return errorFrame;
    } else {
        return nil;
    }
}

@end
