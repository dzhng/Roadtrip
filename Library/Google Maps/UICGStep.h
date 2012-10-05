//
//  UICGStep.h
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface UICGStep : NSObject

@property (nonatomic, retain, readonly) NSDictionary *dictionaryRepresentation;
@property (nonatomic, retain, readonly) CLLocation *location;
@property (nonatomic, assign, readonly) NSInteger polylineIndex;
@property (nonatomic, retain, readonly) NSString *descriptionHtml;
@property (nonatomic, retain, readonly) NSDictionary *distance;
@property (nonatomic, retain, readonly) NSDictionary *duration;

+ (UICGStep *)stepWithDictionaryRepresentation:(NSDictionary *)dictionary;
- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary;

@end
