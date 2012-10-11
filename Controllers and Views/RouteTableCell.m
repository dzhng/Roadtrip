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

- (void)postRouteSelectedNotification;

@end

@implementation RouteTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        cellSelected = false;
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
        if(!cellSelected) {
            cellSelected = true;
            // Configure the view for the selected state
            UIView * bgView = [[UIView alloc] initWithFrame:CGRectZero];
            bgView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.7];
            self.backgroundView = bgView;
            
            // we only send out the notification if the user clicked on the table
            // don't want to be sending double notification for when the user clicked on the map
            if(!animated) {
                // send notification out to model so it knows location has been selected
                NSLog(@"Route cell selected notification sent");
                [self postRouteSelectedNotification];
            }
        }
    } else {
        UIView * bgView = [[UIView alloc] initWithFrame:CGRectZero];
        bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
        self.backgroundView = bgView;
        cellSelected = false;
    }
}

// send out notification to add this location to current list of locations
- (void)postRouteSelectedNotification
{
    NSString *notificationName = ROUTE_SELECTED_NOTIFICATION;
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:self.route, NOTIFICATION_ROUTE_KEY,
                                NOTIFICATION_TABLE_SOURCE, NOTIFICATION_SELECTED_SOURCE, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];
}

@end