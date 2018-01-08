//
//  TableViewCell.h
//  melody
//
//  Created by CodingBrainsMini on 12/1/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstrumentalTableViewCell : UITableViewCell
{

}
@property (weak, nonatomic) IBOutlet UIImageView *img_view_profile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_profile_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_profile_title_id;
@property (weak, nonatomic) IBOutlet UILabel *lbl_timer;
@property (strong, nonatomic) IBOutlet UISlider *slider_progress;
@property (weak, nonatomic) IBOutlet UIButton *btn_ex;
@property (weak, nonatomic) IBOutlet UIButton *btn_eq;
@property (weak, nonatomic) IBOutlet UIButton *btn_replay;
@property (weak, nonatomic) IBOutlet UILabel *lbl_bpm;
@property (weak, nonatomic) IBOutlet UIButton *btn_delete;
@property (weak, nonatomic) IBOutlet UIButton *btn_m;
@property (weak, nonatomic) IBOutlet UIImageView *img_instrumental_cover;
@property (weak, nonatomic) IBOutlet UIButton *btn_play_pause;
@property (weak, nonatomic) IBOutlet UIView *view_activity;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity_indicater;

@property (weak, nonatomic) IBOutlet UIButton *btn_s;

@property (weak, nonatomic) IBOutlet UIView *view_delete;
@property (weak, nonatomic) IBOutlet UIButton *btn_delete_cancel;
@property (weak, nonatomic) IBOutlet UIButton *btn_cell_delete;
@property (weak, nonatomic) IBOutlet UIView *view_upper;


@end
