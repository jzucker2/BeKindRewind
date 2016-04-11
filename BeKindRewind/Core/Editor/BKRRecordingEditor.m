//
//  BKRRecordingEditor.m
//  Pods
//
//  Created by Jordan Zucker on 1/29/16.
//
//

#import "BKRRecordingEditor.h"
#import "BKRCassette+Recordable.h"
#import "BKRRawFrame+Recordable.h"
#import "BKRConstants.h"

/**
 *  This object is used to track unique network components
 *  across NSURLSessionTask instances
 */
@interface BKRNetworkItem : NSObject

/**
 *  This is the network component to compare
 *  (NSURLRequest, NSURLResponse, NSData, etc.)
 */
@property (nonatomic, strong) id item;

/**
 *  This is the unique identifier assigned to the 
 *  task by BeKindRewind
 */
@property (nonatomic, copy) NSString *uniqueIdentifier;

/**
 *  Convenience constructor for object
 *
 *  @param rawFrame unit of a network event
 *
 *  @return newly initialized instance of BKRNetworkItem
 */
+ (instancetype)itemWithRawFrame:(BKRRawFrame *)rawFrame;

/**
 *  Designated initializer for object
 *
 *  @param rawFrame unit of a network event
 *
 *  @return newly initialized instance of BKRNetworkItem
 */
- (instancetype)initWithRawFrame:(BKRRawFrame *)rawFrame;

/**
 *  This is used to test equality
 *
 *  @param networkItem other instance to compare
 *
 *  @return YES if items are equal and NO if they are not
 */
- (BOOL)isEqualToNetworkItem:(BKRNetworkItem *)networkItem;

@end

@implementation BKRNetworkItem

- (instancetype)initWithRawFrame:(BKRRawFrame *)rawFrame {
    self = [super init];
    if (self) {
        _uniqueIdentifier = rawFrame.uniqueIdentifier;
        _item = rawFrame.item;
    }
    return self;
}

+ (instancetype)itemWithRawFrame:(BKRRawFrame *)rawFrame {
    return [[self alloc] initWithRawFrame:rawFrame];
}

- (NSUInteger)hash {
    return [self.item hash] ^ [self.uniqueIdentifier hash];
}

- (BOOL)isEqualToNetworkItem:(BKRNetworkItem *)networkItem {
    if (!networkItem) {
        return NO;
    }
    
    BOOL haveEqualIdentifiers = (
                                 (!self.uniqueIdentifier && !networkItem.uniqueIdentifier) ||
                                 [self.uniqueIdentifier isEqualToString:networkItem.uniqueIdentifier]
                                 );
    BOOL haveEqualItems = (
                           (!self.item && !networkItem.item) ||
                           ([self.item isEqual:networkItem.item])
                           );
    // if two equal pieces of NSData (repeating string that is exactly the same length)
    // are received as part of the same task, then this would mean they are considered equal.
    // Need to make sure all received data is always considered "unique"
    // Let through all responses as well, occasionally the system resends responses, these
    // are used to build the data, and the last time the response is sent needs to be noted,
    // even if its the same response object
    if (
        [self.item isKindOfClass:[NSData class]] ||
        [networkItem.item isKindOfClass:[NSData class]] ||
        [self.item isKindOfClass:[NSURLResponse class]] ||
        [networkItem.item isKindOfClass:[NSURLResponse class]]
        ) {
        haveEqualItems = NO;
    }
    
    return haveEqualIdentifiers && haveEqualItems;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[BKRNetworkItem class]]) {
        return NO;
    }
    
    return [self isEqualToNetworkItem:(BKRNetworkItem *)object];
}

@end

@interface BKRRecordingEditor ()
@property (nonatomic, assign, readwrite) BOOL handledRecording;
@property (nonatomic, strong) NSMutableSet<BKRNetworkItem *> *objectsAdded;
@end

@implementation BKRRecordingEditor

@synthesize recordingStartTime = _recordingStartTime;
@synthesize beginRecordingBlock = _beginRecordingBlock;
@synthesize endRecordingBlock = _endRecordingBlock;

- (instancetype)init {
    self = [super init];
    if (self) {
        _handledRecording = NO;
        _recordingStartTime = nil;
        _objectsAdded = [NSMutableSet set];
    }
    return self;
}

// This resets the BKRRecordingEditor since it interacts with a
// singleton BKRRecorder. This should be called before
// releasing the instance.
- (void)resetWithCompletionBlock:(void (^)(void))completionBlock {
    BKRWeakify(self);
    [super resetWithCompletionBlock:^void (void){
        BKRStrongify(self);
        [self->_objectsAdded removeAllObjects];
        self->_handledRecording = NO;
        self->_recordingStartTime = nil;
        self->_beginRecordingBlock = nil;
        self->_endRecordingBlock = nil;
        if (completionBlock) {
            completionBlock();
        }
    }];
}


- (NSNumber *)recordingStartTime {
    __block NSNumber *recordingTime = nil;
    BKRWeakify(self);
    dispatch_sync(self.editingQueue, ^{
        BKRStrongify(self);
        recordingTime = self->_recordingStartTime;
    });
    return recordingTime;
}

- (void)_updateRecordingStartTimeWithEnabled:(BOOL)currentEnabled {
    if (currentEnabled) {
        self->_recordingStartTime = @([[NSDate date] timeIntervalSince1970]);
    } else {
        self->_recordingStartTime = nil;
    }
}

- (void)setEnabled:(BOOL)enabled withCompletionHandler:(BKRCassetteEditingBlock)editingBlock {
    BKRWeakify(self);
    [super setEnabled:enabled withCompletionHandler:^void(BOOL updatedEnabled, BKRCassette *cassette) {
        BKRStrongify(self);
        [self _updateRecordingStartTimeWithEnabled:enabled];
        if (editingBlock) {
            editingBlock(updatedEnabled, cassette);
        }
    }];
}

- (void)setEnabled:(BOOL)enabled {
    [self setEnabled:enabled withCompletionHandler:nil];
}

- (void)addItem:(id)item forTask:(NSURLSessionTask *)task withContext:(BKRRecordingContext)context {
    if (
        !item ||
        !task
        ) {
        // don't schedule anything if one piece of data is missing or there's not task
        return;
    }
    BKRWeakify(self);
    [self editCassette:^(BOOL updatedEnabled, BKRCassette *cassette) {
        BKRStrongify(self);
        BKRRawFrame *rawFrame = [BKRRawFrame frameWithTask:task];
        rawFrame.item = item;
        BKRNetworkItem *networkItem = [BKRNetworkItem itemWithRawFrame:rawFrame];
        // don't add the same object twice,
        // this happens with NSURLResponse, especially when it has headers
        // "Content-Type" = "application/octet-stream"
        // This can also be an issue if the same NSURLRequest is used
        // in different NSURLSessionTask instances
        if ([self->_objectsAdded containsObject:networkItem]) {
            // already recorded this, return
            return;
        }
        
        // check if you should record first:
        // 1) have a frame to record
        // 2) record starting time exists and is valid for this frame's creationDate
        if (![self _shouldRecord:rawFrame]) {
            return;
        }
        if (!cassette) {
            NSLog(@"%@ has no cassette right now", NSStringFromClass(self.class));
            return;
        }
        self->_handledRecording = YES;
        [cassette addFrame:rawFrame withContext:context];
        [self->_objectsAdded addObject:networkItem];
    }];
}

- (BOOL)_shouldRecord:(BKRRawFrame *)rawFrame {
    if (
        !self->_recordingStartTime ||
        !rawFrame
        ) {
        return NO;
    }
    // need to ensure that rawFrame.creationDate is not earlier than self->_recordingStartTime
    return ([rawFrame.creationDate compare:self->_recordingStartTime] != NSOrderedAscending);
}

- (BOOL)handledRecording {
    __block BOOL currentHandledRecording;
    BKRWeakify(self);
    dispatch_sync(self.editingQueue, ^{
        BKRStrongify(self);
        currentHandledRecording = self->_handledRecording;
    });
    return currentHandledRecording;
}

- (void)executeBeginRecordingBlockWithTask:(NSURLSessionTask *)task {
    // need this to be synchronous on the main queue
    BKRBeginRecordingTaskBlock currentBeginRecordingBlock = self.beginRecordingBlock;
    if (currentBeginRecordingBlock) {
        if ([NSThread isMainThread]) {
            currentBeginRecordingBlock(task);
        } else {
            // if recorder was called from a background queue, then make sure this is called on the main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                currentBeginRecordingBlock(task);
            });
        }
    }
}

- (void)executeEndRecordingBlockWithTask:(NSURLSessionTask *)task {
    BKRWeakify(self);
    [self editCassette:^(BOOL updatedEnabled, BKRCassette *cassette) {
        BKRStrongify(self);
        BKREndRecordingTaskBlock currentEndRecordingTaskBlock = self->_endRecordingBlock;
        if (
            !cassette ||
            !currentEndRecordingTaskBlock
            ) {
            return;
        }
        [cassette executeEndTaskRecordingBlock:currentEndRecordingTaskBlock withTask:task];
    }];
}

- (NSDictionary *)plistDictionary {
    __block NSDictionary *dictionary = nil;
    // this is dispatch sync so that it occurs after any queued writes (adding frames)
    [self editCassetteSynchronously:^(BOOL updatedEnabled, BKRCassette *cassette) {
        dictionary = cassette.plistDictionary;
    }];
    return dictionary;
}

#pragma mark - BKRVCRRecording

- (void)setBeginRecordingBlock:(BKRBeginRecordingTaskBlock)beginRecordingBlock {
    dispatch_barrier_async(self.editingQueue, ^{
        self->_beginRecordingBlock = beginRecordingBlock;
    });
}

- (BKRBeginRecordingTaskBlock)beginRecordingBlock {
    __block BKRBeginRecordingTaskBlock recordingBlock = nil;
    dispatch_sync(self.editingQueue, ^{
        recordingBlock = self->_beginRecordingBlock;
    });
    return recordingBlock;
}

- (void)setEndRecordingBlock:(BKREndRecordingTaskBlock)endRecordingBlock {
    dispatch_barrier_async(self.editingQueue, ^{
        self->_endRecordingBlock = endRecordingBlock;
    });
}

- (BKREndRecordingTaskBlock)endRecordingBlock {
    __block BKREndRecordingTaskBlock recordingBlock = nil;
    dispatch_sync(self.editingQueue, ^{
        recordingBlock = self->_endRecordingBlock;
    });
    return recordingBlock;
}

@end
