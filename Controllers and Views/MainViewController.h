//
//  MainViewController.h
//  Roadtrip
//
//  Created by Zachary Zimbler on 10/13/12.
//  Copyright (c) 2012 David Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "RoadtripCollectionCell.h"
#import "RoadtripViewController.h"

@interface MainViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

// reload the database data, called when first initializing,
// or if relogging in after logout
- (void)reloadDataFromDB;

// logout button handler
- (IBAction)logOutPressed:(id)sender;

// new roadtrip handler
- (IBAction)newRoadtripPressed:(id)sender;

@end
