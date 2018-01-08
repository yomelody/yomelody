  //
//  ViewController.m
//  melody
//
//  Created by CodingBrainsMini on 11/19/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import "ViewController.h"
#import "MelodyViewController.h"
#import "UpdateAccountViewController.h"
#import "SignUpViewController.h"
#import "Constant.h"
#import "Terms_ServiceVC.h"
#import "Privacy_PolicyVC.h"
#import "MessengerViewController.h"
#import "AudioFeedViewController.h"
#import "StudioRecViewController.h"
#import "contactsViewController.h"
#import "BraintreePayPal.h"
#import "ProgressHUD.h"
#define thumbSize CGSizeMake(130, 150)
@import Firebase;
@import GoogleSignIn;
@import FBSDKLoginKit;
@import FBSDKCoreKit;
@import FBSDKShareKit;
@interface ViewController ()<GIDSignInUIDelegate>
{
    NSString * accessToken,*str_Email;
    FBSDKLoginManager *login;

}
@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@end


int i;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SVProgressHUD dismiss];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        // User is logged in, do work such as go to next view controller.
    }
    FBSDKButton *btn;
    [[NSNotificationCenter defaultCenter] addObserverForName:FBSDKAccessTokenDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:
     ^(NSNotification *notification) {
         if (notification.userInfo[FBSDKAccessTokenDidChangeUserID]) {
             // Handle user change
         }
         if ([FBSDKProfile currentProfile]) {
             // Update for new user profile
         }
     }];
    
    
    //------------------- GOOGLE ----------------------
    // TODO(developer) Configure the sign-in button look/feel
    NSLog(@"DICT ===%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]);

    [GIDSignIn sharedInstance].uiDelegate = self;
    
    if ([Appdelegate isGoogleLogin]) {
        
        _dicSignUserGoogle = [Appdelegate dicSignUserGoogleA];
        NSLog(@"_dicSignUserGoogle ===%@",_dicSignUserGoogle);
        [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES;

        [self callSocialLoginGoogle];
    }
    // Uncomment to automatically sign in the user.
    //[[GIDSignIn sharedInstance] signInSilently];
    //----------------------------------------------------
    /******************DELETE SAVED INSTRUMENTS******************/
    BOOL success = NO;
    NSString *alertString = @"Data not deleted";
    
    success = [[DBManager getSharedInstance] DeleteFromTable:@"Instruments3"];
    if (success == NO) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:
                              alertString message:nil
                                                      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else{
        NSLog(@"Data deleted");
  
    }
   
    
    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //Change the host name here to change the server you want to monitor.
    NSString *remoteHostName = @"www.apple.com";
    NSString *remoteHostLabelFormatString = NSLocalizedString(@"Remote Host: %@", @"Remote host label format string");
   // self.remoteHostLabel.text = [NSString stringWithFormat:remoteHostLabelFormatString, remoteHostName];
    
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];

    f_name=[[NSString alloc]init];
    app_id=[[NSString alloc]init];
    l_name=[[NSString alloc]init];
    email_id=[[NSString alloc]init];
    User_name=[[NSString alloc]init];
    profile_url=[[NSString alloc]init];
    str_error_msg=[[NSString alloc]init];
    cover_url=[[NSString alloc]init];
    defaults_userdata = [NSUserDefaults standardUserDefaults];
    [defaults_userdata synchronize];
    
      dic_response=[[NSMutableDictionary alloc]init];
    /*******************Bottom menu ***********************/
    i=0;
    j=0;
    self.view_bottom_menu.frame =  CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 667);
    /*********************************************************/

    UIColor *color = [UIColor grayColor];
    
    _tf_username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    _tf_password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    _btn_lets_go.layer.cornerRadius=20;
    
    /******************profile view afterlogin**********/
    _img_view_profile_pic.layer.cornerRadius = _img_view_profile_pic.frame.size.width / 2;
    _img_view_profile_pic.clipsToBounds = YES;
    _img_view_profile_pic.userInteractionEnabled = YES;
    UITapGestureRecognizer *pgr = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self action:@selector(handlePictab:)];
    [_img_view_profile_pic addGestureRecognizer:pgr];
    
    _img_view_profile_pic_st.layer.cornerRadius = _img_view_profile_pic_st.frame.size.width / 2;
    _img_view_profile_pic_st.clipsToBounds = YES;
    _img_view_profile_pic_st.userInteractionEnabled = YES;
    UITapGestureRecognizer *pgr_st = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handlePictab:)];
    [_img_view_profile_pic_st addGestureRecognizer:pgr_st];
  
    /*************************************************/
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    UISwipeGestureRecognizer*swipedown=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [swipedown setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:swipedown];
    
    
//    TWTRLogInButton *logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession *session, NSError *error) {
//        if (session) {
//            NSLog(@"signed in as %@", [session userName]);
//            NSLog(@"signed%@",session);
//        } else {
//            NSLog(@"error: %@", [error localizedDescription]);
//        }
//    }];
//    logInButton.center = self.view.center;
//    [self.view addSubview:logInButton];
    
    
    if ([_open_login isEqual:@"1"])
    {
        //_view_signup.hidden=YES;
        [_view_signup setHidden:NO];
        _lbl_bottom_quate.text=@"Or signin with your favorite social network";
        
        // _view_settings.hidden=NO;
        [_view_settings setHidden:YES];
        CGRect r = [_view_settings frame];
        r.origin.y = self.view.frame.size.height;
        [_view_settings setFrame:r];
        [UIView animateWithDuration:0.3
                              delay:0.0
         // options:UIViewAnimationCurveEaseOut
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^(void) {
                             self.view_bottom_menu.frame =  CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
                         }
                         completion:NULL];
        self.view_settings.hidden=NO;
        
        [_setting_btn setTitle:@"Done" forState:UIControlStateNormal];
        [_setting_btn setTitleColor:[UIColor colorWithRed:0.0f green:132.0f blue:200.0f alpha:.6] forState:UIControlStateNormal ];
        if (i>0) {
            i=i-1;
        }
        j=j+1;
        if (j>1) {
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^(void) {
                                 self.view_bottom_menu.frame =  CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                             }
                             completion:NULL];
            [_setting_btn setTitle:@"Done" forState:UIControlStateNormal];
            [_setting_btn setTitleColor:[UIColor colorWithRed:0.0f green:132.0f blue:200.0f alpha:.6] forState:UIControlStateNormal ];
            [_signin_btn setTitle:@"Sign in" forState:UIControlStateNormal];
            [_signin_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
            
            j=0;
        }

        
    }
    
    else if ([_open_login isEqual:@"0"]) {
        
        /********* First settings Label will hide *********/
        self.lbl_Settings.hidden = YES;
        [_view_signup setHidden:NO];
        _lbl_bottom_quate.text=@"Or signin with your favorite social network";
        [self.signin_btn setHidden:YES];
        [_view_settings setHidden:YES];
        CGRect r = [_view_settings frame];
        r.origin.y = self.view_settings.frame.origin.y;
        [_view_settings setFrame:r];
        [UIView animateWithDuration:0.3
                              delay:0.0
         // options:UIViewAnimationCurveEaseOut
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^(void) {
                             self.view_bottom_menu.frame =  CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
                         }
                         completion:NULL];
        self.view_settings.hidden=YES;
        
        [_setting_btn setTitle:@"Done" forState:UIControlStateNormal];
        [_setting_btn setTitleColor:[UIColor colorWithRed:0.0f green:132.0f blue:200.0f alpha:.6] forState:UIControlStateNormal ];
        self.signin_btn.hidden = YES;
        //     [_setting_btn setTitle:@"Settings" forState:UIControlStateNormal];
        //     [_setting_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
        if (i>0) {
            i=i-1;
        }
        j=j+1;
        if (j>1) {
            [UIView animateWithDuration:0.3
                                  delay:0.0
             // options:UIViewAnimationCurveEaseOut
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^(void) {
                                 self.view_bottom_menu.frame =  CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                             }
                             completion:NULL];
            [_setting_btn setTitle:@"Settings" forState:UIControlStateNormal];
            [_setting_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
            [_signin_btn setTitle:@"Sign in" forState:UIControlStateNormal];
            [_signin_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
            
            j=0;
        }
       
    }

    _tf_password.tag=2;
    _tf_username.tag=1;
    [_tf_password addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    [_tf_username addTarget:self
                     action:@selector(textFieldDidChange:)
           forControlEvents:UIControlEventEditingChanged];
}

//-(void)pushNotificationReceived
//{
//    [self performSegueWithIdentifier:@"roottochat" sender:self];
//
//}

/* Called by Reachability whenever status changes.
*/
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}


- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (reachability == self.hostReachability)
    {
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        BOOL connectionRequired = [reachability connectionRequired];
        NSString* statusString = @"";
        
        switch (netStatus)
        {
            case NotReachable:        {
                statusString = NSLocalizedString(@"Access Not Available", @"Text field text for access is not available");
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                // Set the annular determinate mode to show task progress.
                hud.mode = MBProgressHUDModeText;
                hud.label.text = NSLocalizedString(@"internet not available!", @"HUD message title");
                hud.label.tintColor=[UIColor blueColor];
                // Move to bottm center.
                hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                
                [hud hideAnimated:YES afterDelay:2.f];

        /*
                 Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
                 */
                NSLog(@"internet not available");
                connectionRequired = NO;
                break;
            }
                
            case ReachableViaWWAN:        {
                statusString = NSLocalizedString(@"Reachable WWAN", @"");
                NSLog(@"internet available");
                
                break;
            }
            case ReachableViaWiFi:        {
                statusString= NSLocalizedString(@"Reachable WiFi", @"");
                  [MBProgressHUD hideHUDForView:self.view animated:NO];
               

                break;
            }
        }
        
        if (connectionRequired)
        {
            NSString *connectionRequiredFormatString = NSLocalizedString(@"%@, Connection Required", @"Concatenation of status string with connection requirement");
            statusString= [NSString stringWithFormat:connectionRequiredFormatString, statusString];
        }
 

        
        NSString* baseLabelText = @"";
        
        if (connectionRequired)
        {
            baseLabelText = NSLocalizedString(@"Cellular data network is available.\nInternet traffic will be routed through it after a connection is established.", @"Reachability text if a connection is required");
        }
        else
        {
            baseLabelText = NSLocalizedString(@"Cellular data network is active.\nInternet traffic will be routed through it.", @"Reachability text if a connection is not required");
        }
    }
    
    if (reachability == self.internetReachability)
    {
        
    }
    
}





- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}






- (void)handlePictab:(UITapGestureRecognizer *)pinchGestureRecognizer
{
    [self performSegueWithIdentifier:@"go_to_profile" sender:self];
}



-(void)dismissKeyboard
{
    [_tf_username resignFirstResponder];
    [_tf_password resignFirstResponder];
}


- (void)viewWillAppear:(BOOL)animated {
    
    [Appdelegate hideProgressHudInView];
    if ([[defaults_userdata stringForKey:@"rememberme"] isEqual:@"remember"]) {
        _btn_logout.hidden=NO;
        _btn_login.hidden=YES;
        _btn_signout_bottom.hidden=NO;
        _signin_btn.hidden=YES;
        
        _view_profile_afterlogin.hidden=NO;
        _img_view_main_logo.hidden=YES;
        [_img_view_profile_pic setImage:[UIImage imageWithData:[defaults_userdata objectForKey:@"profile_pic"]]];
        // NSLog(@"%@",[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[jsonResponse objectForKey:@"response"] objectForKey:@"profilepic"] ]]);
        
        _view_profile_afterlogin_st.hidden=NO;
        _img_view_main_logo_st.hidden=YES;
        [_img_view_profile_pic_st setImage:[UIImage imageWithData:[defaults_userdata objectForKey:@"profile_pic"]]];
        // NSLog(@"%@",[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[jsonResponse objectForKey:@"response"] objectForKey:@"profilepic"] ]]);
        NSString *userName = [NSString stringWithFormat:@"%@ %@",[defaults_userdata stringForKey:@"first_name"],[defaults_userdata stringForKey:@"last_name"]];
        
        _lbl_username.text = userName;
        _lbl_username_st.text = userName;
        _lbl_user_station_st.text=[NSString stringWithFormat:@"@%@",[defaults_userdata stringForKey:@"user_name"]];
        _lbl_user_station.text=[NSString stringWithFormat:@"@%@",[defaults_userdata stringForKey:@"user_name"]];
        
        _lbl_username_st.numberOfLines = 1;
        _lbl_username_st.minimumFontSize = 8;
        _lbl_username_st.adjustsFontSizeToFitWidth = YES;

        _lbl_user_station_st.numberOfLines = 1;
        _lbl_user_station_st.minimumFontSize = 6;
        _lbl_user_station_st.adjustsFontSizeToFitWidth = YES;

        _lbl_username.numberOfLines = 1;
        _lbl_username.minimumFontSize = 8;
        _lbl_username.adjustsFontSizeToFitWidth = YES;

        _lbl_user_station.numberOfLines = 1;
        _lbl_user_station.minimumFontSize = 6;
        _lbl_user_station.adjustsFontSizeToFitWidth = YES;
   
    }
    
    /* If controllers comes from sign up screen through pressing signin button */
    else if([_open_login isEqualToString:@"0"]){
        [self.setting_btn setHidden:NO];
        _btn_logout.hidden=YES;
        _btn_login.hidden=NO;
        _btn_signout_bottom.hidden=YES;
        _view_profile_afterlogin.hidden=YES;
        _img_view_main_logo.hidden=NO;
        _view_profile_afterlogin_st.hidden=YES;
        _img_view_main_logo_st.hidden=NO;
    }
    else
    {
        _btn_logout.hidden=YES;
        _btn_login.hidden=NO;
        _btn_signout_bottom.hidden=YES;
        _signin_btn.hidden=NO;
        _view_profile_afterlogin.hidden=YES;
        _img_view_main_logo.hidden=NO;
        _view_profile_afterlogin_st.hidden=YES;
        _img_view_main_logo_st.hidden=NO;
        
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
  
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view_bottom_menu.frame;
        if (isiPhone5) {
//            f.origin.y =-(keyboardSize.height);
            f.origin.y =-20;
        }
        
        self.view_bottom_menu.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view_bottom_menu.frame;
        f.origin.y = 0;
        self.view_bottom_menu.frame = f;
    }];
}
//-(void)textFieldDidChange :(UITextField *)theTextField{
//    NSLog( @"text changed: %@", theTextField.text);
//    if ([_tf_write_msg.text length]>0) {
//        flag_text=1;
//        [_btn_cancel setTitle:@"Send" forState:UIControlStateNormal];
//    }else{
//        flag_text=0;
//    }
//}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"Working!!!");
//    [_tf_username resignFirstResponder];
//    [_tf_password resignFirstResponder];
    
    if (textField.tag==1) {
        if ([_tf_username.text length]==0) {
            _lbl_username_error.text=@"Required";
        }
        else
        {
         _lbl_username_error.text=nil;
        }
       
    }
    if (textField.tag==2) {
        
        if ([_tf_password.text length]==0) {
            _lbl_password_error.text=@"Required";
        }
        else
        {
           _lbl_password_error.text=nil;
        }
    }
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return YES;
}
- (void)textFieldDidChange:(UITextField *)textField{

    if (textField.tag==1) {
        if ([_tf_username.text length]==0) {
            _lbl_username_error.text=@"Required";
        }
        else
        {
            _lbl_username_error.text=nil;
        }
        
    }
    if (textField.tag==2) {
        
        if ([_tf_password.text length]==0) {
            _lbl_password_error.text=@"Required";
        }
        else
        {
            _lbl_password_error.text=nil;
        }
    }
    
}

- (IBAction)btn_logout:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert !"
                                                                   message:@"Are you sure you want to sign out ?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       
                                                       [self LogOutMethod];
                                                   }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       
                                                   }];
    [alert addAction:cancel];
    [alert addAction:submit];

    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)logout_API{
    @try{
    NSDictionary* params = @{
                             @"user_id":[defaults_userdata valueForKey:@"user_id"],
                             KEY_AUTH_KEY:KEY_AUTH_VALUE
                             };
    NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@logout.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            [SVProgressHUD dismiss];
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Alert"
                                          message:MSG_NoInternetMsg
                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"ok"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            //Handel your yes please button action here
                                        }];
            
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSError *myError = nil;
                
                NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSLog(@"%@",requestReply);
                NSData *data2=[requestReply dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                id jsonObject = [NSJSONSerialization
                                 
                                 JSONObjectWithData:data2
                                 options:NSJSONReadingAllowFragments error:&myError];
                
                NSLog(@"%@",jsonObject);
                if ([[jsonObject valueForKey:@"flag"] isEqual:@"success"]) {
                    
                    NSString *succesMSG = [jsonObject valueForKey:@"msg"];
                    [defaults_userdata removeObjectForKey:@"login_type"];
                    [ProgressHUD showSuccess:@"Logout successfully"];
                }
                
                else{
                    [SVProgressHUD dismiss];
                    UIAlertController * alert=   [UIAlertController
                                                  alertControllerWithTitle:@"Alert"
                                                  message:MSG_LOGOUT
                                                  preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* yesButton = [UIAlertAction
                                                actionWithTitle:@"ok"
                                                style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action)
                                                {
                                                    //Handel your yes please button action here
                                                }];
                    [alert addAction:yesButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            });
        }
    }];
    [task resume];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}

-(void)LogOutMethod
{
    @try{
    if ([Appdelegate isGoogleLogin])
    {
        Appdelegate.isGoogleLogin = NO;
        [[GIDSignIn sharedInstance]signOut];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"rememberme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _btn_login.hidden=NO;
    _btn_logout.hidden=YES;
    _signin_btn.hidden=NO;
    _btn_signout_bottom.hidden=YES;
    _view_profile_afterlogin.hidden=YES;
    _img_view_main_logo.hidden=NO;
    _view_profile_afterlogin_st.hidden=YES;
    _img_view_main_logo_st.hidden=NO;
    
        // -------  Facebook logout -------
    [login logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];
        //---------------------------------
    [defaults_userdata setBool:NO forKey:@"isUserLogged"];
    [defaults_userdata setObject:@"0" forKey:@"like_status"];
    
    UIColor *color = [UIColor grayColor];
    _tf_username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    
    NSLog(@"%@",[defaults_userdata stringForKey:@"app_id"]);
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies)
    {
        // put a check here to clear cookie url which starts with twitter and then delete it
        [cookieStorage deleteCookie:each];
    }
    [self logout_API];
    [self resetDefaults];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}



- (IBAction)btn_signout_bottom:(id)sender {
    NSLog(@"SIGN_OUT");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert !"
                                                                   message:@"Are you sure you want to sign out ?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [self LogOutMethod];
                                                   }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       
                                                   }];
    [alert addAction:cancel];
    [alert addAction:submit];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)resetDefaults {
    @try{
    [defaults_userdata removeObjectForKey:@"first_name"];
    [defaults_userdata removeObjectForKey:@"user_name"];
    [defaults_userdata removeObjectForKey:@"profile_pic"];
    [defaults_userdata removeObjectForKey:@"profile_pic"];
    [defaults_userdata removeObjectForKey:@"cover_pic"];
    [defaults_userdata removeObjectForKey:@"user_name"];
    [defaults_userdata removeObjectForKey:@"register_date"];
    [defaults_userdata removeObjectForKey:@"discription"];
    [defaults_userdata removeObjectForKey:@"user_id"];
    [defaults_userdata removeObjectForKey:@"rememberme"];
    [defaults_userdata synchronize];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}

- (IBAction)btn_station:(id)sender {
    
}

- (IBAction)btn_studio:(id)sender {
}

- (IBAction)btn_chat:(id)sender {
    
    if ([defaults_userdata boolForKey:@"isUserLogged"]) {
        MessengerViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MessengerViewController"];
        myVC.isShare_Audio = NO;

        [self presentViewController:myVC animated:YES completion:nil];
    }
    else{
        Appdelegate.screen_After_Login = Messenger;
        [self module_signin];
    }
}



- (IBAction)action_RateApp:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/apple-store/id375380948?mt=8"];
    //https://www.apple.com/itunes/
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (IBAction)btn_ForgotPwdAction:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:MSG_EmailTitle
                                                                   message:MSG_Email
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       
                                                       if (alert.textFields.count > 0) {
                                                           
                                                           UITextField *textField = [alert.textFields firstObject];
                                                           str_Email = textField.text;
                                                           [self forgotPasswordAPI];
                                                       }
                                                   }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       
                                                   }];
    
    [alert addAction:submit];
    [alert addAction:cancel];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Email"; // if needs
    }];
    
    [self presentViewController:alert animated:YES completion:nil];


}


-(void)forgotPasswordAPI{
    @try{
    NSDictionary* params = @{
                             KEY_AUTH_KEY:KEY_AUTH_VALUE,
                             @"email":str_Email
                             };
    NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@forgot_password.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            //                                                            [SVProgressHUD dismiss];
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Alert"
                                          message:MSG_NoInternetMsg
                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"ok"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            //Handel your yes please button action here
                                        }];
            
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSError *myError = nil;
                
                NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSLog(@"%@",requestReply);
                NSData *data2=[requestReply dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                id jsonObject = [NSJSONSerialization
                                 
                                 JSONObjectWithData:data2
                                 options:NSJSONReadingAllowFragments error:&myError];
                
                NSLog(@"%@",jsonObject);
                if ([[jsonObject valueForKey:@"flag"] isEqual:@"Success"]) {
                    NSString *succesMSG = @"A link to reset password has been sent to your email address.";
                    
                    [TSMessage showNotificationWithTitle:NSLocalizedString(@"Success", nil)
                                                subtitle:NSLocalizedString(succesMSG, nil)
                                                    type:TSMessageNotificationTypeSuccess];
                }
                
                else{
                    NSString *errorMSG = [jsonObject valueForKey:@"password"];
                    [SVProgressHUD dismiss];
                    UIAlertController * alert=   [UIAlertController
                                                  alertControllerWithTitle:@"Alert"
                                                  message:errorMSG
                                                  preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* yesButton = [UIAlertAction
                                                actionWithTitle:@"ok"
                                                style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action)
                                                {
                                                    //Handel your yes please button action here
                                                }];
                    [alert addAction:yesButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            });
        }
    }];
    [task resume];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}


- (IBAction)btn_melody:(id)sender {
    
}

- (IBAction)btn_settings:(id)sender {
    self.lbl_Settings.hidden = NO;
    CGRect r = [_view_settings frame];
    r.origin.y = _view_settings.frame.origin.y;
    [_view_settings setFrame:r];
     [_view_signup setHidden:YES];
    
    [_view_settings setHidden:NO];
    
//   _lbl_bottom_quate.text=@"InstaMelody v1.0 - Studio Version";
    _lbl_bottom_quate.text=@"Best with Headphones";

    [UIView animateWithDuration:0.3
                          delay:0.0
     // options:UIViewAnimationCurveEaseOut
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         self.view_bottom_menu.frame =  CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:NULL];
     [_setting_btn setTitle:@"Done" forState:UIControlStateNormal];
     [_setting_btn setTitleColor:[UIColor colorWithRed:0.0f green:132.0f blue:200.0f alpha:.6] forState:UIControlStateNormal ];
    if([defaults_userdata boolForKey:@"isUserLogged"]) {
        self.signin_btn.hidden = YES;
    }
    else{
        self.signin_btn.hidden = NO;
 
    }
     [_signin_btn setTitle:@"Sign in" forState:UIControlStateNormal];
     [_signin_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    if (j>0) {
        j=j-1;
    }
    i=i+1;
    if (i>1) {
        [UIView animateWithDuration:0.3
                              delay:0.0
         // options:UIViewAnimationCurveEaseOut
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^(void) {
                             self.view_bottom_menu.frame =  CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                         }
                         completion:NULL];
         self.view_settings.hidden=YES;
        [_setting_btn setTitle:@"Settings" forState:UIControlStateNormal];
         [_setting_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
        [_signin_btn setTitle:@"Sign in" forState:UIControlStateNormal];
         [_signin_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
        i=0;
    }

    // btn_menu.hidden=NO;
        // self.view_settings.hidden=YES;
    
                    /*To hide
         [UIView animateWithDuration:0.25 animations:^{
         view_menu.frame =  CGRectMake(130, 30, 0, 0);
         [view_menu setAlpha:0.0f];
         } completion:^(BOOL finished) {
         [view_menu setHidden:YES];
         }];
         */
        
        /*  [UIView animateWithDuration:.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
         self.headerView.frame  = CGRectMake(0, 0, 320,30);
         } completion:^(BOOL finished) {
         
         [UIView animateWithDuration:.5 delay:2.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
         self.headerView.frame  = CGRectMake(0, -30, 320,30);
         
         } completion:^(BOOL finished) {
         
         }];
         
         }];*/
  
}

- (IBAction)btn_signin:(id)sender {
    
    [self module_signin];
    
}


-(void)module_signin{
    
    self.lbl_Settings.hidden = YES;
    [_view_signup setHidden:NO];
    _lbl_bottom_quate.text=@"Or signin with your favorite social network";
    
    [_view_settings setHidden:YES];
    CGRect r = [_view_settings frame];
    r.origin.y = self.view_settings.frame.origin.y;
    [_view_settings setFrame:r];
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^(void) {
                         self.view_bottom_menu.frame =  CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:NULL];
    self.view_settings.hidden=YES;
    UIColor *color = [UIColor grayColor];
    
    _tf_username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    [_setting_btn setTitle:@"Done" forState:UIControlStateNormal];
    
    [_setting_btn setTitleColor:[UIColor colorWithRed:0.0f green:132.0f blue:200.0f alpha:.6] forState:UIControlStateNormal ];
    self.signin_btn.hidden = YES;
    if (i>0) {
        i=i-1;
    }
    j=j+1;
    if (j>1) {
        [UIView animateWithDuration:0.3
                              delay:0.0
         // options:UIViewAnimationCurveEaseOut
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^(void) {
                             self.view_bottom_menu.frame =  CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
                         }
                         completion:NULL];
        [_setting_btn setTitle:@"Settings" forState:UIControlStateNormal];
        [_setting_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
        [_signin_btn setTitle:@"Sign in" forState:UIControlStateNormal];
        [_signin_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
        
        j=0;
    }

}




- (IBAction)btn_login_with_facebook:(id)sender {
//
    @try{
    login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    [login
     logInWithReadPermissions: @[@"email",@"public_profile",@"user_friends"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             app_id = result.token.appID;
             profile_url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", result.token.userID];

             [FBSDKProfile loadCurrentProfileWithCompletion:
              ^(FBSDKProfile *profile, NSError *error) {
                  if (profile) {
                      
                    f_name=[[NSMutableString alloc]init];
                    l_name=[[NSMutableString alloc]init];
                      
                      f_name = profile.firstName;
                      l_name = profile.lastName;
//                      email_id = profile.
                      User_name=profile.name;
                      NSLog(@"Hello, %@!", profile.firstName);
                      [self callSocialLoginWithFacebook];

                  }
              }];
             NSLog(@"Logged in");
         }
     }];
}
@catch (NSException *exception) {
    NSLog(@"exception at likes.php :%@",exception);
}
@finally{
    
}

}


- (IBAction)btn_login_with_twitter:(id)sender {
    
    @try{
//    [Appdelegate showProgressHud];
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
               if (session) {
            NSLog(@"signed in as %@", [session authToken]);
//            [Appdelegate hideProgressHudInView];
            /* Get user info */
            TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:session.userID];
            [client loadUserWithID:session.userID completion:^(TWTRUser * _Nullable user, NSError * _Nullable error) {
//                [Appdelegate hideProgressHudInView];
                NSLog(@"%@",user);
                f_name=[[NSMutableString alloc]init];
                l_name=[[NSMutableString alloc]init];

                NSArray*arr_name=[user.name componentsSeparatedByString:@" "];
                
                for (k=0; k<[arr_name count]-1; k++) {
                    f_name=[NSString stringWithFormat:@"%@ %@ %@",f_name,arr_name[k],[NSString stringWithFormat:@"%@",arr_name[[arr_name count]-1]]];
                }
                l_name=[NSString stringWithFormat:@"%@",arr_name[[arr_name count]-1]];
                app_id=user.userID;
                User_name=session.userName;
                profile_url=user.profileImageLargeURL;
                [self callSocialLogintwr];

            }];
                   

        } else {
            [Appdelegate hideProgressHudInView];
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}

-(void)requestUserEmail
{

}

#pragma mark- GooGle Method


- (IBAction)login_with_sound_cloud:(id)sender {

//    if ([[GIDSignIn sharedInstance] hasAuthInKeychain]) {
        NSLog(@"in if ");
        [[GIDSignIn sharedInstance] signIn];

//    }
//    else{
//        NSLog(@"in else ");
//
//    }
}
    
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    
    
}
    
    // Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn
presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
    
}
    
    // Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
    


- (void)showAlertWithMessage:(NSString*)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark- LOGIN METHOD
#pragma mark-

#pragma mark- GOOGLE LOGIN

-(void)callSocialLoginGoogle
{
    @try{
    if (cover_url == nil) {
        cover_url = @"";
    }
    app_id = _dicSignUserGoogle.userID;      // For client-side use only!
//    app_id= _dicSignUserGoogle.authentication.idToken; // Safe to send to the server
    User_name = _dicSignUserGoogle.profile.name;
    f_name = _dicSignUserGoogle.profile.givenName;
    l_name = _dicSignUserGoogle.profile.familyName;
    email_id = _dicSignUserGoogle.profile.email;
    if ([GIDSignIn sharedInstance].currentUser.profile.hasImage)
    {
        NSUInteger dimension = round(thumbSize.width * [[UIScreen mainScreen] scale]);
        NSURL *imageURL = [_dicSignUserGoogle.profile imageURLWithDimension:dimension];
        profile_url = imageURL.absoluteString;
    }

    
    NSString*device_token;
    if([[[FIRInstanceID instanceID] token] isEqual: [NSNull null]]){
        device_token=[[NSString alloc]initWithFormat:@"DUMMYTOKEN"];
    }
    else{
        device_token=[[NSString alloc]initWithFormat:@"%@",[[FIRInstanceID instanceID] token]];
    }
    
   
        [SVProgressHUD setForegroundColor:[UIColor greenColor]];
        [SVProgressHUD show];
        
        NSDictionary* params = @{
                                 KEY_AUTH_KEY:KEY_AUTH_VALUE,
                                 @"f_name":f_name,
                                 @"l_name":l_name,
                                 @"email":email_id,
                                 @"password":@"",
                                 @"username":User_name,//User_name
                                 @"dob":@"" ,
                                 @"usertype":@"4" ,
                                 @"appid":app_id,
                                 @"cover_pic_url":cover_url,
                                 @"profile_pic_url":profile_url,
                                 @"device_token":device_token,
                                 @"device_type":@"ios"
                                 };
        NSLog(@"%@",params);
        NSMutableString* parameterString = [NSMutableString string];
        for(NSString* key in [params allKeys])
        {
            if ([parameterString length]) {
                [parameterString appendString:@"&"];
            }
            [parameterString appendFormat:@"%@=%@",key, params[key]];
        }
        NSString* urlString = [NSString stringWithFormat:@"%@registration.php",BaseUrl];
        NSURL* url = [NSURL URLWithString:urlString];
        //this is how cookies were created
        NSURLSession* session =[NSURLSession sharedSession];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPShouldHandleCookies:NO];
        
        // __block NSDictionary* jsonResponse;
        NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if(error)
            {
                //do something
                NSLog(@"%@", error);
                [SVProgressHUD dismiss];
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"Message"
                                              message:MSG_NoInternetMsg
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"ok"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action)
                                            {
                                                //Handel your yes please button action here
                                                
                                            }];
                [alert addAction:yesButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    NSError *myError = nil;
                    
                    NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                    NSLog(@"%@",requestReply);
                    NSData *data = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                                 options:kNilOptions
                                                                                   error:&myError];
                    
                    NSLog(@"%@",jsonResponse);
                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                        
                        [defaults_userdata setObject:[dic_response objectForKey:@"profilepic"] forKey:@"profile_pic"];
                       
                        
                        [defaults_userdata setObject:@"4" forKey:@"login_type"];
                        [defaults_userdata setBool:YES forKey:@"isUserLogged"];
                        dic_response=[jsonResponse objectForKey:@"response"];
                         profile_url=[dic_response objectForKey:@"profilepic"];
                        NSLog(@"%@",dic_response);
                        //----------------callSocialLogintwr ---------------
                        if ([_other_vc_flag isEqual:@"1"]) {
                            
                            _img_view_main_logo.hidden=YES;
                            _view_profile_afterlogin.hidden=NO;
                            [_img_view_profile_pic setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profile_url]]]];
                            [defaults_userdata setObject:@"remember" forKey:@"rememberme"];
                            
                            _lbl_username.text=[NSString stringWithFormat:@"%@ %@",f_name,l_name];
                            _lbl_user_station.text=[NSString stringWithFormat:@"@%@",[dic_response objectForKey:@"username"]];
                            
                            _img_view_main_logo_st.hidden=YES;
                            _view_profile_afterlogin_st.hidden=NO;
                            [_img_view_profile_pic_st setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profile_url]]]];
                            
                            _lbl_user_station_st.text=[NSString stringWithFormat:@"@%@",[dic_response objectForKey:@"username"]];
                            
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"username"]] forKey:@"user_name"];
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"f_name"]] forKey:@"first_name"];
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"l_name"]] forKey:@"last_name"];
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"id"]] forKey:@"user_id"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",app_id] forKey:@"fapp_id"];
                            
                            [defaults_userdata setObject:profile_url forKey:@"profile_pic_url"];
                            
//                            [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:profile_url]] forKey:@"profile_pic"];
                            [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dic_response objectForKey:@"profilepic"]]] forKey:@"profile_pic"];
                            
                            [defaults_userdata setObject:cover_url forKey:@"cover_pic_url"];
                            [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:cover_url]] forKey:@"cover_pic"];
                            
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"discription"]] forKey:@"discription"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"email"]] forKey:@"email"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"dob"]] forKey:@"dob"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"mobile"]] forKey:@"mobile"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"fans"]] forKey:@"fans"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"followers"]] forKey:@"followers"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"records"]] forKey:@"records"];
                            [defaults_userdata synchronize];
                            _btn_logout.hidden=NO;
                            _btn_login.hidden=YES;
                            _view_profile_afterlogin.hidden=NO;
                            _img_view_main_logo.hidden=YES;
                            _btn_signout_bottom.hidden=NO;
                            _signin_btn.hidden=YES;
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }
                        else
                        {
                            [UIView animateWithDuration:0.3 animations:^{
                                CGRect f = self.view_bottom_menu.frame;
                                f.origin.y = self.view.frame.size.height;
                                self.view_bottom_menu.frame = f;
                                
                                _img_view_main_logo.hidden=YES;
                                _view_profile_afterlogin.hidden=NO;
                                [_img_view_profile_pic setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profile_url]]]];
                                [defaults_userdata setObject:@"remember" forKey:@"rememberme"];
                                
                                _lbl_user_station.text=[NSString stringWithFormat:@"@%@",[dic_response objectForKey:@"username"]];
                                _lbl_username.text=[NSString stringWithFormat:@"%@ %@",[dic_response objectForKey:@"f_name"],[dic_response objectForKey:@"l_name"]];//N
                                
                                _img_view_main_logo_st.hidden=YES;
                                _view_profile_afterlogin_st.hidden=NO;
                                [_img_view_profile_pic_st setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profile_url]]]];
                                _lbl_username_st.text= [NSString stringWithFormat:@"%@",f_name];
                                _lbl_user_station_st.text=[NSString stringWithFormat:@"@%@",[dic_response objectForKey:@"username"]];
                                
                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"username"]] forKey:@"user_name"];
                                
                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"f_name"]] forKey:@"first_name"];
                                
                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"l_name"]] forKey:@"last_name"];
                                
                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"id"]] forKey:@"user_id"];
                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",app_id] forKey:@"fapp_id"];
                                
                                [defaults_userdata setObject:profile_url forKey:@"profile_pic_url"];
                                
//                                [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:profile_url]] forKey:@"profile_pic"];
                                [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dic_response objectForKey:@"profilepic"]]] forKey:@"profile_pic"];
                                
                                [defaults_userdata setObject:cover_url forKey:@"cover_pic_url"];
                                [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:cover_url]] forKey:@"cover_pic"];
                                
                                
                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"discription"]] forKey:@"discription"];
                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"email"]] forKey:@"email"];
                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"dob"]] forKey:@"dob"];
                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"mobile"]] forKey:@"mobile"];
                                
                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"fans"]] forKey:@"fans"];
                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"followers"]] forKey:@"followers"];
                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"records"]] forKey:@"records"];
                                
                                [defaults_userdata synchronize];
                                // [self viewDidLoad];
                                _btn_logout.hidden=NO;
                                _btn_login.hidden=YES;
                                _view_profile_afterlogin.hidden=NO;
                                _img_view_main_logo.hidden=YES;
                                _btn_signout_bottom.hidden=NO;
                                _signin_btn.hidden=YES;
                                NSLog(@"%@",defaults_userdata);
                            }];
                            
                        }
                        
                    }
                    else
                    {
                        if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                            UIAlertController * alert=   [UIAlertController
                                                          alertControllerWithTitle:@"Message"
                                                          message:[jsonResponse objectForKey:@"msg"]
                                                          preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction* yesButton = [UIAlertAction
                                                        actionWithTitle:@"ok"
                                                        style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action)
                                                        {
                                                            //Handel your yes please button action here
                                                            
                                                        }];
                            
                            [alert addAction:yesButton];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                        
                        
                    }
                    
                });
            }
        }];
        [task resume];
    
    }
    @catch (NSException *exception) {
        NSLog(@"exception at registration with google :%@",exception);
    }
    @finally{
        
    }
}


//------------------ Login For Twitter --------------------
-(void)callSocialLogintwr
{
    
    @try{
    NSString*device_token;
    [Appdelegate showProgressHud];

    if([[[FIRInstanceID instanceID] token] isEqual: [NSNull null]]){
        device_token=[[NSString alloc]initWithFormat:@"DUMMYTOKEN"];
    }
    else{
        device_token=[[NSString alloc]initWithFormat:@"%@",[[FIRInstanceID instanceID] token]];
    }
    if (app_id == nil || User_name == nil || device_token == nil)
    {

            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Login"
                                          message:@"Login failed.."
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"ok"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            //Handel your yes please button action here
                                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"rememberme"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                            _btn_login.hidden=NO;
                                            _btn_logout.hidden=YES;
                                            _signin_btn.hidden=NO;
                                            _btn_signout_bottom.hidden=YES;
                                            
                                            _view_profile_afterlogin.hidden=YES;
                                            _img_view_main_logo.hidden=NO;
                                            
                                            _view_profile_afterlogin_st.hidden=YES;
                                            _img_view_main_logo_st.hidden=NO;
//                                            FBSession *session = [[FBSession alloc] initWithPermissions:@[@"public_profile", @"email"]];
//                                            [FBSession setActiveSession:session];
//                                            [session closeAndClearTokenInformation];
//                                            [session close];
//                                            [FBSession setActiveSession:nil];
                                            [defaults_userdata setBool:NO forKey:@"isUserLogged"];
                                            [defaults_userdata setObject:@"0" forKey:@"like_status"];
                                            
                                            UIColor *color = [UIColor grayColor];
                                            _tf_username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
                                            
                                            NSLog(@"%@",[defaults_userdata stringForKey:@"app_id"]);
                                            
                                            NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                                            for (NSHTTPCookie *each in cookieStorage.cookies) {
                                                // put a check here to clear cookie url which starts with twitter and then delete it
                                                [cookieStorage deleteCookie:each];
                                            }
                                            [self resetDefaults];
                                            
                                        }];
            
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
        
    }
    else{
    [SVProgressHUD setForegroundColor:[UIColor greenColor]];
    
    NSDictionary* params = @{
                             KEY_AUTH_KEY:KEY_AUTH_VALUE,
                             @"f_name":f_name,
                             @"l_name":l_name,
                             @"email":email_id,
                             @"password":@"",
                             @"username":User_name,//User_name
                             @"dob":@"" ,
                             @"usertype":@"3" ,
                             @"appid":app_id,
                             @"cover_pic_url":cover_url,
                             @"profile_pic_url":profile_url,
                             @"device_token":device_token,
                             @"device_type":@"ios"
                             };
    NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
     NSString* urlString = [NSString stringWithFormat:@"%@registration.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    //this is how cookies were created
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    
    // __block NSDictionary* jsonResponse;
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(error)
        {
            //do something
            NSLog(@"%@", error);
            [Appdelegate hideProgressHudInView];
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Message"
                                          message:MSG_NoInternetMsg
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"ok"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            //Handel your yes please button action here
                                            
                                        }];
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *myError = nil;
                
                NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSLog(@"%@",requestReply);
                NSData *data = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:kNilOptions
                                                                               error:&myError];
                
                NSLog(@"%@",jsonResponse);
                if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    
                    [defaults_userdata setObject:@"3" forKey:@"login_type"];
                    [defaults_userdata setBool:YES forKey:@"isUserLogged"];
                    dic_response=[jsonResponse objectForKey:@"response"];
                    NSLog(@"%@",dic_response);
                    //----------------callSocialLogintwr ---------------
                     if ([_other_vc_flag isEqual:@"1"]) {
                         [Appdelegate hideProgressHudInView];

                         _img_view_main_logo.hidden=YES;
                         _view_profile_afterlogin.hidden=NO;
                         [_img_view_profile_pic setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profile_url]]]];
                         [defaults_userdata setObject:@"remember" forKey:@"rememberme"];
                         
                         _lbl_username.text=[NSString stringWithFormat:@"%@ %@",f_name,l_name];
                         _lbl_user_station.text=[NSString stringWithFormat:@"@%@",[dic_response objectForKey:@"username"]];
                         
                         _img_view_main_logo_st.hidden=YES;
                         _view_profile_afterlogin_st.hidden=NO;
                         [_img_view_profile_pic_st setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profile_url]]]];
                         
                         _lbl_user_station_st.text=[NSString stringWithFormat:@"@%@",[dic_response objectForKey:@"username"]];
                         
                         
                         [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"username"]] forKey:@"user_name"];
                         
                         [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"f_name"]] forKey:@"first_name"];
                         
                         [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"l_name"]] forKey:@"last_name"];
                         
                         [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"id"]] forKey:@"user_id"];
                         [defaults_userdata setObject:[NSString stringWithFormat:@"%@",app_id] forKey:@"fapp_id"];
                         
                         [defaults_userdata setObject:profile_url forKey:@"profile_pic_url"];
                         
                         [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:profile_url]] forKey:@"profile_pic"];
                         [defaults_userdata setObject:cover_url forKey:@"cover_pic_url"];
                         [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:cover_url]] forKey:@"cover_pic"];
                         
                         
                         [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"discription"]] forKey:@"discription"];
                         [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"email"]] forKey:@"email"];
                         [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"dob"]] forKey:@"dob"];
                         [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"mobile"]] forKey:@"mobile"];
                         //                  [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"registerdate"]] forKey:@"register_date"];
                         [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"fans"]] forKey:@"fans"];
                         [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"followers"]] forKey:@"followers"];
                         [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"records"]] forKey:@"records"];
                         
                         // [defaults_userdata setObject:str_fb_token forKey:@"fb_id"];
                         [defaults_userdata synchronize];
                         // [self viewDidLoad];
                         _btn_logout.hidden=NO;
                         _btn_login.hidden=YES;
                         _view_profile_afterlogin.hidden=NO;
                         _img_view_main_logo.hidden=YES;
                         _btn_signout_bottom.hidden=NO;
                         _signin_btn.hidden=YES;
                         [self dismissViewControllerAnimated:YES completion:nil];
                     }
                    else
                    {
                        [Appdelegate hideProgressHudInView];
                        [UIView animateWithDuration:0.3 animations:^{
                            CGRect f = self.view_bottom_menu.frame;
                            f.origin.y = self.view.frame.size.height;
                            self.view_bottom_menu.frame = f;
                            
                            _img_view_main_logo.hidden=YES;
                            _view_profile_afterlogin.hidden=NO;
                            [_img_view_profile_pic setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profile_url]]]];
                            // NSLog(@"%@",[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[jsonResponse objectForKey:@"response"] objectForKey:@"profilepic"] ]]);
                            [defaults_userdata setObject:@"remember" forKey:@"rememberme"];
                            
                            _lbl_user_station.text=[NSString stringWithFormat:@"@%@",[dic_response objectForKey:@"username"]];
                            _lbl_username.text=[NSString stringWithFormat:@"%@ %@",[dic_response objectForKey:@"f_name"],[dic_response objectForKey:@"l_name"]];//N
                            
                            _img_view_main_logo_st.hidden=YES;
                            _view_profile_afterlogin_st.hidden=NO;
                            [_img_view_profile_pic_st setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profile_url]]]];
                            _lbl_username_st.text= [NSString stringWithFormat:@"%@",f_name];
                            _lbl_user_station_st.text=[NSString stringWithFormat:@"@%@",[dic_response objectForKey:@"username"]];
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"username"]] forKey:@"user_name"];
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"f_name"]] forKey:@"first_name"];
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"l_name"]] forKey:@"last_name"];
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"id"]] forKey:@"user_id"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",app_id] forKey:@"fapp_id"];
                            
                            [defaults_userdata setObject:profile_url forKey:@"profile_pic_url"];
                            
                            [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:profile_url]] forKey:@"profile_pic"];
                            [defaults_userdata setObject:cover_url forKey:@"cover_pic_url"];
                            [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:cover_url]] forKey:@"cover_pic"];
                            
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"discription"]] forKey:@"discription"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"email"]] forKey:@"email"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"dob"]] forKey:@"dob"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"mobile"]] forKey:@"mobile"];
                            //                  [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"registerdate"]] forKey:@"register_date"];
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"fans"]] forKey:@"fans"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"followers"]] forKey:@"followers"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"records"]] forKey:@"records"];
                            
                            // [defaults_userdata setObject:str_fb_token forKey:@"fb_id"];
                            [defaults_userdata synchronize];
                            // [self viewDidLoad];
                            _btn_logout.hidden=NO;
                            _btn_login.hidden=YES;
                            _view_profile_afterlogin.hidden=NO;
                            _img_view_main_logo.hidden=YES;
                            _btn_signout_bottom.hidden=NO;
                            _signin_btn.hidden=YES;
                            NSLog(@"%@",defaults_userdata);
                        }];

                    }
                    
                }
                else
                {
                    [Appdelegate hideProgressHudInView];

                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"Message"
                                                      message:[jsonResponse objectForKey:@"msg"]
                                                      preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* yesButton = [UIAlertAction
                                                    actionWithTitle:@"ok"
                                                    style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action)
                                                    {
                                                        //Handel your yes please button action here
                                                        
                                                    }];
                        
                        [alert addAction:yesButton];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    
                    
                }
                
            });
        }
    }];
    [task resume];
    }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at registration.php :%@",exception);
    }
    @finally{
        
    }
}



//------------------ Login For FaceBook --------------------
-(void)callSocialLoginWithFacebook
{
    
    @try{
        
        [Appdelegate showProgressHud];
        if ([cover_url length]<=0)
            {
                cover_url=@"https://pbs.twimg.com/profile_images/675440683713355777/V1IsQqqa_reasonably_small.png";
            }
     NSLog(@"%@",[[FIRInstanceID instanceID] token]);
    NSString*device_token;
    if([[[FIRInstanceID instanceID] token] isEqual: [NSNull null]]){
        device_token = [[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"];    }
    else{
        device_token = [[FIRInstanceID instanceID] token];
    }
    
    NSString *profilePicUrlStr =[profile_url stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *apiEndpointPP = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",profilePicUrlStr];
    NSString *shortProfilePicURL = [NSString stringWithContentsOfURL:[NSURL URLWithString:apiEndpointPP]
                                                            encoding:NSASCIIStringEncoding
                                                               error:nil];
    NSLog(@"Long: %@ - Short: %@",profilePicUrlStr,shortProfilePicURL);
    NSString *coverPicUrlStr =[cover_url stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *apiEndpointCP = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",coverPicUrlStr];
    NSString *shortCoverPicURL = [NSString stringWithContentsOfURL:[NSURL URLWithString:apiEndpointCP]
                                                          encoding:NSASCIIStringEncoding
                                                             error:nil];
    NSLog(@"Long: %@ - Short: %@",coverPicUrlStr,shortCoverPicURL);
    NSDictionary* params = @{
                             KEY_AUTH_KEY:KEY_AUTH_VALUE,
                             @"f_name":f_name,
                             @"l_name":l_name,
                             @"email":@"",//amol@codingbrains.com
                             @"password":@"",
                             @"username":User_name,
                             @"dob":@"" ,
                             @"usertype":@"2" ,
                             @"appid":app_id,
                             @"cover_pic_url":shortCoverPicURL,
                             @"profile_pic_url":profile_url,
                             @"device_token":device_token,
                             @"device_type":@"ios"
                             };
    NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
     NSString* urlString = [NSString stringWithFormat:@"%@registration.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    
    //this is how cookies were created
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(error)
        {
            //do something
            [Appdelegate hideProgressHudInView];
            NSLog(@"%@", error);
            [SVProgressHUD dismiss];
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Message"
                                          message:MSG_NoInternetMsg
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"ok"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            //Handel your yes please button action here
                                        }];
            
            
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *myError = nil;
                
                NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSLog(@"%@",requestReply);

                NSData *data = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:kNilOptions
                                                                               error:&myError];
                
                NSLog(@"%@",jsonResponse);
                if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    [Appdelegate hideProgressHudInView];

                    [defaults_userdata setObject:@"2" forKey:@"login_type"];
                    [defaults_userdata setBool:YES forKey:@"isUserLogged"];
                    dic_response=[jsonResponse objectForKey:@"response"];
                    NSLog(@"%@",dic_response);
                   //-------------------- callSocialLoginWithFacebook ---------------
                    if ([_other_vc_flag isEqual:@"1"]) {
                        [Appdelegate hideProgressHudInView];

                        _img_view_main_logo.hidden=YES;
                        _view_profile_afterlogin.hidden=NO;
                        
                        [_img_view_profile_pic setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dic_response valueForKey:@"profilepic"]]]]];
  
                        [defaults_userdata setObject:@"remember" forKey:@"rememberme"];
                        
                        _lbl_user_station.text=[NSString stringWithFormat:@"@%@",[dic_response objectForKey:@"username"]];
                        
                        _img_view_main_logo_st.hidden=YES;
                        _view_profile_afterlogin_st.hidden=NO;
                        
                        [_img_view_profile_pic_st setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dic_response valueForKey:@"profilepic"]]]]];
                        
                        _lbl_username_st.text=[NSString stringWithFormat:@"%@",f_name];
                        
                        _lbl_user_station_st.text=[NSString stringWithFormat:@"@%@",[dic_response objectForKey:@"username"]];
                        
                        
                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"username"]] forKey:@"user_name"];
                        
                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"f_name"]] forKey:@"first_name"];
                        
                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"l_name"]] forKey:@"last_name"];
                        
                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"id"]] forKey:@"user_id"];
                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",app_id] forKey:@"fapp_id"];
                        
                        [defaults_userdata setObject:[dic_response valueForKey:@"profilepic"] forKey:@"profile_pic_url"];
                        
                        [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dic_response valueForKey:@"profilepic"]]] forKey:@"profile_pic"];
                        [defaults_userdata setObject:cover_url forKey:@"cover_pic_url"];
                        [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:cover_url]] forKey:@"cover_pic"];
                        
                        
                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"discription"]] forKey:@"discription"];
                       [defaults_userdata setObject:[NSString stringWithFormat:@"%@",  [dic_response objectForKey:@"email"]] forKey:@"email"];
                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"dob"]] forKey:@"dob"];
                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"mobile"]] forKey:@"mobile"];
      //                  [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"registerdate"]] forKey:@"register_date"];
                       
                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"fans"]] forKey:@"fans"];
                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"followers"]] forKey:@"followers"];
                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"records"]] forKey:@"records"];
                        
                        [defaults_userdata synchronize];
                        _btn_logout.hidden=NO;
                        _btn_login.hidden=YES;
                        _view_profile_afterlogin.hidden=NO;
                        _img_view_main_logo.hidden=YES;
                        _btn_signout_bottom.hidden=NO;
                        _signin_btn.hidden=YES;
                         [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    else{
                        [Appdelegate hideProgressHudInView];

                        //Handel your yes please button action here
                        [UIView animateWithDuration:0.3 animations:^{
                            CGRect f = self.view_bottom_menu.frame;
                            f.origin.y = self.view.frame.size.height;
                            self.view_bottom_menu.frame = f;
                            
                            _img_view_main_logo.hidden=YES;
                            _view_profile_afterlogin.hidden=NO;
                            [_img_view_profile_pic setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dic_response valueForKey:@"profilepic"]]]]];
                            // NSLog(@"%@",[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[jsonResponse objectForKey:@"response"] objectForKey:@"profilepic"] ]]);
                            [defaults_userdata setObject:@"remember" forKey:@"rememberme"];
                            
                            _lbl_username.text = [NSString stringWithFormat:@"%@ %@",f_name,l_name];
                            _lbl_user_station.text=[NSString stringWithFormat:@"@%@",[dic_response objectForKey:@"username"]];
                            
                            _img_view_main_logo_st.hidden=YES;
                            _view_profile_afterlogin_st.hidden=NO;
                            
                            [_img_view_profile_pic_st setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dic_response valueForKey:@"profilepic"]]]]];
                            _lbl_user_station_st.text=[NSString stringWithFormat:@"@%@",[dic_response objectForKey:@"username"]];
                            
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"username"]] forKey:@"user_name"];
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"f_name"]] forKey:@"first_name"];
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"l_name"]] forKey:@"last_name"];
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"id"]] forKey:@"user_id"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",app_id] forKey:@"fapp_id"];
                            
                            [defaults_userdata setObject:[dic_response valueForKey:@"profilepic"] forKey:@"profile_pic_url"];
                            
                            [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dic_response valueForKey:@"profilepic"]]] forKey:@"profile_pic"];
                            [defaults_userdata setObject:cover_url forKey:@"cover_pic_url"];
                            [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:cover_url]] forKey:@"cover_pic"];
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"discription"]] forKey:@"discription"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"email"]] forKey:@"email"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"dob"]] forKey:@"dob"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"mobile"]] forKey:@"mobile"];
                            
                            
                             [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"fans"]] forKey:@"fans"];
                             [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"followers"]] forKey:@"followers"];
                             [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"records"]] forKey:@"records"];
                            
                            
                            //                  [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"registerdate"]] forKey:@"register_date"];
                            
                            // [defaults_userdata setObject:str_fb_token forKey:@"fb_id"];
                            [defaults_userdata synchronize];
                            // [self viewDidLoad];
                            _btn_logout.hidden=NO;
                            _btn_login.hidden=YES;
                            _view_profile_afterlogin.hidden=NO;
                            _img_view_main_logo.hidden=YES;
                            _btn_signout_bottom.hidden=NO;
                            _signin_btn.hidden=YES;
                        }];
                    }
                }
                else
                {
                    [Appdelegate hideProgressHudInView];
                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                        UIAlertController * alert=   [UIAlertController
                      alertControllerWithTitle:@"Alert !"
                      message:@"Please login with Email."
                              preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* yesButton = [UIAlertAction
                                                    actionWithTitle:@"ok"
                                                    style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action)
                                            {
                                            //Handel your yes please button action here
//                                            FBSession *session = [[FBSession alloc] initWithPermissions:@[@"public_profile", @"email"]];
//                                            [FBSession setActiveSession:session];
//                                            [session closeAndClearTokenInformation];
//                                            [session close];
//                                            [FBSession setActiveSession:nil];
                                            [defaults_userdata setBool:NO forKey:@"isUserLogged"];
                                            }];
                        [alert addAction:yesButton];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    
                }
                
            });
        }
    }];
    [task resume];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at Registration with facebook.php :%@",exception);
    }
    @finally{
        
    }
}

- (IBAction)reset_username:(id)sender {
    _tf_username.text=nil;
}

- (IBAction)reset_password:(id)sender {
    _tf_password.text=nil;
}



- (IBAction)btn_lets_go:(id)sender {
    
    @try{
    [_tf_username resignFirstResponder];
    [_tf_password resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view_bottom_menu.frame;
        f.origin.y = 0;
        self.view_bottom_menu.frame = f;
    }];
    
    if ([_tf_username.text length]!=0 && [_tf_password.text length]!=0 && [self NSStringIsValidEmail:_tf_username.text])
    {
        [SVProgressHUD setForegroundColor:[UIColor greenColor]];
        [SVProgressHUD show];
        NSString*device_token;
        device_token=[[NSString alloc]initWithFormat:@"%@",[[FIRInstanceID instanceID] token]];

        NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
        [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
        [params setObject:_tf_username.text forKey:@"email"];
        [params setObject:_tf_password.text forKey:@"password"];
        [params setObject:device_token forKey:@"devicetoken"];
        [params setObject:@"ios" forKey:@"device_type"];
     
        NSLog(@"%@",params);
        NSMutableString* parameterString = [NSMutableString string];
        for(NSString* key in [params allKeys])
        {
            if ([parameterString length]) {
                [parameterString appendString:@"&"];
            }
            [parameterString appendFormat:@"%@=%@",key, params[key]];
        }
         NSString* urlString = [NSString stringWithFormat:@"%@login.php",BaseUrl];
        NSURL* url = [NSURL URLWithString:urlString];
        //this is how cookies were created
        NSURLSession* session =[NSURLSession sharedSession];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPShouldHandleCookies:NO];
      
        NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if(error)
            {
                //do something
                NSLog(@"%@", error);
                [SVProgressHUD dismiss];
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"Message"
                                              message:MSG_NoInternetMsg
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"ok"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action)
                                            {
                                                //Handel your yes please button action here
                                            }];
                [alert addAction:yesButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    NSError *myError = nil;
                    
                    NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                    NSLog(@"%@",requestReply);
                    
                    NSData *data = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                                 options:kNilOptions
                                                                                   error:&myError];
                    
                    NSLog(@"%@",jsonResponse);
                    if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                        [defaults_userdata setBool:YES forKey:@"isUserLogged"];

                        dic_response=[jsonResponse objectForKey:@"response"];
                         NSLog(@"%@",dic_response);
                        //Handel your yes please button action here
                        if ([_other_vc_flag isEqual:@"1"]) {
                            
                            _img_view_main_logo.hidden=YES;
                            _view_profile_afterlogin.hidden=NO;
                            [_img_view_profile_pic setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [dic_response objectForKey:@"profilepic"] ]]]]];
                            NSString *userName = [NSString stringWithFormat:@"%@ %@",[defaults_userdata stringForKey:@"first_name"],[defaults_userdata stringForKey:@"last_name"]];
                            
                            _lbl_username.text = userName;
                            _lbl_user_station.text=[NSString stringWithFormat:@"@%@",[dic_response objectForKey:@"username"]];
                            
                            _img_view_main_logo_st.hidden=YES;
                            _view_profile_afterlogin_st.hidden=NO;
                            [_img_view_profile_pic_st setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [dic_response objectForKey:@"profilepic"] ]]]]];
                            
                            _lbl_username_st.text=[NSString stringWithFormat:@"%@ %@",[dic_response objectForKey:@"First_name"],[dic_response objectForKey:@"Last_name"]];
                            
                            _lbl_user_station_st.text=[NSString stringWithFormat:@"@%@",[dic_response objectForKey:@"username"]];
                            
                            [defaults_userdata setObject:@"remember" forKey:@"rememberme"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"username"]] forKey:@"user_name"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"First_name"]] forKey:@"first_name"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"Last_name"]] forKey:@"last_name"];
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"user_id"]] forKey:@"user_id"];
                        
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"discription"]] forKey:@"discription"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"email"]] forKey:@"email"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"dob"]] forKey:@"dob"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"mobile"]] forKey:@"mobile"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"registerdate"]] forKey:@"register_date"];
                            // [defaults_userdata setObject:[NSString stringWithFormat:@"http://%@", [dic_response objectForKey:@"profilepic"] ] forKey:@"profile_pic"];
                            [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"profilepic"]]]] forKey:@"profile_pic"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"profilepic"]] forKey:@"profile_pic_url"];
                            // [defaults_userdata setObject:str_fb_token forKey:@"fb_id"];
                           
                            // [defaults_userdata setObject:[NSString stringWithFormat:@"http://%@",[dic_response objectForKey:@"coverpic"]] forKey:@"cover_pic"];
                            [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"coverpic"]]]] forKey:@"cover_pic"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"coverpic"]] forKey:@"cover_pic_url"];
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"fans"]] forKey:@"fans"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"followers"]] forKey:@"followers"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"records"]] forKey:@"records"];
                            
                             [defaults_userdata synchronize];
                            // [self viewDidLoad];
                            _btn_logout.hidden=NO;
                            _btn_login.hidden=YES;
                            _view_profile_afterlogin.hidden=NO;
                            _img_view_main_logo.hidden=YES;
                            _btn_signout_bottom.hidden=NO;
                            _signin_btn.hidden=YES;
                            NSLog(@"%@",defaults_userdata);
                            _lbl_password_error.text=nil;
                            _lbl_username_error.text=nil;
                            _tf_password.text=nil;
                            _tf_username.text=nil;
                            
                            
                            if ([Appdelegate.screen_After_Login isEqualToString:Activity]) {
                                    AudioFeedViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioFeedViewController"];
                                    myVC.isBack = YES;
                                    [self presentViewController:myVC animated:YES completion:nil];
                            }
                           else if ([Appdelegate.screen_After_Login isEqualToString:Messenger]) {
                        
                               MessengerViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MessengerViewController"];
                               myVC.isBack = YES;
                               [self presentViewController:myVC animated:YES completion:nil];
                            }
                            
                            else{
                            
                            [self dismissViewControllerAnimated:YES completion:nil];
                            }
                            
                        }
                        
                        else{
                            
                        [UIView animateWithDuration:0.3 animations:^{
                            CGRect f = self.view_bottom_menu.frame;
                            f.origin.y = self.view.frame.size.height;
                            self.view_bottom_menu.frame = f;
                            _signin_btn.hidden=YES;
                            _img_view_main_logo.hidden=YES;
                            _view_profile_afterlogin.hidden=NO;
                            [_img_view_profile_pic setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [dic_response objectForKey:@"profilepic"] ]]]]];
                           // NSLog(@"%@",[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[jsonResponse objectForKey:@"response"] objectForKey:@"profilepic"] ]]);
                            
                            _lbl_username.text=[NSString stringWithFormat:@"%@ %@",[dic_response objectForKey:@"First_name"],[dic_response objectForKey:@"Last_name"]];
                            
                            _lbl_user_station.text=[NSString stringWithFormat:@"@%@",[dic_response objectForKey:@"username"]];
                            
                            _img_view_main_logo_st.hidden=YES;
                            _view_profile_afterlogin_st.hidden=NO;
                            [_img_view_profile_pic_st setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [dic_response objectForKey:@"profilepic"] ]]]]];
                            
                            _lbl_username_st.text=[NSString stringWithFormat:@"%@ %@",[dic_response objectForKey:@"First_name"],[dic_response objectForKey:@"Last_name"]];
                            
                            _lbl_user_station_st.text=[NSString stringWithFormat:@"@%@",[dic_response objectForKey:@"username"]];
                            
                            [defaults_userdata setObject:@"remember" forKey:@"rememberme"];

                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"username"]] forKey:@"user_name"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"First_name"]] forKey:@"first_name"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"Last_name"]] forKey:@"last_name"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"user_id"]] forKey:@"user_id"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"discription"]] forKey:@"discription"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"email"]] forKey:@"email"];
                             [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"dob"]] forKey:@"dob"];
                             [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"mobile"]] forKey:@"mobile"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"registerdate"]] forKey:@"register_date"];
                            // [defaults_userdata setObject:[NSString stringWithFormat:@"http://%@", [dic_response objectForKey:@"profilepic"] ] forKey:@"profile_pic"];
                             [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"profilepic"]]]] forKey:@"profile_pic"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"profilepic"]] forKey:@"profile_pic_url"];
                           // [defaults_userdata setObject:str_fb_token forKey:@"fb_id"];
                            [defaults_userdata synchronize];
                           // [defaults_userdata setObject:[NSString stringWithFormat:@"http://%@",[dic_response objectForKey:@"coverpic"]] forKey:@"cover_pic"];
                            [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"coverpic"]]]] forKey:@"cover_pic"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"coverpic"]] forKey:@"cover_pic_url"];
                            
                            
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"fans"]] forKey:@"fans"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"followers"]] forKey:@"followers"];
                            [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"records"]] forKey:@"records"];

                            [defaults_userdata synchronize];
                            _btn_logout.hidden=NO;
                            _btn_login.hidden=YES;
                            _view_profile_afterlogin.hidden=NO;
                            _img_view_main_logo.hidden=YES;
                            _btn_signout_bottom.hidden=NO;
                            _signin_btn.hidden=YES;
                            NSLog(@"%@",defaults_userdata);
                            _lbl_password_error.text=nil;
                            _lbl_username_error.text=nil;
                            _tf_password.text=nil;
                            _tf_username.text=nil;
                            if ([Appdelegate.screen_After_Login isEqualToString:Activity]) {
                                AudioFeedViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioFeedViewController"];
                                myVC.isBack = YES;

                                [self presentViewController:myVC animated:YES completion:nil];
                            }
                            else if ([Appdelegate.screen_After_Login isEqualToString:Messenger]) {
                                
                                MessengerViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MessengerViewController"];
                                myVC.isBack = YES;
//                                [ProgressHUD showSuccess:@"Login Successful"];
                                [self presentViewController:myVC animated:YES completion:nil];
                            }
                            
                            
                        }];
                        }

                    }
                    else
                    {
                        if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                            UIAlertController * alert=   [UIAlertController
                                                          alertControllerWithTitle:@"Alert"
                                                          message:@"Email or password is incorrect!"
                                                          preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction* yesButton = [UIAlertAction
                                                        actionWithTitle:@"ok"
                                                        style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action)
                                                        {
                                                            //Handel your yes please button action here
                                                            
                                                            
                                                        }];
                            
                            
                            [alert addAction:yesButton];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                        
                        
                    }
                    
                });
            }
        }];
        [task resume];
        
    }
    else
    {
        if ([_tf_password.text length]==0) {
            _lbl_password_error.text=@"Required";
        }
        if ([_tf_username.text length]==0) {
            _lbl_username_error.text=@"Required";
        }
        else if (![self NSStringIsValidEmail:_tf_username.text])
        {
            _lbl_username_error.text=@"incorrect email";
        }
    }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at login.php :%@",exception);
    }
    @finally{
        
    }
}
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"go_to_melody_screen"]) {
        
        MelodyViewController*vc=segue.destinationViewController;
        vc.view_suscription_visible=@"YES";
        
    }
    if ([segue.identifier isEqual:@"segue_studio_ric"]) {
        StudioRecViewController*vc=segue.destinationViewController;
        vc.isJoinScreen = NO;
    }
    
}




- (IBAction)myAccountAction:(id)sender {
    NSLog(@"u press myaccount btn *************");
    if([defaults_userdata boolForKey:@"isUserLogged"]) {
        UpdateAccountViewController *updateVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UpdateAccountViewController"];
        [updateVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:updateVC animated:YES completion:nil];
    }
    
    else {
        SignUpViewController *signUPVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
        [signUPVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:signUPVC animated:YES completion:nil];    }
}
- (IBAction)action_TermsService:(id)sender {
    
    Terms_ServiceVC *termsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Terms_ServiceVC"];
    [termsVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:termsVC animated:YES completion:nil];
}

- (IBAction)actionPrivacyPolicy:(id)sender {
    Privacy_PolicyVC *privacyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Privacy_PolicyVC"];
    [privacyVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:privacyVC animated:YES completion:nil];
}


- (IBAction)action_InviteContacts:(id)sender {
    if ([defaults_userdata boolForKey:@"isUserLogged"]) {

    contactsViewController *contactVC = [self.storyboard instantiateViewControllerWithIdentifier:@"contactsViewController"];
    [contactVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:contactVC animated:YES completion:nil];
    }
    
}

/*
 ****OLD SIGNOUT METHOD FOR SIGNOUT_BOTTOM
 //    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"rememberme"];
 //    [[NSUserDefaults standardUserDefaults] synchronize];
 _btn_login.hidden=NO;
 _btn_logout.hidden=YES;
 _view_profile_afterlogin.hidden=YES;
 _img_view_main_logo.hidden=NO;
 
 _view_profile_afterlogin_st.hidden=YES;
 _img_view_main_logo_st.hidden=NO;
 _btn_signout_bottom.hidden=YES;
 _signin_btn.hidden=NO;
 FBSession *session = [[FBSession alloc] initWithPermissions:@[@"public_profile", @"email"]];
 
 [FBSession setActiveSession:session];
 [session closeAndClearTokenInformation];
 [session close];
 [FBSession setActiveSession:nil];
 
 [defaults_userdata setBool:NO forKey:@"isUserLogged"];
 
 UIColor *color = [UIColor whiteColor];
 _tf_username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
 
 //    [twsession.authToken setValue:@"" forKey:@"authToken"];
 //    NSURL *url = [NSURL URLWithString:@"https://twitter.com"];
 //    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
 //    for (NSHTTPCookie *cookie in cookies)
 //    {
 //        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
 //    }
 //    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession session, NSError error) {
 //        [[[Twitter sharedInstance] sessionStore] logOutUserID:session.userID];
 //    }];
 //    [[NSURLCache sharedURLCache] removeAllCachedResponses];
 NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
 for (NSHTTPCookie *each in cookieStorage.cookies) {
 // put a check here to clear cookie url which starts with twitter and then delete it
 [cookieStorage deleteCookie:each];
 }
 [self resetDefaults];
 */


@end
