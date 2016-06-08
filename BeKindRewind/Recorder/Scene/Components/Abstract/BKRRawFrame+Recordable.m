//
//  BKRRawFrame+Recordable.m
//  Pods
//
//  Created by Jordan Zucker on 2/12/16.
//
//

#import "BKRRawFrame+Recordable.h"
#import "BKRDataFrame.h"
#import "BKRRedirectFrame.h"
#import "BKRResponseFrame.h"
#import "BKRRequestFrame.h"
#import "BKRErrorFrame.h"

@implementation BKRRawFrame (Recordable)

- (BKRFrame *)editedRecordingWithContext:(BKRRecordingContext)context {
    // array is typically expected for redirects only
    if (
        [self.item isKindOfClass:[NSDictionary class]] &&
        (context == BKRRecordingContextRedirecting)
        ) {
        // init a redirect frame
        NSDictionary *redirectDict = self.item;
        BKRRedirectFrame *redirectFrame = [BKRRedirectFrame frameFromFrame:self];
        NSURLResponse *response = redirectDict[kBKRRedirectResponseKey];
        if (response) {
            [redirectFrame addResponse:response];
        }
        NSURLRequest *request = redirectDict[kBKRRedirectRequestKey];
        if (request) {
            [redirectFrame addRequest:request];
        }
        if (
            !redirectFrame.requestFrame &&
            !redirectFrame.responseFrame
            ) {
            // no point in saving a redirect with no request or response
            return nil;
        }
        return redirectFrame;
    }
    if ([self.item isKindOfClass:[NSData class]]) {
        BKRDataFrame *dataFrame = [BKRDataFrame frameFromFrame:self];
        [dataFrame addData:self.item];
        return dataFrame;
    } else if ([self.item isKindOfClass:[NSURLResponse class]]) {
        BKRResponseFrame *responseFrame = [BKRResponseFrame frameFromFrame:self];
        [responseFrame addResponse:self.item];
        return responseFrame;
    } else if ([self.item isKindOfClass:[NSURLRequest class]]) {
        BKRRequestFrame *requestFrame = nil;
        switch (context) {
            case BKRRecordingContextBeginning:
            {
                BKROriginalRequestFrame *originalRequestFrame = [BKROriginalRequestFrame frameFromFrame:self];
                [originalRequestFrame addRequest:self.item];
                requestFrame = originalRequestFrame;
            }
                break;
            case BKRRecordingContextAddingCurrentRequest:
            {
                BKRCurrentRequestFrame *currentRequestFrame = [BKRCurrentRequestFrame frameFromFrame:self];
                [currentRequestFrame addRequest:self.item];
                requestFrame = currentRequestFrame;
            }
                break;
            case BKRRecordingContextExecuting:
            case BKRRecordingContextRedirecting:
            case BKRRecordingContextUnknown:
                break;
        }
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
