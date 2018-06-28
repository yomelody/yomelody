//
//  MessengerViewController.m
//  melody
//
//  Created by CodingBrainsMini on 11/21/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//


#import "Constant.h"

@interface MessengerViewController ()
{
    NSMutableArray*arr_contactList;
    NSMutableArray*arr_followerListM;
    NSMutableArray*arr_followingListM;
    NSMutableDictionary *dic_tempM;
    NSMutableArray*arr_response;
    NSString *grp_name;
}
@end

@implementation MessengerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tbl_view_messages_list.hidden = YES;
    self.img_placeholderNoConversation.hidden = YES;
    self.noConversationLbl.hidden = YES;
    arr_contactList = [[NSMutableArray alloc]init];
    dic_tempM = [[NSMutableDictionary alloc]init];

    
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification_UpdateGroup:)
                                                 name:@"updateGroup"
                                               object:nil];
}


- (void) receiveNotification_UpdateGroup:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"updateGroup"])
        NSLog (@"Successfully received the test notification!");
    [self loadRecentConversession];
}

- (IBAction)btn_msg_to_new_contact:(id)sender{
    
}




-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"Current logged user %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]);
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]) {
//        if(arr_response == nil)
        [self loadRecentConversession];
//    }
}

-(void)viewDidDisappear:(BOOL)animated{
//    _isShare_Audio = NO;    
}

#pragma mark - TableView Delegates & Datsource
#pragma mark -

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [arr_receiver_id count];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 90;
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    messagesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil)
        
    {
        NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"messagesTableViewCell"
                                                      owner:self options:nil];
        cell.accessoryType = UITableViewCellStyleDefault;
        cell = (messagesTableViewCell*)[nib2 objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.img_view_profileimage.layer.cornerRadius = cell.img_view_profileimage.frame.size.width / 2;
        cell.img_view_profileimage.clipsToBounds = YES;
        [cell.btn_next addTarget:self action:@selector(go_to_chat:) forControlEvents:UIControlEventTouchUpInside];
        
        //------------------------* Check Unseen Msg *------------------------
          if ([[[arr_response objectAtIndex:indexPath.row]valueForKey:@"New_message"] isEqualToString:@"0"]){
              cell.img_RedCircle.hidden = YES;
              cell.lbl_MsgCount.hidden = YES;
          }
          else{
              cell.img_RedCircle.hidden = NO;
              cell.lbl_MsgCount.hidden = NO;
              cell.lbl_MsgCount.text = [[arr_response objectAtIndex:indexPath.row]valueForKey:@"New_message"];

          }
      
        //-------------------------- For Group Chat --------------------------
        if ([[[arr_response objectAtIndex:indexPath.row]valueForKey:@"chat_type"] isEqualToString:@"group"]){
            grp_name = [[arr_response objectAtIndex:indexPath.row]valueForKey:@"group_name"];
            if ([grp_name isEqualToString:@""]) {
            cell.lbl_sender_name.text = @"Group";
            }
            else{
            cell.lbl_sender_name.text=[[arr_response objectAtIndex:indexPath.row]valueForKey:@"group_name"];
            }
            
            //------------------------- Set Msg --------------------------
            NSString * str_msg = [NSString stringWithFormat:@"%@:%@",[arr_sender_name objectAtIndex:indexPath.row],[arr_receiver_msg objectAtIndex:indexPath.row]];
            cell.lbl_message.text=str_msg;
            
            //---------------------- Set Profile Pic ---------------------
            NSLog(@"url %@",[arr_receiver_profile objectAtIndex:indexPath.row]);
            
            NSURL *url = [NSURL URLWithString:[[arr_response objectAtIndex:indexPath.row]valueForKey:@"group_pick"]];
            
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.img_view_profileimage.image=image;
                        });
                    }
                }
            }];
            [task resume];

        }
        else{
//
//            if([[arr_receiver_id objectAtIndex:index] isEqual:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]]) {
//                cell.lbl_sender_name.text=[arr_sender_name objectAtIndex:indexPath.row];
//            }
//            else{
                cell.lbl_sender_name.text=[arr_receiver_name objectAtIndex:indexPath.row];
//            }
            
            //------------------------- Set Msg --------------------------
            cell.lbl_message.text=[arr_receiver_msg objectAtIndex:indexPath.row];
            
            //------------------ profile navigation ---------------------
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
            cell.img_view_profileimage.userInteractionEnabled=YES;
            tap.numberOfTapsRequired = 1;
            tap.view.tag=indexPath.row;
            cell.img_view_profileimage.tag = indexPath.row;
            tap.cancelsTouchesInView = YES;
            [cell.img_view_profileimage addGestureRecognizer:tap];

            //---------------------- Set Profile Pic ---------------------
            NSLog(@"url %@",[arr_receiver_profile objectAtIndex:indexPath.row]);
            if ([arr_receiver_profile objectAtIndex:indexPath.row] != [NSNull null]) {
                NSURL *url = [NSURL URLWithString:[arr_receiver_profile objectAtIndex:indexPath.row]];
                
                NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (data) {
                        UIImage *image = [UIImage imageWithData:data];
                        if (image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                cell.img_view_profileimage.image=image;
                            });
                        }
                    }
                }];
                [task resume];
            }
            }
       
        //----------------------- Set Time -----------------------
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSDate *aDate =[dateFormat dateFromString:[arr_date_time objectAtIndex:indexPath.row]];
        
        NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:aDate];
        NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
        if([today day] == [otherDay day] &&
           [today month] == [otherDay month] &&
           [today year] == [otherDay year] &&
           [today era] == [otherDay era])
        {
            NSLog(@"today");
            NSString *time=[self TodayTimeCalculation:[arr_date_time objectAtIndex:indexPath.row]];
            cell.lbl_timing.text = time;
        }
        else
        {
            NSLog(@"OTHER");
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"dd/MM/yy"];
            NSString *time = [arr_date_time objectAtIndex:indexPath.row];
            NSDate *currDate =[dateFormat dateFromString:time];
            NSString *currentDate = [formatter stringFromDate:currDate];
            cell.lbl_timing.text = [NSString stringWithFormat:@"%@",currentDate];
        }
        
    }
    
    return cell;
    
}

- (void) handleImageTap:(UITapGestureRecognizer *)gestureRecognizer
{
    NSLog(@"imaged tab");
    CGPoint tapLocation = [gestureRecognizer locationInView:_tbl_view_messages_list];
    NSIndexPath *iPath = [_tbl_view_messages_list indexPathForRowAtPoint:tapLocation];
    //NSLog(@"FINAL TAG VALUE %ld",(long)iPath.row);
    ProfileViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    if([[arr_sender_id objectAtIndex:iPath.row] isEqual:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]])
    {
        myVC.follower_id=[arr_receiver_id objectAtIndex:iPath.row];
    }
    else
    {
        myVC.follower_id=[arr_sender_id objectAtIndex:iPath.row];
    }
    [self presentViewController:myVC animated:YES completion:nil];
    
}


-(NSString*)TodayTimeCalculation:(NSString*)PostDate
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    index=indexPath.row;
    [self performSegueWithIdentifier:@"go_to_chatvc" sender:self];
}
/*********************************************************************************/

#pragma mark - Navigation
#pragma mark -
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"go_to_chatvc"]) {
        
        chatViewController *chatVC = [segue destinationViewController];
        chatVC.str_chat_id = [arr_chat_id objectAtIndex:index];
        chatVC.str_receiver_id = [arr_receiver_id objectAtIndex:index];
        chatVC.str_sender_ID = [arr_sender_id objectAtIndex:index];

        chatVC.str_receiver_type = @"message";
        
        if (_isShare_Audio) {
            chatVC.str_file_id =_str_file_id;
            chatVC.str_screen_type = _str_screen_type;
            chatVC.isShare_Audio = _isShare_Audio;
        }
        //-------------------------- For Group Chat --------------------------
        if ([[[arr_response objectAtIndex:index]valueForKey:@"chat_type"] isEqualToString:@"group"]){
            chatVC.isChat_type_Group = YES;
            grp_name = [[arr_response objectAtIndex:index]valueForKey:@"group_name"];
            if ([grp_name isEqualToString:@""]) {
                chatVC.str_GroupName = @"Group";
            }
            else{
                chatVC.str_GroupName = [[arr_response objectAtIndex:index]valueForKey:@"group_name"];

            }
            chatVC.str_GroupImage = [[arr_response objectAtIndex:index]valueForKey:@"group_pick"];
            
            [[NSUserDefaults standardUserDefaults] setValue :[[arr_response objectAtIndex:index]valueForKey:@"group_name"] forKey:@"group_name"];
            
            [[NSUserDefaults standardUserDefaults] setValue :[[arr_response objectAtIndex:index]valueForKey:@"group_pic"] forKey:@"group_pick"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            chatVC.str_receiver_name = [[arr_response objectAtIndex:index]valueForKey:@"group_name"];
        }
        else{
            chatVC.isChat_type_Group = NO;
            chatVC.str_receiver_name = [arr_receiver_name objectAtIndex:index];

        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[arr_chat_id objectAtIndex:index] forKey:@"chat_id"];
        
        if([[arr_receiver_id objectAtIndex:index] isEqual:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]]) {
            [[NSUserDefaults standardUserDefaults] setObject:[arr_sender_id objectAtIndex:index] forKey:@"receiver_id"];

        }
        else
        {
        [[NSUserDefaults standardUserDefaults] setObject:[arr_receiver_id objectAtIndex:index] forKey:@"receiver_id"];
        }
        
        if ([arr_receiver_profile objectAtIndex:index] != [NSNull null]){
        [[NSUserDefaults standardUserDefaults] setObject:[arr_receiver_profile objectAtIndex:index] forKey:@"profilepic"];
        }
    }
}


- (IBAction)btn_back:(id)sender {
    if (_isBack) {
        _isBack = NO;
        UIViewController *vc = self.presentingViewController;
        while (vc.presentingViewController) {
            vc = vc.presentingViewController;
        }
        [vc dismissViewControllerAnimated:YES completion:NULL];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
 
    }
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

- (IBAction)btn_audiofeed:(id)sender {
    [_btn_audiofeed setImage:[UIImage imageNamed:@"btn_audio_feed_bold.png"] forState:UIControlStateNormal];
    [_btn_discover setImage:[UIImage imageNamed:@"btn_discover.png"] forState:UIControlStateNormal];
    [_btn_messenger setImage:[UIImage imageNamed:@"btn_messenger.png"] forState:UIControlStateNormal];
    [_btn_profile setImage:[UIImage imageNamed:@"btn_profile.png"] forState:UIControlStateNormal];
}

- (IBAction)btn_discover:(id)sender {
    [_btn_audiofeed setImage:[UIImage imageNamed:@"btn_audio_feed.png"] forState:UIControlStateNormal];
    [_btn_discover setImage:[UIImage imageNamed:@"btn_discover_bold.png"] forState:UIControlStateNormal];
    [_btn_messenger setImage:[UIImage imageNamed:@"btn_messenger.png"] forState:UIControlStateNormal];
    [_btn_profile setImage:[UIImage imageNamed:@"btn_profile.png"] forState:UIControlStateNormal];
}

- (IBAction)btn_messenger:(id)sender {
    [_btn_audiofeed setImage:[UIImage imageNamed:@"btn_audio_feed.png"] forState:UIControlStateNormal];
    [_btn_discover setImage:[UIImage imageNamed:@"btn_discover.png"] forState:UIControlStateNormal];
    [_btn_messenger setImage:[UIImage imageNamed:@"btn_messenger_bold.png"] forState:UIControlStateNormal];
    [_btn_profile setImage:[UIImage imageNamed:@"btn_profile.png"] forState:UIControlStateNormal];
}

- (IBAction)btn_profile:(id)sender {
    [_btn_audiofeed setImage:[UIImage imageNamed:@"btn_audio_feed.png"] forState:UIControlStateNormal];
    [_btn_discover setImage:[UIImage imageNamed:@"btn_discover.png"] forState:UIControlStateNormal];
    [_btn_messenger setImage:[UIImage imageNamed:@"btn_messenger.png"] forState:UIControlStateNormal];
    [_btn_profile setImage:[UIImage imageNamed:@"btn_profile_bold.png"] forState:UIControlStateNormal];
}
-(void)go_to_chat:(id)sender
{
//    NSLog(@"hi");
    [self performSegueWithIdentifier:@"go_to_chatvc" sender:self];
}



-(void)loadRecentConversession
{
    
    if([[MyManager sharedManager] isInternetAvailable])
    {
        [KSToastView ks_showToast:@"Internet connectivity issue" delay:0.1f];
        return;
    }
    [Appdelegate showProgressHud];
    NSDictionary* params = @{
                             KEY_AUTH_KEY:KEY_AUTH_VALUE,
                             @"userid" : [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]
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
    //userconversation1.php is for Testing pupose
    NSString* urlString = [NSString stringWithFormat:@"%@userconversation.php",BaseUrl];//UserConversation.php
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(error)
        {
            [Appdelegate hideProgressHudInView];
            if([[MyManager sharedManager] isInternetAvailable])
            {
                [KSToastView ks_showToast:@"Internet connectivity issue" delay:0.1f];
                return;
            }
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
                arr_response=[[NSMutableArray alloc]init];
                NSLog(@"%@",jsonResponse);
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    [Appdelegate hideProgressHudInView];

                    arr_response=[jsonResponse objectForKey:@"response"];
                    if ( arr_response.count > 0){
                        _tbl_view_messages_list.hidden = NO;
                        self.noConversationLbl.hidden = YES;
                        
                    arr_receiver_name=[[NSMutableArray alloc]init];
                    arr_receiver_id=[[NSMutableArray alloc]init];
                    arr_chat_id=[[NSMutableArray alloc]init];
                    arr_receiver_profile=[[NSMutableArray alloc]init];
                    arr_receiver_msg=[[NSMutableArray alloc]init];
                    arr_date_time=[[NSMutableArray alloc]init];
                    arr_isread=[[NSMutableArray alloc]init];
                    arr_sender_id=[[NSMutableArray alloc]init];
                    arr_sender_name=[[NSMutableArray alloc]init];
                    int i;
                    for (i=0; i<[arr_response count]; i++) {
                        [arr_sender_id insertObject:[[arr_response objectAtIndex:i] objectForKey:@"senderID"] atIndex:i];
                        [arr_sender_name insertObject:[[arr_response objectAtIndex:i] objectForKey:@"sender_name"] atIndex:i];
                        [arr_receiver_name insertObject:[[arr_response objectAtIndex:i] objectForKey:@"receiver_name"] atIndex:i];
                        [arr_receiver_id insertObject:[[arr_response objectAtIndex:i] objectForKey:@"receiverID"] atIndex:i];
                        [arr_receiver_profile insertObject:[[arr_response objectAtIndex:i] objectForKey:@"profilePick"] atIndex:i];
                        [arr_receiver_msg insertObject:[[arr_response objectAtIndex:i] objectForKey:@"message"] atIndex:i];
                        [arr_chat_id insertObject:[[arr_response objectAtIndex:i] objectForKey:@"chatID"] atIndex:i];
                        [arr_date_time insertObject:[[arr_response objectAtIndex:i] objectForKey:@"sendat"] atIndex:i];
                        [arr_isread insertObject:[[arr_response objectAtIndex:i] objectForKey:@"isread"] atIndex:i];
                        
                    }
                        self.img_placeholderNoConversation.hidden = YES;
                    [_tbl_view_messages_list reloadData];
                    }
                    
                    else{
                        self.img_placeholderNoConversation.hidden = NO;
                        _tbl_view_messages_list.hidden = YES;
                        self.noConversationLbl.hidden = NO;
                    }
                }
                else
                {
                    [Appdelegate hideProgressHudInView];
                    self.img_placeholderNoConversation.hidden = NO;

                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                        [Appdelegate hideProgressHudInView];

                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"Alert"
                                                      message:@"Unable to load users!"
                                                      preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* yesButton = [UIAlertAction
                                                    actionWithTitle:@"ok"
                                                    style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action)
                                                    {
                                                        //Handel your yes please button action here
                                                    [Appdelegate hideProgressHudInView];

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

- (IBAction)btn_invite:(id)sender{
    contactsViewController *contactVC = [self.storyboard instantiateViewControllerWithIdentifier:@"contactsViewController"];
    contactVC.str_file_id = _str_file_id;
    contactVC.isShare_Audio = _isShare_Audio;
    contactVC.str_screen_type = _str_screen_type;
    [contactVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:contactVC animated:YES completion:nil];

}



@end
