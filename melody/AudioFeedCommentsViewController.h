//
//  AudioFeedCommentsViewController.h
//  melody
    //
//  Created by coding Brains on 26/12/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import "Constant.h"

@interface AudioFeedCommentsViewController : UIViewController<UITextFieldDelegate,AVAudioPlayerDelegate,AVAudioRecorderDelegate>
{
    int text_flag;
    NSMutableArray*arr_text;
    NSMutableArray*arr_comment_id;
    NSMutableArray*arr_user_id;
    NSUserDefaults*defaults_userdata;
    NSMutableArray*arr_user_profile_pic;
    NSMutableArray*arr_user_username;
    NSMutableArray*arr_user_name;
    NSMutableArray*arr_comment_timedate;
    
        NSString*like_count;
    NSString*like_status;
    NSString*play_count;
    NSString*share_count;
    AVAudioPlayer *audioPlayer;
    long instrument_play_index;
    int instrument_play_status;
    NSInteger index;

}
- (IBAction)btn_back:(id)sender;
- (IBAction)btn_home:(id)sender;
- (IBAction)btn_melody_pack:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tbl_view_comments;
@property (weak, nonatomic) IBOutlet UITextField *tf_addcomment;
@property (weak, nonatomic) IBOutlet UIButton *btn_send_cancel;
- (IBAction)btn_send_cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *view_add_comment;
@property (strong,nonatomic) NSMutableDictionary *dic_data;

@property (weak, nonatomic) IBOutlet UIImageView *placeholder_Img;

@property (strong, nonatomic) NSString *fileID;
@property (strong, nonatomic) NSString *fileType;
@property (strong, nonatomic) NSString *isFrom;

@end
