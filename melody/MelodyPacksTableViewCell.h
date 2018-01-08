//
//  MelodyPacksTableViewCell.h
//  melody
//
//  Created by CodingBrainsMini on 11/26/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MelodyPacksTableViewCell : UITableViewCell
{

}
@property (weak, nonatomic) IBOutlet UIImageView *img_melodypack_cover;
@property (weak, nonatomic) IBOutlet UILabel *lbl_no_of_instrumentals;
@property (weak, nonatomic) IBOutlet UILabel *lbl_bpm;
@property (weak, nonatomic) IBOutlet UILabel *lbl_genre;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_profile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_profile_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_profile_id;
@property (weak, nonatomic) IBOutlet UIButton *btn_add;
@property (weak, nonatomic) IBOutlet UILabel *lbl_timer;
@property (weak, nonatomic) IBOutlet UILabel *lbl_date;
@property (weak, nonatomic) IBOutlet UISlider *slider_progress;
@property (weak, nonatomic) IBOutlet UIButton *btn_play;
@property (weak, nonatomic) IBOutlet UIButton *lbl_no_of_play;
@property (weak, nonatomic) IBOutlet UIButton *btn_like;
@property (weak, nonatomic) IBOutlet UIButton *lbl_no_of_like;
@property (weak, nonatomic) IBOutlet UIButton *btn_comment;
@property (weak, nonatomic) IBOutlet UIButton *lbl_no_of_comments;
@property (weak, nonatomic) IBOutlet UIButton *btn_share;
@property (weak, nonatomic) IBOutlet UIButton *btn_no_of_share;
@property (weak, nonatomic) IBOutlet UIButton *btn_menu;
@property (weak, nonatomic) IBOutlet UIButton *btn_hide;
@property (weak, nonatomic) IBOutlet UIButton *btn_playpause;






@end
