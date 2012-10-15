//
//  TextFormat.h
//  Roadtrip
//
//  Created by David Zhang on 10/14/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextFormat : NSObject

+ (NSString*)formatDistanceFromMeters:(NSInteger)meters;
+ (NSString*)formatTimeFromSeconds:(NSInteger)seconds;

@end
