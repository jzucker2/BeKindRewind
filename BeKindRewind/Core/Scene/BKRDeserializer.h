//
//  BKRDeserializer.h
//  Pods
//
//  Created by Jordan Zucker on 1/18/16.
//
//

#import <Foundation/Foundation.h>
#import "BKRScene.h"

@protocol BKRDeserializer <NSObject>

// a BKR class object
- (id)bkrRepresentation;


@end
