//
//  SubscriptionPlanTableViewCell.h
//  melody
//
//  Created by CodingBrainsMini on 11/28/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubscriptionPlanTableViewCell : UITableViewCell
{

}
@property (weak, nonatomic) IBOutlet UILabel *lbl_plan_type;
@property (weak, nonatomic) IBOutlet UILabel *lbl_recording_time;
@property (weak, nonatomic) IBOutlet UILabel *lbl_layers_count;
@property (weak, nonatomic) IBOutlet UISwitch *switch_pan;
- (IBAction)switch_plan:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lbl_plan_price;
@property (weak, nonatomic) IBOutlet UIView *view_plan_price;
@property (weak, nonatomic) IBOutlet UIView *view_free_plan;
@property (weak, nonatomic) IBOutlet UILabel *lbl_layer_text;
@property (weak, nonatomic) IBOutlet UILabel *lbl_rec_time_text;
@property (weak, nonatomic) IBOutlet UILabel *lbl_perMonth;


@end
