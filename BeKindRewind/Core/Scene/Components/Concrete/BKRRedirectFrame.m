//
//  BKRRedirectFrame.m
//  Pods
//
//  Created by Jordan Zucker on 3/4/16.
//
//

#import "BKRRedirectFrame.h"
#import "BKRRequestFrame.h"
#import "BKRResponseFrame.h"

@interface BKRRedirectFrame ()
@property (nonatomic, strong, readwrite) BKRRequestFrame *requestFrame;
@property (nonatomic, strong, readwrite) BKRResponseFrame *responseFrame;
@end

@implementation BKRRedirectFrame

- (void)addRequest:(NSURLRequest *)request {
    self.requestFrame = [BKRRequestFrame frameFromFrame:self];
    [self.requestFrame addRequest:request];
}

- (void)addResponse:(NSURLResponse *)response {
    self.responseFrame = [BKRResponseFrame frameFromFrame:self];
    [self.responseFrame addResponse:response];
}

- (NSDictionary *)plistDictionary {
    NSDictionary *superDict = [super plistDictionary];
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionaryWithDictionary:superDict];
    NSDictionary *responseDictionary = self.responseFrame.plistDictionary;
    if (responseDictionary) {
        plistDict[@"response"] = responseDictionary;
    }
    NSDictionary *requestDictionary = self.requestFrame.plistDictionary;
    if (requestDictionary) {
        plistDict[@"request"] = requestDictionary;
    }
    return [[NSDictionary alloc] initWithDictionary:plistDict.copy copyItems:YES];
}

- (instancetype)initFromPlistDictionary:(NSDictionary *)dictionary {
    self = [super initFromPlistDictionary:dictionary];
    if (self) {
        NSDictionary *responseDict = dictionary[@"response"];
        if (responseDict) {
            _responseFrame = [[BKRResponseFrame alloc] initFromPlistDictionary:responseDict];
        }
        NSDictionary *requestDict = dictionary[@"request"];
        if (requestDict) {
            _requestFrame = [[BKRRequestFrame alloc] initFromPlistDictionary:requestDict];
        }
    }
    return self;
}

@end
