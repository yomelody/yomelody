//
//  receivefileTableViewCell.h
//  melody
//
//  Created by coding Brains on 29/04/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface receivefileTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img_view_profile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Date;
@property (weak, nonatomic) IBOutlet UIButton *btn_play;
@property (weak, nonatomic) IBOutlet UILabel *lbl_audio_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_user_name;
@property (weak, nonatomic) IBOutlet UILabel *lbl_numberOf_audio;
@property (weak, nonatomic) IBOutlet UIButton *btn_previous;
@property (weak, nonatomic) IBOutlet UIButton *btn_next;
@property (weak, nonatomic) IBOutlet UIButton *btn_AudioShare_join;


@end
