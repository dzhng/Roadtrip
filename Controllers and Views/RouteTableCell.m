//
//  RouteTableCell.m
//  Roadtrip
//
//  Created by David Zhang on 10/6/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import "RouteTableCell.h"

@implementation RouteTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
