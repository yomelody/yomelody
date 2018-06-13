//
//  SocialSettingsViewController.m
//  melody
//
//  Created by coding Brains on 24/12/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import "SocialSettingsViewController.h"
#import "ViewController.h"
#import "Constant.h"
#import <SafariServices/SafariServices.h>




@interface SocialSettingsViewController ()<SFSafariViewControllerDelegate>
{
    NSDictionary*dic_responseGET;
    NSString *socialStatusType,*send_status,*get_status,*fb_status,*twitter_status,*google_status;
}
@end

@implementation SocialSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    defaults_userdata=[NSUserDefaults standardUserDefaults];
    _img_view_profile_pic.layer.cornerRadius = _img_view_profile_pic.frame.size.width / 2;
    _img_view_profile_pic.clipsToBounds = YES;
    _img_view_profile_pic.userInteractionEnabled = YES;
    UITapGestureRecognizer *pgr = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handlePictab:)];
    [_img_view_profile_pic addGestureRecognizer:pgr];
    dic_responseGET=[[NSDictionary alloc]init];
    [self getCurrentSocialStatus];

}




- (void)viewWillAppear:(BOOL)animated {
    if ([[defaults_userdata stringForKey:@"rememberme"] isEqual:@"remember"]) {
        _view_profile_afterlogin.hidden=NO;
        _img_view_main_logo.hidden=YES;
        [_img_view_profile_pic setImage:[UIImage imageWithData:[defaults_userdata objectForKey:@"profile_pic"]]];
        _lbl_username.text=[defaults_userdata stringForKey:@"first_name"];
        _lbl_user_station.text=[NSString stringWithFormat:@"@%@",[defaults_userdata stringForKey:@"user_name"]];
        
    }
    else
    {
        _view_profile_afterlogin.hidden=YES;
        _img_view_main_logo.hidden=NO;
        
    }
   
}
- (void)handlePictab:(UITapGestureRecognizer *)pinchGestureRecognizer
{
    [self performSegueWithIdentifier:@"go_to_profile" sender:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btn_done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)switch_FBAction:(id)sender {
    if([defaults_userdata boolForKey:@"isUserLogged"])
    {
        //        [defaults_userdata setBool:self.switch_fb.isOn forKey:@"status_fb"];
        //        [defaults_userdata synchronize];
        //        NSLog(@"%lu",(unsigned long)self.switch_fb.isOn);
        if([fb_status isEqualToString:@"0"])
        {
            send_status = @"1";
            _switch_fb.on = YES;
        }
        else
        {
            send_status = @"0";
            _switch_fb.on = NO;
        }
        socialStatusType=@"facebook";
        [self setCurrentSocialStatus];
    }
    else
    {
        _switch_fb.on = NO;
        ViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        myVC.open_login=@"0";
        myVC.other_vc_flag=@"1";
        [self presentViewController:myVC animated:YES completion:nil];
    }
    
}


- (IBAction)switch_TwitterAction:(id)sender {
    if([defaults_userdata boolForKey:@"isUserLogged"])
    {
        if([twitter_status isEqualToString:@"0"])
        {
            send_status = @"1";
            _switch_twitter.on = YES;
        }
        else
        {
            send_status = @"0";
            _switch_twitter.on = NO;
        }
        socialStatusType=@"twitter";
        [self setCurrentSocialStatus];
    }
    else
    {
        _switch_twitter.on = NO;
        ViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        myVC.open_login=@"0";
        myVC.other_vc_flag=@"1";
        [self presentViewController:myVC animated:YES completion:nil];
    }
}






- (IBAction)switch_GoogleAction:(id)sender {
    if([defaults_userdata boolForKey:@"isUserLogged"]) {
        //    [defaults_userdata setBool:self.switch_google.isOn forKey:@"status_google"];
        //    [defaults_userdata synchronize];
        //    NSLog(@"%lu",(unsigned long)self.switch_google.isOn);
        if ([google_status isEqualToString:@"0"]) {
            send_status = @"1";
            _switch_google.on = YES;
            [self showGooglePlusShare:[NSURL URLWithString:@""]];
            
            
            

        }
        else
        {
            send_status  = @"0";
            _switch_google.on = NO;
        }
        socialStatusType = @"google";
        [self setCurrentSocialStatus];
    }
    else{
        _switch_google.on = NO;
        ViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        myVC.open_login=@"0";
        myVC.other_vc_flag=@"1";
        [self presentViewController:myVC animated:YES completion:nil];
    }
}


-(void)setCurrentSocialStatus
{
    /*
     URL: http://52.89.220.199/api/change_social_status.php
     Parameter:
     
     ApiAuthenticationKey:@_$%yomelody%audio#@mixing(app*
     user_id:1
     type:facebook, twitter, google
     status:1
     */
    NSMutableDictionary * params = [[NSMutableDictionary alloc]init];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    
    
    if([defaults_userdata boolForKey:@"isUserLogged"]) {
        [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:@"user_id"];
    }
    [params setObject:socialStatusType forKey:@"type"];
    [params setObject:send_status forKey:@"status"];
    NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@change_social_status.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    
    //this is how cookies were created
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(error)
        {
            //[SVProgressHUD dismiss];
            NSLog(@"%@", error);
            
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
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    fb_status=[[jsonResponse objectForKey:@"Response"] objectForKey:@"status"];
                    twitter_status=[[jsonResponse objectForKey:@"Response"] objectForKey:@"status"];
                    google_status=[[jsonResponse objectForKey:@"Response"] objectForKey:@"status"];
                }
                else
                {
                    
                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                        NSLog(@"unsuccess error");
                        
                    }
                }
            });
        }
    }];
    [task resume];
}

-(void)getCurrentSocialStatus
{
    /*
     
     URL: http://52.89.220.199/api/social_status.php
     Parameter:
     ApiAuthenticationKey:@_$%yomelody%audio#@mixing(app*
     user_id:1
     
     */
    NSMutableDictionary * params = [[NSMutableDictionary alloc]init];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    
    
    if([defaults_userdata boolForKey:@"isUserLogged"]) {
        [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:@"user_id"];
    }
    
    NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@social_status.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    
    //this is how cookies were created
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(error)
        {
            //[SVProgressHUD dismiss];
            NSLog(@"%@", error);
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
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    dic_responseGET = [jsonResponse objectForKey:@"Response"];
                    fb_status = [dic_responseGET objectForKey:@"facebook_status"];
                    twitter_status = [dic_responseGET objectForKey:@"twitter_status"];
                    google_status = [dic_responseGET objectForKey:@"google_status"];
                    if ([[dic_responseGET objectForKey:@"facebook_status"] isEqualToString:@"0"])
                    {
                        [self.switch_fb setOn:NO];
                    }
                    else
                    {
                        [self.switch_fb setOn:YES];
                    }
                    if ([[dic_responseGET objectForKey:@"google_status"] isEqualToString:@"0"])
                    {
                        [self.switch_google setOn:NO];
                    }
                    else
                    {
                        [self.switch_google setOn:YES];
                    }
                    if ([[dic_responseGET objectForKey:@"twitter_status"] isEqualToString:@"0"])
                    {
                        [self.switch_twitter setOn:NO];
                    }
                    else
                    {
                        [self.switch_twitter setOn:YES];
                    }
                }
                else
                {
                    
                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                        NSLog(@"unsuccess error");
                        
                    }
                }
            });
        }
    }];
    [task resume];
}

- (void)showGooglePlusShare:(NSURL*)shareURL {
    
    NSURLComponents* urlComponents = [[NSURLComponents alloc]
                                      initWithString:@"https://plus.google.com/share"];
    urlComponents.queryItems = @[[[NSURLQueryItem alloc]
                                  initWithName:@"url"
                                  value:[shareURL absoluteString]]];
    NSURL* url = [urlComponents URL];
    
    if ([SFSafariViewController class]) {
        // Open the URL in SFSafariViewController (iOS 9+)
        SFSafariViewController* controller = [[SFSafariViewController alloc]
                                              initWithURL:url];
        controller.delegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        // Open the URL in the device's browser
        [[UIApplication sharedApplication] openURL:url];
    }
}


- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
