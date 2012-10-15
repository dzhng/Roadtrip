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

- (id)init
{
    self = [super init];
    if(self) {
        self.roadtrips = [[NSMutableArray alloc] init];
    }
    return self;
}

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
    NSArray* dbObjects = [query findObjects];
    
    [self.roadtrips removeAllObjects];
    for (PFObject* r in dbObjects) {
        RoadtripModel* roadtrip = [[RoadtripModel alloc] initFromDB:r];
        [self.roadtrips addObject:roadtrip];
    }
    
    return self.roadtrips;
}

- (RoadtripModel*)newRoadtrip
{
    // allocate a new roadtrip object, the roadtrip object will auto sync to db
    RoadtripModel* roadtrip = [[RoadtripModel alloc] initNewObject];
    
    // set current roadtrip object
    self.currentRoadtrip = roadtrip;
    
    // append to roadtrips array
    [self.roadtrips addObject:roadtrip];
    
    return roadtrip;
}

@end
