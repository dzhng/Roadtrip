//
//  AppModel.m
//  Roadtrip
//
//  Created by David Zhang on 10/12/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "AppModel.h"

@implementation AppModel

// singleton instance
static AppModel* model = nil;

+ (AppModel*)model
{
    if(model == nil) {
        model = [[super alloc] init];
    }
    return model;
}

@end
