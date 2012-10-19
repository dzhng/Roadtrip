//
//  BezelSwipe.h
//  Roadtrip
//
//  Created by David Zhang on 10/19/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface BezelSwipe : UIGestureRecognizer

@property (assign, nonatomic) bool right;    // if swipe direction is from left to right

@end
