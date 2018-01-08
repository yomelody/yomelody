//
//  DiscoverViewController.h
//  melody
//
//  Created by CodingBrainsMini on 11/21/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>


@interface DiscoverViewController : UIViewController<AVAudioPlayerDelegate>
{
  NSMutableArray*arr_filter_data_list;
    int status;
    NSUserDefaults*defaults_userdata;
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
    NSMutableArray*arr_rec_post_date,*arr_rec_duration;
    NSMutableArray*arr_rec_no_of_play;
    NSMutableArray*arr_rec_no_of_like;
    NSMutableArray*arr_rec_no_of_share;
    NSMutableArray*arr_rec_no_of_coments;
    NSMutableArray*arr_rec_like_status;
    NSMutableArray*followerID;
    NSMutableArray*arr_rec_recordings;
    NSMutableArray*arr_rec_recordings_url;

 
    /**********************************************/
    NSString*genre;
}
@property (weak, nonatomic) IBOutlet NSString *sender_tag;

@property (weak, nonatomic) IBOutlet UICollectionView *cv_menu;
@property (weak, nonatomic) IBOutlet UIView *vew_slider;

- (IBAction)btn_filter:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tbl_view_audiodeeds_filter;
- (IBAction)btn_back:(id)sender;
- (IBAction)btn_home:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *placeholder_img;

@property (weak, nonatomic) IBOutlet UITextField *tf_srearch;
- (IBAction)btn_search_cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_search_cancel;
@property (weak, nonatomic) IBOutlet UIView *view_search;
@property (weak, nonatomic) IBOutlet UIView *view_main;
- (IBAction)btn_search:(id)sender;
/**********************************************/

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
@end
