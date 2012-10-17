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
        }
    } else {
        UIView * bgView = [[UIView alloc] initWithFrame:CGRectZero];
        bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        self.backgroundView = bgView;
        cellSelected = false;
    }
}

@end