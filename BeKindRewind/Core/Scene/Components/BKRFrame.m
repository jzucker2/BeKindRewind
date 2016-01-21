//
//  BKRFrame.m
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import "NSURLSessionTask+BKRAdditions.h"
#import "BKRFrame.h"

@interface BKRFrame ()
@property (nonatomic, strong, readwrite) NSDate *creationDate;
@property (nonatomic, copy, readwrite) NSString *uniqueIdentifier;

@end

@implementation BKRFrame

- (void)_init {
    _creationDate = [NSDate date];
}

- (instancetype)initWithTask:(NSURLSessionTask *)task {
    self = [super init];
    if (self) {
        [self _init];
        _uniqueIdentifier = task.globallyUniqueIdentifier;
    }
    return self;
}

+ (instancetype)frameWithTask:(NSURLSessionTask *)task {
    return [[self alloc] initWithTask:task];
}

- (instancetype)initFromFrame:(BKRFrame *)frame {
    self = [super init];
    if (self) {
        _creationDate = frame.creationDate;
        _uniqueIdentifier = frame.uniqueIdentifier;
    }
    return self;
}

+ (instancetype)frameFromFrame:(BKRFrame *)frame {
    return [[self alloc] initFromFrame:frame];
}

- (NSDictionary *)plistDictionary {
    return @{
             @"creationDate": self.creationDate.copy,
             @"uniqueIdentifier": self.uniqueIdentifier.copy
             };
}

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _creationDate = dictionary[@"creationDate"];
        _uniqueIdentifier = dictionary[@"uniqueIdentifier"];
    }
    return self;
}

@end
