//
//  AppModel.m
//  Roadtrip
//
//  Created by David Zhang on 10/12/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "AppModel.h"
#import "Database.h"

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

- (NSArray*)getAllRoadtrips
{
    PFQuery* query = [PFQuery queryWithClassName:ROADTRIP_CLASS];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    return [query findObjects];
}

- (RoadtripModel*)newRoadtrip
{
    // allocate a new roadtrip object, the roadtrip object will auto sync to db
    RoadtripModel* roadtrip = [[RoadtripModel alloc] initNewObject];
    
    // set current roadtrip object
    self.currentRoadtrip = roadtrip;
    
    return roadtrip;
}

@end
