//
//  RoadtripModel.h
//  Roadtrip
//
//  Created by David Zhang on 10/4/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "RoadtripLocation.h"
#import "RoadtripRoute.h"
#import "ModelNotifications.h"

@protocol RoadtripModelDelegate <NSObject>

- (void)searchDone:(NSArray*)locationObjects;
- (void)locationInserted:(RoadtripLocation*)location AtIndex:(NSInteger)index;
- (void)handleSelectedFromTable:(id) selected;
- (void)handleSelectedFromMap:(id)selected;
- (void)handleDeselect;

@end

@interface RoadtripModel : NSObject
{
    CLGeocoder* geocoder;        // stores geocoder used for location lookup
}

@property (assign, nonatomic) id <RoadtripModelDelegate> delegate;

// data model of locations
@property (retain, nonatomic) NSMutableArray* locationArray;
@property (retain, nonatomic) NSMutableArray* searchLocationArray;

// data model of routes
@property (retain, nonatomic) NSMutableArray* routeArray;

// currently selected location
@property (retain, nonatomic) id selected;

- (id)init;
- (void)geocodeWithAddress:address;

@end
