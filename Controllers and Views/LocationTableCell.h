//
//  LocationTableCell.h
//  Roadtrip
//
//  Created by David Zhang on 10/3/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoadtripLocation.h"
#import "AppModel.h"


@interface LocationTableCell : UITableViewCell
{
    bool cellSelected;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (retain, nonatomic) RoadtripLocation* location;

- (void)updateLocation:(RoadtripLocation*)location;

@end
