//
//  AudioFeedTableViewCell.h
//  melody
//
//  Created by CodingBrainsMini on 11/22/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioFeedTableViewCell : UITableViewCell
{

}
@property (weak, nonatomic) IBOutlet UIButton *btn_Profile;
/******************top profile section*******************/
@property (weak, nonatomic) IBOutlet UIImageView *imgview_profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *lbl_profile_name;
@property (weak, nonatomic) IBOutlet UILabel *lbl_profile_twitter_id;
@property (weak, nonatomic) IBOutlet UILabel *lbl_date_top;
/********************************************************/
@property (weak, nonatomic) IBOutlet UISlider *slider_progress;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_back_cover;
@property (weak, nonatomic) IBOutlet UILabel *lbl_timer;
@property (weak, nonatomic) IBOutlet UILabel *lbl_date_aidios;
@property (weak, nonatomic) IBOutlet UIButton *btn_next_audio;
@property (weak, nonatomic) IBOutlet UIButton *btn_previous_audio;
@property (weak, nonatomic) IBOutlet UILabel *lbl_oneof;
@property (weak, nonatomic) IBOutlet UIButton *btn_join;
@property (weak, nonatomic) IBOutlet UILabel *lbl_geners;

/******************Bottom play,like ,comment,share section*******************/
@property (weak, nonatomic) IBOutlet UIButton *btn_play;
@property (weak, nonatomic) IBOutlet UIButton *btn_play_value;
@property (weak, nonatomic) IBOutlet UIButton *btn_like;
@property (weak, nonatomic) IBOutlet UIButton *btn_like_value;
@property (weak, nonatomic) IBOutlet UIButton *btn_comment;
@property (weak, nonatomic) IBOutlet UIButton *btn_comment_value;
@property (weak, nonatomic) IBOutlet UIButton *btn_share;
@property (weak, nonatomic) IBOutlet UIButton *btn_share_value;
@property (weak, nonatomic) IBOutlet UIButton *btn_other_options;
@property (weak, nonatomic) IBOutlet UIButton *btn_hide;
@property (weak, nonatomic) IBOutlet UIButton *btn_PlayRecording;
@property (weak, nonatomic) IBOutlet UIView *roundBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *lbl_included;
@property (weak, nonatomic) IBOutlet UISwitch *switch_PublicOrPrivate;

/********************************************************/
@end
