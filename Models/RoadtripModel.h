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
#import "ModelNotifications.h"

@protocol RoadtripModelDelegate <NSObject>

- (void)searchDone:(NSArray*)locationObjects;
- (void)locationInserted:(RoadtripLocation*)location AtIndex:(NSInteger)index;
- (void)handleSelectedFromTable:(RoadtripLocation*)location;
- (void)handleSelectedFromMap:(RoadtripLocation*)location;
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

// currently selected location
@property (retain, nonatomic) RoadtripLocation* selectedLocation;

- (id)init;
- (void)geocodeWithAddress:address;

@end
