//
//  UICGStep.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "UICGStep.h"

@implementation UICGStep

+ (UICGStep *)stepWithDictionaryRepresentation:(NSDictionary *)dictionary {
	UICGStep *step = [[UICGStep alloc] initWithDictionaryRepresentation:dictionary];
    return step;
}

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary {
	self = [super init];
	if (self != nil) {
		_dictionaryRepresentation = dictionary;
		
		NSDictionary *point = [_dictionaryRepresentation objectForKey:@"Point"];
		NSArray *coordinates = [point objectForKey:@"coordinates"];
		CLLocationDegrees latitude  = [[coordinates objectAtIndex:0] doubleValue];
		CLLocationDegrees longitude = [[coordinates objectAtIndex:1] doubleValue];
		_location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
		
		id index = [_dictionaryRepresentation objectForKey:@"polylineIndex"];
		if (index == [NSNull null]) {
			_polylineIndex = -1;
		} else {
			_polylineIndex = [index integerValue];
		}
		_descriptionHtml = [_dictionaryRepresentation objectForKey:@"descriptionHtml"];
		_distance = [_dictionaryRepresentation objectForKey:@"Distance"];
		_duration = [_dictionaryRepresentation objectForKey:@"Duration"];
	}
	return self;
}

@end
