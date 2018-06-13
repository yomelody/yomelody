//
//  MelodyViewController.h
//  melody
//
//  Created by CodingBrainsMini on 11/26/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <StoreKit/StoreKit.h>
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface MelodyViewController : UIViewController<UIActivityItemSource,SKProductsRequestDelegate,SKPaymentTransactionObserver>
{
    NSUserDefaults *defaults_userdata;
    NSMutableArray*arr_plan_type;
    NSMutableArray*arr_recording_time;
    NSMutableArray*arr_packageStatusDetails;
    NSMutableArray*arr_layes;
    NSMutableArray*arr_plan_price;
    NSMutableArray *arr_response1;
    NSMutableArray*arr_filter_data_list;

    int status1;
    int status2;
    int currentSoundsIndex;
    BOOL melody_pack_tab_isOpen;
    BOOL recordings_tab_isOpen;
    /*********************Variables for melody packs ************************/
    NSMutableArray *arr_response;
    NSMutableArray*arr_melody_pack_id;
    NSMutableArray*arr_melody_pack_name;
    NSMutableArray*arr_melody_pack_instrumentals_count;
    NSMutableArray*arr_melody_pack_bpm;
    NSMutableArray*arr_melody_pack_genre;
    NSMutableArray*arr_melody_pack_station;
    NSMutableArray*arr_melody_pack_cover;
    NSMutableArray*arr_melody_pack_profile;
    NSMutableArray*arr_melody_pack_intrumentals;
    NSMutableArray*arr_melody_thumbnailURL;

    NSMutableArray*arr_melody_pack_post_date;
    NSMutableArray*arr_melody_pack_no_of_play;
    NSMutableArray*arr_melody_pack_no_of_like;
    NSMutableArray*arr_melody_pack_no_of_share;
    NSMutableArray*arr_melody_pack_no_of_coments;
    NSMutableArray*arr_melody_instrumentals_path;
    NSMutableArray*arr_melody_like_status;
    NSMutableArray*arr_melody_url;
    NSMutableArray*followerID,*arr_melody_pack_timerM;

    //followerID
    /**********************************************/
    /*********************Variables for Recordings ************************/
    NSMutableArray* arr_rec_play_count;
    NSMutableArray* arr_rec_like_count;
    NSMutableArray* arr_rec_comment_count;
    NSMutableArray* arr_rec_share_count,*arr_rec_duration;
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
    NSMutableArray*arr_rec_post_date;
    NSMutableArray* arr_rec_like_status;
    /**********************************************/
    NSMutableArray*arr_menu_items;
    NSMutableArray*arr_tab_select;
    NSMutableArray*arr_genre_id;
    NSString*genre,*genre1;
    int instrument_play_status;
    AVAudioPlayer*audioPlayer;
    /****************in app purchase******************/
    NSArray *validProducts;
    UIActivityIndicatorView *activityIndicatorView;
    IBOutlet UIButton *purchaseButton;
    NSMutableArray*arr_PublicState;
}

//------------------- * IAP * -------------------------
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
// Add two new method declarations
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;

- (void)fetchAvailableProducts;
- (BOOL)canMakePurchases;
- (void)purchaseMyProduct:(SKProduct*)product;
//-----------------------------------------------------

/*************************************************/
@property (strong,nonatomic) NSMutableString*str_parentID;

@property (assign,nonatomic) BOOL isJoinScreen;
@property (strong,nonatomic) NSString *view_suscription_visible;
@property (weak, nonatomic) IBOutlet UICollectionView *cv_menu;


- (IBAction)btn_back:(id)sender;
- (IBAction)btn_home:(id)sender;
@property (strong,nonatomic) NSMutableArray *arr_instruments_added;
@property (weak, nonatomic) NSString *sender_tag;
@property (weak, nonatomic) IBOutlet UIButton *btn_filter;
@property (weak, nonatomic) IBOutlet UIButton *btn_search;
- (IBAction)btn_filter:(id)sender;
- (IBAction)btn_search:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *tf_srearch;
- (IBAction)btn_search_cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_search_cancel;
@property (weak, nonatomic) IBOutlet UIView *view_search;
@property (weak, nonatomic) IBOutlet UIView *view_main_menu;
/*****************melody packs ,recordings and subscription tab outlets******************/
@property (weak, nonatomic) IBOutlet UIView *view_melodypacks_and_recordings_tab;
@property (weak, nonatomic) IBOutlet UITableView *tbl_view_melodypacks;
@property (weak, nonatomic) IBOutlet UITableView *tbl_view_recordings;
@property (weak, nonatomic) IBOutlet UIButton *btn_melodypacks_tab;
@property (weak, nonatomic) IBOutlet UIButton *btn_recording_tab;
@property (weak, nonatomic) IBOutlet UIButton *btn_subscription_tab;
- (IBAction)btn_melodypacks_tab:(id)sender;
- (IBAction)btn_recording_tab:(id)sender;
- (IBAction)btn_subscription_tab:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *view_subscription_tab;


@property (weak, nonatomic) IBOutlet UIImageView *img_view_user_profile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title_bellow_user_profile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_descrp_bellow_title;
@property (weak, nonatomic) IBOutlet UITableView *tbl_view_subscr_packs;
@property (nonatomic, assign) BOOL isCoverImage;
@property (nonatomic, strong) NSData* imagedata_forCover;
@property (nonatomic, strong) NSString* imagename_forCover;




@property (weak, nonatomic) IBOutlet UIImageView *placeholder_img;

/**********************************************************************/
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
@property (weak, nonatomic) IBOutlet UILabel *lbl_allRightsReservedYear;

@property (weak, nonatomic) IBOutlet UIView *view_tabBar;
@property (weak, nonatomic) IBOutlet UIButton *btn_restore;
- (IBAction)btn_restoreAction:(id)sender;

// New code for Redirection recording

@property (strong,nonatomic) NSString*fromScreen;
@property (strong,nonatomic) NSString*genereValue;
@property (strong,nonatomic) NSMutableDictionary *chatDict;
/******************************************************/
@property (strong,nonatomic) NSMutableDictionary *stationDict;
@property (strong,nonatomic) NSString *view_recording_visible;


@end
