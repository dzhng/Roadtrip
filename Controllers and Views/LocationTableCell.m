//
//  LocationTableCell.m
//  Roadtrip
//
//  Created by David Zhang on 10/3/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "LocationTableCell.h"
#import "ModelNotifications.h"

@interface LocationTableCell()

- (void)postLocationSelectedNotification;

@end

@implementation LocationTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        cellSelected = false;
    }
    return self;
}

- (void)updateLocation:(RoadtripLocation *)location
{
    self.location = location;
    self.titleLabel.text = location.title;
    self.subtitleLabel.text = location.subtitle;
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
            bgView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1];
            self.backgroundView = bgView;
            
            // we only send out the notification if the user clicked on the table
            // don't want to be sending double notification for when the user clicked on the map
            if(!animated) {
                // send notification out to model so it knows location has been selected
                [self postLocationSelectedNotification];
            }
        }
    } else {
        UIView * bgView = [[UIView alloc] initWithFrame:CGRectZero];
        bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        self.backgroundView = bgView;
        cellSelected = false;
    }
}

// send out notification to add this location to current list of locations
- (void)postLocationSelectedNotification
{
    NSString *notificationName = LOCATION_SELECTED_NOTIFICATION;
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:self.location, NOTIFICATION_LOCATION_KEY,
                                NOTIFICATION_TABLE_SOURCE, NOTIFICATION_SELECTED_SOURCE, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:dictionary];
}

@end
