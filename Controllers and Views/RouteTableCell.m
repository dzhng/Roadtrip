//
//  RouteTableCell.m
//  Roadtrip
//
//  Created by David Zhang on 10/6/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "RouteTableCell.h"
#import "ModelNotifications.h"

@interface RouteTableCell()

- (void)routeUpdatedNotification:(NSNotification*)notification;

@end

@implementation RouteTableCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // watch route updated notification
        [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(routeUpdatedNotification:)
            name:ROUTE_UPDATED_NOTIFICATION
            object:nil];
    }
    return self;
}

- (void)updateRoute:(RoadtripRoute *)route
{
    self.route = route;
    self.timeLabel.text = route.timeText;
    self.distanceLabel.text = route.distanceText;
    self.costLabel.text = route.costText;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // draw table based on state
    if(selected) {
        // Configure the view for the selected state
        UIView * bgView = [[UIView alloc] initWithFrame:CGRectZero];
        bgView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.7];
        self.backgroundView = bgView;
    } else {
        UIView * bgView = [[UIView alloc] initWithFrame:CGRectZero];
        bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
        self.backgroundView = bgView;
    }
}

- (void)routeUpdatedNotification:(NSNotification *)notification
{
    // grab the the route
    NSDictionary *dictionary = [notification userInfo];
    RoadtripRoute* route = [dictionary valueForKey:NOTIFICATION_ROUTE_KEY];
    
    // check is the route updated is this route
    if(route == self.route) {
        // update current route
        [self updateRoute:route];
    }
}

@end