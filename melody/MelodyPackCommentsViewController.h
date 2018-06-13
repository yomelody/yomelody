//
//  MelodyPackCommentsViewController.h
//  melody
//
//  Created by coding Brains on 22/02/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface MelodyPackCommentsViewController : UIViewController<AVAudioPlayerDelegate>
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
    NSString* like_count;
    NSString* play_count;
    NSString* like_status;
    NSMutableArray* arr_melody_instrumentals_path;
    AVAudioPlayer*audioPlayer;
    int currentSoundsIndex;
 
}
@property (strong,nonatomic) NSMutableDictionary *dic_data;
- (IBAction)btn_back:(id)sender;
- (IBAction)btn_home:(id)sender;
- (IBAction)btn_melodypack:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tbl_melodypack_comments;
@property (weak, nonatomic) IBOutlet UIView *view_comment;
@property (weak, nonatomic) IBOutlet UITextField *tf_comment;
@property (weak, nonatomic) IBOutlet UIButton *btn_send;
- (IBAction)btn_send:(id)sender;
@property (strong, nonatomic) NSString *isFromMelody;

@property (strong, nonatomic) NSString *fileID;
@property (strong, nonatomic) NSString *fileType;
@property (strong, nonatomic) NSString *isFrom;
@end
