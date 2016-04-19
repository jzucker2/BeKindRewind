//
//  BKRErrorFrame.m
//  Pods
//
//  Created by Jordan Zucker on 1/25/16.
//
//

#import "BKRErrorFrame.h"
#import "BKRConstants.h"

@interface BKRErrorFrame ()
@property (nonatomic, readwrite) NSInteger code;
@property (nonatomic, copy, readwrite) NSString *domain;
@property (nonatomic, readwrite) NSDictionary *userInfo;
@end

@implementation BKRErrorFrame

- (void)addError:(NSError *)error {
    self.code = error.code;
    self.domain = error.domain;
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:error.userInfo copyItems:YES];
    userInfo[kBKRSceneUUIDKey] = self.uniqueIdentifier;
    self.userInfo = userInfo.copy;
}

- (NSError *)error {
    return [NSError errorWithDomain:self.domain code:self.code userInfo:self.userInfo];
}

- (NSDictionary *)plistDictionary {
    NSDictionary *superDict = [super plistDictionary];
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionaryWithDictionary:superDict];
    plistDict[@"domain"] = self.domain;
    plistDict[@"code"] = @(self.code);
    if (self.userInfo) {
        NSMutableDictionary *plistUserInfo = self.userInfo.mutableCopy;
        if (self.userInfo[NSURLErrorFailingURLErrorKey]) {
            NSURL *failingURL = self.userInfo[NSURLErrorFailingURLErrorKey];
            plistUserInfo[NSURLErrorFailingURLErrorKey] = failingURL.absoluteString;
        }
        plistDict[@"userInfo"] = [[NSDictionary alloc] initWithDictionary:plistUserInfo copyItems:YES];
    }
//    plistDict[@"description"] = self.error.description;
    return [[NSDictionary alloc] initWithDictionary:plistDict copyItems:YES];
}

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    self = [super initFromPlistDictionary:dictionary];
    if (self) {
        _code = [dictionary[@"code"] integerValue];
        _domain = dictionary[@"domain"];
        if (dictionary[@"userInfo"]) {
            NSMutableDictionary *finalUserInfo = [dictionary[@"userInfo"] mutableCopy];
            if (finalUserInfo[NSURLErrorFailingURLErrorKey]) {
                NSString *failingURLString = finalUserInfo[NSURLErrorFailingURLErrorKey];
                finalUserInfo[NSURLErrorFailingURLErrorKey] = [NSURL URLWithString:failingURLString];
                _userInfo = finalUserInfo;
            }
        }
    }
    return self;
}

- (NSURL *)failingURL {
    if (self.userInfo) {
        return self.userInfo[NSURLErrorFailingURLErrorKey];
    }
    return nil;
}

- (NSString *)failingURLString {
    if (self.userInfo) {
        return self.userInfo[NSURLErrorFailingURLStringErrorKey];
    }
    return nil;
}

@end
