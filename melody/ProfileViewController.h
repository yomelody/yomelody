//
//  ProfileViewController.h
//  melody
//
//  Created by CodingBrainsMini on 11/21/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

@interface ProfileViewController : UIViewController<UIImagePickerControllerDelegate,AVAudioPlayerDelegate,AVAudioRecorderDelegate,UIActionSheetDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSMutableArray*arr_filter_data_list;
    NSUserDefaults*defaults_userdata;
    NSData *imageData;
    NSString *imageName;
    int status;
    
    NSMutableArray*arr_menu_items;
    NSMutableArray*arr_tab_select;
    NSMutableArray*arr_genre_id;
    /*********************Variables for Recordings ************************/
    
    NSMutableArray* arr_rec_play_count;
    NSMutableArray* arr_rec_like_count;
    NSMutableArray* arr_rec_comment_count;
    NSMutableArray* arr_rec_share_count;
    NSMutableArray *arr_rec_response;
    NSMutableArray*arr_rec_pack_id;
    NSMutableArray*arr_rec_name;
    NSMutableArray*arr_rec_instrumentals_count;
    NSMutableArray*arr_rec_bpm;
    NSMutableArray*arr_rec_genre;
    NSMutableArray*arr_rec_station;
    NSMutableArray*arr_rec_cover;
    NSMutableArray*arr_rec_profile;
    NSMutableArray*arr_rec_intrumentals;
    NSMutableArray*arr_rec_post_date, *arr_rec_duration;
    NSMutableArray*arr_rec_no_of_play;
    NSMutableArray*arr_rec_no_of_like;
    NSMutableArray*arr_rec_no_of_share;
    NSMutableArray*arr_rec_no_of_coments;
    NSMutableArray*arr_rec_like_status;
    int sender_tag;
    NSMutableArray*followerID;
    NSMutableArray*arr_rec_recordings;
    NSMutableArray*arr_rec_recordings_url;

    /**********************************************/
    AVAudioPlayer *audioPlayer;
    NSTimer *recordingTimer;
    long instrument_play_index;
    int instrument_play_status;
     /**********************************************/
    
    NSString*genre;
    //****************************
    UICollectionView*cv_images;
    UIView*dp_view;
    
}
@property (strong, nonatomic) NSString *user_id;
@property (strong, nonatomic) NSString *follower_id;
@property (weak, nonatomic) NSString *sender_tag;
@property (weak, nonatomic) IBOutlet UICollectionView *cv_menu;
- (IBAction)btn_back:(id)sender;
- (IBAction)btn_home:(id)sender;
- (IBAction)btn_edit_cover:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *tf_srearch;
- (IBAction)btn_search_cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_search_cancel;
@property (weak, nonatomic) IBOutlet UIView *view_search;
@property (weak, nonatomic) IBOutlet UIView *view_main_menu;


/************************ top section out lets***************/
@property (weak, nonatomic) IBOutlet UIImageView *img_view_cover;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_profile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_user_name;
@property (weak, nonatomic) IBOutlet UILabel *lbl_user_tweeter_id;
@property (weak, nonatomic) IBOutlet UILabel *lbl_number_of_records;
@property (weak, nonatomic) IBOutlet UILabel *lbl_number_of_fans;
@property (weak, nonatomic) IBOutlet UILabel *lbl_number_of_followings;

/*************************************************************/
/******tab buttons outlets and actions and views autlets**********/
@property (weak, nonatomic) IBOutlet UIButton *btn_audio_tab;
@property (weak, nonatomic) IBOutlet UIButton *btn_activity_tab;
@property (weak, nonatomic) IBOutlet UIButton *btn_bio_tab;
@property (weak, nonatomic) IBOutlet UIButton *btn_filter;
@property (weak, nonatomic) IBOutlet UIButton *btn_search;
- (IBAction)btn_audio_tab:(id)sender;
- (IBAction)btn_activity_tab:(id)sender;
- (IBAction)btn_bio_tab:(id)sender;
- (IBAction)btn_filter:(id)sender;
- (IBAction)btn_search:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lbl_description;

@property (weak, nonatomic) IBOutlet UIButton *btn_all_tab;
@property (weak, nonatomic) IBOutlet UIButton *btn_hiphop_tab;
@property (weak, nonatomic) IBOutlet UIButton *btn_pop_tab;
@property (weak, nonatomic) IBOutlet UIButton *btn_rock_tab;
@property (weak, nonatomic) IBOutlet UIButton *btn_raggae_tab;
@property (weak, nonatomic) IBOutlet UIButton *btn_edm_tab;
- (IBAction)btn_all_tab:(id)sender;
- (IBAction)btn_hiphop_tab:(id)sender;
- (IBAction)btn_pop_tab:(id)sender;
- (IBAction)btn_rock_tab:(id)sender;
- (IBAction)btn_raggae_tab:(id)sender;
- (IBAction)btn_edm_tab:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *view_activity;
@property (weak, nonatomic) IBOutlet UIView *view_audio;
@property (weak, nonatomic) IBOutlet UITableView *tbl_view_activities;
@property (weak, nonatomic) IBOutlet UITableView *tbl_view_audios;


/***************bio tab outlets******************/

@property (weak, nonatomic) IBOutlet UIButton *btn_edit_biotab;
- (IBAction)btn_edit_description:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_profile_biotab;
@property (weak, nonatomic) IBOutlet UILabel *lbl_artist;
@property (weak, nonatomic) IBOutlet UILabel *lbl_station;
@property (weak, nonatomic) IBOutlet UILabel *lbl_created_date;
@property (weak, nonatomic) IBOutlet UITextView *text_view_description;
@property (weak, nonatomic) IBOutlet UIView *view_bio_tab;

/*******************************************/
/***************************************************************/
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
/****************Filter Audio shadow Autlets*************/
@property (weak, nonatomic) IBOutlet UIView *view_filter_shadow;
- (IBAction)btn_filter_shadow_cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tbl_view_filter_data_list;
@property (weak, nonatomic) IBOutlet UIView *view_filter;

/******************************************************/
@property (weak, nonatomic) IBOutlet UIButton *btn_chat;
- (IBAction)btn_chat:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_follow_unfollow;
- (IBAction)btn_follow_unfollow:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *placeholder_img;
@property (weak, nonatomic) IBOutlet UIButton *btn_editCover;

@property (weak, nonatomic) IBOutlet UIImageView *img_editBtn;

@property (weak, nonatomic) IBOutlet UIImageView *img_editProfile;

@end
