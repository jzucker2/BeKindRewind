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
        return nil;
    } else {
        return jsonData;
    }
}

- (NSDictionary *)plistDictionary {
    NSDictionary *superDict = [super plistDictionary];
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionaryWithDictionary:superDict];
    plistDict[@"data"] = self.data.copy;
    id JSON = [self JSONConvertedObject];
    if (JSON) {
        plistDict[@"JSON"] = JSON;
    }
    return [[NSDictionary alloc] initWithDictionary:plistDict copyItems:YES];
}

@end
