//
//  BKRScene+Playable.m
//  Pods
//
//  Created by Jordan Zucker on 2/12/16.
//
//

#import "BKRScene+Playable.h"
#import "BKRRawFrame+Playable.h"
#import "BKRResponseFrame.h"
#import "BKRErrorFrame.h"
#import "BKRDataFrame.h"
#import "BKRRequestFrame.h"
#import "BKRRedirectFrame.h"
#import "BKRResponseStub.h"
#import "BKRConstants.h"
#import "NSURL+BKRAdditions.h"

@implementation BKRScene (Playable)

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    NSParameterAssert(dictionary);
    self = [self init];
    if (self) {
        self.uniqueIdentifier = dictionary[@"uniqueIdentifier"];
        [self _addEditedFrames:dictionary[@"frames"]];
    }
    return self;
}

- (void)_addEditedFrames:(NSArray<NSDictionary *> *)rawFrames {
    BKRWeakify(self);
    dispatch_queue_t editingQueue = dispatch_queue_create("com.BKRPlayableScene.editingQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_apply(rawFrames.count, editingQueue, ^(size_t iteration) {
        BKRStrongify(self);
        BKRRawFrame *rawFrame = [[BKRRawFrame alloc] initFromPlistDictionary:rawFrames[iteration]];
        [self addFrameToFramesArray:rawFrame.editedPlaying];
    });
}

- (NSData *)_responseData {
    NSMutableData *responseData = [NSMutableData data];
    NSNumber *secondResponseTimestamp = self.allResponseFrames.lastObject.creationDate;
    for (BKRDataFrame *dataFrame in self.allDataFrames) {
        // turns out that NSURLSession might record two responses and receive
        // the first packet of data twice, but it only returns data received after the second
        // NSURLResponse (including resending NSData itself to simulate receiving
        // it after). This is hidden from the user when the completion handler
        // delivers all the data at the end
        // so check to make sure this data was created after the last response date
        if ([dataFrame.creationDate compare:secondResponseTimestamp] == NSOrderedDescending) {
            [responseData appendData:dataFrame.rawData];
        }
    }
    return responseData.copy;
}

- (NSInteger)_responseStatusCode {
    BKRResponseFrame *responseFrame = self.allResponseFrames.firstObject;
    return responseFrame.statusCode;
}

- (NSDictionary *)_responseHeadersForFrame:(BKRResponseFrame *)responseFrame {
    NSMutableDictionary *responseHeaders = responseFrame.allHeaderFields.mutableCopy;
    NSString *redirectLocation = responseHeaders[@"Location"];
    if (redirectLocation) {
        NSURLComponents *redirectComponents = [NSURLComponents componentsWithString:redirectLocation];
        if (!redirectComponents.scheme) {
            // we need to build an absolute path URL for OHHTTPStubs
#warning fix this!
            NSURL *temporaryRedirectLocationURL = [NSURL URLWithString:redirectLocation];
            NSURL *baseURL = [responseFrame.URL BKR_baseURL];
            NSURL *finalRedirectLocationURL = [NSURL URLWithString:redirectLocation relativeToURL:baseURL];
            responseHeaders[@"Location"] = finalRedirectLocationURL.absoluteString;
        }
    }
    responseHeaders[kBKRSceneUUIDKey] = self.uniqueIdentifier;
    return responseHeaders.copy;
}

- (NSError *)_responseError {
    BKRErrorFrame *responseFrame = self.allErrorFrames.firstObject;
    return responseFrame.error;
}

- (BKRResponseStub *)finalResponseStub {
    NSError *responseError = [self _responseError];
    if (!responseError) {
        BKRResponseFrame *responseFrame = self.allResponseFrames.firstObject;
        return [BKRResponseStub responseWithData:[self _responseData] statusCode:(int)[self _responseStatusCode] headers:[self _responseHeadersForFrame:responseFrame]];
    }
    return [BKRResponseStub responseWithError:responseError];
}

- (NSUInteger)numberOfRedirects {
    return self.allRedirectFrames.count;
}

- (BOOL)hasRedirects {
    return (self.numberOfRedirects > 0);
}

- (BKRRequestFrame *)requestFrameForRedirect:(NSUInteger)redirectNumber {
    return [self redirectFrameForRedirect:redirectNumber].requestFrame;
}

- (BKRRedirectFrame *)redirectFrameForRedirect:(NSUInteger)redirectNumber {
    if (redirectNumber >= self.allRedirectFrames.count) {
        return nil;
    }
    return self.allRedirectFrames[redirectNumber];
}

- (BKRResponseStub *)responseStubForRedirectFrame:(BKRRedirectFrame *)redirectFrame {
    if (!redirectFrame) {
        NSError *error = [NSError errorWithDomain:@"BeKindRewind" code:-999 userInfo:@{
                                                                                       NSLocalizedDescriptionKey: @"No expected to redirect this many times",
                                                                                       NSLocalizedFailureReasonErrorKey: @"Too many redirects encountered!",
                                                                                       kBKRSceneUUIDKey: self.uniqueIdentifier
                                                                                       }];
        return [BKRResponseStub responseWithError:error];
    }
    NSDictionary *headers = [self _responseHeadersForFrame:redirectFrame.responseFrame];
    return [BKRResponseStub responseWithData:nil statusCode:(int)redirectFrame.responseFrame.statusCode headers:headers];
}

- (BKRResponseStub *)responseStubForRedirect:(NSUInteger)redirectNumber {
    BKRRedirectFrame *redirectFrame = [self redirectFrameForRedirect:redirectNumber];
    return [self responseStubForRedirectFrame:redirectFrame];
}

- (NSString *)originalRequestURLAbsoluteString {
    return self.originalRequest.URLAbsoluteString;
}

- (NSString *)requestURLAbsoluteStringForRedirect:(NSUInteger)redirectNumber {
    return [self requestFrameForRedirect:redirectNumber].URLAbsoluteString;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%p>: request: %@", self, self.originalRequest.URL];
}

@end
