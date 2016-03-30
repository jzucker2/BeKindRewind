//
//  BKRPlayhead.m
//  Pods
//
//  Created by Jordan Zucker on 3/15/16.
//
//

#import "BKRPlayhead.h"
#import "BKRResponseStub.h"
#import "BKRConstants.h"
#import "BKRScene+Playable.h"
#import "NSArray+BKRAdditions.h"

//typedef returnType (^TypeName)(parameterTypes);
//TypeName blockName = ^returnType(parameters) {...};
typedef void (^BKRUpdatePlayheadItemBlock)(BKRPlayheadItem *item);

@interface BKRPlayheadItem ()
@property (nonatomic, strong, readwrite) BKRScene *scene;
@end

@implementation BKRPlayheadItem

- (instancetype)initItemWithScene:(BKRScene *)scene {
    self = [super init];
    if (self) {
        _scene = scene;
//        _redirectsRemaining = scene.allRedirectFrames.count;
        _redirectsCompleted = 0;
        _state = BKRPlayingSceneStateInactive;
        _responseStubs = [NSMutableArray array];
        _requests = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)itemWithScene:(BKRScene *)scene {
    return [[self alloc] initItemWithScene:scene];
}

- (NSUInteger)expectedNumberOfRedirects {
    return self.scene.numberOfRedirects;
}

- (BOOL)expectsRedirect {
    return ((self.expectedNumberOfRedirects - self.numberOfRedirectsStubbed) > 0);
}

- (NSUInteger)numberOfRedirectsStubbed {
    __block NSUInteger redirectsStubbed = 0;
    [self.responseStubs.copy enumerateObjectsUsingBlock:^(BKRResponseStub * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isRedirect) {
            redirectsStubbed++;
        }
    }];
    return redirectsStubbed;
}

- (BOOL)hasFinalResponseStub {
    return [self.responseStubs.copy BKR_any:^BOOL(id obj) {
        BKRResponseStub *responseStub = (BKRResponseStub *)obj;
        // if the BKRPlayheadItem contains a non redirect response, it has a finalResponseStub
        return (!responseStub.isRedirect);
    }];
}

@end

@interface BKRPlayhead () <NSCopying>
@property (nonatomic, strong, readwrite) NSArray<BKRPlayheadItem *> *allItems;
@end

@implementation BKRPlayhead

- (instancetype)initWithScenes:(NSArray<BKRScene *> *)scenes {
    self = [super init];
    if (self) {
        __block NSMutableArray<BKRPlayheadItem *> *items = [NSMutableArray array];
        [scenes enumerateObjectsUsingBlock:^(BKRScene * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [items addObject:[BKRPlayheadItem itemWithScene:obj]];
        }];
        _allItems = items.copy;
    }
    return self;
}

+ (instancetype)playheadWithScenes:(NSArray<BKRScene *> *)scenes {
    return [[self alloc] initWithScenes:scenes];
}

- (void)startRequest:(NSURLRequest *)request withResponseStub:(BKRResponseStub *)responseStub {
    NSLog(@"%s request (%@, %@) responseStub (%@)", __PRETTY_FUNCTION__, request, request.allHTTPHeaderFields, responseStub);
    [self _updateStateToState:BKRPlayingSceneStateActive forResponseStub:responseStub withExtraProcessingBlock:nil];
}

- (void)redirectOriginalRequest:(NSURLRequest *)request withRedirectRequest:(NSURLRequest *)redirectRequest withResponseStub:(BKRResponseStub *)responseStub {
    NSLog(@"%s request (%@, %@) redirectRequest (%@, %@) responseStub (%@)", __PRETTY_FUNCTION__, request, request.allHTTPHeaderFields, redirectRequest, redirectRequest.allHTTPHeaderFields, responseStub);
//    [self _updateStateToState:BKRPlayingSceneStateRedirecting forResponseStub:responseStub withExtraProcessingBlock:^(BKRPlayheadItem *item) {
//        item.redirectsRemaining--;
//    }];
    [self _updateFirstPlayheadItemMatchingResponseStub:responseStub withUpdateBlock:^(BKRPlayheadItem *item) {
        item.redirectsCompleted--;
    }];
}

- (void)completeRequest:(NSURLRequest *)request withResponseStub:(BKRResponseStub *)responseStub error:(NSError *)error {
    NSLog(@"%s request (%@, %@) responseStub (%@) error (%@)", __PRETTY_FUNCTION__, request, request.allHTTPHeaderFields, responseStub, error);
    [self _updateStateToState:BKRPlayingSceneStateCompleted forResponseStub:responseStub withExtraProcessingBlock:nil];
}

- (void)_updateStateToState:(BKRPlayingSceneState)updatedState forResponseStub:(BKRResponseStub *)responseStub withExtraProcessingBlock:(BKRUpdatePlayheadItemBlock)updateItemBlock {
    [self _updateFirstPlayheadItemMatchingResponseStub:responseStub withUpdateBlock:^(BKRPlayheadItem *item) {
        item.state = updatedState;
        if (updateItemBlock) {
            updateItemBlock(item);
        }
    }];
}

- (NSArray<BKRPlayheadItem *> *)inactiveItems {
    return [self.allItems filteredArrayUsingPredicate:[self _predicateForItemWithState:BKRPlayingSceneStateInactive]];
}

- (NSArray<BKRPlayheadItem *> *)activeItems {
    return [self.allItems filteredArrayUsingPredicate:[self _predicateForItemWithState:BKRPlayingSceneStateActive]];
}

- (NSArray<BKRPlayheadItem *> *)redirectingItems {
//    return [self.allItems filteredArrayUsingPredicate:[self _predicateForItemWithState:BKRPlayingSceneStateRedirecting]];
    return [self.allItems BKR_select:^BOOL(id obj) {
        BKRPlayheadItem *item = (BKRPlayheadItem *)obj;
        return item.expectsRedirect;
    }];
}

- (NSArray<BKRPlayheadItem *> *)completedItems {
    return [self.allItems filteredArrayUsingPredicate:[self _predicateForItemWithState:BKRPlayingSceneStateCompleted]];
}

- (NSArray<BKRPlayheadItem *> *)incompleteItems {
    //    NSCompoundPredicate *activeOrRedirectingPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[[self _predicateForItemWithState:BKRPlayingSceneStateActive], [self _predicateForItemWithState:BKRPlayingSceneStateRedirecting]]];
    NSPredicate *incompleteItemsPredicate = [NSPredicate predicateWithFormat:@"self.state != %ld", (long)BKRPlayingSceneStateCompleted];
    return [self.allItems filteredArrayUsingPredicate:incompleteItemsPredicate];
}

- (NSPredicate *)_predicateForItemWithState:(BKRPlayingSceneState)state {
    [NSString stringWithFormat:@"%ld", (long)state];
    return [NSPredicate predicateWithFormat:@"self.state == %ld", (long)state];
    //    return [NSPredicate predicateWithFormat:]
}

- (void)_updateFirstPlayheadItemMatchingResponseStub:(BKRResponseStub *)responseStub withUpdateBlock:(BKRUpdatePlayheadItemBlock)updateItemBlock {
    [self.allItems enumerateObjectsUsingBlock:^(BKRPlayheadItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.scene.uniqueIdentifier isEqualToString:responseStub.sceneIdentifier]) {
            if (updateItemBlock) {
                updateItemBlock(obj);
            }
            *stop = YES;
        }
    }];
}

- (void)addResponseStub:(BKRResponseStub *)responseStub forRequest:(NSURLRequest *)request {
    [self _updateFirstPlayheadItemMatchingResponseStub:responseStub withUpdateBlock:^(BKRPlayheadItem *item) {
        [item.responseStubs addObject:responseStub];
        [item.requests addObject:request];
    }];
}

- (id)copyWithZone:(NSZone *)zone {
    BKRPlayhead *playhead = [[[self class] allocWithZone:zone] init];
    playhead.allItems = self.allItems;
    return playhead;
}

@end
