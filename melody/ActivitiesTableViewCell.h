//
//  ActivitiesTableViewCell.h
//  melody
//
//  Created by CodingBrainsMini on 11/23/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivitiesTableViewCell : UITableViewCell
{

}
@property (weak, nonatomic) IBOutlet UIImageView *img_view_profileimage;
@property (weak, nonatomic) IBOutlet UILabel *lbl_activity;
@property (weak, nonatomic) IBOutlet UILabel *lbl_topic;
@property (weak, nonatomic) IBOutlet UILabel *lbl_timing;

@end
