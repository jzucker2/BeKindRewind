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
@property (nonatomic, strong, readwrite) NSNumber *creationDate;
@property (nonatomic, copy, readwrite) NSString *uniqueIdentifier;

@end

@implementation BKRFrame

- (instancetype)initWithTask:(NSURLSessionTask *)task {
    self = [super init];
    if (self) {
        _creationDate = @([[NSDate date] timeIntervalSince1970]);
        _uniqueIdentifier = task.BKR_globallyUniqueIdentifier;
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

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        _creationDate = @([[NSDate date] timeIntervalSince1970]);
        _uniqueIdentifier = identifier;
    }
    return self;
}

+ (instancetype)frameWithIdentifier:(NSString *)identifier {
    return [[self alloc] initWithIdentifier:identifier];
}

- (NSDictionary *)plistDictionary {
    return @{
             @"creationDate": self.creationDate.copy,
             @"uniqueIdentifier": self.uniqueIdentifier.copy,
             @"class": NSStringFromClass(self.class)
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

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@: <%p> ID: %@", NSStringFromClass(self.class), self, self.uniqueIdentifier];
}

@end
