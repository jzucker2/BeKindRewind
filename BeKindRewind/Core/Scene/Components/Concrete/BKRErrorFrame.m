//
//  BKRErrorFrame.m
//  Pods
//
//  Created by Jordan Zucker on 1/25/16.
//
//

#import "BKRErrorFrame.h"

@interface BKRErrorFrame ()
@property (nonatomic, strong) NSError *error;
@end

@implementation BKRErrorFrame

- (void)addError:(NSError *)error {
    self.error = error;
}

- (NSDictionary *)plistDictionary {
    NSDictionary *superDict = [super plistDictionary];
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionaryWithDictionary:superDict];
    plistDict[@"domain"] = self.error.domain;
    plistDict[@"code"] = @(self.error.code);
    if (self.error.userInfo) {
        plistDict[@"userInfo"] = [[NSDictionary alloc] initWithDictionary:self.error.userInfo copyItems:YES];
    }
    plistDict[@"description"] = self.error.description;
    return [[NSDictionary alloc] initWithDictionary:plistDict copyItems:YES];
}

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    self = [super initFromPlistDictionary:dictionary];
    if (self) {
        _error = [NSError errorWithDomain:dictionary[@"domain"] code:[dictionary[@"code"] integerValue] userInfo:dictionary[@"userInfo"]];
    }
    return self;
}

@end
