//
//  UICGRoute.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICGRoute.h"

@implementation UICGRoute

+ (UICGRoute *)routeWithDictionaryRepresentation:(NSDictionary *)dictionary {
	UICGRoute *route = [[UICGRoute alloc] initWithDictionaryRepresentation:dictionary];
    return route;
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary {
	self = [super init];
	if (self != nil) {
		_dictionaryRepresentation = dictionary;
        NSArray *allKeys = [_dictionaryRepresentation allKeys];
        NSDictionary *k = [_dictionaryRepresentation objectForKey:[allKeys objectAtIndex:[allKeys count] - 1]];
		NSArray *stepDics = [k objectForKey:@"Steps"];
		_numerOfSteps = [stepDics count];
		_steps = [[NSMutableArray alloc] initWithCapacity:_numerOfSteps];
		for (NSDictionary *stepDic in stepDics) {
			[(NSMutableArray *)_steps addObject:[UICGStep stepWithDictionaryRepresentation:stepDic]];
		}
		
		_endGeocode = [_dictionaryRepresentation objectForKey:@"MJ"];
		_startGeocode = [_dictionaryRepresentation objectForKey:@"dT"];
		
		_distance = [k objectForKey:@"Distance"];
		_duration = [k objectForKey:@"Duration"];
		NSDictionary *endLocationDic = [k objectForKey:@"End"];
		NSArray *coordinates = [endLocationDic objectForKey:@"coordinates"];
		CLLocationDegrees longitude = [[coordinates objectAtIndex:0] doubleValue];
		CLLocationDegrees latitude  = [[coordinates objectAtIndex:1] doubleValue];
		_endLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
		_summaryHtml = [k objectForKey:@"summaryHtml"];
		_polylineEndIndex = [[k objectForKey:@"polylineEndIndex"] integerValue];
	}
	return self;
}

- (UICGStep *)stepAtIndex:(NSInteger)index {
	return [_steps objectAtIndex:index];;
}

@end
