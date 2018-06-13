
//  AppDelegate.m
//  melody
//
//  Created by CodingBrainsMini on 11/19/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import "AppDelegate.h"
#import <objc/runtime.h>
#import "chatViewController.h"
#define CLIENT_ID @"ab91a50019b2954d03cad204bd6ace99"
#define CLIENT_SECRET @"f7e8588e40c22510686d80a198331774"
#define REDIRECT_URI @"www.facebook.com"//don't forget to change this in Info.plist as well
#import <UIKit/UIKit.h>
#import "Constant.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "ProfileViewController.h"
//#import "RageIAPHelper.h"

#define SC_API_URL @"https://api.soundcloud.com"
#define SC_TOKEN @"SC_TOKEN"
#define SC_CODE @"SC_CODE"
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif
@import GoogleSignIn;
@import Firebase;
//@import FirebaseInstanceID;
@import FirebaseMessaging;
@import FBSDKLoginKit;
@import FBSDKCoreKit;
@import FBSDKShareKit;

// Implement UNUserNotificationCenterDelegate to receive display notification via APNS for devices
// running iOS 10 and above. Imement FIRMesplsagingDelegate to receive data message via FCM for
// devices running iOS 10 and above.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate,GIDSignInDelegate,GIDSignInUIDelegate>
{
     NSString *deviceTokenn;
    NSString *ClientID_Google;
    
}
@end
#endif

// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

@implementation UIApplication (Private)

- (BOOL)customOpenURL:(NSURL*)url
{
    if (Appdelegate.currentViewController) {
        [Appdelegate.currentViewController handleURL:url];
        return YES;
    }
    return NO;
}
@end



@implementation AppDelegate

NSString *const kGCMMessageIDKey = @"gcm.message_id";

- (instancetype)init
{
     self = [super init];
     if (self) {
     [FIRApp configure];
 
     }
     return self;
}

- (void) handleURL:(NSURL *)url{
     
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSInteger badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
//    badgeCount = [strBadgeCount integerValue];
    NSLog(@"badgeCount %ld",(long)badgeCount);
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[NSUserDefaults standardUserDefaults] setObject:@"none" forKey:@"navigation"];

    _isHomeClicked=YES;
    
    //--------------------* In App Purchase *---------------------------------
//    [RageIAPHelper sharedInstance];
    //------------------------------------------------------------------------
    
    //--------------------* Facebook *----------------------------------------
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    //------------------------------------------------------------------------
    
    //-----------* Crashlytics with Twitter *---------------------------------
    [Fabric with:@[[Crashlytics class], [Twitter class]]];
    //    [Fabric with:@[[Twitter class]]];
    //------------------------------------------------------------------------

    //--------------------* Google *------------------------------------------
    ClientID_Google =  @"com.googleusercontent.apps.870917113323-vgq1s736bmcfmodsp32a4no4flha372r";
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES;
    //    [[GGLContext sharedInstance] configureWithError: &configureError];
    //    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    //-------------------------------------------------------------------------
    
    //--------------------* Image Fetch from Phone Gallery *-------------------
     PHFetchOptions *options = [[PHFetchOptions alloc] init];
     options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
     _assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
     [self getImageFromGallery];
     //------------------------------------------------------------------------
    
    //--------------------* Get and Set Camera & Gallery status *--------------
     if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"camera_status"] isEqual:@"0"])
     {
     }
     else
     {
         [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"camera_status"];
     }
     if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"gallery_status"] isEqual:@"0"])
     {
     }
     else
     {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"gallery_status"];
     }
    //---------------------------------------------------------------------------
    
    //-----------* Notification Handler for various iOS version *----------------
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)
    {
        // iOS 7.1 or earlier. Disable the deprecation warnings.
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge);
        [application registerForRemoteNotificationTypes:allNotificationTypes];
        #pragma clang diagnostic pop
    }
    else
    {
        // iOS 8 or later
        // [START register_for_notifications]
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max)
        {
            UIUserNotificationType allNotificationTypes =
            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        }
        else
        {
            // iOS 10 or later
            #if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
            // For iOS 10 display notification (sent via APNS)
            [UNUserNotificationCenter currentNotificationCenter].delegate = self;
            UNAuthorizationOptions authOptions =
            UNAuthorizationOptionAlert
            | UNAuthorizationOptionSound
            | UNAuthorizationOptionBadge;
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
            }];
            
            // For iOS 10 data message (sent via FCM)
            [FIRMessaging messaging].remoteMessageDelegate = self;
            #endif
        }
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        // [END register_for_notifications]
    }
    //---------------------------------------------------------------------------
    
    //*--------------------* Get Notify for images *-----------------------------
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getImageNotification:)
                                                 name:@"getImages" object:nil];
    
    // [START add_token_refresh_observer]
    
    // Add observer for InstanceID token refresh callback.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];
    // [END add_token_refresh_observer]
    
    return YES;
    
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Expects the URL of the scheme e.g. "fb://"
- (BOOL)schemeAvailable:(NSString *)scheme {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:scheme];
    return [application canOpenURL:URL];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
     NSURL *URL = [NSURL URLWithString:url.scheme];
    NSLog(([application canOpenURL:URL]) ? @"Yes" : @"No");
    
 
    //----------------* Twitter *-------------------
    if ([[Twitter sharedInstance] application:application openURL:url options:options]) {
        return YES;
    }
    //----------------* iTunes  and Google*-------------------
    if ([url.scheme localizedCaseInsensitiveCompare:@"http://itunes.apple.com"] == NSOrderedSame) {
        return YES;
    }
   if([url.scheme localizedCaseInsensitiveCompare:@"fb1437005633236379"] == NSOrderedSame)
    {
        return YES;
        
    }
    else
    {
        return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
     }
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    //----------------* Facebook *-------------------
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];
    
//    BFURL *parsedUrl = [BFURL URLWithInboundURL:url sourceApplication:sourceApplication];
//    if ([parsedUrl appLinkData]) {
//        // this is an applink url, handle it here
//        NSURL *targetUrl = [parsedUrl targetURL];
//        [[[UIAlertView alloc] initWithTitle:@"Received link:"
//                                    message:[targetUrl absoluteString]
//                                   delegate:nil
//                          cancelButtonTitle:@"OK"
//                          otherButtonTitles:nil] show];
//    }
      //Add any custom logic here.
    //----------------* Payments *-------------------

         return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];

    // Add any custom logic here.
//     return handled;
}
#pragma mark - Google SignIn Method
#pragma mark -
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
        // Perform any operations on signed in user here.
        if (error == nil) {
            GIDAuthentication *authentication = user.authentication;
            FIRAuthCredential *credential =
            [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                             accessToken:authentication.accessToken];
            _dicSignUserGoogleA = user;
            _isGoogleLogin=YES;
            
            id userInfoGoogle = user;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *viewController =[storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
            self.window.rootViewController = viewController;
            [self.window makeKeyAndVisible];
        } else {
            NSLog(@"ERROR : %@",error);
        }
    }

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

// [START refresh_token]
#pragma mark - tike Refresh Notification
#pragma mark -
- (void)tokenRefreshNotification:(NSNotification *)notification {
     // Note that this callback will be fired everytime a new token is generated, including the first
     // time. So if you need to retrieve the token as soon as it is available this is where that
     // should be done.
     
     NSString *refreshedToken = [[FIRInstanceID instanceID] token];
     
     NSLog(@"InstanceID token: %@", refreshedToken);
     
     // Connect to FCM since connection may have failed when attempted before having a token.
     [self connectToFcm];
     
     // TODO: If necessary send token to application server.
}

#pragma mark - SoundCloud Method
#pragma mark -

- (void)showErrorAlert {
     [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot authenticate with current data." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
     
     [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"       ege"];
     
     
     if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  )
     {
          
          [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"notification_navigation"];
          
          UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
          
          UIViewController *viewController =[storyboard instantiateViewControllerWithIdentifier:@"chatViewController"];
         
          self.window.rootViewController = viewController;
          [self.window makeKeyAndVisible];
     }

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    // Print full message.
    NSLog(@"%@", userInfo);
    
    completionHandler(UIBackgroundFetchResultNewData);
     [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"messege"];
   
     if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  )
     {
          
          [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"notification_navigation"];
          
          UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
          
          UIViewController *viewController =[storyboard instantiateViewControllerWithIdentifier:@"chatViewController"];
          
          self.window.rootViewController = viewController;
          [self.window makeKeyAndVisible];
     }
     
}




#pragma mark - Getting Image Notification
#pragma mark -
- (void) getImageNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"getImages"])
        NSLog (@"Successfully received the test notification!");
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    _assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    [self getImageFromGallery];
}



- (UIViewController *)visibleViewController:(UIViewController *)rootViewController
{
     if (rootViewController.presentedViewController == nil)
     {
          return rootViewController;
     }
     if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]])
     {
          UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
          UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
          
          return [self visibleViewController:lastViewController];
     }
     if ([rootViewController.presentedViewController isKindOfClass:[UITabBarController class]])
     {
          UITabBarController *tabBarController = (UITabBarController *)rootViewController.presentedViewController;
          UIViewController *selectedViewController = tabBarController.selectedViewController;
          
          return [self visibleViewController:selectedViewController];
     }
     
     UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
     
     return [self visibleViewController:presentedViewController];
}


//--------------------- Control comes when user RECIEVED messages ------------
//------------------------------ ***** 1 st ***--------------------------------
// Receive displayed notifications for iOS 10 devices.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Handle incoming notification messages while app is in the foreground.


- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
     // Print message ID.
     NSString *jsonString;
    NSMutableDictionary *dic =[[NSMutableDictionary alloc]init];
     NSDictionary *userInfo = notification.request.content.userInfo;
//    NSDictionary *userInfo = response.notification.request.content.userInfo;

     NSString *str_notification_type =[userInfo valueForKey:@"gcm.notification.notification_type"];
     if ([str_notification_type isEqualToString:@"Activity"]) {
         jsonString = [[userInfo valueForKey:@"aps"] valueForKey:@"alert" ];
     }
     else if ([str_notification_type isEqualToString:@"Chat"]) {
         jsonString = [[[userInfo valueForKey:@"aps"] valueForKey:@"alert"]valueForKey:@"title"];
         [dic setObject:jsonString forKey:@"msg_title"];
         [dic setObject:[userInfo valueForKey:@"gcm.notification.chat_id"] forKey:@"chat_id"];
     }
     
     if (userInfo[kGCMMessageIDKey]) {
          NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
     }
     NSLog(@"%@", userInfo);
     
     // Change this to your preferred presentation option
     completionHandler(UNNotificationPresentationOptionNone);
     NSLog(@"%@",_str_chat_status);
     [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"messege"];
     [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"notification_navigation"];
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
     if ([str_notification_type isEqualToString:@"Activity"]) {
        
          UIViewController *viewController =[storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
         if ([viewController isKindOfClass:[ProfileViewController class]]){
             // viewController is visible
//             self.window.rootViewController = viewController;//change
//             [self.window makeKeyAndVisible];
         }
//          self.window.rootViewController = viewController;//change
//          [self.window makeKeyAndVisible];
     }
     else {
          UIViewController *viewController =[storyboard instantiateViewControllerWithIdentifier:@"chatViewController"];
//         NSLog(@"Current View Controller Class Name: %@",NSStringFromClass(self.window.rootViewController.navigationController.visibleViewController.class));

//         if ([chatViewController is]){
             // viewController is visible
//             self.window.rootViewController = viewController;//change
//             [self.window makeKeyAndVisible];
//         }
         
     }
     
}



//----------------- * tap on notification when app in background ----------------
// Handle notification messages after display notification is tapped by the user.

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler {
     NSLog(@"didReceiveNotificationResponse");
     NSString *jsonString;
    NSMutableDictionary *dic =[[NSMutableDictionary alloc]init];
     NSDictionary *userInfo = response.notification.request.content.userInfo;
     NSLog(@"response.notification.request.content.body: %@", userInfo);
     NSString *str_notification_type =[userInfo valueForKey:@"gcm.notification.notification_type"];
     if ([str_notification_type isEqualToString:@"Activity"]) {
          jsonString = [[userInfo valueForKey:@"aps"] valueForKey:@"alert" ];
     }
     else if ([str_notification_type isEqualToString:@"Chat"]) {
         //chat_id
          jsonString = [[[userInfo valueForKey:@"aps"] valueForKey:@"alert"]valueForKey:@"title"];
         [dic setObject:jsonString forKey:@"msg_title"];
         [dic setObject:[userInfo valueForKey:@"gcm.notification.chat_id"] forKey:@"chat_id"];
     }
    

    NSLog(@"%@", userInfo);
     
     [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"messege"];
     [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"notification_navigation"];
    [[NSUserDefaults standardUserDefaults] setObject:@"activity" forKey:@"navigation"];

     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
     if ([str_notification_type isEqualToString:@"Activity"]) {
          UIViewController *viewController =[storyboard instantiateViewControllerWithIdentifier:@"AudioFeedViewController"];
         
          self.window.rootViewController = viewController;//change
          [self.window makeKeyAndVisible];
     }
     else {
          UIViewController *viewController =[storyboard instantiateViewControllerWithIdentifier:@"chatViewController"];
          self.window.rootViewController = viewController;//change
          [self.window makeKeyAndVisible];
     }
     
}

#endif
// [END ios_10_message_handling]

// [START ios_10_data_message_handling]
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Receive data message on iOS 10 devices while app is in the foreground.
//------------ Controls comes when user send messages -----------------------
//------------------------------ ***** 3 rd ***--------------------------------
//------------------------- applicationReceivedRemoteMessage -----------------------------

- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    // Print full message
     NSLog(@"applicationReceivedRemoteMessage with FIRMessagingRemoteMessage");
    NSLog(@"remoteMessage %@", remoteMessage.appData);
     NSString *jsonString = [remoteMessage.appData valueForKey:@"body"];
//     [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"messege"];
     [[NSUserDefaults standardUserDefaults] setObject:jsonString forKey:@"messege"];
          [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"notification_navigation"];
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
     UIViewController *viewController =[storyboard instantiateViewControllerWithIdentifier:@"chatViewController"];
//     self.window.rootViewController = viewController;
//     [self.window makeKeyAndVisible];
     
}
#endif
// [END ios_10_data_message_handling]



// [START connect_to_fcm]
- (void)connectToFcm {
    // Won't connect since there is no token
    if (![[FIRInstanceID instanceID] token]) {
        return;
    }
    // Disconnect previous FCM connection if it exists.
    [[FIRMessaging messaging] disconnect];
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
            
        }
        else
        {
            NSLog(@"Connected to FCM.");
        }
    }];
}
// [END connect_to_fcm]

//--------------- didFailToRegisterForRemoteNotificationsWithError -----------------
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unable to register for remote notifications: %@", error);
}


// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
// If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
// the InstanceID token.

//--------------- didRegisterForRemoteNotificationsWithDeviceToken -----------------
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
     NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
     token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    //---------------- * Sandbox User * -----------------
     [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeSandbox];
    //---------------- * Production User * -----------------
//    [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeProd];
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    if (refreshedToken != nil) {
        [[NSUserDefaults standardUserDefaults]setObject:refreshedToken forKey:@"deviceToken"];
    }
     NSLog(@"InstanceID token: %@", refreshedToken);
     // Connect to FCM since connection may have failed when attempted before having a token.
     [self connectToFcm];
}




// [START connect_on_active]
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self connectToFcm];
    
    Method customOpenUrl = class_getInstanceMethod([UIApplication class], @selector(customOpenURL:));
    Method openUrl = class_getInstanceMethod([UIApplication class], @selector(openURL:));
    
    method_exchangeImplementations(openUrl, customOpenUrl);
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    application.applicationIconBadgeNumber = 0;

}

// [END connect_on_active]

// [START disconnect_from_fcm]
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[FIRMessaging messaging] disconnect];
    NSLog(@"Disconnected from FCM");
}
// [END disconnect_from_fcm]







#pragma mark - Public method implementation

-(void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI{
/*   [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:allowLoginUI
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      // Create a NSDictionary object and set the parameter values.
                                      NSDictionary *sessionStateInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                        session, @"session",
                                                                        [NSNumber numberWithInteger:status], @"state",
                                                                        error, @"error",
                                                                        nil];
                                      
                                      // Create a new notification, add the sessionStateInfo dictionary to it and post it.
                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"SessionStateChangeNotification"
                                                                                          object:nil
                                                                                        userInfo:sessionStateInfo];
                                      
                                  }];*/
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"] != nil) {
        [self notificationBadgeAPI];
    }
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Method of Badge Notification
#pragma mark -
-(void)notificationBadgeAPI{
    @try{
        NSDictionary* params = @{
                                 KEY_AUTH_KEY:KEY_AUTH_VALUE,
                                 @"userid":[[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"]
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
        NSString* urlString = [NSString stringWithFormat:@"%@totalnewmessage.php",BaseUrl];
        NSURL* url = [NSURL URLWithString:urlString];
        NSURLSession* session =[NSURLSession sharedSession];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPShouldHandleCookies:NO];
        
        NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {

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
                        
                        NSString *strBadgeCount = [jsonObject valueForKey:@"newMessage"];
                        
                        NSInteger badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
                        badgeCount = [strBadgeCount integerValue];
                        NSLog(@"badgeCount %ld",(long)badgeCount);
                        NSLog(@"strBadgeCount %@",strBadgeCount);
                        [UIApplication sharedApplication].applicationIconBadgeNumber = badgeCount;
                        
                    
                    }
                    else{
                        
                    }
                });
            }
        }];
        [task resume];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at notificationBadgeAPI :%@",exception);
    }
    @finally{
        
    }
}


#pragma mark - CUSTOM METHODS
#pragma mark -

#pragma mark - Date Time Format in Hours, Minutes and seconds
#pragma mark -
-(NSString*)TodayTimeCalculation:(NSString*)PostDate
{
     NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
     [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
     NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
     [dateFormat setTimeZone:gmt];
     NSDate *ExpDate = [dateFormat dateFromString:PostDate];
     NSCalendar *calendar = [NSCalendar currentCalendar];
     NSDateComponents *components = [calendar components:(NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:ExpDate toDate:[NSDate date] options:0];
     NSString *time;
     if(components.hour!=0)
     {
          if(components.hour==1)
          {
               time=[NSString stringWithFormat:@"%ld hr",(long)components.hour];
          }
          else
          {
               time=[NSString stringWithFormat:@"%ld hrs",(long)components.hour];
          }
     }
     else if(components.minute!=0)
     {
          if(components.minute==1)
          {
               time=[NSString stringWithFormat:@"%ld min",(long)components.minute];
          }
          else
          {
               time=[NSString stringWithFormat:@"%ld mins",(long)components.minute];
          }
     }
     else if(components.second>=0)
     {
          if(components.second==0)
          {
               time=[NSString stringWithFormat:@"1 sec"];
          }
          else
          {
               time=[NSString stringWithFormat:@"%ld secs",(long)components.second];
          }
     }
     return [NSString stringWithFormat:@"%@ ago",time];
}

#pragma mark - Date Time Format in Years, Months, Weeks, Days, Hours, Minutes and seconds
#pragma mark -
-(NSString*)HourCalculation:(NSString*)PostDate
{
     NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
     [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
     NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
     [dateFormat setTimeZone:gmt];
     NSDate *ExpDate = [dateFormat dateFromString:PostDate];
     NSCalendar *calendar = [NSCalendar currentCalendar];
     NSDateComponents *components = [calendar components:(NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitWeekdayOrdinal | NSCalendarUnitSecond) fromDate:ExpDate toDate:[NSDate date] options:0];
     NSString *time;
     if(components.year!=0)
     {
          if(components.year==1)
          {
               time=[NSString stringWithFormat:@"%ld year",(long)components.year];
          }
          else
          {
               time=[NSString stringWithFormat:@"%ld years",(long)components.year];
          }
     }
     else if(components.month!=0)
     {
          if(components.month==1)
          {
               time=[NSString stringWithFormat:@"%ld month",(long)components.month];
          }
          else
          {
               time=[NSString stringWithFormat:@"%ld months",(long)components.month];
          }
     }
     else if(components.week!=0)
     {
          if(components.week==1)
          {
               time=[NSString stringWithFormat:@"%ld week",(long)components.week];
          }
          else
          {
               time=[NSString stringWithFormat:@"%ld weeks",(long)components.week];
          }
     }
     else if(components.day!=0)
     {
          if(components.day==1)
          {
               time=[NSString stringWithFormat:@"%ld day",(long)components.day];
          }
          else
          {
               time=[NSString stringWithFormat:@"%ld days",(long)components.day];
          }
     }
     else if(components.hour!=0)
     {
          if(components.hour==1)
          {
               time=[NSString stringWithFormat:@"%ld hr",(long)components.hour];
          }
          else
          {
               time=[NSString stringWithFormat:@"%ld hrs",(long)components.hour];
          }
     }
     else if(components.minute!=0)
     {
          if(components.minute==1)
          {
               time=[NSString stringWithFormat:@"%ld min",(long)components.minute];
          }
          else
          {
               time=[NSString stringWithFormat:@"%ld mins",(long)components.minute];
          }
     }
     else if(components.second>=0)
     {
          if(components.second==0)
          {
               time=[NSString stringWithFormat:@"1 sec"];
          }
          else
          {
               time=[NSString stringWithFormat:@"%ld secs",(long)components.second];
          }
     }
     else if(components.weekday>=0)
     {
          switch (components.weekday) {
               case 0:
                    
                    break;
                    
               default:
                    break;
          }
          
     }
     return [NSString stringWithFormat:@"%@ ago",time];
}
#pragma mark - Method to check NSNull Data
#pragma mark -
- (id)valueOrNil:(id)value {
    if ([value isMemberOfClass:[NSNull class]]) {
        return nil;
    }
    return value;
}
#pragma mark - Image : Scalling
#pragma mark -
- (UIImage *) scaleAndRotateImage: (UIImage *)image
{
     int kMaxResolution = 3000; // Or whatever
     CGImageRef imgRef = image.CGImage;
     CGFloat width = CGImageGetWidth(imgRef);
     CGFloat height = CGImageGetHeight(imgRef);
     CGAffineTransform transform = CGAffineTransformIdentity;
     CGRect bounds = CGRectMake(0, 0, width, height);
     if (width > kMaxResolution || height > kMaxResolution) {
          CGFloat ratio = width/height;
          if (ratio > 1) {
               bounds.size.width = kMaxResolution;
               bounds.size.height = bounds.size.width / ratio;
          }
          else {
               bounds.size.height = kMaxResolution;
               bounds.size.width = bounds.size.height * ratio;
          }
     }
     
     CGFloat scaleRatio = bounds.size.width / width;
     CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef),      CGImageGetHeight(imgRef));
     CGFloat boundHeight;
     UIImageOrientation orient = image.imageOrientation;
     switch(orient)
     {
          case UIImageOrientationUp: //EXIF = 1
               transform = CGAffineTransformIdentity;
               break;
               
          case UIImageOrientationUpMirrored: //EXIF = 2
               transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
               transform = CGAffineTransformScale(transform, -1.0, 1.0);
               break;
               
          case UIImageOrientationDown: //EXIF = 3
               transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
               transform = CGAffineTransformRotate(transform, M_PI);
               break;
               
          case UIImageOrientationDownMirrored: //EXIF = 4
               transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
               transform = CGAffineTransformScale(transform, 1.0, -1.0);
               break;
               
          case UIImageOrientationLeftMirrored: //EXIF = 5
               boundHeight = bounds.size.height;
               bounds.size.height = bounds.size.width;
               bounds.size.width = boundHeight;
               transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
               transform = CGAffineTransformScale(transform, -1.0, 1.0);
               transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
               break;
               
          case UIImageOrientationLeft: //EXIF = 6
               boundHeight = bounds.size.height;
               bounds.size.height = bounds.size.width;
               bounds.size.width = boundHeight;
               transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
               transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
               break;
               
          case UIImageOrientationRightMirrored: //EXIF = 7
               boundHeight = bounds.size.height;
               bounds.size.height = bounds.size.width;
               bounds.size.width = boundHeight;
               transform = CGAffineTransformMakeScale(-1.0, 1.0);
               transform = CGAffineTransformRotate(transform, M_PI / 2.0);
               break;
               
          case UIImageOrientationRight: //EXIF = 8
               boundHeight = bounds.size.height;
               bounds.size.height = bounds.size.width;
               bounds.size.width = boundHeight;
               transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
               transform = CGAffineTransformRotate(transform, M_PI / 2.0);
               break;
               
          default:
               [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
     }
     
     UIGraphicsBeginImageContext(bounds.size);
     
     CGContextRef context = UIGraphicsGetCurrentContext();
     
     if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
     {
          CGContextScaleCTM(context, -scaleRatio, scaleRatio);
          CGContextTranslateCTM(context, -height, 0);
     }
     else {
          CGContextScaleCTM(context, scaleRatio, -scaleRatio);
          CGContextTranslateCTM(context, 0, -height);
     }
     
     CGContextConcatCTM(context, transform);
     
     CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
     UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     return imageCopy;
}

#pragma mark - Gallery Permission
#pragma mark -

- (BOOL)hasGalleryPermission
{
     BOOL hasGalleryPermission = NO;
     PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
     
     if (authorizationStatus == PHAuthorizationStatusAuthorized) {
          hasGalleryPermission = YES;
     }
     return hasGalleryPermission;
}

#pragma mark - Progress HUD
#pragma mark -

-(void)showProgressHudForViewWithDetailsLabel:(NSString*)details andLabelText:(NSString*)label
{
     hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
     hud.mode           = MBProgressHUDModeIndeterminate;
     hud.labelFont      = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14.0f];
     hud.detailsLabelText = details;
     hud.labelText  = label;
}

-(void)showMessageHudWithMessage:(NSString*)message andDelay:(float)delay
{
     [hud hide:YES];
     hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
     hud.mode           = MBProgressHUDModeText;
     hud.detailsLabelFont  = [UIFont fontWithName:@"HelveticaNeue-Bold"
                                             size:12.0];
     hud.detailsLabelText  =  message;
     [hud hide:YES afterDelay:delay];
}

-(void)hideProgressHudInView
{
     [MBProgressHUD hideAllHUDsForView:self.window animated:YES];
}

-(void)showProgressHud
{
     hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
     hud.mode=MBProgressHUDModeIndeterminate;
     hud.bezelView.color=[UIColor clearColor];
     //     hud.backgroundColor=[UIColor clearColor];
     hud.contentColor=[UIColor blueColor];
     
}

#pragma mark - Method of Date Format
#pragma mark -
-(NSString *)formatDateWithString:(NSString *)date
{
     NSString *dateString = @"";
     if (date != nil) {
          NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
          [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
          NSDate * convrtedDate = [dateFormatter dateFromString:date];
          [dateFormatter setDateFormat:@"MM/dd/yy"];
         dateString  = [dateFormatter stringFromDate:convrtedDate];
     }
     return dateString;
}


#pragma mark - Fetching Image from Gallery
#pragma mark -

- (void)getImageFromGallery{
    @try{
     self.str_chat_status=@"1";
     if ([self hasGalleryPermission])
     {
          _arr_Gallery_Items=[[NSMutableArray alloc]init];
          _imageManager = [[PHCachingImageManager alloc] init];
          int k;
          if ([_assetsFetchResults count]>100) {
               for (k=0; k<100; k++) {
                    PHAsset *asset = _assetsFetchResults[k];
                    
                    float oldheight = asset.pixelHeight;
                    float scaleFactor =150/ oldheight;
                    
                    float newwidth = asset.pixelWidth * scaleFactor;
                    float newheight = oldheight * scaleFactor;
                    
                    [_imageManager requestImageForAsset:asset targetSize:CGSizeMake(newwidth,newheight) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info)
                     {
                         if (result != nil) {
                             [_arr_Gallery_Items insertObject:result atIndex:k];

                         }
                     }];
               }
          }
          else
          {
               for (k=0; k<[_assetsFetchResults count]; k++) {
                    PHAsset *asset = _assetsFetchResults[k];
                    
                    [_imageManager requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth/20,asset.pixelHeight/20) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info)
                     {
                          //_img_view_profile.image = result;
                         if (result != nil) {
                             [_arr_Gallery_Items insertObject:result atIndex:k];
                             
                         }                     }];
               }
          }
     }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at getImageFromGallery :%@",exception);
    }
    @finally{
        
    }
}

#pragma mark - Image : Compression
#pragma mark -
-(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize
{
     UIGraphicsBeginImageContext(newSize);
     [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
     UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     return newImage;
}

#pragma mark - Seconds Converter
#pragma mark -
- (NSString *)timeFormatted:(NSString *)totalSeconds
{
     int timeValue = [totalSeconds intValue];
     int seconds = timeValue % 60;
     int minutes = (timeValue / 60) % 60;
     int hours = timeValue / 3600;
     if (hours==0)
     {
          return [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
     }
     else
     {
          return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
     }
}

@end
