 //
//  MelodyPackCommentsViewController.m
//  melody
//
//  Created by coding Brains on 22/02/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import "MelodyPackCommentsViewController.h"
#import "MelodyPackCommentTableViewCell.h"
#import "CommentMessegesTableViewCell.h"
#import "Constant.h"


@interface MelodyPackCommentsViewController ()<UITextFieldDelegate>
{
    CGSize keyboardSize;
    NSTimer *sliderTimer;
    BOOL isplay;
    NSMutableArray *soundsArray;
    long fileSize,instrument_play_index;
    NSData *tempData;
    NSMutableArray *melodyUrlArrayURLM;
    UIActivityViewController *activityController;

}
@end

@implementation MelodyPackCommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    text_flag=0;
    // Do any additional setup after loading the view.
     defaults_userdata=[NSUserDefaults standardUserDefaults];
    isplay = NO;
    _tbl_melodypack_comments.separatorColor = [UIColor clearColor];
    //_tbl_view_comments.backgroundColor = [UIColor clearColor];
    text_flag=0;
    _tf_comment.delegate=self;
    [_tf_comment addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    NSLog(@"%@",_dic_data);
    // hides the index
    like_count=[[NSString alloc]init];
    like_count=[_dic_data objectForKey:@"likescounts"];
    play_count=[[NSString alloc]init];;
        play_count=[_dic_data objectForKey:@"playcounts"];
    like_status=[[NSString alloc]init];
    like_status=[_dic_data objectForKey:@"like_status"];
    _tbl_melodypack_comments.sectionIndexMinimumDisplayRowCount = NSIntegerMax;
    soundsArray = [NSMutableArray new];
    fileSize = 0;
    tempData = 0;

}




-(void)dismissKeyboard
{
    [_tf_comment resignFirstResponder];
    
}


- (void)viewWillAppear:(BOOL)animated {
    @try{
    
    NSArray *melodyUrlArray=[[NSArray alloc]init];
    melodyUrlArray = [_dic_data valueForKey:@"instruments"];
    melodyUrlArrayURLM=[[NSMutableArray alloc]init];
    for (int i=0; i<melodyUrlArray.count; i++) {
        NSString *strUrl = [[melodyUrlArray objectAtIndex:i]valueForKey:@"instrument_url"];
        [melodyUrlArrayURLM addObject:strUrl];
    }
   
   
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
    
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

-(void)viewDidDisappear:(BOOL)animated{
    if (audioPlayer.isPlaying) {
        [self stopPlay];
        soundsArray = [NSMutableArray new];
    }
    [sliderTimer invalidate];
}



#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view_comment.frame;
        f.origin.y = self.view.frame.size.height-(keyboardSize.height+49);
        [_tbl_melodypack_comments setFrame:CGRectMake(_tbl_melodypack_comments.frame.origin.x, _tbl_melodypack_comments.frame.origin.y, _tbl_melodypack_comments.frame.size.width, _tbl_melodypack_comments.frame.size.height-(keyboardSize.height))];
        self.view_comment.frame = f;
        
    }];
    
//    self.tbl_melodypack_comments.contentSize = CGSizeMake(0,[arr_comment_id count]*127+150+keyboardSize.height+self.view_comment.frame.size.height);
//    self.tbl_melodypack_comments.scrollEnabled=YES;
}



-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view_comment.frame;
        f.origin.y = self.view.frame.size.height-49;
        [_tbl_melodypack_comments setFrame:CGRectMake(_tbl_melodypack_comments.frame.origin.x, _tbl_melodypack_comments.frame.origin.y, _tbl_melodypack_comments.frame.size.width, _tbl_melodypack_comments.frame.size.height+(keyboardSize.height))];
        self.view_comment.frame = f;
    }];
    
    
//    self.tbl_melodypack_comments.contentSize = CGSizeMake(0,[arr_comment_id count]*127+150+self.view_comment.frame.size.height);

}


-(void)textFieldDidChange:(UITextField *)theTextField{
    NSLog( @"text changed: %@", _tf_comment.text);
    if ([_tf_comment.text length]>0) {
        text_flag=1;
        [_btn_send setTitle:@"Send" forState:UIControlStateNormal];
    }else{
        text_flag=0;
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"Working!!!");
    [_tf_comment resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate & DataSource
#pragma mark -

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
        return 190;
    }
    else
    {
//        CGSize labelHeight = [self heigtForCellwithString:_tf_comment.text   withFont:_tf_comment.font];
//        return labelHeight.height; // the return height + your other view height
        return 127;
    }
}
//    -(CGSize)heigtForCellwithString:(NSString *)stringValue withFont:(UIFont*)font{
//        CGSize constraint = CGSizeMake(70,9999); // Replace 300 with your label width
//        NSDictionary *attributes = @{NSFontAttributeName: font};
//        CGRect rect = [stringValue boundingRectWithSize:constraint
//                                                options:         (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
//                                             attributes:attributes
//                                                context:nil];
//        return rect.size;
//        
//    }
//
//-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//
//   return UITableViewAutomaticDimension;
//    
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0) {
        MelodyPackCommentTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"MelodyComment"];
        if (cell == nil)
            
        {
            NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"MelodyPackCommentTableViewCell"
                             
                                                          owner:self options:nil];
            cell.accessoryType = UITableViewCellStyleDefault;
            
            cell = (MelodyPackCommentTableViewCell*)[nib2 objectAtIndex:0];
        }
        
        
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.slider_progress setMinimumTrackImage:[UIImage imageNamed:@"blue_bar.png"] forState:UIControlStateNormal];
            [cell.slider_progress setMaximumTrackImage:[UIImage imageNamed:@"black_bar.png"] forState:UIControlStateNormal];
            [cell.slider_progress setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateNormal];
            [cell.slider_progress setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateFocused];
            cell.img_profile.layer.cornerRadius = cell.img_profile.frame.size.width / 2;
             cell.img_profile.clipsToBounds = YES;

            cell.btn_play_pause.tag=indexPath.row;
            [cell.btn_play_pause addTarget:self action:@selector(btn_playpause_clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btn_add_melody_pack.tag=indexPath.row;
            [cell.btn_add_melody_pack addTarget:self action:@selector(btn_add_clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btn_play.tag=indexPath.row;
            [cell.btn_play addTarget:self action:@selector(btn_play_clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btn_like.tag=indexPath.row;
            [cell.btn_like addTarget:self action:@selector(btn_like_clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            
            cell.btn_comment.tag=indexPath.row;
            [cell.btn_comment addTarget:self action:@selector(btn_Melodypackcomment_clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btn_share.tag=indexPath.row;
            [cell.btn_share addTarget:self action:@selector(openshare:) forControlEvents:UIControlEventTouchUpInside];
            if ([[_dic_data objectForKey:@"cover"] length]>6) {
               // NSURL *url = [NSURL URLWithString:[_dic_data objectForKey:@"cover"]];
                
                NSString *imageCoverUrlString = [_dic_data objectForKey:@"cover"];
                NSString *encodedCoverImageUrlString = [imageCoverUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURL *url = [NSURL URLWithString: encodedCoverImageUrlString];
                
                NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (data) {
                        UIImage *image = [UIImage imageWithData:data];
                        if (image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                cell.img_view_cover.image=image;
                                
                            });
                        }
                    }
                }];
                [task resume];
            }
           
            if ([[_dic_data objectForKey:@"profilepic"] length]>6)
            {
              //  NSURL *url2 = [NSURL URLWithString:[_dic_data objectForKey:@"profilepic"]];
                NSString *imageProfileUrlString = [_dic_data objectForKey:@"profilepic"];
                NSString *encodedProfileImageUrlString = [imageProfileUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURL *url2 = [NSURL URLWithString: encodedProfileImageUrlString];
                
                NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:url2 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (data) {
                        UIImage *image = [UIImage imageWithData:data];
                        if (image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                cell.img_profile.image=image;                                    });
                        }
                    }
                }];
                [task2 resume];
                
            }
           
            if ([like_status isEqual:@"1"]) {
                [cell.btn_like setBackgroundImage:[UIImage imageNamed:@"btn_hand_fill.png"] forState:UIControlStateNormal];
            }
            else{
                [cell.btn_like setBackgroundImage:[UIImage imageNamed:@"btn_hand_outline.png"] forState:UIControlStateNormal];
            }

            cell.lbl_pack_title.text=[_dic_data objectForKey:@"name"];
            cell.lbl_pack_username.text=[NSString stringWithFormat:@"%@",[_dic_data objectForKey:@"username"]];
            cell.lbl_genre.text=[NSString stringWithFormat:@"Genre : %@",[_dic_data objectForKey:@"genre_name"]];
            cell.lbl_timer.textAlignment=NSTextAlignmentRight;
            //cell.lbl_date.text=[_dic_data objectForKey:@"date"];
            cell.lbl_timer.text =[Appdelegate timeFormatted:[_dic_data objectForKey:@"duration"]];
            cell.lbl_date.textAlignment=NSTextAlignmentRight;
            NSString *tempDate =[_dic_data objectForKey:@"date"];
            if (tempDate.length >0) {
                cell.lbl_date.text=[Appdelegate formatDateWithString:tempDate];
            }
            cell.lbl_bpm.text=[NSString stringWithFormat:@"BPM : %@",[_dic_data objectForKey:@"bpm"]];
            if ([[_dic_data objectForKey:@"instruments"] count]==1) {
                cell.lbl_no_of_instrumentals.text=[NSString stringWithFormat:@"1 Instrumental"];
            }
            else
            {
                cell.lbl_no_of_instrumentals.text=[NSString stringWithFormat:@"%lu Instrumentals",[[_dic_data objectForKey:@"instruments"] count]];
            }
            [cell.btn_play_count setTitle:[NSString stringWithFormat:@"%@",play_count] forState:UIControlStateNormal];
            
          //  [cell.btn_comment_count setTitle:[NSString stringWithFormat:@"%@",[_dic_data objectForKey:@"commentscounts"]] forState:UIControlStateNormal];
            [cell.btn_comment_count setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)[arr_comment_id count]] forState:UIControlStateNormal];
            [cell.btn_share_count setTitle:[NSString stringWithFormat:@"%@",[_dic_data objectForKey:@"sharecounts"]] forState:UIControlStateNormal];
            [cell.btn_like_count setTitle:like_count forState:UIControlStateNormal];
        
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
            cell.tv_comment.editable=NO;
            cell.tv_comment.showsVerticalScrollIndicator=YES;
            cell.lbl_name.text=[arr_user_name objectAtIndex:indexPath.row];
            cell.lbl_user_name.text=[NSString stringWithFormat:@"@%@",[arr_user_username objectAtIndex:indexPath.row]];
            cell.lbl_name.text=[arr_user_name objectAtIndex:indexPath.row];
            //cell.lbl_time.text=[arr_comment_timedate objectAtIndex:indexPath.row];
            cell.lbl_time.textAlignment=NSTextAlignmentRight;
             NSString *tempDate=[arr_comment_timedate objectAtIndex:indexPath.row];
            if (tempDate == nil || tempDate.length >0) {
                cell.lbl_time.text=[Appdelegate TodayTimeCalculation:tempDate];
            }
            if ([[arr_user_profile_pic objectAtIndex:indexPath.row] length]>6)
            {
                NSURL *url2 = [NSURL URLWithString:[arr_user_profile_pic objectAtIndex:indexPath.row]];
                
                NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:url2 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (data) {
                        UIImage *image = [UIImage imageWithData:data];
                        if (image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
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
                                    [params setObject:[_dic_data objectForKey:@"melodypackid"] forKey:@"file_id"];
                                    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"user_id"];
                                    [params setObject:[arr_comment_id objectAtIndex:sender.tag] forKey:@"comment_id"];
                                    [params setObject:@"admin_melody" forKey:KEY_SHARE_FILETYPE];
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
                                                    [arr_comment_id removeObjectAtIndex:sender.tag];
                                                    [arr_text removeObjectAtIndex:sender.tag];
                                                    [arr_user_profile_pic removeObjectAtIndex:sender.tag];
                                                    [arr_user_id removeObjectAtIndex:sender.tag];
                                                    [arr_user_name removeObjectAtIndex:sender.tag];
                                                    [arr_user_username removeObjectAtIndex:sender.tag];
                                                    
                                                    [_tbl_melodypack_comments reloadData];
                                                    
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
    [_tbl_melodypack_comments reloadData];

    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
  }
//btn_add_clicked

-(void)btn_add_clicked:(UIButton*)sender
{
    
}
#pragma mark - Play Action
#pragma mark -

-(void)btn_playpause_clicked:(UIButton*)sender
{
      @try{
    instrument_play_index = sender.tag;
    MelodyPackCommentTableViewCell *cell = [_tbl_melodypack_comments cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if(audioPlayer)
    {
        if (audioPlayer.isPlaying) {
            [cell.btn_play_pause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
            [self pausePlay];
        }
        else{
            [cell.btn_play_pause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
            [self allPlay];
            
        }
    }
    else
    {
        soundsArray = [[NSMutableArray alloc]init];
        [Appdelegate showProgressHud];
        [cell.btn_play_pause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
        dispatch_queue_t myqueue = dispatch_queue_create("queue", NULL);
        dispatch_async(myqueue, ^{
            for (int i=0; i<melodyUrlArrayURLM.count; i++) {
                NSString *strUrl = [melodyUrlArrayURLM objectAtIndex:i];
                [self addPlayerObjects:strUrl index:i];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if([defaults_userdata boolForKey:@"isUserLogged"]) {
                    [self play_count];
                }
                
                audioPlayer = [soundsArray objectAtIndex:fileSize];
                sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerupdateSlider) userInfo:nil repeats:YES];
                cell.slider_progress.maximumValue=[audioPlayer duration];
                cell.slider_progress.minimumValue=0.0;
                
                for (audioPlayer in soundsArray){
                    audioPlayer.delegate=self;
                    [cell.slider_progress addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
                    cell.slider_progress.tag = instrument_play_index;
                    [Appdelegate hideProgressHudInView];
                    [audioPlayer play];
                }
                
            });
        });

    }
      }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}


-(void)play_count
{
    
    @try{
        
    arr_melody_instrumentals_path=[[NSMutableArray alloc]init];
    for (int a=0; a<[[_dic_data objectForKey:@"instruments"] count]; a++) {
        [arr_melody_instrumentals_path addObject:[[[_dic_data objectForKey:@"instruments"] objectAtIndex:a] valueForKey:@"instrument_url"] ];
    }
    if ([arr_melody_instrumentals_path count]>0) {
        
        NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
        [params setObject:[_dic_data objectForKey:@"melodypackid"] forKey:@"fileid"];
        [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
        [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:@"userid"];
        [params setObject:@"melody" forKey:@"type"];
        if ([_isFromMelody isEqualToString:@"USER"])
        {
            [params setObject:@"user" forKey:@"user_type"];
        }
        else
        {
            [params setObject:@"admin" forKey:@"user_type"];
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
        NSString* urlString = [NSString stringWithFormat:@"%@playcount.php",BaseUrl];
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
                        long a=[[_dic_data objectForKey:@"playcounts"] integerValue]+1;
                        play_count=[NSNumber numberWithLong:a];
                        [_tbl_melodypack_comments reloadData];
                        
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
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}



//Modified playSound method
-(void)addPlayerObjects:(NSString*)urlStr index:(long)index
{
    @try{
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSURL *urlforPlay = [NSURL URLWithString:urlStr];
        NSData *data = [NSData dataWithContentsOfURL:urlforPlay];
        
        if (data.length > tempData.length) {
            fileSize = index;
            tempData = data;
        }
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
        [soundsArray addObject:audioPlayer];
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception at adding recording :%@",exception);
    }
    @finally{
    }
}

-(void)stopPlay{
    
    
    for (AVAudioPlayer *audio in soundsArray){
        MelodyPackCommentTableViewCell *cell = [_tbl_melodypack_comments cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.slider_progress.value = 0.0;
        [cell.btn_play_pause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
        [audio stop];
    }
}

-(void)allPlay{
    
    for (AVAudioPlayer *audio in soundsArray){
        MelodyPackCommentTableViewCell *cell = [_tbl_melodypack_comments cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.slider_progress.value = 0.0;
        [audio play];
    }
}

-(void)pausePlay{
    
    
    for (AVAudioPlayer *audio in soundsArray){
        MelodyPackCommentTableViewCell *cell = [_tbl_melodypack_comments cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.slider_progress.value = 0.0;
        [audio pause];
        
    }
}



#pragma mark - END

#pragma mark - Audio Player Delegate Method
#pragma mark -

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    MelodyPackCommentTableViewCell *cell = [_tbl_melodypack_comments cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.btn_play_pause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
    audioPlayer = nil;
    
    cell.slider_progress.value = 0.0;
    [sliderTimer invalidate];
    sliderTimer = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@" player error description %@",error);
}

#pragma mark - END


-(void)btn_like_clicked:(UIButton*)sender
{
    @try{
    if ([like_status isEqual:@"1"]) {
        like_status=@"0";
    }
    else{
    like_status=@"1";
    }
    
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:[_dic_data objectForKey:@"melodypackid"] forKey:@"file_id"];
    [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:@"user_id"];
    [params setObject:like_status forKey:@"likes"];
//    [params setObject:@"admin_melody" forKey:@"type"];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    [params setObject:[_dic_data objectForKey:@"name"] forKey:@"topic"];
        if ([_isFromMelody isEqualToString:@"USER"])
        {
            [params setObject:@"user_melody" forKey:@"type"];
        }
        else
        {
            [params setObject:@"admin_melody" forKey:@"type"];
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
                    like_count=[dic_response objectForKey:@"likes"];
                
                    [_tbl_melodypack_comments reloadData];
                    
                }
                else
                {
                    if([like_status isEqual:@"1"])
                    {
                    like_status=@"0";
                    }
                    else
                    {
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




-(void)btn_share_clicked:(UIButton*)sender
{
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    NSUserDomainMask, YES)objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"sound.wav"];//Audio file
    
    NSURL *fileUrl     = [NSURL fileURLWithPath:filePath isDirectory:NO];
    NSArray *activityItems = @[fileUrl];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
    

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
                                        myVC.str_file_id = [_dic_data valueForKey:@"melodypackid"];
                                        myVC.str_screen_type = @"melody";
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
                                       // NSString *text = @"hello";
                                       // NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[arr_rec_thumbnail_url objectAtIndex:i_Path]]];
                                       //UIImage *image = [UIImage imageNamed:@"socialsharing-facebook-image.jpg"];
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
                                           //        [controller addURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[arr_rec_thumbnail_url objectAtIndex:i_Path]]]];
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


- (IBAction)btn_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)btn_home:(id)sender {

    UIViewController *vc = self.presentingViewController;
   
    [vc dismissViewControllerAnimated:YES completion:NULL];
    
}


- (IBAction)btn_melodypack:(id)sender {
}
- (IBAction)btn_send:(id)sender {
    if (text_flag==0) {
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self.view_comment.frame;
            f.origin.y = self.view.frame.size.height-49;
            self.view_comment.frame = f;
           
            [_tf_comment resignFirstResponder];
        }];
//        [self dismissViewControllerAnimated:YES completion:nil];
        [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];

    }
    else
    {

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        text_flag=0;
        [self callcommentapi];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [_tbl_melodypack_comments setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        });
        [_btn_send setTitle:@"Cancel" forState:UIControlStateNormal];
        
    }

}
-(void)callcommentapi
{
    
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:[_dic_data objectForKey:@"melodypackid"] forKey:@"file_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"user_id"];
    [params setObject:_tf_comment.text forKey:@"comment"];

    if ([_isFromMelody isEqualToString:@"USER"])
    {
        [params setObject:@"user_melody" forKey:KEY_SHARE_FILETYPE];
    }
    else
    {
        [params setObject:@"admin_melody" forKey:KEY_SHARE_FILETYPE];
    }    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    [params setObject:[_dic_data objectForKey:@"name"] forKey:@"topic"];
    

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
            //do something
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
                    _tf_comment.text=nil;
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
                    
                    [self callcommentlistapi];
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"updateCommentsMelody"
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
    [params setObject:[_dic_data objectForKey:@"melodypackid"] forKey:@"file_id"];

    if ([_isFromMelody isEqualToString:@"USER"])
    {
        [params setObject:@"user_melody" forKey:KEY_SHARE_FILETYPE];
    }
    else
    {
        [params setObject:@"admin_melody" forKey:KEY_SHARE_FILETYPE];
    }
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
            //do something
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
                     [_tbl_melodypack_comments reloadData];
                }
                else
                {
                    [Appdelegate hideProgressHudInView];
                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {

                    }
                }
            });
        }
    }];
    [task resume];
    
}


-(void)sliderChanged
{
    
    MelodyPackCommentTableViewCell *cell = [_tbl_melodypack_comments cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [audioPlayer setCurrentTime:cell.slider_progress.value];
    
}
-(void)timerupdateSlider{
    
    @try{
    // Update the slider about the music time
    NSLog(@"fileSize %ld",fileSize);
    audioPlayer = [soundsArray objectAtIndex:fileSize];
    
    MelodyPackCommentTableViewCell *cell = [_tbl_melodypack_comments cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentSoundsIndex inSection:0]];
    cell.slider_progress.value = audioPlayer.currentTime;
}
@catch (NSException *exception) {
    NSLog(@"exception at likes.php :%@",exception);
}
@finally{
    
}
}

@end
