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
//@property (nonatomic, copy, readonly) BKRStubsTestBlock stubsTestBlock;
//@property (nonatomic, copy, readonly) BKRStubsResponseBlock stubsResponseBlock;
@end

@implementation BKRPlayingEditor

@synthesize matcher = _matcher;
//@synthesize stubsTestBlock = _stubsTestBlock;
//@synthesize stubsResponseBlock = _stubsResponseBlock;

- (instancetype)initWithMatcher:(id<BKRRequestMatching>)matcher {
    self = [super init];
    if (self) {
        _matcher = matcher;
    }
    return self;
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
        [self->_context addRequest:request];
        [self->_context incrementResponseCount];
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
    NSArray<BKRScene *> *currentScenes = (NSArray<BKRScene *> *)self->_context.allScenes;
    // reverse array: http://stackoverflow.com/questions/586370/how-can-i-reverse-a-nsarray-in-objective-c
    if (!currentScenes.count) {
        return;
    }
    [BKROHHTTPStubsWrapper stubRequestPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
//        return [self]
//        BOOL finalTestResult = [matcher hasMatchForRequest:request withContext:self->_context.copy];
//        // add in other checks as well
//        return finalTestResult;
        return [self _hasMatchForRequest:request withMatcher:matcher];
    } withStubResponse:^BKRResponseStub * _Nonnull(NSURLRequest * _Nonnull request) {
//        BKRResponseStub *responseStub = [matcher matchForRequest:request withContext:self->_context.copy];
        BKRResponseStub *responseStub = [self _responseStubForRequest:request withMatcher:matcher];
//        [self->_context addRequest:request];
//        [self->_context incrementResponseCount];
        return responseStub;
    }];
    NSLog(@"now completion block");
    // performed synchronously after above method
    if (completionBlock) {
        completionBlock(YES, nil); // ok to pass in nil for cassette, nothing else uses this value
    }
}

@end
