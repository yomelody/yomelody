//
//  AudioFeedViewController.h
//  melody
//
//  Created by CodingBrainsMini on 11/21/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
#import "AudioFeedTableViewCell.h"
#import "ActivitiesTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
@interface AudioFeedViewController : UIViewController<AVAudioPlayerDelegate,AVAudioRecorderDelegate>
{
    NSMutableArray*arr_filter_data_list;
    int status;
    NSMutableArray*arr_menu_items;
    NSMutableArray*arr_tab_select;
    NSMutableArray*arr_genre_id;

    NSUserDefaults*defaults_userdata;
    /*********************Variables for Recordings ************************/
    NSMutableArray* arr_rec_play_count;
    NSMutableArray* arr_rec_like_count;
    NSMutableArray* arr_rec_comment_count;
    NSMutableArray* arr_rec_share_count;
    NSMutableArray *arr_rec_response;
    NSMutableArray*arr_rec_pack_id;
    NSMutableArray*arr_rec_name;
    NSMutableArray*arr_rec_recordings_count;
    NSMutableArray*arr_rec_bpm;
    NSMutableArray*arr_rec_genre;
    NSMutableArray*arr_rec_station;
    NSMutableArray*arr_rec_cover;
    NSMutableArray*arr_rec_profile;
    NSMutableArray*arr_rec_intrumentals;
    NSMutableArray*arr_rec_post_date;
    NSMutableArray*arr_rec_no_of_play;
    NSMutableArray*arr_rec_no_of_like;
    NSMutableArray*arr_rec_no_of_share;
    NSMutableArray*arr_rec_no_of_coments;
    NSMutableArray*arr_rec_like_status;
    NSMutableArray*arr_rec_recordings;
    NSMutableArray*arr_rec_recordings_url;
    NSMutableArray*followerID;
    NSMutableArray*arr_rec_thumbnail_url;
    NSMutableArray*arr_rec_duration,*arr_recordingCountM;
    NSMutableString*state;
    AVAudioPlayer *audioPlayer;
    NSTimer *recordingTimer;
    long instrument_play_index;
    int instrument_play_status;
    int sync_flag;

    /**********************************************/
    NSString*genre;
    NSInteger index;
    UIActivityViewController *activityController;
}

@property (nonatomic, assign) BOOL isBack;

@property (weak, nonatomic) IBOutlet NSString *sender_tag;

@property (weak, nonatomic) IBOutlet UICollectionView *cv_menu;
@property (weak, nonatomic) IBOutlet UIButton *btn_audio_tab;
- (IBAction)btn_audio_tab:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_activity_tab;
- (IBAction)btn_activity_tab:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_filter;
@property (weak, nonatomic) IBOutlet UIButton *btn_search;
- (IBAction)btn_filter:(id)sender;
- (IBAction)btn_search:(id)sender;
- (IBAction)btn_back:(id)sender;
- (IBAction)btn_home:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *tf_srearch;
- (IBAction)btn_search_cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_search_cancel;
@property (weak, nonatomic) IBOutlet UIView *view_search;
@property (weak, nonatomic) IBOutlet UIView *view_main_menu;


/**************************Audio Tab outlets*************************/
@property (weak, nonatomic) IBOutlet UIView *view_audiotab;
@property (weak, nonatomic) IBOutlet UITableView *tbl_view_audio_feed;
/***************************** ************************/

/**************************Activity Tab outlets************************/
@property (weak, nonatomic) IBOutlet UIView *view_activitytab;
@property (weak, nonatomic) IBOutlet UITableView *tbl_view_activity;
/****************************************************************/
/***************Bottom tab outlet***************/
@property (weak, nonatomic) IBOutlet UIButton *btn_audiofeed;
@property (weak, nonatomic) IBOutlet UIButton *btn_discover;
@property (weak, nonatomic) IBOutlet UIButton *btn_messenger;
@property (weak, nonatomic) IBOutlet UIButton *btn_profile;
- (IBAction)btn_audiofeed:(id)sender;
- (IBAction)btn_discover:(id)sender;
- (IBAction)btn_messenger:(id)sender;
- (IBAction)btn_profile:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *placeholder_img;

/*********************************************/
/****************Filter Audio shadow Autlets*************/
@property (weak, nonatomic) IBOutlet UIView *view_filter_shadow;
- (IBAction)btn_filter_shadow_cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tbl_view_filter_data_list;
@property (weak, nonatomic) IBOutlet UIView *view_filter;

/******************************************************/
@end
