//
//  ViewController.h
//  melody
//
//  Created by CodingBrainsMini on 11/19/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <FacebookSDK/FacebookSDK.h>
//#import <TwitterCore/TwitterCore.h>
#import <TwitterKit/TwitterKit.h>
#import <Twitter/Twitter.h>
#import <TwitterCore/TwitterCore.h>
@import GoogleSignIn;
@interface ViewController : UIViewController<TWTRTimelineDelegate,TWTRTweetDetailViewControllerDelegate,TWTRTweetViewDelegate,TWTRAPIServiceConfig,UITextFieldDelegate>
{
    int i;
    int j;
    //NSMutableArray*setting_menu;
    NSMutableDictionary*dic_response;
    NSUserDefaults*defaults_userdata;
    NSString*f_name;
    NSString*l_name;
    NSString*app_id;
    NSString*User_name;
    NSString*email_id;
    NSString*profile_url;
    NSString*str_error_msg;
    TWTRSession *twsession;
    NSString *open_login;
    NSString*cover_url;
   
    int k;
}
@property (strong, nonatomic)NSString *open_login;
@property (nonatomic, assign)BOOL *isSignUpScreen;

@property (strong, nonatomic)NSString *other_vc_flag;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_main_logo;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_main_logo_st;
@property (weak, nonatomic) IBOutlet UILabel *lbl_bottom_quate;

@property (weak, nonatomic) IBOutlet UIView *view_profile_afterlogin;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_profile_pic;
@property (weak, nonatomic) IBOutlet UILabel *lbl_username;
@property (weak, nonatomic) IBOutlet UILabel *lbl_user_station;
@property (weak, nonatomic) IBOutlet UIView *view_profile_afterlogin_st;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_profile_pic_st;
@property (weak, nonatomic) IBOutlet UILabel *lbl_username_st;
@property (weak, nonatomic) IBOutlet UILabel *lbl_user_station_st;

- (IBAction)btn_logout:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btn_forgotPassword;
- (IBAction)btn_ForgotPwdAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btn_logout;
@property (weak, nonatomic) IBOutlet UIButton *btn_login;
@property (weak, nonatomic) IBOutlet UIButton *btn_signout_bottom;
- (IBAction)btn_signout_bottom:(id)sender;

- (IBAction)btn_station:(id)sender;
- (IBAction)btn_studio:(id)sender;
- (IBAction)btn_chat:(id)sender;
- (IBAction)btn_melody:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *view_bottom_menu;
/*******************settings  menu outlets*********/
- (IBAction)btn_settings:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *view_settings;
@property (weak, nonatomic) IBOutlet UIButton *setting_btn;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Settings;


/*************************************************/

- (IBAction)myAccountAction:(id)sender;

/****************SignIn menu outlets*******************/
@property (weak, nonatomic) IBOutlet UILabel *lbl_username_error;
@property (weak, nonatomic) IBOutlet UILabel *lbl_password_error;

@property (weak, nonatomic) IBOutlet UIButton *signin_btn;
- (IBAction)btn_signin:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *view_signup;
@property (weak, nonatomic) IBOutlet UITextField *tf_username;
@property (weak, nonatomic) IBOutlet UITextField *tf_password;
@property (weak, nonatomic) IBOutlet UIButton *btn_lets_go;
- (IBAction)reset_username:(id)sender;
- (IBAction)reset_password:(id)sender;
- (IBAction)btn_lets_go:(id)sender;
- (IBAction)btn_login_with_facebook:(id)sender;
- (IBAction)btn_login_with_twitter:(id)sender;
- (IBAction)login_with_sound_cloud:(id)sender;


/*****************************************/

- (IBAction)action_TermsService:(id)sender;
- (IBAction)actionPrivacyPolicy:(id)sender;
- (IBAction)action_RateApp:(id)sender;
- (IBAction)action_InviteContacts:(id)sender;
@property(weak, nonatomic) IBOutlet GIDSignInButton *signInButton;
@property(weak, nonatomic)  GIDGoogleUser *dicSignUserGoogle;


@end

