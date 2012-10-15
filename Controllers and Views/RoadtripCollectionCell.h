//
//  RoadtripCollectionCell.h
//  Roadtrip
//
//  Created by David Zhang on 10/14/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoadtripModel.h"

@interface RoadtripCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mapImage;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;

// roadtrip represented by this cell
@property (retain, nonatomic) RoadtripModel* roadtrip;

// update the data in this cell with model data
- (void)updateRoadtrip:(RoadtripModel*)roadtrip;

@end
