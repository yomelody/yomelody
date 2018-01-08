    //
//  StudioPlayViewController.m
//  melody
//
//  Created by CodingBrainsMini on 11/29/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import "StudioPlayViewController.h"
#import "CollectionViewCell.h"
#import "Constant.h"
#import "InstrumentalTableViewCell.h"
#import <AudioUnit/AudioUnit.h>
#import <CoreAudioKit/CoreAudioKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AudioFeedCommentsViewController.h"
#import "CommentMessegesTableViewCell.h"
#import "StudioRecViewController.h"
#import "ProfileViewController.h"
#import "contactsViewController.h"

@interface StudioPlayViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,AVAudioPlayerDelegate>
{
    NSInteger _numberOfCells;
    long instrument_play_index;
    long lastIndexvalue;
    BOOL toggle_PlayPause;
    int instrument_play_status;
    BOOL btn_m_isOn;
    BOOL btn_s_isOn;
    NSMutableArray *arr_joinedUserM;
    NSMutableArray *arr_instrumentsM;
    NSMutableArray*dic_response;
    long currentIndex_user;

    NSString*like_count;
    NSString*play_count;
    NSString*share_count;
    AVAudioPlayer *audioPlayer_user;
    BOOL isBtnPLay;
    BOOL isCommentScreen,toggle_include;
    float actualHeight;
    UIActivityViewController *activityController;
    NSString* likeStaus;
    NSInteger currentIndexValue;
    NSMutableString* str_RecName;
    NSMutableString* str_RecDate;
    NSTimer* sliderTimer;
    long joinedUser;
    BOOL isPlayAll,isHeadphoneON,isAllAudioPlaying;
    BOOL isPlayable;

    NSMutableArray *soundsArray;
    NSMutableArray*arr_instrument_ids;
    NSMutableArray*arr_instrument_paths;
    NSString *parentUserID;
    NSTimer *timer;
    NSInteger seconds,totalSeconds,minutes,hours;
    NSString*resulttimer;
    NSInteger currentJoinedUserDuration;
}
@end


@implementation StudioPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeAll_varibles];
    [self joinedUser];
   
}


-(void)initializeAll_varibles{
    
    self.view_Comment.hidden = YES;
    self.view_Bottom.hidden =NO;
    isPlayable = NO;
    lastIndexvalue = 10000;
    toggle_PlayPause = NO;
    _numberOfCells=8;
    btn_m_isOn=NO;
    btn_s_isOn=NO;
    self.tbl_Instrument.hidden = YES;
    toggle_include = NO;
    isAllAudioPlaying = NO;
    _btn_PlayAll.enabled = NO;

    arr_joinedUserM = [[NSMutableArray alloc]init];
    arr_instrumentsM = [[NSMutableArray alloc]init];

    self.img_profile.layer.cornerRadius = self.img_profile.frame.size.width / 2;
    self.img_profile.clipsToBounds = YES;
    
    defaults_userdata = [NSUserDefaults standardUserDefaults];
    [defaults_userdata setObject:[NSNumber numberWithInt:99999] forKey:@"index_currentUser"];
    
    self.view_fxeq.hidden=YES;
   
    _col_view_profiles.showsHorizontalScrollIndicator=NO;
    isBtnPLay = NO;
    
    self.btn_currentUsrProfile.layer.cornerRadius=self.btn_currentUsrProfile.frame.size.width/2;
    self.btn_currentUsrProfile.clipsToBounds = YES;
    
    isCommentScreen = NO;

    
    NSString * str_likeVal = [[NSString alloc]init];
    str_likeVal = [defaults_userdata valueForKey:@"like_status"];

    if ([str_likeVal isEqual:@"1"]) {
        [_btn_like setBackgroundImage:[UIImage imageNamed:@"btn_hand_fill.png"] forState:UIControlStateNormal];
    }
    else{
        [_btn_like setBackgroundImage:[UIImage imageNamed:@"btn_hand_outline.png"] forState:UIControlStateNormal];
    }
    
    
    //-------------------- TextField ---------------------
    _tf_addcomment.delegate=self;
    [_tf_addcomment addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.coverImageView addGestureRecognizer:tap];
    soundsArray = [NSMutableArray new];
    [sliderTimer invalidate];
    sliderTimer = nil;
    arr_instrument_ids=[[NSMutableArray alloc]init];
    arr_instrument_paths=[[NSMutableArray alloc]init];
    
}

#pragma mark - EZ Audio PLayer
#pragma mark -
-(void)initializesEZAudio
{
    
    // Customizing the audio plot's look
    self.view_wave.plotType        = EZPlotTypeBuffer;
    self.view_wave.shouldFill      = NO;
    self.view_wave.shouldMirror    = NO;
    [self.player_wave setVolume:5];
    // Create the audio player
    self.player_wave = [EZAudioPlayer audioPlayerWithDelegate:self];
    [self setupNotificationsForPlay];
    
}

- (void)setupNotificationsForPlay
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeAudioFile:)
                                                 name:EZAudioPlayerDidChangeAudioFileNotification
                                               object:self.player_wave];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangeOutputDevice:)
                                                 name:EZAudioPlayerDidChangeOutputDeviceNotification
                                               object:self.player_wave];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidChangePlayState:)
                                                 name:EZAudioPlayerDidChangePlayStateNotification
                                               object:self.player_wave];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidReachEndOfFile:)
                                                 name:EZAudioPlayerDidReachEndOfFileNotification
                                               object:self.player_wave];
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangeAudioFile:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player changed audio file: %@", [player audioFile]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangeOutputDevice:(NSNotification *)notification
{
    EZAudioPlayer *player = [notification object];
    NSLog(@"Player changed output device: %@", [player device]);
}

//------------------------------------------------------------------------------

- (void)audioPlayerDidChangePlayState:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        EZAudioPlayer *player = [notification object];
        BOOL isPlaying = [player isPlaying];
        if (isPlaying)
        {
        }
        _view_wave.hidden = !isPlaying;
    });
}

- (void)playerDidReachEndOfFile:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_view_wave clear];
    });
}






- (void)openFileWithFilePathURL:(NSURL *)filePathURL
{
    @try{
    _audioFile = [EZAudioFile audioFileWithURL:filePathURL];
    _view_wave.plotType = EZPlotTypeBuffer;
    _view_wave.shouldFill = NO;
    _view_wave.shouldMirror = NO;
    __weak typeof (self) weakSelf = self;
    [self.audioFile getWaveformDataWithCompletionBlock:^(float **waveformData,
                                                         int length)
     {
         [weakSelf.view_wave updateBuffer:waveformData[0]
                           withBufferSize:length];
     }];
    
    // Play the audio file
    [_player_wave setAudioFile:_audioFile];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}

#pragma mark - End


-(void)dismissKeyboard
{
    [_tf_addcomment resignFirstResponder];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self joinedUser];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    
}
- (void)viewDidAppear:(BOOL)animated {
    [self callcommentlistapi];
}

-(void)viewDidDisappear:(BOOL)animated{
    [sliderTimer invalidate];
    [timer invalidate];
}

-(void)joinedUser
{
    [Appdelegate showProgressHud];
    NSDictionary* params = @{
            @"userid": self.str_CurrernUserId,
            KEY_AUTH_KEY: KEY_AUTH_VALUE,
            @"rid": self.str_RecordingId
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
    NSString* urlString = [NSString stringWithFormat:@"%@joined_users.php",BaseUrl];
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
                dic_response=[[NSMutableArray alloc]init];
                NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSLog(@"%@",requestReply);
                NSData *data = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                              options:kNilOptions
                                              error:&myError];
                
                NSLog(@"%@",jsonResponse);
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    [Appdelegate hideProgressHudInView];
                    dic_response=[jsonResponse objectForKey:@"response"];
                    NSLog(@"%@",dic_response);
                    parentUserID = [[dic_response objectAtIndex:0]valueForKey:@"user_id"];
                    currentIndex_user = 0;
                    joinedUser = [[[dic_response objectAtIndex:0] valueForKey:@"joined_artists"]longValue];
                    _lbl_currentUserCount.text = [NSString stringWithFormat:@"( %ld of %ld )",currentIndex_user+1,joinedUser];
                    if (([[dic_response objectAtIndex:0] valueForKey:@"instruments"]) != [NSNull null]){
                        self.tbl_Instrument.hidden = NO;
                    }
                       //----------------- Set Current User Data * ---------------
                    self.lbl_currentUsrName.text = [[dic_response objectAtIndex:0] valueForKey:@"user_name"];
       
                    self.lbl_title.text=[NSString stringWithFormat:@"%@",[[dic_response objectAtIndex:0] valueForKey:@"recording_name"]];
                    self.lbl_subTitle.text=[NSString stringWithFormat:@"@%@",[[dic_response objectAtIndex:0] valueForKey:@"user_name"]];
                    
                    [_btn_include setTitle:[NSString stringWithFormat:@"Included :%ld",(unsigned long)dic_response.count] forState:UIControlStateNormal];
                    if (isiPhone5) {
                         _btn_include.titleLabel.font=[UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
                    }
                    //==============new set data=============
                    _lbl_dateStr.text=[Appdelegate formatDateWithString:[[dic_response objectAtIndex:0] valueForKey:@"recording_date"]];
                    _lbl_duration.textAlignment=NSTextAlignmentRight;
                    _lbl_dateStr.textAlignment=NSTextAlignmentRight;
//                    _lbl_duration.text=[Appdelegate timeFormatted:[[dic_response objectAtIndex:0] valueForKey:@"recording_duration"]];
                    _lbl_duration.text=@"00:00";
                    _lbl_joindate.text=[Appdelegate formatDateWithString:[[dic_response objectAtIndex:0] valueForKey:@"recording_date"]];
                    
                    //----------------- Play Count * ---------------
                        if([[dic_response objectAtIndex:0] valueForKey:@"play_counts"] != [NSNull null]){
                           self.lbl_PlayCount.text = [[dic_response objectAtIndex:0] valueForKey:@"play_counts"];
                        }

                        //----------------- Like Count * ---------------
                          if([[dic_response objectAtIndex:0] valueForKey:@"like_counts"] != [NSNull null]){
                        self.lbl_LikeCount.text = [[dic_response objectAtIndex:0] valueForKey:@"like_counts"];
                          }

                        str_RecName = [[dic_response objectAtIndex:0] valueForKey:@"recording_name"];
                         str_RecDate = [[dic_response objectAtIndex:0] valueForKey:@"recording_date"];
                    
                       //----------------- Like Status * ---------------

                        likeStaus = [[dic_response objectAtIndex:0] valueForKey:@"like_status"];

                        long like_val = [likeStaus longLongValue];
                        NSString * str_likeVal = [[NSString alloc]init];
                        
                        //
                        if (like_val == 0) {
                            str_likeVal = @"0";
                        }
                        else{
                            str_likeVal = @"1";
                        }
                        [defaults_userdata setObject:str_likeVal forKey:@"like_staus"];

                        //----------------- Comment Count * ---------------
                           if([[dic_response objectAtIndex:0] valueForKey:@"comment_counts"] != [NSNull null]){
                        self.lbl_MsgCount.text = [[dic_response objectAtIndex:0] valueForKey:@"comment_counts"];
                           }

                        //----------------- Share Count * ---------------
                           if([[dic_response objectAtIndex:0] valueForKey:@"share_counts"] != [NSNull null]){
                        self.lbl_ShareCount.text = [[dic_response objectAtIndex:0] valueForKey:@"share_counts"];
                           }

                    
                        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[dic_response objectAtIndex:0] valueForKey:@"profile_pic"]]];
                        
                        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                            if (data) {
                                UIImage *image = [UIImage imageWithData:data];
                                if (image) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self.btn_currentUsrProfile setImage:image forState:UIControlStateNormal];
                                    });
                                }
                            }
                        }];
                        [task resume];

                if ([[dic_response objectAtIndex:0] valueForKey:@"joined"] != [NSNull null]) {
                    arr_joinedUserM = [[dic_response objectAtIndex:0] valueForKey:@"joined"];
                    self.col_view_profiles.delegate = self;
                    self.col_view_profiles.dataSource = self;
                        }

                    if ([[dic_response objectAtIndex:0] valueForKey:@"instruments"] != [NSNull null]) {
                        arr_instrumentsM = [[dic_response objectAtIndex:0] valueForKey:@"instruments"];
                    if ([arr_instrumentsM count]>0) {
                        self.tbl_Instrument.hidden = NO;
                        [self.tbl_Instrument reloadData];
                            [self performSelectorInBackground:@selector(someMethodForLaodData:) withObject:nil];
                        }
                        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
                        [self becomeFirstResponder];
                        
                        self.lbl_instuments_count.text = [NSString stringWithFormat:@"%lu Instrumentals",(unsigned long)arr_instrumentsM.count];
                    }
                    else{
                        self.lbl_instuments_count.text = @"No instrumentals";
                    }
                    
                //---------------------* Profile pic *-----------------------
                NSURL *url_ProfilePic = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[dic_response objectAtIndex:0] valueForKey:@"profile_pic"]]];
                self.img_profile.contentMode = UIViewContentModeScaleToFill;
                        
                [self.img_profile sd_setImageWithURL:url_ProfilePic
                                                    placeholderImage:[UIImage imageNamed:@"artist.png"]];
                
            }
                else
                {
                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                        [Appdelegate hideProgressHudInView];

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



-(void)callcommentlistapi
{
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:_str_RecordingId forKey:@"file_id"];
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
                NSMutableArray*arr_response=[[NSMutableArray alloc]init];
                NSLog(@"%@",jsonResponse);
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {

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
                    [_tbl_Instrument reloadData];
                }
                else
                {
                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                
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
                                    [params setObject:_str_RecordingId forKey:@"file_id"];
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
                                    
                                    //this is how cookies were created
                                    
                                    
                                    NSURLSession* session =[NSURLSession sharedSession];
                                    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
                                    [request setHTTPMethod:@"POST"];
                                    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
                                    [request setHTTPShouldHandleCookies:NO];
                                    
                                    //NSString* Cookie = [NSString stringWithFormat:@"%@=%@",cookie.name,cookie.value];
                                    //[request setValue:Cookie forHTTPHeaderField:@"Cookie"];
                                    // __block NSDictionary* jsonResponse;
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
                                                // NSData *data2=[requestReply dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                                                
                                                
                                                // NSDictionary* jsonObject = [NSJSONSerialization
                                                
                                                //      JSONObjectWithData:data2
                                                //    options:NSJSONReadingAllowFragments error:&myError];
                                                
                                                NSData *data = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
                                                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                                                             options:kNilOptions
                                                                                                               error:&myError];
                                                NSMutableDictionary*dic_response1=[[NSMutableDictionary alloc]init];
                                                NSLog(@"%@",jsonResponse);
                                                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                                                    dic_response1=[jsonResponse objectForKey:@"response"];
                                                    [arr_comment_id removeObjectAtIndex:sender.tag];
                                                    [arr_text removeObjectAtIndex:sender.tag];
                                                    [arr_user_profile_pic removeObjectAtIndex:sender.tag];
                                                    [arr_user_id removeObjectAtIndex:sender.tag];
                                                    [arr_user_name removeObjectAtIndex:sender.tag];
                                                    [arr_user_username removeObjectAtIndex:sender.tag];
                                                    
                                                    [_tbl_Instrument reloadData];
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




-(void)callcommentapi
{
    [Appdelegate showProgressHud];
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:_str_RecordingId forKey:@"file_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"user_id"];
    [params setObject:_tf_addcomment.text forKey:@"comment"];
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
    NSString* urlString = [NSString stringWithFormat:@"%@comments.php",BaseUrl];
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
                        // [_dic_data repla objectForKey:@"commentscounts"]
                        
                        
                    }
                    //                    [_dic_data removeObjectForKey:@"commentscounts"];
                    //
                    //                    [_dic_data setObject:[NSString stringWithFormat:@"%lu",(unsigned long)[arr_user_id count]] forKey:@"commentscounts"];
//                    [_tbl_Instrument reloadData];
                    self.lbl_MsgCount.text=[[jsonResponse objectForKey:@"response"] objectForKey:@"total_count"];
                    [self callcommentlistapi];
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


// This method is used to stop and deallocate audio
-(void)deAllocateAudio{
    if (audioPlayer.isPlaying) {
        [audioPlayer stop];
    }
    if (audioPlayer_user.isPlaying) {
        [audioPlayer_user stop];
    }
    [self stopPlay];
    [sliderTimer invalidate];
    [timer invalidate];
    sliderTimer = nil;
    timer = nil;
    audioPlayer = nil;
    audioPlayer_user= nil;
}


- (IBAction)btn_back:(id)sender {
    [SVProgressHUD dismiss];
    [self deAllocateAudio];
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)btn_home:(id)sender {
    [SVProgressHUD dismiss];
    [self deAllocateAudio];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)btn_InviteAction:(id)sender{
    if ([defaults_userdata boolForKey:@"isUserLogged"]) {
        
        contactsViewController *contactVC = [self.storyboard instantiateViewControllerWithIdentifier:@"contactsViewController"];
        [contactVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:contactVC animated:YES completion:nil];
    }
    
}

#pragma mark - Play Method
#pragma mark -

-(void)someMethodForLaodData:(id)sender{
    [self load_instrumentals];
}

- (void)btn_plaupause_clicked:(UIButton* )sender {
    
    @try{
        instrument_play_index=sender.tag;
        toggle_PlayPause = !toggle_PlayPause;
        InstrumentalTableViewCell *cell = [self.tbl_Instrument cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
        if (audioPlayer && lastIndexvalue == sender.tag) {
            if (audioPlayer.playing && (lastIndexvalue == sender.tag)) {
                [cell.btn_play_pause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                [audioPlayer pause];
            }
            else{
                [cell.btn_play_pause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
                [audioPlayer play];
            }
            
        }
        else{
            [Appdelegate showProgressHud];
            dispatch_queue_t myqueue = dispatch_queue_create("queue", NULL);
            dispatch_async(myqueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@" instrument_play_index = %ld",instrument_play_index);
           
            InstrumentalTableViewCell *cell = [self.tbl_Instrument cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
            //   if (instrument_play_status==0) {

            if ([[arr_instrumentsM objectAtIndex:instrument_play_index] valueForKey:@"instrument_url"] != [NSNull null]){
                 NSString * url_recording;
                url_recording = [[arr_instrumentsM objectAtIndex:instrument_play_index] valueForKey:@"instrument_url"];
                
                url_recording = [url_recording stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                NSError*error=nil;
                NSURL *urlforPlay = [NSURL URLWithString:url_recording];
                NSData *data = [NSData dataWithContentsOfURL:urlforPlay];
                audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
            [audioPlayer prepareToPlay];
            if ([audioPlayer prepareToPlay] == YES){
                sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerupdateSlider) userInfo:nil repeats:YES];
                // Set the maximum value of the UISlider
                cell.slider_progress.maximumValue=[audioPlayer duration];
                  cell.slider_progress.value = 0.0;
                [cell.slider_progress addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];
                [cell.btn_play_pause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
                [Appdelegate hideProgressHudInView];
                audioPlayer.delegate = self;
                [audioPlayer prepareToPlay];
                [audioPlayer play];
             
                instrument_play_status=1;
                lastIndexvalue = sender.tag;
                
            }
            else {
                [Appdelegate hideProgressHudInView];
                int errorCode = CFSwapInt16HostToBig ([error code]);
                NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
                
            }
            
        }
    });
    });
            
    }// else
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        [Appdelegate hideProgressHudInView];
    }
}


-(void)changeAudioProgress
{
    NSLog(@"changeAudioProgress");
    seconds=seconds+1;
    totalSeconds = totalSeconds+1;
    if (seconds >0 && seconds<60) {
        resulttimer = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
        
    }
    else {
        minutes=minutes+1;
        seconds=0;
        if (minutes >0 && minutes<60) {
            
            resulttimer = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
        }
        else
        {
            hours=hours+1;
            minutes=0;
            if (hours >0 && hours<60) {
                resulttimer = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
            }
        }
    }
    // set result as label.text
    self.lbl_duration.text=resulttimer;
    //[self.view bringSubviewToFront:_lbl_timer];
}


//Modified playSound method
-(void)addPlayerObjects:(NSString*)urlStr
{
    @try{
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSURL *urlforPlay = [NSURL URLWithString:urlStr];
        NSData *data = [NSData dataWithContentsOfURL:urlforPlay];
        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
        [soundsArray addObject:audioPlayer];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at addPlayerObjects :%@",exception);
    }
    @finally{
        
    }
}

-(void)stopPlay{
    
    
    int z;
    z=0;
    for (AVAudioPlayer *audio in soundsArray){
        InstrumentalTableViewCell *cell = [_tbl_Instrument cellForRowAtIndexPath:[NSIndexPath indexPathForRow:z inSection:0]];
        cell.slider_progress.value = 0.0;
        [cell.btn_play_pause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
        [audio stop];
        
        z++;
    }
}

-(void)pausePlay{
    
    int z;
    z=0;
    for (AVAudioPlayer *audio in soundsArray){
        InstrumentalTableViewCell *cell = [_tbl_Instrument cellForRowAtIndexPath:[NSIndexPath indexPathForRow:z inSection:0]];
        cell.slider_progress.value = 0.0;
//        [cell.btn_play_pause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];

         [cell.btn_play_pause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
        [audio pause];
        z++;
    }
}

-(void)allPlay{
    
    int z;
    z=0;
    for (AVAudioPlayer *audio in soundsArray){
        InstrumentalTableViewCell *cell = [_tbl_Instrument cellForRowAtIndexPath:[NSIndexPath indexPathForRow:z inSection:0]];
        cell.slider_progress.value = 0.0;
        [cell.btn_play_pause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
        [audio play];
        z++;
    }
}




-(void)load_instrumentals{
    
    @try{
        dispatch_queue_t myqueue = dispatch_queue_create("queue", NULL);
        dispatch_async(myqueue, ^{
            
            soundsArray = [NSMutableArray new];
            for (int j=0; j<[arr_instrumentsM count]; j++) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    InstrumentalTableViewCell *cell = [_tbl_Instrument cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0]];
                    cell.view_activity.hidden=NO;
                    NSURL *url3 = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[arr_instrumentsM objectAtIndex:j] valueForKey:@"instrument_url"]]];
                    //My New Code -----------------
                    NSString *strUrl = [[arr_instrumentsM objectAtIndex:j] valueForKey:@"instrument_url"];
                    [self performSelectorInBackground:@selector(addPlayerObjects:)withObject:strUrl];
                    
                    NSArray *parts = [[NSString stringWithFormat:@"%@",[[arr_instrumentsM objectAtIndex:j] valueForKey:@"instrument_url"]] componentsSeparatedByString:@"/"];
                    NSString *filename = [parts lastObject];
                    
                    NSString *ins_id=[NSString stringWithFormat:@"%@",[[arr_instrumentsM objectAtIndex:j] valueForKey:@"id"]];
                    NSString*type=@"admin";
                    NSArray *data = [[DBManager getSharedInstance] findByIntrumentType:@"admin"];
                    
                    NSLog(@"%@",data);
                    int g;
                    for (g=0; g<[data count]; g++) {
                        [arr_instrument_ids insertObject:[[data objectAtIndex:g] objectForKey:@"inst_id"] atIndex:g];
                        [arr_instrument_paths insertObject:[[data objectAtIndex:g] objectForKey:@"inst_path"] atIndex:g];
                    }
                    
                    if ([arr_instrument_ids containsObject:[[arr_instrumentsM objectAtIndex:j] valueForKey:@"id"] ]) {
                        cell.view_activity.hidden=YES;
                   
                        NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:arr_instrumentsM.count];
                        for (NSMutableArray *arrayObject in arr_instrumentsM)
                        {
                            NSData *arrayEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:arrayObject];
                            [archiveArray addObject:arrayEncodedObject];
                        }
                        
                        [defaults_userdata setObject:archiveArray forKey:@"instrument_array"];
                        [defaults_userdata synchronize];
                    }
                    else
                    {
                        
                        NSURLSessionTask *task3 = [[NSURLSession sharedSession] dataTaskWithURL:url3 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                            if (data) {
                                // UIImage *image = [UIImage imageWithData:data];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                                    NSString *path = [paths  objectAtIndex:0];
                                    //Save the data
                                    NSString *alertString2 = @"Data Not Saved!";
                                    NSString *dataPath = [path stringByAppendingPathComponent:filename];
                                    dataPath = [dataPath stringByStandardizingPath];
                                    BOOL success2 = [data writeToFile:dataPath atomically:YES];
                                    if (success2 == NO) {
                                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:
                                                              alertString2 message:nil
                                                                                      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                        [alert show];
                                    }
                                    else
                                    {
                                        BOOL success = NO;
                                        NSString *alertString = @"Data Insertion failed";
                                        
                                        success = [[DBManager getSharedInstance] saveInstrument:ins_id instrument_path:dataPath intrument_type:type];
                                        
                                        if (success == NO) {
                                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:
                                                                  alertString message:nil
                                                                                          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                            [alert show];
                                        }
                                        else
                                        {
                                            [arr_instrument_paths addObject:dataPath];
                                            if (arr_instrumentsM.count-1 == j) {
                                                isPlayable = YES;
                                                _btn_PlayAll.enabled = YES;
//                                                [_tbl_Instrument reloadData];
                                            }
                                            
                                        }
                                        
                                    }
                                    cell.view_activity.hidden=YES;
                                    
                                });
                            }
                        }];
                        [task3 resume];
                    }
                });
            }
            //    [ProgressHUD dismiss];
        });
    }
    @catch (NSException *exception) {
        NSLog(@"exception at load all instruments : %@",exception);
    }
    @finally{
        
    }
}




- (IBAction)btn_PlayAllAction:(id)sender {
    
    NSLog(audioPlayer.isPlaying?@"YES":@"NO");
    
    if (isAllAudioPlaying) {
        
        if (isPlayAll) {
            isPlayAll = !isPlayAll;
            //transparent_pause
            [_btn_PlayAll setImage:[UIImage imageNamed:@"btn_play_fill.png"] forState:UIControlStateNormal];
            [self pausePlay];
            
        }
        else{
            isPlayAll = !isPlayAll;
            [_btn_PlayAll setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
            [self allPlay];
            
        }
    }
    else{
        isPlayAll = YES;
        isAllAudioPlaying = YES;
        [_btn_PlayAll setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        [self play_all_instruments];
    }
}


-(void)play_all_instruments{
    
    int z;
    z=0;
    for (audioPlayer in soundsArray){
        InstrumentalTableViewCell *cell = [_tbl_Instrument cellForRowAtIndexPath:[NSIndexPath indexPathForRow:z inSection:0]];
        audioPlayer.delegate=self;
        instrument_play_index = z;
        sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerupdateSlider_ForAllInstruments) userInfo:nil repeats:YES];
        cell.slider_progress.maximumValue=[audioPlayer duration];
        cell.slider_progress.minimumValue=0.0;
        [cell.slider_progress addTarget:self action:@selector(sliderChanged_Studio) forControlEvents:UIControlEventValueChanged];
        cell.slider_progress.tag = z;
        [cell.btn_play_pause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
        instrument_play_status=1;
        [audioPlayer play];
        z++;
    }
    
}

-(void)timerupdateSlider_ForAllInstruments{
    // Update the slider about the music time
    long z ;
    z=0;
    for (AVAudioPlayer *player in soundsArray){
        InstrumentalTableViewCell *cell = [_tbl_Instrument cellForRowAtIndexPath:[NSIndexPath indexPathForRow:z inSection:0]];
        cell.slider_progress.value = player.currentTime;
        z++;
    }
    NSLog(@"timerupdateSlider_ForAllInstruments = %f",audioPlayer.currentTime);
}

-(void)sliderChanged_Studio{
    
    InstrumentalTableViewCell *cell = [_tbl_Instrument cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    cell.slider_progress.value = audioPlayer.currentTime;
    [audioPlayer setCurrentTime:cell.slider_progress.value];
    instrument_play_status=1;
}


- (IBAction)btn_playAction:(id)sender {
    
    @try{
        if (audioPlayer_user) {
            if (toggle_PlayPause) {
                toggle_PlayPause = !toggle_PlayPause;
                [self.btn_play setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                [Appdelegate hideProgressHudInView];
                [audioPlayer_user pause];
//                [_player_wave pause];
            }
            else{
                toggle_PlayPause = !toggle_PlayPause;
                [self.btn_play setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
                [Appdelegate hideProgressHudInView];
                [audioPlayer_user play];
//                [_player_wave play];

            }
        }
        
        else{
            
            [Appdelegate showProgressHud];
            [self.btn_play setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
            dispatch_queue_t myqueue = dispatch_queue_create("queue", NULL);
            dispatch_async(myqueue, ^{
                [self btn_playCount];

            isBtnPLay = YES;
            NSString * url_recording;
            if ([dic_response valueForKey:@"recording_url"] != [NSNull null]){
                url_recording = [[dic_response objectAtIndex:currentIndex_user] valueForKey:@"recording_url"];
                url_recording = [url_recording stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                
                NSURL *urlforPlay = [NSURL URLWithString:url_recording];
                NSURL *urlforPlay1 = [NSURL URLWithString:@"http://52.89.220.199/api/uploads/melody/instruments/1514441336beatpack-01-drums.wav"];

                //http://52.89.220.199/api/uploads/melody/instruments/1514441336beatpack-01-drums.wav
//                [self openFileWithFilePathURL:urlforPlay1];
                NSData *data = [NSData dataWithContentsOfURL:urlforPlay];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                NSError*error=nil;
                audioPlayer_user = [[AVAudioPlayer alloc] initWithData:data error:&error];
                
                [audioPlayer_user prepareToPlay];
                if ([audioPlayer_user prepareToPlay] == YES){
                    
                    audioPlayer_user.delegate = self;
                    [audioPlayer_user prepareToPlay];
                    [Appdelegate hideProgressHudInView];
                    [self player_wave];
                    [audioPlayer_user play];
                    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeAudioProgress) userInfo:nil repeats:YES];
                    instrument_play_status=1;
                    
                }else {
                    [self.btn_play setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                    [Appdelegate hideProgressHudInView];
                    int errorCode = CFSwapInt16HostToBig ([error code]);
                    NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
                }
                });

            }
                
            });
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{

    }
}

-(void)playWave{
    if ([_player_wave isPlaying])
    {
        [_player_wave pause];
    }
    else
    {
        if (self.view_wave.shouldMirror && (self.view_wave.plotType == EZPlotTypeBuffer))
        {
            self.view_wave.shouldMirror = NO;
            self.view_wave.shouldFill = NO;
        }
        
        [_player_wave play];
    }
}

- (IBAction)btn_previousAction:(id)sender {
    @try{
        if (currentIndex_user > 0) {
            currentIndex_user -= 1;
            self.btn_cancel.hidden = YES;
            self.lbl_currentUsrName.textColor = [UIColor whiteColor];
            if (audioPlayer_user.isPlaying) {
                [audioPlayer_user stop];
                audioPlayer_user = nil;
                [timer invalidate];
                timer = nil;
            }
                self.lbl_duration.text=@"00:00";
                [self.btn_play setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];

            
            [defaults_userdata setObject:[NSNumber numberWithInt:(int)currentIndex_user] forKey:@"index_currentUser"];
            arr_instrumentsM = [[dic_response objectAtIndex:currentIndex_user]valueForKey:@"instruments"];
            _lbl_currentUserCount.text = [NSString stringWithFormat:@"( %ld of %ld )",currentIndex_user+1,joinedUser];
            [_tbl_Instrument reloadData];
            [_col_view_profiles reloadData];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}


- (IBAction)btn_nextAction:(id)sender {
    @try{
        if (currentIndex_user < dic_response.count-1) {
            currentIndex_user += 1;
            self.btn_cancel.hidden = YES;
            self.lbl_currentUsrName.textColor = [UIColor whiteColor];
            if (audioPlayer_user.isPlaying) {
                [audioPlayer_user stop];
                audioPlayer_user = nil;
                [timer invalidate];
            }
                timer = nil;
                self.lbl_duration.text=@"00:00";
                
                [self.btn_play setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];

            
            
            [defaults_userdata setObject:[NSNumber numberWithInt:(int)currentIndex_user] forKey:@"index_currentUser"];
            arr_instrumentsM = [[dic_response objectAtIndex:currentIndex_user]valueForKey:@"instruments"];
            _lbl_currentUserCount.text = [NSString stringWithFormat:@"( %ld of %ld )",currentIndex_user+1,joinedUser];
            [_tbl_Instrument reloadData];
            [_col_view_profiles reloadData];
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}

#pragma mark -
#pragma mark -




-(void)timerupdateSlider{
    // Update the slider about the music time
    
    InstrumentalTableViewCell *cell = [_tbl_Instrument cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    cell.slider_progress.value = audioPlayer.currentTime;
}

-(void)sliderChanged{
    @try{
    InstrumentalTableViewCell *cell = [_tbl_Instrument cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    // [audioPlayer stop];
    [audioPlayer setCurrentTime:cell.slider_progress.value];
    // [audioPlayer prepareToPlay];
    [audioPlayer play];
    [cell.btn_play_pause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
    instrument_play_status=1;
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}


-(void)btn_m_clicked:(UIButton*)sender
{
    InstrumentalTableViewCell *cell = [self.tbl_Instrument cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    if (btn_m_isOn) {
        [cell.btn_m setBackgroundColor:[UIColor whiteColor]];
        [cell.btn_m setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        btn_m_isOn=NO;
    }
    else
    {
        [cell.btn_m setBackgroundColor:[UIColor redColor]];
        [cell.btn_m setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn_m_isOn=YES;
    }
    
}
-(void)btn_s_clicked:(UIButton*)sender
{
    InstrumentalTableViewCell *cell = [self.tbl_Instrument cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    if (btn_s_isOn) {
        [cell.btn_s setBackgroundColor:[UIColor whiteColor]];
        [cell.btn_s setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        btn_s_isOn=NO;
    }
    else
    {
        [cell.btn_s setBackgroundColor:[UIColor greenColor]];
        [cell.btn_s setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn_s_isOn=YES;
    }
}
-(void)fx_clicked:(UIButton *)sender{
    _view_fxeq.hidden=NO;
    _view_eq.hidden=YES;
    __view_fx.hidden=NO;
    
}
-(void)eq_clicked:(UIButton *)sender{
    _view_fxeq.hidden=NO;
    _view_eq.hidden=NO;
    __view_fx.hidden=YES;
    
}



-(void)delete_clicked:(UIButton *)sender{
    @try{
    InstrumentalTableViewCell *cell = [self.tbl_Instrument cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    cell.view_delete.hidden=NO;
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}


-(void)final_delete_clicked:(UIButton *)sender{
    @try{
    // [arr_instrument_paths removeObjectAtIndex:sender.tag];
    NSArray * arr_temp = [arr_instrumentsM copy];
    [self.tbl_Instrument reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}


-(void)final_delete_cancelled:(UIButton *)sender{
    @try{
    InstrumentalTableViewCell *cell = [self.tbl_Instrument cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    cell.view_delete.hidden=YES;
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}





- (IBAction)btn_fxeq_hide:(id)sender {
    _view_fxeq.hidden=YES;

}


- (IBAction)btn_cancelAction:(id)sender {
    
}


- (IBAction)btn_currentUsrProfileAction:(id)sender {
    
    @try{
    
    self.btn_cancel.hidden = NO;
    [defaults_userdata setObject:[NSNumber numberWithInt:99999] forKey:@"index_currentUser"];
    self.lbl_currentUsrName.textColor = [UIColor colorWithRed:4/255.0 green:51/255.0 blue:1 alpha:1];//4,51,255
    
    arr_instrumentsM = [[dic_response objectAtIndex:0] valueForKey:@"instruments"];
    [self.col_view_profiles reloadData];
    [self.tbl_Instrument reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}



#pragma mark - Audio Player Delegate Method
    
    -(void)audioPlayerDidFinishPlaying:
    (AVAudioPlayer *)player successfully:(BOOL)flag
    {
        @try{
            if (isBtnPLay) {
                [self.btn_play setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                audioPlayer_user = nil;
                isBtnPLay = NO;
                
            }
            
            InstrumentalTableViewCell *cell = [self.tbl_Instrument cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
            [cell.btn_play_pause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
            audioPlayer = nil;
            seconds=0;
            minutes=0;
            hours=0;
            cell.slider_progress.value=0.0;
            [timer invalidate];
            
        }
        @catch (NSException *exception) {
            NSLog(@"exception at likes.php :%@",exception);
        }
        @finally{
            
        }
    }
    
    
    -(void)audioPlayerDecodeErrorDidOccur:
    (AVAudioPlayer *)player
error:(NSError *)error
    {
        NSLog(@"Decode Error occurred");
    }
    
 
    
    
#pragma mark - TableView Delegates & Datasource
    
    -(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    {
        if (isCommentScreen) {
            return [arr_comment_id count];
        }
        else {
            return [arr_instrumentsM count];
        }
        return 0;
        
    }
    -(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        return 105;
        
    }
    
    -(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
    {
        return 1;
        
    }
    
    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        @try{
        if (isCommentScreen) {
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
                //- (IBAction)btn_LikeAction:(id)sender;
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
                NSString *tempDate =[arr_comment_timedate objectAtIndex:indexPath.row];
                if (tempDate.length >0) {
                    cell.lbl_time.text=[Appdelegate formatDateWithString:tempDate];
                }
                if ([[arr_user_profile_pic objectAtIndex:indexPath.row] length]>6)
                {
                 
            //------------------------* Profile pic *--------------------------
            NSURL *url2 = [NSURL URLWithString:[arr_user_profile_pic objectAtIndex:indexPath.row]];
            cell.img_profile.contentMode = UIViewContentModeScaleToFill;
            [cell.img_profile sd_setImageWithURL:url2
                                             placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        
                }
                return cell;
            }
            return cell;
        }
        else{
            InstrumentalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Instruments"];
            if (cell == nil)
            {
                NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"InstrumentalTableViewCell"
                                                              owner:self options:nil];
                cell.accessoryType = UITableViewCellStyleDefault;
                cell.view_activity.hidden=YES;

//                cell.view_upper.backgroundColor = [UIColor clearColor];
                cell = (InstrumentalTableViewCell*)[nib2 objectAtIndex:0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.img_view_profile.layer.cornerRadius = cell.img_view_profile.frame.size.width / 2;
                cell.img_view_profile.clipsToBounds = YES;
                [cell.slider_progress setMinimumTrackImage:[UIImage imageNamed:@"blue_bar.png"] forState:UIControlStateNormal];
               // [cell.slider_progress setMaximumTrackImage:[UIImage imageNamed:@"black_bar.png"] forState:UIControlStateNormal];
                [cell.slider_progress setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateNormal];
                
                cell.layer.shadowColor = [[UIColor grayColor] CGColor];
                cell.layer.shadowOpacity = 0.4;
                cell.layer.shadowRadius = 0;
                cell.layer.shadowOffset = CGSizeMake(1.0, 1.0);
                cell.btn_play_pause.tag=indexPath.row;
                [cell.btn_play_pause addTarget:self action:@selector(btn_plaupause_clicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.btn_ex.tag=indexPath.row;
                [cell.btn_ex addTarget:self action:@selector(fx_clicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.btn_eq.tag=indexPath.row;
                [cell.btn_eq addTarget:self action:@selector(eq_clicked:) forControlEvents:UIControlEventTouchUpInside];
                
                cell.btn_delete.tag=indexPath.row;
                [cell.btn_delete addTarget:self action:@selector(delete_clicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.btn_cell_delete.tag=indexPath.row;
                [cell.btn_cell_delete addTarget:self action:@selector(final_delete_clicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.btn_delete_cancel.tag=indexPath.row;
                [cell.btn_delete_cancel addTarget:self action:@selector(final_delete_cancelled:) forControlEvents:UIControlEventTouchUpInside];
                
                cell.btn_m.tag=indexPath.row;
                [cell.btn_m addTarget:self action:@selector(btn_m_clicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.btn_s.tag=indexPath.row;
                [cell.btn_s addTarget:self action:@selector(btn_s_clicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.view_delete.hidden=YES;
                
                cell.lbl_bpm.text=[[arr_instrumentsM objectAtIndex:indexPath.row] valueForKey:@"bpm"];
                
                NSLog(@"name %@ ",[[arr_instrumentsM objectAtIndex:indexPath.row] valueForKey:@"instrument_name"]);
                
                cell.lbl_profile_title.text=[[arr_instrumentsM objectAtIndex:indexPath.row] valueForKey:@"instruments_name"];
                cell.lbl_profile_title.textColor = [UIColor whiteColor];
               
                cell.lbl_profile_title_id.text=[[arr_instrumentsM objectAtIndex:indexPath.row] valueForKey:@"username"];
                cell.img_instrumental_cover.contentMode = UIViewContentModeScaleToFill;
                cell.img_view_profile.contentMode = UIViewContentModeScaleAspectFill;
                
        //------------------------* Cover pic *--------------------------
                NSString *imageUrlString = [[arr_instrumentsM objectAtIndex:indexPath.row] valueForKey:@"coverpic"];
                NSString *encodedImageUrlString = [imageUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURL *image_Cover_URL = [NSURL URLWithString: encodedImageUrlString];
                NSLog(@" ====== %@",image_Cover_URL);
                //NSURL *cover_url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[arr_instrumentsM objectAtIndex:indexPath.row] valueForKey:@"coverpic"]]];
                
                cell.img_instrumental_cover.contentMode = UIViewContentModeScaleToFill;
                
                
                [cell.img_instrumental_cover sd_setImageWithURL:image_Cover_URL
                                               placeholderImage:[UIImage imageNamed:@"Cover_profile"]];
                
        //------------------------* Profile pic *--------------------------
       NSURL *url2 = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[arr_instrumentsM objectAtIndex:indexPath.row] valueForKey:@"profilepic"]]];
        cell.img_view_profile.contentMode = UIViewContentModeScaleToFill;
        [cell.img_view_profile sd_setImageWithURL:url2
                                               placeholderImage:[UIImage imageNamed:@"artist.png"]];
   
        cell.lbl_timer.text=[Appdelegate timeFormatted:[[arr_instrumentsM objectAtIndex:indexPath.row] valueForKey:@"duration"]];
                return cell;
                
            }
            return cell;
        }
        return nil;
        }
        @catch (NSException *exception) {
            NSLog(@"exception at likes.php :%@",exception);
        }
        @finally{
            
        }
    }

    
#pragma mark - Collection Delegates & Datasource
    
    - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
        
        //return CGSizeMake( self.view.frame.size.width /12, 70);
        return CGSizeMake(72,79);
    }
    
    
    - (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
    {
        return [dic_response count];
    }
    
    
    
    -(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
    {
        @try{
        CollectionViewCell *cell = (CollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        
        //---------------------- * Profile Image * ------------------------
        cell.img_profile.layer.cornerRadius=cell.img_profile.frame.size.width/2;
        cell.img_profile.clipsToBounds = YES;
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[dic_response objectAtIndex:indexPath.item] valueForKey:@"profile_pic"]]];

        cell.img_profile.contentMode = UIViewContentModeScaleToFill;
        
        [cell.img_profile sd_setImageWithURL:url
                                    placeholderImage:[UIImage imageNamed:@"artist.png"]];
        
        
        //---------------------- * User Name * ------------------------
        
        cell.view_username.backgroundColor=[UIColor blackColor];
        cell.lbl_username.text =[NSString stringWithFormat:@"@%@",[[dic_response objectAtIndex:indexPath.item] valueForKey:@"user_name"]];
        
        //---------------------- * Cross Button * ------------------------
        
        //    NSInteger first = indexPath.item;
        //    NSInteger second = [[defaults_userdata objectForKey:@"index_currentUser"]intValue];
        //
        //    NSLog(@"\nfirst =  %li \nsecond = %li",(long)first,(long)second);
        //    //    NSLog(@" index ==== %d",(indexPath.item == (NSInteger)[defaults_userdata valueForKey:@"index_currentUser"]));
        //
        //    if(first == second){
            
       /* if (indexPath.item == currentIndex_user)
        {
            if (indexPath.item == 0)
            {
                cell.btn_cancel.hidden=YES;
            }
            else
            {
            cell.btn_cancel.hidden=NO;
           
            }
             cell.lbl_username.textColor=[UIColor whiteColor];
        }
        else
        {
            cell.lbl_username.textColor=[UIColor colorWithRed:4/255.0 green:51/255.0 blue:1 alpha:1];
            
            cell.btn_cancel.hidden=YES;
        }*/
            [cell.btn_cancel addTarget:self action:@selector(btn_RemoveJoinedUser:) forControlEvents:UIControlEventTouchUpInside];
            
            if (indexPath.item == currentIndex_user)
            {
                if (indexPath.item == 0)
                {
                    cell.btn_cancel.hidden=YES;
                    
                }
                else
                {
                    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] isEqualToString:parentUserID] && [[[dic_response objectAtIndex:currentIndex_user] objectForKey:@"user_id"] isEqualToString:parentUserID])
                    {
                        
                        cell.btn_cancel.hidden = NO;
                    }
                    else
                    {
                        NSLog(@"______INDEXPATH %ld",(long)indexPath.item);
                        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] isEqualToString:parentUserID])
                        {
                            cell.btn_cancel.hidden = NO;
                        }
                        else
                        {
                            cell.btn_cancel.hidden = YES;
                        }
                    }
                }
                cell.lbl_username.textColor=[UIColor whiteColor];
            }
            else
            {
                cell.lbl_username.textColor=[UIColor colorWithRed:4/255.0 green:51/255.0 blue:1 alpha:1];
                NSLog(@"*****INDEXPATH %ld",(long)indexPath.item);
                cell.btn_cancel.hidden=YES;
                
            }
        return cell;
        }
        @catch (NSException *exception) {
            NSLog(@"exception at likes.php :%@",exception);
        }
        @finally{
            
        }
    }


-(void)btn_RemoveJoinedUser:(UIButton*)sender
{
    @try{
    NSLog(@"REMOVED");
    [_col_view_profiles performBatchUpdates:^{
    
        NSMutableArray *tempJoinedUserArray=[[NSMutableArray alloc]init];
        tempJoinedUserArray=[dic_response mutableCopy];
        [tempJoinedUserArray removeObjectAtIndex:currentIndex_user];
        dic_response=[tempJoinedUserArray mutableCopy];
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:currentIndex_user inSection:0];
        [_col_view_profiles deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
//        [_col_view_profiles reloadData];
        currentIndex_user = currentIndex_user-1;
      _lbl_currentUserCount.text = [NSString stringWithFormat:@"( %ld of %ld )",currentIndex_user+1,(unsigned long)dic_response.count];
         arr_instrumentsM = [[dic_response objectAtIndex:currentIndex_user]valueForKey:@"instruments"];
        [_tbl_Instrument reloadData];
    } completion:^(BOOL finished) {
    
    }];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at btn_RemoveJoinedUser:%@",exception);
    }
    @finally{
        
    }
}
    
    
    - (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
    {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    
    
    -(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
    {
        @try{
        [audioPlayer stop];
        [audioPlayer_user stop];
        audioPlayer_user = nil;
            [timer invalidate];
            timer = nil;
            
            currentIndex_user = indexPath.item;

        if (currentIndex_user == lastIndexvalue) {
            if (![defaults_userdata boolForKey:@"isUserLogged"]) {
                ViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
                myVC.open_login=@"0";
                myVC.other_vc_flag=@"1";
                [self presentViewController:myVC animated:YES completion:nil];
            }
            else{
            ProfileViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
                if ([dic_response count]>=currentIndex_user)  {
                    myVC.follower_id = [[dic_response objectAtIndex:indexPath.item]valueForKey:@"user_id"];
                }
            
            [self presentViewController:myVC animated:YES completion:nil];
            }
        }
            
        currentJoinedUserDuration = [[[dic_response objectAtIndex:currentIndex_user]valueForKey:@"recording_duration"] intValue];

                if (audioPlayer_user.isPlaying) {
                    [audioPlayer_user stop];
                    audioPlayer_user = nil;
                    [self.btn_play setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                }
            
            [self.btn_play setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
            self.lbl_currentUsrName.textColor = [UIColor whiteColor];
            _lbl_currentUserCount.text = [NSString stringWithFormat:@"( %ld of %ld )",currentIndex_user+1,(unsigned long)dic_response.count];
            [defaults_userdata setObject:[NSNumber numberWithInt:(int)indexPath.item] forKey:@"index_currentUser"];
            arr_instrumentsM = [[dic_response objectAtIndex:indexPath.item]valueForKey:@"instruments"];
            
            [timer invalidate];
            timer = nil;
            self.lbl_duration.text=@"00:00";
        [_tbl_Instrument reloadData];
        [_col_view_profiles reloadData];
        //    [self joinedUser];
        }
        @catch (NSException *exception) {
            NSLog(@"exception at likes.php :%@",exception);
        }
        @finally{
            
        }
        lastIndexvalue = indexPath.item;
    }




#pragma mark - Navigation

#pragma mark - keyboard movements
    - (void)keyboardWillShow:(NSNotification *)notification
    {
        @try{
        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self.view_Comment.frame;
            f.origin.y = self.view.frame.size.height-(keyboardSize.height+49);
            self.view_Comment.frame = f;
            
        }];
        }
        @catch (NSException *exception) {
            NSLog(@"exception at likes.php :%@",exception);
        }
        @finally{
            
        }
    }
    
    -(void)keyboardWillHide:(NSNotification *)notification
    {
        @try{
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self.view_Comment.frame;
            f.origin.y = self.view.frame.size.height-49;
            self.view_Comment.frame = f;
        }];
        }
        @catch (NSException *exception) {
            NSLog(@"exception at likes.php :%@",exception);
        }
        @finally{
            
        }
    }


    -(void)textFieldDidChange:(UITextField *)theTextField{
        @try{
        NSLog( @"text changed: %@", _tf_addcomment.text);
        if ([_tf_addcomment.text length]>0) {
            text_flag=1;
            [_btn_send_cancel setTitle:@"Send" forState:UIControlStateNormal];
        }else{
            text_flag=0;
        }
        }
        @catch (NSException *exception) {
            NSLog(@"exception at likes.php :%@",exception);
        }
        @finally{
            
        }
    }


    - (BOOL)textFieldShouldReturn:(UITextField *)textField{
        NSLog(@"Working!!!");
        [_tf_addcomment resignFirstResponder];
        return YES;
    }



#pragma mark - IBAction Method

- (IBAction)btn_includeAction:(id)sender {
    @try{
    toggle_include = !toggle_include;
    
    if (toggle_include) {
        actualHeight = _cons_CollectionView_hieght.constant;
        _cons_CollectionView_hieght.constant = 0.0;
    }
    else{
        _cons_CollectionView_hieght.constant = actualHeight;
    }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}

- (IBAction)btn_LikeAction:(id)sender {
    
    @try{
    likeStaus = [defaults_userdata valueForKey:@"like_status"];
    long like_val = [likeStaus longLongValue];
    NSString * str_likeVal = [[NSString alloc]init];
    
    //
    if (like_val == 1) {
        str_likeVal = @"0";
    }
    else{
        str_likeVal = @"1";
    }
    
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:_str_RecordingId forKey:@"file_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"user_id"];
    [params setObject:str_likeVal forKey:@"likes"];
    [params setObject:@"user_recording" forKey:@"type"];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    [params setObject:[[dic_response objectAtIndex:currentIndex_user] valueForKey:@"recording_name"] forKey:@"topic"];

    
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
    
    //NSString* Cookie = [NSString stringWithFormat:@"%@=%@",cookie.name,cookie.value];
    //[request setValue:Cookie forHTTPHeaderField:@"Cookie"];
    // __block NSDictionary* jsonResponse;
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
                NSMutableDictionary*dic_responsee = [[NSMutableDictionary alloc]init];
                NSLog(@"%@",jsonResponse);
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    dic_responsee=[jsonResponse objectForKey:@"response"];
                    NSLog(@"%@",dic_responsee);
                    like_count=[dic_responsee objectForKey:@"likes" ];
                    //                    like_status=like_val;
                    self.lbl_LikeCount.text = like_count;
                    //------------ Change Like Status image --------------
                    
                    if ([str_likeVal isEqual:@"1"]) {
                        [_btn_like setBackgroundImage:[UIImage imageNamed:@"btn_hand_fill.png"] forState:UIControlStateNormal];
                    }
                    else{
                        [_btn_like setBackgroundImage:[UIImage imageNamed:@"btn_hand_outline.png"] forState:UIControlStateNormal];
                    }
                    
                    [defaults_userdata setObject:str_likeVal forKey:@"like_status"];
                    
                }
                else
                {
 
                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
             
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



- (IBAction)btn_ShareAction:(UIButton*)sender {
    
    //NEW CODE
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
                                        myVC.str_file_id = _str_RecordingId;
                                        currentIndexValue=sender.tag;
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
                                       NSArray *activityItems = @[@"YoMelody !"];
                                       activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                                       
                                       if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                                       {
                                           activityController.popoverPresentationController.sourceView = self.view;
                                           activityController.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4, 0, 0);
                                       }
                                       [self presentViewController:activityController animated:YES completion:nil];
                                       if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                                           
                                           SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                                           // NSLog(@"url %@",[arr_rec_thumbnail_url objectAtIndex:i_Path]);
                                           [controller setInitialText:@"First post from my iPhone app"];
                                           //[controller addURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[arr_rec_thumbnail_url objectAtIndex:i_Path]]]];
                                           [controller addImage:[UIImage imageNamed:@"socialsharing-facebook-image.jpg"]];
                                           [controller setCompletionHandler:^(SLComposeViewControllerResult result) {
                                               
                                               switch (result) {
                                                   case SLComposeViewControllerResultCancelled:
                                                       NSLog(@"Post Canceled");
                                                       break;
                                                   case SLComposeViewControllerResultDone:
                                                       NSLog(@"Post Successful");
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
    
    
    
   /*
    NSString *userid = [defaults_userdata objectForKey:@"user_id"];
    NSLog(@"userid %@",userid);
    NSDictionary* params = @{
                             KEY_AUTH_KEY:KEY_AUTH_VALUE,
                             @"shared_by_user":@"hh",
                             KEY_SHARE_FILETYPE:@"user_recording",
                             @"fileid":_str_RecordingId,
                             @"shared_with":@"user"
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
    NSString* urlString = [NSString stringWithFormat:@"%@sharefile.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    
    //this is how cookies were created
    
    
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    
    //NSString* Cookie = [NSString stringWithFormat:@"%@=%@",cookie.name,cookie.value];
    //[request setValue:Cookie forHTTPHeaderField:@"Cookie"];
    // __block NSDictionary* jsonResponse;
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
                NSMutableDictionary*dic_responsee = [[NSMutableDictionary alloc]init];
                NSLog(@"%@",jsonResponse);
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    dic_responsee=[jsonResponse objectForKey:@"response"];
                    NSLog(@"%@",dic_responsee);
                    //                    long a = [[arr_rec_play_count objectAtIndex:sender] integerValue]+1;
                    //                    [arr_rec_play_count replaceObjectAtIndex:sender withObject:[NSNumber numberWithInteger:a]];
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
    */
    
    
    
}

- (IBAction)btn_DeleteAction:(id)sender {

    
}




-(void)btn_playCount{
    
    @try{
    NSString *userid = [defaults_userdata objectForKey:@"user_id"];
    NSLog(@"userid %@",userid);
    
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:_str_RecordingId forKey:@"fileid"];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:@"userid"];
    [params setObject:@"recording" forKey:@"type"];
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
    
    //this is how cookies were created
    
    
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    
    //NSString* Cookie = [NSString stringWithFormat:@"%@=%@",cookie.name,cookie.value];
    //[request setValue:Cookie forHTTPHeaderField:@"Cookie"];
    // __block NSDictionary* jsonResponse;
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
                NSMutableDictionary*dic_responsePlay=[[NSMutableDictionary alloc]init];
                NSLog(@"%@",jsonResponse);
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    dic_responsePlay=[jsonResponse objectForKey:@"response"];
                    NSLog(@"%@",dic_responsePlay);
                    self.lbl_PlayCount.text = [dic_responsePlay valueForKey:@"play_count"];
                    
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
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}




- (IBAction)btn_CommentAction:(id)sender {
    @try{
    isCommentScreen = YES;
    self.view_Comment.hidden = NO;
    //    self.view_Bottom.hidden =YES;
    self.view_Bottom.frame = CGRectMake(0,self.view_record.frame.origin.y+ self.view_record.frame.size.height, self.view_record.frame.size.width, 50);
    [_tbl_Instrument reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}

- (IBAction)btn_send_cancel:(id)sender {
    @try{
    [self.view endEditing:YES];
    if (text_flag==0) {
        self.view_Bottom.hidden = NO;
        self.view_Comment.hidden = YES;
        isCommentScreen = NO;
        [_tf_addcomment resignFirstResponder];
        self.view_Bottom.frame = CGRectMake(0,self.view.frame.size.height-50, self.view_record.frame.size.width, 50);
        [_tbl_Instrument reloadData];
        
    }
    else
    {
        [_tf_addcomment resignFirstResponder];
        text_flag=0;
        [self callcommentapi];
        [_tbl_Instrument setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        [_btn_send_cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        
    }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}



- (IBAction)btn_joinAction:(id)sender {
    [self joinMethodCalled_withParameter];
    }

-(void)joinMethodCalled_withParameter{
    if (audioPlayer_user.playing || audioPlayer.playing) {
        [audioPlayer stop];
        [audioPlayer_user stop];
        audioPlayer = nil;
        audioPlayer_user = nil;
        [sliderTimer invalidate];
        sliderTimer = nil;
    }
    audioPlayer = nil;
    audioPlayer_user = nil;
    [sliderTimer invalidate];
    sliderTimer = nil;
    
    StudioRecViewController *studioVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StudioRecViewController"];
    
    studioVC.str_name = str_RecName;
    studioVC.str_date = str_RecDate;
    studioVC.arr_melodypack_instrumental = arr_instrumentsM;
    studioVC.isJoinScreen = YES;
    studioVC.str_parentID = _str_RecordingId;
    studioVC.str_instrumentTYPE = INSTRUMENT_TYPE;
    [studioVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:studioVC animated:YES completion:nil];
}

- (IBAction)btn_joinRecordingPressed:(id)sender {
    [self joinMethodCalled_withParameter];
}

    
@end
