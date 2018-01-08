//
//  Constant.h
//  melody
//
//  Created by coding Brains on 04/07/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#ifndef Constant_h
#define Constant_h
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "TSMessage.h"
#import "SVProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AFNetworking/AFNetworking.h>
#import <Photos/Photos.h>
#import "ViewController.h"
#import "DBManager.h"
#import "Reachability.h"
#import "ActionSheetPicker.h"
//#import <FacebookSDK/FacebookSDK.h>
#import "PayPalMobile.h"
#import "MessengerViewController.h"
#endif /* Constant_h */
//http://52.89.220.199/api/company_policy/privacy_policy.php
#define PRIVACY_POLICY_URL @"http://52.89.220.199/api/company_policy/privacy_policy.php"
#define TERMS_SERVICE_URL @"http://52.89.220.199/api/company_policy/terms_services.php"

#define BaseUrl @"http://52.89.220.199/api/"//25/07/17 LIVE
//#define BaseUrl @"http://52.89.220.199/dev_api/"//25/07/17 DEV

#pragma ERROR MESSAGES
#define NUMBERS_ONLY @"1234567890"
#define CHARACTER_LIMIT 3
#define MSG_NoInternetMsg @"Internet not available"
#define MSG_TimedOut @"Connection Timed Out"
#define MSG_AuthError @"AuthFailiure Error"
#define MSG_NetworkError @"Network Error"
#define MSG_ParseError @"Parse Error"
//@"Registered Successfuly!"
#define Station_list 0
#define Filter 1
#define Search 2
#define MAX_FILE_SIZE 100*100
#define MSG_RegisteredSucces @"Registration Successful!"
#define MSG_FilterArtist @"Choose Artist Name to Search Artist"
#define MSG_Email @"Please enter your Email"
#define MSG_EmailTitle @"Forgot Password"

#define MSG_FilterArtistTItle @"Artist"
#define MSG_FilterBPM @"Enter the Value of BPM"
#define MSG_FilterBPMTItle @"BPM"
#define KEY @"admin@123"
#define KEY_PASSED @"passed"
#define KEY_AUTH_VALUE @"@_$%yomelody%audio#@mixing(app*"
#define KEY_AUTH_KEY @"ApiAuthenticationKey"

#define Appdelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#pragma mark - Navigation
#define Activity @"Activity"
#define Messenger @"Messenger"
#define Placeholder @"Write something..."
#define INSTRUMENT_TYPE @"instrument_id"
#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

//-----------------------* Key Value *----------------------
#define KEY_USER_ID @"id"
#define KEY_KEY @"key"
#define KEY_GENRE_NAME @"genre_name"
#define KEY_BPM_COUNT @"bpm_count"
#define KEY_LIKE_COUNT @"like_count"
#define KEY_PLAY_COUNT @"play_count"
#define KEY_PROFILE_URL @"profile_url"
#define KEY_RECORDING_TOPIC @"recording_topic"
#define KEY_RECORDING_URL @"recording_url"
#define KEY_RECORDINGS @"recordings"
#define KEY_INSTRUMENT_URL @"instrument_url"
#define KEY_BPM @"bpm"
#define KEY_COVER_URL @"cover_url"
#define KEY_TITLE @"title"
#define KEY_DURATION @"duration"
#define KEY_USER_NAME @"user_name"
#define KEY_SHARE_COUNT @"share_count"
#define KEY_THUMBNAIL_URL @"thumbnail_url"
#define KEY_JOIN_COUNT @"join_count"
#define KEY_LIKE_STATUS @"like_status"
#define KEY_ADVERTISEMENT_IMAGE @"adv_image"
#define KEY_ADVERTISEMENT_NAME @"adv_name"
#define KEY_LOGIN_TYPE @"logintype"
#define KEY_ACTIVITY_TIME @"ActivityTime"
#define KEY_SHARE_FILETYPE @"file_type"

#define MSG_LOGOUT @"Logout Successfully"
//file_type

