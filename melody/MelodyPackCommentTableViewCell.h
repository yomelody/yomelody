//
//  MelodyPackCommentTableViewCell.h
//  melody
//
//  Created by coding Brains on 22/02/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MelodyPackCommentTableViewCell : UITableViewCell
{

}
@property (weak, nonatomic) IBOutlet UILabel *lbl_no_of_instrumentals;
@property (weak, nonatomic) IBOutlet UILabel *lbl_bpm;
@property (weak, nonatomic) IBOutlet UILabel *lbl_genre;
@property (weak, nonatomic) IBOutlet UILabel *lbl_pack_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_pack_username;
@property (weak, nonatomic) IBOutlet UIButton *btn_add_melody_pack;
@property (weak, nonatomic) IBOutlet UILabel *lbl_timer;
@property (weak, nonatomic) IBOutlet UILabel *lbl_date;
@property (weak, nonatomic) IBOutlet UISlider *slider_progress;
@property (weak, nonatomic) IBOutlet UIButton *btn_play_pause;
@property (weak, nonatomic) IBOutlet UIButton *btn_play;
@property (weak, nonatomic) IBOutlet UIButton *btn_play_count;
@property (weak, nonatomic) IBOutlet UIButton *btn_like;
@property (weak, nonatomic) IBOutlet UIButton *btn_like_count;
@property (weak, nonatomic) IBOutlet UIButton *btn_comment;
@property (weak, nonatomic) IBOutlet UIButton *btn_comment_count;
@property (weak, nonatomic) IBOutlet UIButton *btn_share;
@property (weak, nonatomic) IBOutlet UIButton *btn_share_count;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_cover;
//@property (weak, nonatomic) IBOutlet UIImageView *img_view_cover;
@property (weak, nonatomic) IBOutlet UIImageView *img_profile;

@end
