//
//  chatViewController.h
//  melody
//
//  Created by coding Brains on 21/12/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
@interface chatViewController : UIViewController<UITextViewDelegate,AVAudioPlayerDelegate>
{
    
    UIView*dp_view;
    UICollectionView*cv_images;
    NSData*imageData;
    NSString*imageName;
    /****************************Outlets related to chat*****************************/
    int flag_text;
    NSMutableString*msg_txt;
    NSMutableArray*arr_msg;
    NSMutableArray*arr_msgWithImage;

    NSMutableArray*arr_msg_date;
    NSMutableArray*arr_msg_time;
    NSMutableArray*arr_msg_read_unread_status;
    NSMutableArray*arr_msg_id;
    NSMutableArray*arr_msg_type;
    NSMutableArray*arr_msg_sender_id,*arr_AudioSharedM;
    AVAudioPlayer *audioPlayer;
    NSTimer *recordingTimer;
    long instrument_play_index;


}
/****************outlets data comes from contactsviewcontroller******************/
@property(strong,nonatomic)NSMutableArray*arr_msg_user_id;
@property (nonatomic, assign) BOOL isChat_type_Group;
@property (nonatomic, assign) BOOL isShare_Audio;
@property(nonatomic , strong)NSString* str_screen_type;
@property(nonatomic , strong)NSString* str_file_id;


@property(nonatomic , strong)NSString* str_sender_ID;
@property(nonatomic , strong)NSString* str_receiver_type;
@property(nonatomic , strong)NSString* str_receiver_id;
@property(nonatomic , strong)NSString* str_receiver_name;

@property(nonatomic , strong)NSString* str_chat_id;
@property(nonatomic , strong)NSString* str_receiver_profile_url;

@property (strong, nonatomic) UIWindow *window;

//-------------------- IBAction ---------------------
- (IBAction)btn_back:(id)sender;
- (IBAction)btn_home:(id)sender;
- (IBAction)btn_write_msg_open_contacts:(id)sender;
- (IBAction)btn_invite:(id)sender;
- (IBAction)btn_cancel:(id)sender;
- (IBAction)btn_go_to_studio_play:(id)sender;

//-------------------- IBOutlet ---------------------
@property (weak, nonatomic) IBOutlet UITableView *tbl_view_chat;
@property (weak, nonatomic) IBOutlet UIView *view_bottom_write_msg;
@property (weak, nonatomic) IBOutlet UITextView *tv_write_msg;
@property (weak, nonatomic) IBOutlet UIButton *btn_cancel;
@property (weak, nonatomic) IBOutlet UIButton *btn_go_to_studio_play;
@property (weak, nonatomic) IBOutlet UIView *view_form;
@property (weak, nonatomic) IBOutlet UIView *view_profile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_quate;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_profile;
@property (weak, nonatomic) IBOutlet UITextView *chatTextView;
@property (weak, nonatomic) IBOutlet UIButton *inviteBtn;
@property (weak, nonatomic) IBOutlet UIButton *btn_camera;
@property (weak, nonatomic) IBOutlet UIView *vew_msg;
@property (strong, nonatomic)  NSString *str_GroupImage;
@property (strong, nonatomic)  NSString *str_GroupName;
//---------------* Audio Share Play View *-------------------

@property (weak, nonatomic) IBOutlet UIButton *btn_play;
@property (weak, nonatomic) IBOutlet UIButton *btn_previous;
@property (weak, nonatomic) IBOutlet UIButton *btn_next;
@property (weak, nonatomic) IBOutlet UILabel *lbl_songTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbl_numberOfSongs;
@property (weak, nonatomic) IBOutlet UILabel *lbl_userFullName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_userName;
@property (weak, nonatomic) IBOutlet UIImageView *img_profile;
@property (weak, nonatomic) IBOutlet UIView *view_SharePlay;
@property (weak, nonatomic) IBOutlet UILabel *lbl_recieverName;

- (void) handleURL:(NSURL *)url;
@property (weak, nonatomic) IBOutlet UISlider *share_Slider;

@property (strong, nonatomic)NSString *img_view_Profile;

@end
