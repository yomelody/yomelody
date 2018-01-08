//
//  StudioRecViewController.h
//  melody
//
//  Created by CodingBrainsMini on 11/24/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "WaveView.h"
#import "EZAudio.h"
#import "GTLRGmail.h"

#define kAudioFilePath @"sounds.wav"


@class CircleProgressBar;
@class AudioPlayerView;
@class EZAudioPlot;
@protocol AudioPlayerViewDelegate<NSObject>
-(void) audioPlayerViewPlayFromHTTPSelected:(AudioPlayerView*)audioPlayerView;

@end


typedef enum : NSUInteger {
    CustomizationStateDefault = 0,
    CustomizationStateCustom,
    CustomizationStateCustomAttributed,
} CustomizationState;

@interface StudioRecViewController : UIViewController<AVAudioPlayerDelegate,AVAudioRecorderDelegate,UITableViewDelegate,UITableViewDataSource,EZAudioPlayerDelegate,EZMicrophoneDelegate, EZRecorderDelegate>
{
    
   // UIView*view_master_volume;
    NSString*resulttimer;
    NSUserDefaults*defaults_userdata;
    NSMutableDictionary*dic;
    NSString *isMelody;
    NSMutableString*state;
    BOOL stopBtnFlag,pauseBtnFlag;
    NSData *objectData;
    NSTimer *recordingTimer;
    NSInteger seconds,totalSeconds,minutes,hours;
    AVAudioPlayer *audioPlayer;
    AVAudioRecorder *audioRecorder;
    NSMutableArray*arr_instruments;
    int cancel_back_status;
    int save_next_status;
    int sync_flag;
    int public_flag;
    int rec_type;
    NSData*imageData;
    NSString*imageName;
    NSMutableArray*arr_genre;
    NSMutableArray*arr_genre_select;
    NSMutableArray*arr_melodypack_instrumentals;
    NSMutableArray*arr_instrument_ids;
    NSMutableArray*arr_instrument_paths;
    long instrument_play_index;
    int instrument_play_status;
    NSDictionary*dic_response;
    NSMutableArray*arr_genre_id;
    NSMutableArray*arr_response1;
    NSMutableString*str_genre_id;
    BOOL btn_loop_isOn;

    NSMutableArray*arr_player_objects;
    NSMutableArray*arr_slider_timer_objects;
    AVAudioPlayer*audioPlayer_ofstate;
    NSString *thumbNailUrl;
}

@property (atomic, assign) BOOL canceled;
@property (nonatomic, strong) AVAudioRecorder *Audiorecorder;

@property (weak, nonatomic) IBOutlet UIButton *btn_done;

@property (weak, nonatomic) IBOutlet UIView *view_messege;
@property (weak, nonatomic) IBOutlet UIButton *btn_sync;
- (IBAction)btn_sync:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *view_sync;
@property (weak, nonatomic) IBOutlet WaveView *view_waveform;
//@property (nonatomic, weak) IBOutlet EZAudioPlotGL *audioPlot;
/*********************Outlets of view after Done button clicked******************/
@property (weak, nonatomic) IBOutlet UILabel *lbl_text;
@property (weak, nonatomic) IBOutlet UIView *view_topic;
@property (weak, nonatomic) IBOutlet UITextField *tf_topic;
@property (weak, nonatomic) IBOutlet UITextField *tf_genre;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_errow;
@property (weak, nonatomic) IBOutlet UIButton *btn_next_save;
@property (weak, nonatomic) IBOutlet UIButton *btn_back_cancel;
@property (weak, nonatomic) IBOutlet UIView *view_select_asmelody;
@property (weak, nonatomic) IBOutlet UIView *view_select_asrecording;
@property (weak, nonatomic) IBOutlet UIButton *btn_melody_select;
@property (weak, nonatomic) IBOutlet UIButton *btn_recording_select;
@property (weak, nonatomic) IBOutlet UIView *view_save_as;
@property (weak, nonatomic) IBOutlet UIView *view_saveas_popup;
- (IBAction)btn_cancel_back:(id)sender;
- (IBAction)btn_save_next:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *view_add_cover;
@property (weak, nonatomic) IBOutlet UITextField *tf_cover;
@property (weak, nonatomic) IBOutlet UIImageView *img_cover;
- (IBAction)btn_genre:(id)sender;
- (IBAction)btn_add_cover:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *view_genre_dropdown;
@property (weak, nonatomic) IBOutlet UITableView *tbl_view_genre;
- (IBAction)btn_genre_ok:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *view_genre;
@property (weak, nonatomic) IBOutlet UIImageView *img_rec_cover;
@property (weak, nonatomic) IBOutlet UIButton *btn_genre_ok;
- (IBAction)btn_melody_select:(id)sender;
- (IBAction)btn_rec_select:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView_Genere;
/* ********************  FX ******************* */

@property (weak, nonatomic) IBOutlet UISlider *slider_pan;
@property (weak, nonatomic) IBOutlet UISlider *slider_pitch;
@property (weak, nonatomic) IBOutlet UISlider *slider_reverb;
@property (weak, nonatomic) IBOutlet UISlider *slider_bpm;
@property (weak, nonatomic) IBOutlet UISlider *slider_delay;
@property (weak, nonatomic) IBOutlet UISlider *slider_compression;

/* ********************  EQ ******************* */
@property (weak, nonatomic) IBOutlet UISlider *slider_volume;
@property (weak, nonatomic) IBOutlet UISlider *slider_treble;
@property (weak, nonatomic) IBOutlet UISlider *slider_bass;


/***********************************************/
@property (weak, nonatomic) IBOutlet CircleProgressBar *view_circle_progress;

@property (weak, nonatomic) IBOutlet UITableView *tbl_view_instrumentals;

@property (weak, nonatomic) IBOutlet UILabel *lbl_station_recording;
@property (weak, nonatomic) IBOutlet UILabel *lbl_topic_recording;
@property (weak, nonatomic) IBOutlet UILabel *lbl_timer;
@property (weak, nonatomic) IBOutlet UILabel *lbl_date;
@property (weak, nonatomic) IBOutlet UILabel *lbl_topic_melody;
@property (weak, nonatomic) IBOutlet UILabel *lbl_date_melody;

@property (weak, nonatomic) IBOutlet UIImageView *img_vew_profile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_noinstrumentals;

@property (weak, nonatomic) IBOutlet CircleProgressBar *circleProgressBar;
@property (strong, nonatomic)NSData *objectData;

- (IBAction)btn_playAll_Action:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_playAll;

- (IBAction)btn_back:(id)sender;
- (IBAction)btn_home:(id)sender;
- (IBAction)switch_public_toggle:(id)sender;
- (IBAction)invite:(id)sender;
- (IBAction)btn_done:(id)sender;

//-------------* Property for Melody to Sudio recording *-------------
@property (retain,nonatomic) NSMutableArray*arr_melodypack_instrumental;
@property (strong,nonatomic) NSMutableString*str_name;
@property (strong,nonatomic) NSMutableString*str_date;
@property (assign,nonatomic) BOOL isJoinScreen;
@property (strong,nonatomic) NSMutableString*str_parentID;
@property (strong,nonatomic) NSString*str_instrumentTYPE;


@property (weak, nonatomic) IBOutlet UISwitch *switch_public;
@property (weak, nonatomic) IBOutlet UILabel *lbl_public;
@property (strong, nonatomic) NSMutableString*str_no_of_instrumentals;
/**********************Master volume popup outlets***********/
@property (weak, nonatomic) IBOutlet UIButton *btn_master_volume;
- (IBAction)btn_master_volume:(id)sender;

@property (weak, nonatomic) IBOutlet UIView*view_master_volume_shadow;
@property (weak, nonatomic) IBOutlet UIView*view_master_volume;
@property (weak, nonatomic) IBOutlet UISlider *slider_recording_volume;
@property (weak, nonatomic) IBOutlet UISlider *slider_melody_volume;
- (IBAction)cancel_mastervolume_popup:(id)sender;

/***********************************************************/
@property (weak, nonatomic) IBOutlet UIButton *btn_record_activities;
- (IBAction)btn_record_activities:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_state;
- (IBAction)btn_state:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *view_state;
/***************Bottom tab outlet***************/
@property (weak, nonatomic) IBOutlet UIButton *btn_audiofeed;
@property (weak, nonatomic) IBOutlet UIButton *btn_discover;
@property (weak, nonatomic) IBOutlet UIButton *btn_messenger;
@property (weak, nonatomic) IBOutlet UIButton *btn_profile;
- (IBAction)btn_audiofeed:(id)sender;
- (IBAction)btn_discover:(id)sender;
- (IBAction)btn_messenger:(id)sender;
- (IBAction)btn_profile:(id)sender;

/*********************************************/
/********************EX-EQ*********************/
@property (weak, nonatomic) IBOutlet UIButton *btn_fxeq_hide;
- (IBAction)btn_fxeq_hide:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *_view_fx;
@property (weak, nonatomic) IBOutlet UIView *view_eq;
@property (weak, nonatomic) IBOutlet UIView *view_fxeq;

//-------------- * Wave Form * --------------/



//------------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------------
@property (nonatomic, strong)  GIDSignInButton *signInButton;
@property (nonatomic, strong) UITextView *output;
@property (nonatomic, strong) GTLRGmailService *service;
//
// An EZAudioFile that will be used to load the audio file at the file path specified
//
@property (nonatomic, strong) EZAudioFile *audioFile;

//
// The CoreGraphics based audio plot
//
@property (nonatomic, strong) IBOutlet EZAudioPlotGL *audioPlot;
@property (nonatomic, strong) EZAudioPlayer *player;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isCoverImage;
@property (nonatomic, strong) NSData* imagedata_forCover;


@end
