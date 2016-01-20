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

#endif /* BKRConstants_h */
