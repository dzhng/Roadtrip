//
//  RouteTableCell.h
//  Roadtrip
//
//  Created by David Zhang on 10/6/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoadtripRoute.h"

@interface RouteTableCell : UITableViewCell
{
}

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;

@property (retain, nonatomic) RoadtripRoute* route;

- (void)updateRoute:(RoadtripRoute *)route;

@end
