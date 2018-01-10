//
//  AudioFeedCommentsViewController.m
//  melody
//
//  Created by coding Brains on 26/12/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import "AudioFeedCommentsViewController.h"
#import "CommentMessegesTableViewCell.h"
#import "AudioFeedCommentTableViewCell.h"
#import "Constant.h"
#import "StudioPlayViewController.h"
#import "ProfileViewController.h"

@interface AudioFeedCommentsViewController ()
{
    BOOL toggle_PlayPause;
    NSTimer* sliderTimer;
    NSArray *recordingArray;
    UIActivityViewController *activityController;
    long current_Index_user;

}
@end
long lastIndexAFC = 10000;

@implementation AudioFeedCommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%@",_dic_data);
    defaults_userdata=[NSUserDefaults standardUserDefaults];
    _tbl_view_comments.separatorColor = [UIColor clearColor];
    text_flag=0;
     like_count=[[NSString alloc]init];
     like_status=[[NSString alloc]init];
     play_count=[[NSString alloc]init];
     share_count=[[NSString alloc]init];
    like_count=[_dic_data objectForKey:@"like_count"];
    like_status=[_dic_data objectForKey:@"like_status"];
    play_count=[_dic_data objectForKey:@"play_count"];
    share_count=[_dic_data objectForKey:@"share_count"];
    recordingArray = [_dic_data objectForKey:@"recordings"];
    //----------------- * TextField * ------------------------
    _tf_addcomment.delegate=self;
    [_tf_addcomment addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    current_Index_user = 0;
}

-(void)dismissKeyboard
{
    [_tf_addcomment resignFirstResponder];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewDidAppear:(BOOL)animated {
    [self callcommentlistapi];
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
 
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view_add_comment.frame;
        f.origin.y = self.view.frame.size.height-(keyboardSize.height+49);
        [_tbl_view_comments setFrame:CGRectMake(_tbl_view_comments.frame.origin.x, _tbl_view_comments.frame.origin.y, _tbl_view_comments.frame.size.width, _tbl_view_comments.frame.size.height-(keyboardSize.height))];
        self.view_add_comment.frame = f;
       
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view_add_comment.frame;
        f.origin.y = self.view.frame.size.height-49;
        [_tbl_view_comments setFrame:CGRectMake(_tbl_view_comments.frame.origin.x, _tbl_view_comments.frame.origin.y, _tbl_view_comments.frame.size.width, _tbl_view_comments.frame.size.height+(keyboardSize.height))];
        self.view_add_comment.frame = f;
    }];
}


-(void)textFieldDidChange:(UITextField *)theTextField{
    NSLog( @"text changed: %@", _tf_addcomment.text);
    if ([_tf_addcomment.text length]>0) {
        text_flag=1;
        [_btn_send_cancel setTitle:@"Send" forState:UIControlStateNormal];
    }else{
        text_flag=0;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"Working!!!");
    [_tf_addcomment resignFirstResponder];
    return YES;
}


- (IBAction)btn_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (IBAction)btn_home:(id)sender {
    
//    UIViewController *vc = self.presentingViewController;
//
//    [vc dismissViewControllerAnimated:YES completion:NULL];
    if (Appdelegate.isFirstTimeSignUp)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
        //Appdelegate.isFirstTimeSignUp=NO; >> IF PROBLEM OCCURS AGAIN UNCOMMENT THIS LINE
    }
    else{
        [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    }
}


- (IBAction)btn_melody_pack:(id)sender {
}
- (IBAction)btn_send_cancel:(id)sender {
    if (text_flag==0) {
  
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self.view_add_comment.frame;
            f.origin.y = self.view.frame.size.height-49;
            self.view_add_comment.frame = f;
            [_tf_addcomment resignFirstResponder];
        }];
        [self dismissViewControllerAnimated:YES completion:nil];

    }
    else
    {
        [_tf_addcomment resignFirstResponder];
        text_flag=0;
        [self callcommentapi];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tbl_view_comments setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        });
        [_btn_send_cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqual:@"audiofeed_to_studio_play"]) {
         
         StudioPlayViewController*vc=segue.destinationViewController;
         NSLog(@"DICT DATA %@",_dic_data);
         vc.str_CurrernUserId = [_dic_data objectForKey:@"added_by"];
         vc.str_RecordingId = [_dic_data objectForKey:@"recording_id"];
         // vc.arr_recordings=[arr_rec_recordings objectAtIndex:index];
     }
 }
 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }
    else
    {
        return [arr_comment_id count];
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (indexPath.section==0) {
        return 267;
    }
    else
    {
        return 150;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0) {
         AudioFeedCommentTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"audio_comment"];
        if (cell == nil)
            
        {
            NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"AudioFeedCommentTableViewCell"
                             
                                                          owner:self options:nil];
            cell.accessoryType = UITableViewCellStyleDefault;
            
            cell = (AudioFeedCommentTableViewCell*)[nib2 objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
            [cell.slider_progress setThumbImage:[UIImage imageNamed:@"thumb_transparent.png"] forState:UIControlStateNormal];
            cell.imgview_profile.layer.cornerRadius = cell.imgview_profile.frame.size.width / 2;
            cell.imgview_profile.clipsToBounds = YES;
            
            cell.layer.shadowColor = [[UIColor grayColor] CGColor];
            cell.layer.shadowOpacity = 0.4;
            cell.layer.shadowRadius = 0;
            cell.layer.shadowOffset = CGSizeMake(1.0, 1.0);
            cell.btn_hide.hidden=YES;
            cell.btn_comment.tag=indexPath.row;
            cell.btn_like.tag=indexPath.row;
            [cell.btn_like addTarget:self action:@selector(btn_Recordings_like_clicked:) forControlEvents:UIControlEventTouchUpInside];
            cell.btn_hide.tag=indexPath.row;
          
            
            //btn_nextAction
            //btn_previousAction
            [cell.btn_next_audio addTarget:self action:@selector(btn_nextAction:) forControlEvents:UIControlEventTouchUpInside];

            [cell.btn_previous_audio addTarget:self action:@selector(btn_previousAction:) forControlEvents:UIControlEventTouchUpInside];

            
            [cell.btn_share addTarget:self action:@selector(openshare:) forControlEvents:UIControlEventTouchUpInside];
            cell.btn_join.tag=indexPath.row;
            
            [cell.btn_join addTarget:self action:@selector(join_clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.btn_playpause addTarget:self action:@selector(btn_Recordings_Play_clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.lbl_profile_name.text=[_dic_data objectForKey:@"recording_topic"];
            cell.lbl_profile_user_name.text=[_dic_data objectForKey:@"user_name"];
            //cell.lbl_timer
            [cell.btn_play_value setTitle:[_dic_data objectForKey:@"play_count"] forState:UIControlStateNormal];
            cell.lbl_date_top.textAlignment = NSTextAlignmentRight;
            
            NSString *tempDate = [_dic_data objectForKey:@"date_added"];
            if (tempDate == nil || tempDate.length >0) {
                cell.lbl_date_top.text=[Appdelegate formatDateWithString:tempDate];
                cell.lbl_date_aidios.text=[Appdelegate formatDateWithString:tempDate];
            }
            
//            cell.lbl_included.text=[NSString stringWithFormat:@"%lu",(unsigned long)[[_dic_data objectForKey:@"recordings"] count]];
            cell.lbl_included.text=[NSString stringWithFormat:@"%@",[_dic_data objectForKey:@"join_count"]];
            long includeL =[[_dic_data objectForKey:@"join_count"] intValue];
            
            
          
                cell.lbl_oneof.text = [NSString stringWithFormat:@"( 1 of %ld )",includeL];
            
            cell.lbl_timer.text=[Appdelegate timeFormatted:[[[_dic_data objectForKey:@"recordings"] objectAtIndex:0] objectForKey:@"duration"]];
            cell.lbl_geners.textAlignment=NSTextAlignmentRight;
            cell.lbl_geners.text=[NSString stringWithFormat:@"Genre : %@",[_dic_data objectForKey:@"genre_name"]];
            
            cell.imgview_profile.contentMode = UIViewContentModeScaleToFill;
            cell.img_view_back_cover.contentMode = UIViewContentModeScaleAspectFill;
            [cell.btn_like_value setTitle:[NSString stringWithFormat:@"%@",like_count] forState:UIControlStateNormal];
            [cell.btn_comment_value setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)[arr_comment_id count]] forState:UIControlStateNormal];
            if ([like_status isEqual:@"1"]) {
                [cell.btn_like setBackgroundImage:[UIImage imageNamed:@"btn_hand_fill.png"] forState:UIControlStateNormal];
            }
            else{
                [cell.btn_like setBackgroundImage:[UIImage imageNamed:@"btn_hand_outline.png"] forState:UIControlStateNormal];
            }
            
            
            
            //------------- Cover pic -----------------
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[_dic_data objectForKey:@"cover_url"]]];
            
            cell.img_view_back_cover.contentMode = UIViewContentModeScaleToFill;
            
            [cell.img_view_back_cover sd_setImageWithURL:url
                                        placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            

            
            NSURL *url2 = [NSURL URLWithString:[_dic_data  objectForKey:@"profile_url"]];
            
            NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:url2 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.imgview_profile.contentMode = UIViewContentModeScaleToFill;

                            cell.imgview_profile.image=image;                                    });
                    }
                }
            }];
            [task2 resume];
       
        
        return cell;
    
    }
    else
    {
        CommentMessegesTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:nil];
        
        
        if (cell == nil)
            
        {
            NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"CommentMessegesTableViewCell"
                             
                                                          owner:self options:nil];
            cell.accessoryType = UITableViewCellStyleDefault;
            
            cell = (CommentMessegesTableViewCell*)[nib2 objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.btn_delete_comment.tag=indexPath.row;
            [cell.btn_delete_comment addTarget:self action:@selector(btn_delete_comment_cliked:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([arr_user_id objectAtIndex:indexPath.row]==[defaults_userdata objectForKey:@"user_id"]) {
                cell.btn_delete_comment.hidden=NO;
                cell.btn_delete_comment.tag=indexPath.row;
                [cell.btn_delete_comment addTarget:self action:@selector(btn_delete_comment_cliked:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                cell.btn_delete_comment.hidden=YES;
            }
            cell.img_profile.layer.cornerRadius=cell.img_profile.frame.size.width/2;
            cell.img_profile.clipsToBounds=YES;
            cell.tv_comment.text=[arr_text objectAtIndex:indexPath.row];
            cell.lbl_name.text=[arr_user_name objectAtIndex:indexPath.row];
            cell.lbl_user_name.text=[NSString stringWithFormat:@"@%@",[arr_user_username objectAtIndex:indexPath.row]];
            cell.lbl_name.text=[arr_user_name objectAtIndex:indexPath.row];
            cell.lbl_time.textAlignment=NSTextAlignmentRight;
            NSString *tempDate=[arr_comment_timedate objectAtIndex:indexPath.row];
            if (tempDate == nil || tempDate.length >0) {
            cell.lbl_time.text=[Appdelegate TodayTimeCalculation:tempDate];
            }
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
            cell.img_profile.userInteractionEnabled=YES;
            tap.cancelsTouchesInView = YES;
            tap.numberOfTapsRequired = 1;
            tap.view.tag=indexPath.row;
            cell.img_profile.tag = indexPath.row;
            
            [cell.img_profile addGestureRecognizer:tap];
            if ([[arr_user_profile_pic objectAtIndex:indexPath.row] length]>6)
            {
                NSURL *url2 = [NSURL URLWithString:[arr_user_profile_pic objectAtIndex:indexPath.row]];
                
                NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:url2 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (data) {
                        UIImage *image = [UIImage imageWithData:data];
                        if (image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                cell.img_profile.contentMode = UIViewContentModeScaleToFill;
                                cell.img_profile.image=image;                                    });
                        }
                    }
                }];
                [task2 resume];
                
            }
            return cell;
        }
        return cell;
    }
}

- (void) handleImageTap:(UITapGestureRecognizer *)gestureRecognizer
{
    NSLog(@"imaged tap");
    CGPoint tapLocation = [gestureRecognizer locationInView:_tbl_view_comments];
    NSIndexPath *iPath = [_tbl_view_comments indexPathForRowAtPoint:tapLocation];
    
    NSLog(@"FINAL TAG VALUE %ld",(long)iPath.row);
    ProfileViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    myVC.follower_id = [arr_user_id objectAtIndex:iPath.row];
    [self presentViewController:myVC animated:YES completion:nil];
    
}
-(void)btn_Recordings_like_clicked:(UIButton*)sender
{
    
    @try{
    NSString* like_val=[[NSString alloc]init];
    if ([like_status isEqual:@"1"]) {
        like_val=@"0";
    }
    else{
        like_val=@"1";
    }
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:[_dic_data objectForKey:@"recording_id"] forKey:@"file_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"user_id"];
    [params setObject:like_val forKey:@"likes"];
    [params setObject:@"user_recording" forKey:@"type"];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    [params setObject:[_dic_data objectForKey:@"recording_topic"] forKey:@"topic"];


    NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@likes.php",BaseUrl];
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
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Message"
                                          message:@"Network Error !"
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
                NSMutableDictionary*dic_response=[[NSMutableDictionary alloc]init];
                NSLog(@"%@",jsonResponse);
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    dic_response=[jsonResponse objectForKey:@"response"];
                    NSLog(@"%@",dic_response);
                    like_count=[dic_response objectForKey:@"likes" ];
                    like_status=like_val;
                    
                    //---------------------- Get IndexPath ---------------------
                    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tbl_view_comments];
                    NSIndexPath *indexPath = [_tbl_view_comments indexPathForRowAtPoint:buttonPosition];
                    //------------------ Reload TableView Cell -----------------
                    if (indexPath != nil) {
                        [_tbl_view_comments beginUpdates];
                        [_tbl_view_comments reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [_tbl_view_comments endUpdates];
                    }
                  
                    
                }
                else
                {
                    if ([like_status isEqual:@"1"]) {
                        like_status=@"0";
                    }
                    else{
                        like_status=@"1";
                    }
                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"Alert"
                                                      message:@"Error to like!"
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
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}




-(void)callcommentapi
{
    [Appdelegate showProgressHud];

    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:[_dic_data objectForKey:@"recording_id"] forKey:@"file_id"];
    [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:@"user_id"];
    [params setObject:_tf_addcomment.text forKey:@"comment"];
    [params setObject:@"user_recording" forKey:KEY_SHARE_FILETYPE];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    [params setObject:[_dic_data objectForKey:@"recording_topic"] forKey:@"topic"];
    
       NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@comments.php",BaseUrl];
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
            [Appdelegate hideProgressHudInView];
            NSLog(@"%@", error);
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Message"
                                          message:@"Network Error !"
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
                NSMutableArray*arr_response=[[NSMutableArray alloc]init];
                NSLog(@"%@",jsonResponse);
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    [Appdelegate hideProgressHudInView];
                    _tf_addcomment.text=nil;
                    NSLog(@"%@",arr_response);
                    arr_text=[[NSMutableArray alloc]init];
                    arr_comment_id=[[NSMutableArray alloc]init];
                    arr_user_profile_pic=[[NSMutableArray alloc]init];
                    arr_user_id=[[NSMutableArray alloc]init];
                    arr_user_username=[[NSMutableArray alloc]init];
                    arr_user_name=[[NSMutableArray alloc]init];
                    arr_comment_timedate=[[NSMutableArray alloc]init];
                    arr_response=[[jsonResponse objectForKey:@"response"] objectForKey:@"comments"];
                    NSLog(@"%@",arr_response);
                    int i;
                    for (i=0; i<[arr_response count]; i++) {
                        
                        [arr_user_id insertObject:[[arr_response objectAtIndex:i] objectForKey:@"user_id"] atIndex:i];
                        [arr_user_name insertObject:[[arr_response objectAtIndex:i] objectForKey:@"name"] atIndex:i];
                        [arr_user_username insertObject:[[arr_response objectAtIndex:i] objectForKey:@"user_name"] atIndex:i];
                        [arr_comment_id insertObject:[[arr_response objectAtIndex:i] objectForKey:@"comment_id"] atIndex:i];
                        [arr_text insertObject:[[arr_response objectAtIndex:i] objectForKey:@"comment_text"] atIndex:i];
                        [arr_user_profile_pic insertObject:[[arr_response objectAtIndex:i] objectForKey:@"user_profile_url"] atIndex:i];
                        [arr_comment_timedate insertObject:[[arr_response objectAtIndex:i] objectForKey:@"comment_time"] atIndex:i];
                        
                    }
                    [_tbl_view_comments reloadData];
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"updateComments"
                     object:self];
                    
                }
                else
                {
                    [Appdelegate hideProgressHudInView];
                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"Alert"
                                                      message:@"Unable to add comment!"
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



-(void)callcommentlistapi
{
    
    [Appdelegate showProgressHud];
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
  
    [params setObject:[_dic_data objectForKey:@"recording_id"] forKey:@"file_id"];
    [params setObject:@"user_recording" forKey:KEY_SHARE_FILETYPE];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
 
    NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@commentlist.php",BaseUrl];
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
            NSLog(@"%@", error);
            [Appdelegate hideProgressHudInView];
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Message"
                                          message:@"Network Error !"
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
                NSMutableArray*arr_response=[[NSMutableArray alloc]init];
                NSLog(@"%@",jsonResponse);
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    [Appdelegate hideProgressHudInView];

                    arr_text=[[NSMutableArray alloc]init];
                    arr_comment_id=[[NSMutableArray alloc]init];
                    arr_user_profile_pic=[[NSMutableArray alloc]init];
                    arr_user_id=[[NSMutableArray alloc]init];
                    arr_user_username=[[NSMutableArray alloc]init];
                    arr_user_name=[[NSMutableArray alloc]init];
                    arr_comment_timedate=[[NSMutableArray alloc]init];
                    arr_response=[jsonResponse objectForKey:@"response"];
                    NSLog(@"%@",arr_response);
                    int i;
                    for (i=0; i<[arr_response count]; i++) {
                        
                        [arr_user_id insertObject:[[arr_response objectAtIndex:i] objectForKey:@"user_id"] atIndex:i];
                        [arr_user_name insertObject:[[arr_response objectAtIndex:i] objectForKey:@"name"] atIndex:i];
                        [arr_user_username insertObject:[[arr_response objectAtIndex:i] objectForKey:@"user_name"] atIndex:i];
                        [arr_comment_id insertObject:[[arr_response objectAtIndex:i] objectForKey:@"comment_id"] atIndex:i];
                        [arr_text insertObject:[[arr_response objectAtIndex:i] objectForKey:@"comment_text"] atIndex:i];
                        [arr_user_profile_pic insertObject:[[arr_response objectAtIndex:i] objectForKey:@"user_profile_url"] atIndex:i];
                        [arr_comment_timedate insertObject:[[arr_response objectAtIndex:i] objectForKey:@"comment_time"] atIndex:i];
                        
                    }
                    [_tbl_view_comments reloadData];
                }
                else
                {
                    [Appdelegate hideProgressHudInView];
                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                        [Appdelegate hideProgressHudInView];

                    }
                    
                }
                
            });
        }
    }];
    [task resume];
    
}
-(void)btn_delete_comment_cliked:(UIButton*)sender
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Alert"
                                  message:@"Do you sure to delete the comment?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    
                                    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
                                    [params setObject:[_dic_data objectForKey:@"recording_id"] forKey:@"file_id"];
                                    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"user_id"];
                                    [params setObject:[arr_comment_id objectAtIndex:sender.tag] forKey:@"comment_id"];
                                    [params setObject:@"user_recording" forKey:KEY_SHARE_FILETYPE];
                                    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
                                    
                                    NSLog(@"%@",params);
                                    NSMutableString* parameterString = [NSMutableString string];
                                    for(NSString* key in [params allKeys])
                                    {
                                        if ([parameterString length]) {
                                            [parameterString appendString:@"&"];
                                        }
                                        [parameterString appendFormat:@"%@=%@",key, params[key]];
                                    }
                                    NSString* urlString = [NSString stringWithFormat:@"%@deletecomments.php",BaseUrl];
                                    NSURL* url = [NSURL URLWithString:urlString];
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
                                            UIAlertController * alert=   [UIAlertController
                                                                          alertControllerWithTitle:@"Message"
                                                                          message:@"Network Error !"
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
                                                NSMutableDictionary*dic_response=[[NSMutableDictionary alloc]init];
                                                NSLog(@"%@",jsonResponse);
                                                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                                                    dic_response=[jsonResponse objectForKey:@"response"];
                                                    [arr_comment_id removeObjectAtIndex:sender.tag];
                                                    [arr_text removeObjectAtIndex:sender.tag];
                                                    [arr_user_profile_pic removeObjectAtIndex:sender.tag];
                                                    [arr_user_id removeObjectAtIndex:sender.tag];
                                                    [arr_user_name removeObjectAtIndex:sender.tag];
                                                    [arr_user_username removeObjectAtIndex:sender.tag];
                                                    
                                                    [_tbl_view_comments reloadData];
                                                    [self callcommentlistapi];

                                                }
                                                else
                                                {
                                                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                                                        UIAlertController * alert=   [UIAlertController
                                                                                      alertControllerWithTitle:@"Alert"
                                                                                      message:@"Error"
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
                                    
                                }];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   
                                   
                                   
                               }];
    [alert addAction:noButton];
    
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)openshare:(UIButton*)sender
{
    
    if ([defaults_userdata boolForKey:@"isUserLogged"])
    {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@""
                                      message:@"Share with YoMelody chat"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Yes"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        MessengerViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MessengerViewController"];
                                        myVC.str_file_id = [_dic_data valueForKey:@"recording_id"];
                                        myVC.str_screen_type = @"station";
                                        Appdelegate.fromShareScreen = 0;
                                        
                                        myVC.isShare_Audio = YES;
                                        [self presentViewController:myVC animated:YES completion:nil];
                                        //Handel your yes please button action here
                                    }];
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"No"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       //Handel your yes please button action here
                        NSArray *activityItems = @[@"Hi ! this is Gaurav"];
                        activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                            {
                                activityController.popoverPresentationController.sourceView = self.view;
                                activityController.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4, 0, 0);
                            }
                                       
                        [self presentViewController:activityController animated:YES completion:nil];
                        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                        [controller setInitialText:@"First post from my iPhone app"];
                        [controller addImage:[UIImage imageNamed:@"socialsharing-facebook-image.jpg"]];
                                        
                        [controller setCompletionHandler:^(SLComposeViewControllerResult result) {
                        switch (result) {
                            case SLComposeViewControllerResultCancelled:
                            NSLog(@"Post Canceled");
                            break;
                            case SLComposeViewControllerResultDone:
                            NSLog(@"Post Sucessful");
                            break;
                            default:
                            break;
                            }
                            }];
                                        
                        [self presentViewController:controller animated:YES completion:Nil];
                            }
            else if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
            {
                SLComposeViewController *tweetSheet = [SLComposeViewController
                                                       composeViewControllerForServiceType:SLServiceTypeTwitter];
                [tweetSheet setInitialText:@"Great fun to learn iOS programming at appcoda.com!"];
                [self presentViewController:tweetSheet animated:YES completion:nil];
            }
        }];
        [alert addAction:noButton];
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
       
    }
}

#pragma mark - Audio Player Delegate Method
#pragma mark -

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    AudioFeedCommentTableViewCell *cell = [self.tbl_view_comments cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.btn_playpause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
    cell.slider_progress.value = 0.0;
    toggle_PlayPause= YES;
    audioPlayer = nil;
    [sliderTimer invalidate];
    sliderTimer = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@" player error description %@",error);
}

- (void)btn_Recordings_Play_clicked:(UIButton* )sender {
    
    @try{
        instrument_play_index = sender.tag;
        AudioFeedCommentTableViewCell *cell = [_tbl_view_comments cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
        
        if(audioPlayer) {
                if (audioPlayer.playing) {
                    [cell.btn_playpause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                    [audioPlayer pause];
                    }
        
                else {
                    [cell.btn_playpause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
                    [audioPlayer play];
                    }
        }
        else{
            [Appdelegate showProgressHud];
            dispatch_queue_t myqueue = dispatch_queue_create("queue", NULL);
            dispatch_async(myqueue, ^{
            [self method_PlayCount];

            if(audioPlayer){
                [audioPlayer stop];
                audioPlayer = nil;
            }
            
            NSError*error=nil;
            NSString *urlstr =[_dic_data objectForKey:@"recording_url"];
            urlstr = [urlstr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
            
            NSURL *urlforPlay = [NSURL URLWithString:urlstr];
            NSData *data = [NSData dataWithContentsOfURL:urlforPlay];
            audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
                dispatch_async(dispatch_get_main_queue(), ^{

            [audioPlayer setDelegate:self];
            [audioPlayer prepareToPlay];
            if ([audioPlayer prepareToPlay] == YES){
                
                if (lastIndexAFC != 10000) {
                    AudioFeedCommentTableViewCell *cell1 = [_tbl_view_comments cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastIndexAFC inSection:0]];
                    cell1.slider_progress.value = 0.0;
                    [cell1.btn_playpause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                }
                sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerupdateSlider) userInfo:nil repeats:YES];
                // Set the maximum value of the UISlider
                cell.slider_progress.maximumValue=[audioPlayer duration];
                cell.slider_progress.value = 0.0;
                // Set the valueChanged target
                [cell.slider_progress addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];
                [cell.btn_playpause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
                    [Appdelegate hideProgressHudInView];
                    [audioPlayer stop];
                    [audioPlayer play];
                
            }
            
            else {
                AudioFeedCommentTableViewCell *cell1 = [_tbl_view_comments cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastIndexAFC inSection:0]];
                cell1.slider_progress.value = 0.0;
                [cell1.btn_playpause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
//                UIAlertController * alert=   [UIAlertController
//                                              alertControllerWithTitle:@"Alert"
//                                              message:@"Url Not Supported"
//                                              preferredStyle:UIAlertControllerStyleAlert];
//                
//                UIAlertAction* yesButton = [UIAlertAction
//                                            actionWithTitle:@"ok"
//                                            style:UIAlertActionStyleDefault
//                                            handler:^(UIAlertAction * action)
//                                            {
//                                                [Appdelegate hideProgressHudInView];
//                                                
//                                            }];
//                
//                [alert addAction:yesButton];
//                [self presentViewController:alert animated:YES completion:nil];
                int errorCode = CFSwapInt16HostToBig ([error code]);
                NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
            }
            
        });
    });
    }
        lastIndexAFC = sender.tag;
    }
    @catch (NSException *exception) {
        NSLog(@"exception at play :%@",exception);
    }
    @finally{
        
    }
}


-(void)timerupdateSlider{
    // Update the slider about the music time
    
    AudioFeedCommentTableViewCell *cell = [_tbl_view_comments cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    cell.slider_progress.value = audioPlayer.currentTime;
}


-(void)sliderChanged{
    // Fast skip the music when user scroll the UISlider
    AudioFeedCommentTableViewCell *cell = [_tbl_view_comments cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    [audioPlayer setCurrentTime:cell.slider_progress.value];
    [cell.btn_playpause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
    instrument_play_status=1;
    
}


-(void)join_clicked:(UIButton*)sender
{
    
    if (![defaults_userdata boolForKey:@"isUserLogged"]) {
        ViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        myVC.open_login=@"0";
        myVC.other_vc_flag=@"1";
        [self presentViewController:myVC animated:YES completion:nil];
    }
    else{
        index=sender.tag;
        [self performSegueWithIdentifier:@"audiofeed_to_studio_play" sender:self];
    }
    
}

-(void)method_PlayCount{
    
    NSString *userid = [defaults_userdata objectForKey:@"user_id"];
    NSLog(@"userid %@",userid);
    NSLog(@"DATA %@",_dic_data);
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:[_dic_data objectForKey:@"recording_id"] forKey:@"fileid"];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    if ([defaults_userdata boolForKey:@"isUserLogged"]) {
        [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:@"userid"];
        
    }    [params setObject:@"recording" forKey:@"type"];
    [params setObject:@"user" forKey:@"user_type"];
    
    
    NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@playcount.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(error)
        {
            //do something
            NSLog(@"%@", error);
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Message"
                                          message:@"Network Error !"
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
                NSMutableDictionary*dic_response=[[NSMutableDictionary alloc]init];
                NSLog(@"%@",jsonResponse);
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    dic_response=[jsonResponse objectForKey:@"response"];
                    NSLog(@"%@",dic_response);
                    // long a = [[arr_rec_play_count objectAtIndex:sender] integerValue]+1;
                    //  [arr_rec_play_count replaceObjectAtIndex:sender withObject:[NSNumber numberWithInteger:a]];
                    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                    
                    [tempDict addEntriesFromDictionary:_dic_data];
                    [tempDict setObject:[dic_response objectForKey:@"play_count"] forKey:@"play_count"];
                    _dic_data=tempDict;
                    [self.tbl_view_comments reloadData];
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"updatePlayCount"
                     object:self];
                    
                }
                else
                {
                    
                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"Alert"
                                                      message:@"Error"
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





- (IBAction)btn_nextAction:(id)sender {
    @try{
        AudioFeedCommentTableViewCell *cell = [_tbl_view_comments cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

        if (current_Index_user < recordingArray.count-1) {
            current_Index_user += 1;
            if (audioPlayer.isPlaying) {

                [audioPlayer stop];
                audioPlayer = nil;
                [cell.btn_playpause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];

            }
            
            [defaults_userdata setObject:[NSNumber numberWithInt:(int)current_Index_user] forKey:@"index_currentUser"];
            cell.lbl_oneof.text = [NSString stringWithFormat:@"( %ld of %ld )",current_Index_user+1,(unsigned long)recordingArray.count];
            [_tbl_view_comments reloadData];
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}


- (IBAction)btn_previousAction:(id)sender {
    @try{
        AudioFeedCommentTableViewCell *cell = [_tbl_view_comments cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

        if (current_Index_user > 0) {
            current_Index_user -= 1;
            if (audioPlayer.isPlaying) {
                [audioPlayer stop];
                audioPlayer = nil;
                [cell.btn_playpause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];

            }
            cell.lbl_oneof.text = [NSString stringWithFormat:@"( %ld of %ld )",current_Index_user+1,(unsigned long)recordingArray.count];
            [_tbl_view_comments reloadData];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}

@end
