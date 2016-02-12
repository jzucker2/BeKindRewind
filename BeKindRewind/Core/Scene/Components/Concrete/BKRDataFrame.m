//
//  BKRDataFrame.m
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#import "BKRDataFrame.h"

@interface BKRDataFrame ()
@property (nonatomic, copy)  NSData *data;

@end

@implementation BKRDataFrame

- (void)addData:(NSData *)data {
    self.data = data;
}

- (NSData *)rawData {
    return self.data;
}

- (id)JSONConvertedObject {
    NSError *jsonSerializingError = nil;
    id jsonData = [NSJSONSerialization JSONObjectWithData:self.data options:kNilOptions error:&jsonSerializingError];
    if (jsonSerializingError) {
        NSLog(@"%@: failed to convert to JSON with error: %@", self.debugDescription, jsonSerializingError.localizedDescription);
        return nil;
    } else {
        return jsonData;
    }
}

- (NSDictionary *)plistDictionary {
    NSDictionary *superDict = [super plistDictionary];
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionaryWithDictionary:superDict];
    plistDict[@"data"] = self.data.copy;
    // TODO: reimplement this when JSON conversion can gracefully handle plist issues (can't save a null value to a plist)
//    id JSON = [self JSONConvertedObject];
//    if (JSON) {
//        plistDict[@"JSON"] = JSON;
//    }
    return [[NSDictionary alloc] initWithDictionary:plistDict copyItems:YES];
}

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    self = [super initFromPlistDictionary:dictionary];
    if (self) {
        _data = dictionary[@"data"];
    }
    return self;
}

@end
