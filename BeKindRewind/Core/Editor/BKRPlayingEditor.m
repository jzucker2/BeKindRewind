//
//  BKRPlayingEditor.m
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKRPlayingEditor.h"
#import "BKRPlayingContext.h"
#import "BKROHHTTPStubsWrapper.h"
#import "BKRCassette+Playable.h"
#import "BKRScene+Playable.h"
#import "BKRConstants.h"
#import "BKRResponseStub.h"

@interface BKRPlayingEditor ()
@property (nonatomic, strong) BKRPlayingContext *context;
@end

@implementation BKRPlayingEditor

@synthesize matcher = _matcher;

- (instancetype)initWithMatcher:(id<BKRRequestMatching>)matcher {
    self = [super init];
    if (self) {
        _matcher = matcher;
        BKRWeakify(self);
        [BKROHHTTPStubsWrapper onStubActivation:^(NSURLRequest *request, BKRResponseStub *responseStub) {
            BKRStrongify(self);
            [self _stubActivationWithRequest:request responseStub:responseStub];
        }];
        [BKROHHTTPStubsWrapper onStubRedirectResponse:^(NSURLRequest *request, NSURLRequest *redirectRequest, BKRResponseStub *responseStub) {
            BKRStrongify(self);
            [self _stubRedirectWithRequest:request redirectRequest:redirectRequest responseStub:responseStub];
        }];
        [BKROHHTTPStubsWrapper onStubCompletion:^(NSURLRequest *request, BKRResponseStub *responseStub, NSError *error) {
            BKRStrongify(self);
            [self _stubCompletionWithRequest:request responseStub:responseStub error:error];
        }];
    }
    return self;
}

- (void)_stubActivationWithRequest:(NSURLRequest *)request responseStub:(BKRResponseStub *)responseStub {
    BKRWeakify(self);
    [self editCassette:^(BOOL updatedEnabled, BKRCassette *cassette) {
        BKRStrongify(self);
        if (!updatedEnabled) {
            return;
        }
        [self->_context startRequest:request withResponseStub:responseStub];
    }];
}

- (void)_stubRedirectWithRequest:(NSURLRequest *)request redirectRequest:(NSURLRequest *)redirectRequest responseStub:(BKRResponseStub *)responseStub {
    BKRWeakify(self);
    [self editCassette:^(BOOL updatedEnabled, BKRCassette *cassette) {
        BKRStrongify(self);
        if (!updatedEnabled) {
            return;
        }
        [self->_context redirectOriginalRequest:request withRedirectRequest:redirectRequest withResponseStub:responseStub];
    }];
}

- (void)_stubCompletionWithRequest:(NSURLRequest *)request responseStub:(BKRResponseStub *)responseStub error:(NSError *)error {
    BKRWeakify(self);
    [self editCassette:^(BOOL updatedEnabled, BKRCassette *cassette) {
        BKRStrongify(self);
        if (!updatedEnabled) {
            return;
        }
        [self->_context completeRequest:request withResponseStub:responseStub error:error];
    }];
}

+ (instancetype)editorWithMatcher:(id<BKRRequestMatching>)matcher {
    return [[self alloc] initWithMatcher:matcher];
}

- (void)setEnabled:(BOOL)enabled {
    [self setEnabled:enabled withCompletionHandler:nil];
}

- (void)setEnabled:(BOOL)enabled withCompletionHandler:(BKRCassetteEditingBlock)editingBlock {
    BKRWeakify(self);
    [super setEnabled:enabled withCompletionHandler:^void(BOOL updatedEnabled, BKRCassette *cassette) {
        BKRStrongify(self);
        if (updatedEnabled) {
            self->_context = [BKRPlayingContext contextWithScenes:cassette.allScenes];
            [self _addStubsForMatcher:self->_matcher withCompletionHandler:editingBlock];
        } else {
            self->_context = nil;
            [self _removeAllStubs];
            if (editingBlock) {
                editingBlock(updatedEnabled, cassette);
            }
        }

    }];
}

- (BOOL)_hasMatchForRequest:(NSURLRequest *)request withMatcher:(id<BKRRequestMatching>)matcher {
    __block BOOL finalTestResult = NO;
    BKRWeakify(self);
    [self readCassette:^(BOOL updatedEnabled, BKRCassette *cassette) {
        BKRStrongify(self);
        finalTestResult = [matcher hasMatchForRequest:request withContext:self->_context.copy];
        // add all the other checks here
    }];
    return finalTestResult;
}

- (BKRResponseStub *)_responseStubForRequest:(NSURLRequest *)request withMatcher:(id<BKRRequestMatching>)matcher {
    __block BKRResponseStub *responseStub = nil;
    BKRWeakify(self);
    [self editCassetteSynchronously:^(BOOL updatedEnabled, BKRCassette *cassette) {
        BKRStrongify(self);
        responseStub = [matcher matchForRequest:request withContext:self->_context.copy];
#warning update context for response
//        [self->_context addSceneResponseStub:responseStub forRequest:request];
        [self->_context addResponseStub:responseStub forRequest:request];
//        [self->_context addRequest:request];
//        [self->_context incrementResponseCount];
    }];
    return responseStub;
}

- (void)resetWithCompletionBlock:(void (^)(void))completionBlock {
    BKRWeakify(self);
    [super resetWithCompletionBlock:^void (void){
        BKRStrongify(self);
        if ([self->_matcher respondsToSelector:@selector(reset)]) {
            [self->_matcher reset];
        }
        self->_context = nil;
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)_removeAllStubs {
    [BKROHHTTPStubsWrapper removeAllStubs];
}

- (void)_addStubsForMatcher:(id<BKRRequestMatching>)matcher withCompletionHandler:(BKRCassetteEditingBlock)completionBlock {
    [BKROHHTTPStubsWrapper stubRequestPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [self _hasMatchForRequest:request withMatcher:matcher];
    } withStubResponse:^BKRResponseStub * _Nonnull(NSURLRequest * _Nonnull request) {
        BKRResponseStub *responseStub = [self _responseStubForRequest:request withMatcher:matcher];
        return responseStub;
    }];
    // performed synchronously after above method
    // this is called within the "com.BKR.editingQueue" queue that is part of the superclass
    if (completionBlock) {
        completionBlock(YES, nil); // ok to pass in nil for cassette, nothing else uses this value
    }
}

@end
