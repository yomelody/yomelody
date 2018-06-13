//
//  StudioPlayViewController.h
//  melody
//
//  Created by CodingBrainsMini on 11/29/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//
#import "Constant.h"
#import "EZAudio.h"
//#include "EZAudio.h"
#define kAudioFileDefault [[NSBundle mainBundle] pathForResource:@"simple-drum-beat" ofType:@"wav"]

@class EZAudioPlot;

@interface StudioPlayViewController : UIViewController<AVAudioPlayerDelegate,AVAudioRecorderDelegate,UITextFieldDelegate,EZAudioPlayerDelegate,EZMicrophoneDelegate, EZRecorderDelegate>
{
    AVAudioPlayer*audioPlayer;
    int text_flag;
    NSMutableArray*arr_text;
    NSMutableArray*arr_comment_id;
    NSMutableArray*arr_user_id;
    NSUserDefaults*defaults_userdata;
    NSMutableArray*arr_user_profile_pic;
    NSMutableArray*arr_user_username;
    NSMutableArray*arr_user_name;
    NSMutableArray*arr_comment_timedate;
    
}

@property (weak, nonatomic) IBOutlet UILabel *lbl_duration;
@property (weak, nonatomic) IBOutlet UILabel *lbl_dateStr;
@property (weak, nonatomic) IBOutlet UILabel *lbl_joindate;

//--------------------- * Current User * -----------------------------
@property (weak, nonatomic) IBOutlet UIImageView *img_currentUsrBG;
@property (weak, nonatomic) IBOutlet UIButton *btn_currentUsrProfile;
- (IBAction)btn_currentUsrProfileAction:(id)sender;
- (IBAction)btn_joinRecordingPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *img_currentUsrProfile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_currentUsrName;
- (IBAction)btn_cancelAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_cancel;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@property (weak, nonatomic) IBOutlet UICollectionView *col_view_profiles;
@property (weak, nonatomic) IBOutlet UICollectionViewCell *col_view_cell;
@property (weak, nonatomic) IBOutlet UILabel *lbl_id;
/***************Bottom tab outlet***************/

- (IBAction)btn_home:(id)sender;
- (IBAction)btn_back:(id)sender;

/*********************************************/
@property (strong,nonatomic) NSMutableDictionary *arr_recordings;
@property (strong,nonatomic) NSString *str_CurrernUserId;
@property (strong,nonatomic) NSMutableString *str_RecordingId;
@property (weak, nonatomic) IBOutlet UIImageView *img_profile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;
@property (weak, nonatomic) IBOutlet UILabel *lbl_subTitle;
- (IBAction)btn_InviteAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tbl_Instrument;

// *-----------------------* EQ & FX *------------------------
@property (weak, nonatomic) IBOutlet UIButton *btn_fxeq_hide;

- (IBAction)btn_fxeq_hide:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *_view_fx;
@property (weak, nonatomic) IBOutlet UIView *view_eq;
@property (weak, nonatomic) IBOutlet UIView *view_fxeq;


//------------------------  FX SLIDER---------------------------

@property (weak, nonatomic) IBOutlet UISlider *slider_pan;
@property (weak, nonatomic) IBOutlet UISlider *slider_pitch;
@property (weak, nonatomic) IBOutlet UISlider *slider_reverb;
@property (weak, nonatomic) IBOutlet UISlider *slider_bpm;
@property (weak, nonatomic) IBOutlet UISlider *slider_delay;
@property (weak, nonatomic) IBOutlet UISlider *slider_compression;

// ------------------------  EQ --------------------------
@property (weak, nonatomic) IBOutlet UISlider *slider_volume;
@property (weak, nonatomic) IBOutlet UISlider *slider_treble;
@property (weak, nonatomic) IBOutlet UISlider *slider_bass;

// *-----------------------* Bottom View * Count  *------------------------
@property (weak, nonatomic) IBOutlet UILabel *lbl_PlayCount;
@property (weak, nonatomic) IBOutlet UILabel *lbl_LikeCount;
@property (weak, nonatomic) IBOutlet UILabel *lbl_MsgCount;
@property (weak, nonatomic) IBOutlet UILabel *lbl_ShareCount;
@property (weak, nonatomic) IBOutlet UIButton *btn_include;
- (IBAction)btn_includeAction:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cons_CollectionView_hieght;

- (IBAction)btn_LikeAction:(id)sender;
- (IBAction)btn_CommentAction:(id)sender;
- (IBAction)btn_ShareAction:(id)sender;
- (IBAction)btn_DeleteAction:(id)sender;
//--------------------------------------------------------
// *-----------------------* Play methods  *------------------------
@property (weak, nonatomic) IBOutlet UIButton *btn_PlayAll;
- (IBAction)btn_PlayAllAction:(id)sender;

- (IBAction)btn_playAction:(id)sender;
- (IBAction)btn_previousAction:(id)sender;
- (IBAction)btn_nextAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lbl_currentUserCount;
@property (weak, nonatomic) IBOutlet UIButton *btn_play;
@property (weak, nonatomic) IBOutlet UIButton *btn_like;
@property (weak, nonatomic) IBOutlet UIButton *btn_comment;

//-------------------- * Comment View * ----------------------------
@property (weak, nonatomic) IBOutlet UIView *view_Comment;
@property (weak, nonatomic) IBOutlet UITextField *tf_addcomment;
@property (weak, nonatomic) IBOutlet UIButton *btn_send_cancel;
- (IBAction)btn_send_cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *view_Bottom;
@property (weak, nonatomic) IBOutlet UIView *view_record;
- (IBAction)btn_joinAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lbl_instuments_count;

@property (weak, nonatomic) IBOutlet UIButton *btn_join;


//EZAudioPLotGL
@property (nonatomic, strong) EZAudioFile *audioFile;
@property (weak, nonatomic) IBOutlet EZAudioPlotGL *view_wave;
@property (nonatomic, strong) EZAudioPlayer *player_wave;
@property (weak, nonatomic) IBOutlet UICollectionView *colUserName;

@property (weak, nonatomic) IBOutlet UIView *view_main;

@property (weak, nonatomic) IBOutlet UIView *view_join;
@property (nonatomic,weak) IBOutlet EZAudioPlot *audioPlot;
//
// The microphone component
//
@property (nonatomic, strong) EZMicrophone *microphone;
@property (nonatomic, assign) BOOL isRecording;

// New code for Redirection recording

@property (strong,nonatomic) NSString*fromScreen;
@property (strong,nonatomic) NSMutableDictionary *chatDict;

@property (strong,nonatomic) NSMutableDictionary *stationDict;
@end
