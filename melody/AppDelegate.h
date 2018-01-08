//
//  AppDelegate.h
//  melody
//
//  Created by CodingBrainsMini on 11/19/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import <UserNotifications/UserNotifications.h>
#import "MBProgressHUD.h"
#import "Constant.h"
#import <Photos/Photos.h>
#import "chatViewController.h"
@import GoogleSignIn;
@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate,GIDSignInUIDelegate>
{
    NSDictionary *userInfo;
    MBProgressHUD *hud;
    
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic)  NSString* screen_After_Login;
@property (assign) BOOL isHomeClicked;
@property (assign) BOOL isGoogleLogin;
@property (assign) BOOL isFirstTimeSignUp;
@property(nonatomic , strong) GIDGoogleUser *dicSignUserGoogleA;
@property(assign) NSInteger fromShareScreen;
@property (nonatomic, assign) id currentViewController;
@property (retain, nonatomic) NSString *str_chat_status;
@property(nonatomic , strong) PHFetchResult *assetsFetchResults;
@property(nonatomic , strong) PHCachingImageManager *imageManager;
@property(nonatomic , strong) NSMutableArray*arr_Gallery_Items;

-(void)showProgressHud;
-(void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI;
-(NSString*)HourCalculation:(NSString*)PostDate;
- (UIImage *) scaleAndRotateImage: (UIImage *)image;
-(NSString *)formatDateWithString:(NSString *)date;
- (BOOL)hasGalleryPermission;
/**
 *  Method to add Progress Whenever the ASIHttp request is fired
 *
 *  @param details sub string when the progress hud is shown
 *  @param label   main string when the progress hud is shown
 */

-(void)showProgressHudForViewWithDetailsLabel:(NSString*)details andLabelText:(NSString*)label;

/**
 *  Method to show the message in toast
 *
 *  @param message Description string
 *  @param delay   time till when the message will be displayed
 */
-(void) showMessageHudWithMessage:(NSString*)message andDelay:(float)delay;

/**
 *  Method called when progress hud is to be hidden
 */
-(void)hideProgressHudInView;
-(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize;

- (void) handleURL:(NSURL *)url;
- (NSString *)timeFormatted:(NSString *)totalSeconds;
-(NSString*)TodayTimeCalculation:(NSString*)PostDate;
- (id)valueOrNil:(id)value;

@end
