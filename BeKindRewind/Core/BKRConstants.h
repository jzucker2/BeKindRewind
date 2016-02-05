//
//  BKRConstants.h
//  Pods
//
//  Created by Jordan Zucker on 1/20/16.
//
//

#ifndef BKRConstants_h
#define BKRConstants_h

// the NO if statement doesn't run but is a compiler check to test if the object containst the key
#define BKRKey(object, selector) ({ __typeof(object) testObject = nil; if (NO) { (void)((testObject).selector); } @#selector; })

// typedef returnType (^TypeName)(parameterTypes);
typedef void (^BKRBeforeAddingStubs)(void);
typedef void (^BKRAfterAddingStubs)(void);

typedef void (^BKRBeginRecordingTaskBlock)(NSURLSessionTask *task);
typedef void (^BKREndRecordingTaskBlock)(NSURLSessionTask *task);


#endif /* BKRConstants_h */
