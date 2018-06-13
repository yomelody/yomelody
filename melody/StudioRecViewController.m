
//
//  StudioRecViewController.m
//  melody
//
//  Created by CodingBrainsMini on 11/24/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import "StudioRecViewController.h"
#import "Constant.h"
@import FBSDKShareKit;
@import FBSDKCoreKit;
@import GoogleSignIn;
#define kAudioFileDefault [[NSBundle mainBundle] pathForResource:@"simple-drum-beat" ofType:@"wav"]

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)
@interface StudioRecViewController (Private)

- (CustomizationState)nextCustomizationState:(CustomizationState)state;
- (NSString*)buttonTextForState:(CustomizationState)state;
- (void)customizeAccordingToState:(CustomizationState)state;

@end

@interface StudioRecViewController ()<AVAudioPlayerDelegate,FBSDKSharing,FBSDKSharingDelegate,GIDSignInDelegate,GIDSignInUIDelegate,SFSafariViewControllerDelegate>
{
    int i;
    //    CustomizationState _state;
    NSMutableArray * arr_MelodyHasInsturmenrM,*arrIndexLoopM;
    NSMutableDictionary * dic_MelodyDataM;
    NSTimer* sliderTimer,*sliderTimerForAll;
    NSInteger totalDuration,currentDuration;
    BOOL isPlayable,isAudMixing;
    NSArray * arr_recording;
    NSMutableArray * arr_recordingM,*arrIndexCounterM,*arrIndexCounterL,*arrIndexCounterPLayPauseM;
    NSMutableDictionary * dic_recording;
    NSString *str_instrumentID;
    BOOL isPlayAll,isHeadphoneON,isAllAudioPlaying,haveDoneFB;
    NSMutableArray *soundsArray,*soundArrayCopy;
    float audioVolume;
    long lastIndexvalueFX;
    NSString *packageDuration,*packageLayer,*fb_status,*twitter_status,*google_status;
    NSDictionary*dic_responseGET;
    NSString *strThumbnailURL;
    NSInteger indexForInstrument;
}

@property (nonatomic, strong) NSArray *inputs;

@end
BOOL toggle_PlayPause = NO;
BOOL isTwitter = YES;
BOOL shouldInitialState = NO;
long lastIndexvalue = 10000;

@implementation StudioRecViewController

#pragma mark - Initial Methods
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializesEZAudio];
    isTwitter =YES;
    isAudMixing=NO;
    haveDoneFB = NO;
    isAllAudioPlaying = NO;
    self.scrollView_Genere.contentSize = CGSizeMake(0,self.view.frame.size.height*2/3);
    lastIndexvalueFX = 999999;
    if ([_arr_melodypack_instrumental count]==0) {
        arr_melodypack_instrumentals = [[NSMutableArray alloc]init];
    }
    else
    {
        arr_melodypack_instrumentals = [[NSMutableArray alloc]init];
        arr_melodypack_instrumentals = [_arr_melodypack_instrumental mutableCopy];
    }
    arrIndexCounterM = [[NSMutableArray alloc]init];
    resulttimer=[[NSMutableString alloc]init];
    defaults_userdata = [NSUserDefaults standardUserDefaults];
    [defaults_userdata synchronize];
    _view_fxeq.hidden=YES;
    _btn_sync.layer.cornerRadius=self.btn_sync.frame.size.width/2;
    sync_flag=0;
    rec_type=0;
    if ([arr_melodypack_instrumentals count]==1) {
        _lbl_noinstrumentals.text=@"1 Instrumental";
        _view_messege.hidden=YES;
        _view_sync.hidden=NO;
        _tbl_view_instrumentals.hidden=NO;
    }else if ([arr_melodypack_instrumentals count]>1) {
        _lbl_noinstrumentals.text=[NSString stringWithFormat:@"%lu Instrumentals",(unsigned long)[arr_melodypack_instrumentals count]];
        _view_messege.hidden=YES;
        _view_sync.hidden=NO;
        _tbl_view_instrumentals.hidden=NO;
    }
    else{
        
        _lbl_noinstrumentals.text=@"No Instrumental";
        _view_messege.hidden=NO;
        _view_sync.hidden=YES;
        _tbl_view_instrumentals.hidden=YES;
    }
    
    audioPlayer_ofstate.delegate=self;
    _view_circle_progress.hidden=YES;
    arr_instruments=[[NSMutableArray alloc] init];
    totalSeconds = 0;
    seconds=0;
    minutes=0;
    hours=0;
    _tbl_view_instrumentals.tag=1;
    _tbl_view_genre.tag=2;
    _img_vew_profile.layer.cornerRadius = _img_vew_profile.frame.size.width / 2;
    _img_vew_profile.clipsToBounds = YES;
    _lbl_public.hidden=YES;
    _switch_public.hidden=YES;
    
    if (isiPhone5)
    {
        [_lbl_public setFrame:CGRectMake(_lbl_public.frame.origin.x, _lbl_public.frame.origin.y+7, _lbl_public.frame.size.width, _lbl_public.frame.size.height)];
    }
    
    _switch_public.backgroundColor=[UIColor lightGrayColor];
    _switch_public.layer.cornerRadius = 16.0;
    
    [_switch_public setOn:NO animated:YES];
    
    state=[[NSMutableString alloc]initWithFormat:@"IDLE"];
    [defaults_userdata setValue:state forKey:@"state_recording"];
    
    i=1;
    [_btn_record_activities setImage:[UIImage imageNamed:@"state_melody_btn.png"] forState:UIControlStateSelected];
    [self.view bringSubviewToFront:_btn_record_activities];
    // Do any additional setup after loading the view.
    _view_master_volume.layer.masksToBounds = YES;
    _view_master_volume.layer.cornerRadius = 5;
    save_next_status=0;
    _view_saveas_popup.hidden=YES;
    _view_save_as.layer.cornerRadius=15;
    _btn_back_cancel.layer.cornerRadius=15;
    _btn_melody_select.layer.cornerRadius=_btn_melody_select.frame.size.width/2;
    [_btn_recording_select setBackgroundColor:[UIColor lightGrayColor]];
    _btn_recording_select.layer.cornerRadius=_btn_recording_select.frame.size.width/2;
    [_btn_recording_select setBackgroundColor:[UIColor lightGrayColor]];
    _view_genre_dropdown.hidden=YES;
    _view_genre_dropdown.layer.cornerRadius=10;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    UISwipeGestureRecognizer*swipedown=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [swipedown setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:swipedown];
    [self.view addGestureRecognizer:tap];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yy"];
    NSString *currentDate = [formatter stringFromDate:[NSDate date]];
    _lbl_date.text=currentDate;
    _lbl_date_melody.text = currentDate;
    
    if (_str_name) {
        _lbl_topic_melody.text=_str_name;
    }
    [self loadgenres];
    if (arr_melodypack_instrumentals.count > 0) {
        isPlayable = NO;
        _btn_playAll.enabled = NO;
    }
    [_btn_genre_ok setBackgroundColor:[UIColor whiteColor]];
    //Add this to viewDidLoad
    soundsArray = [NSMutableArray new];
    soundArrayCopy = [NSMutableArray new];
    [sliderTimer invalidate];
    [sliderTimerForAll invalidate];
    sliderTimer = nil;
    
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [sliderTimerForAll invalidate];
    sliderTimerForAll = nil;
}



- (void)viewWillAppear:(BOOL)animated {
    
    audioRecorder = nil;
    NSLog(@"state_recording %@",[defaults_userdata valueForKey:@"state_recording"]);
    if ([[defaults_userdata valueForKey:@"state_recording"]isEqualToString:@"RECORDED"]) {
        state=[[NSMutableString alloc]initWithFormat:@"RECORDED"];
        _btn_done.userInteractionEnabled = YES;
//        state=[[NSMutableString alloc]initWithFormat:@"IDLE"];

    }
    else{
        _btn_done.userInteractionEnabled = NO;
        state=[[NSMutableString alloc]initWithFormat:@"IDLE"];
    }
    
    [defaults_userdata setValue:state forKey:@"state_recording"];
    [self initializesAllVaribles];
//    self.recordingAudioPlot.hidden = NO;
    self.playingAudioPlot.hidden = NO;
    NSLog(@"viewWillAppear");
    [self setCounterForIndex];
    if([defaults_userdata boolForKey:@"isUserLogged"]) {
        [self checkSubscriptionValidityStatus];
        [self getCurrentSocialStatus];
    }
    NSData*data=[defaults_userdata objectForKey:@"profile_pic"];
    if (data.length!=0) {
        _img_vew_profile.image=[UIImage imageWithData:[defaults_userdata objectForKey:@"profile_pic"]];
    }
    
    if ([defaults_userdata boolForKey:@"isUserLogged"]) {
        _lbl_station_recording.text=[NSString stringWithFormat:@"@%@",[defaults_userdata objectForKey:@"user_name"]];
    }
    else
    {
        _lbl_station_recording.text=@"";
    }
    
    if (_isCoverImage) {
        if (_imagedata_forCover != nil) {
            imageData = _imagedata_forCover;
            imageName = _imagename_forCover;
        }
        UIImage* image = [UIImage imageWithData:imageData];
        _img_rec_cover.image=image;
    }
    else
    {
        NSString *lastStr = _coverPicFromChat.lastPathComponent;
        NSArray *arr = [lastStr componentsSeparatedByString:@"."];
        if (![[arr objectAtIndex:1] isEqualToString:@"jpg"]) {
            _img_rec_cover.image= [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_coverPicFromChat]]];
            
        }
    }
    
    if ([arr_melodypack_instrumentals count]>0) {
        if (!isAudMixing)
        {
            [self performSelectorInBackground:@selector(someMethodForLaodData:) withObject:nil];
        }
    }
}


- (void)viewDidUnload{
    [super viewDidUnload];
    NSLog(@"viewDidUnload");
    
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    [self resignFirstResponder];
    [audioPlayer stop];
    [audioRecorder stop];
    [recordingTimer invalidate];
    [sliderTimer invalidate];
}



- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"viewDidAppear");
    [sliderTimer invalidate];
   
    [self becomeFirstResponder];
}

//
//
////Modified playSound method
//-(void)addPlayerObjects:(NSString*)urlStr
//{
//
//    @try{
//        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
//        NSURL *urlforPlay = [NSURL URLWithString:urlStr];
//        NSData *data = [NSData dataWithContentsOfURL:urlforPlay];
//        AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
//        [soundsArray addObject:audioPlayer];
//        if (soundsArray.count == arr_melodypack_instrumentals.count) {
//            soundArrayCopy = [soundsArray mutableCopy];
//        }
//
//    }
//    @catch (NSException *exception) {
//        NSLog(@"exception at addPlayerObjects :%@",exception);
//    }
//    @finally{
//
//    }
//
//}

-(void)stopPlay{
    
    int z;
    z=0;
    for (AVAudioPlayer *audio in soundsArray){
        InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:z inSection:0]];
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
        InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:z inSection:0]];
        cell.slider_progress.value = 0.0;
        [audio pause];
        z++;
    }
}


-(void)resetAll{
    
    int z;
    for (z=0;z<arr_melodypack_instrumentals.count;z++){
        InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:z inSection:0]];
        cell.slider_progress.value = 0.0;
        [cell.btn_play_pause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
    }
    [sliderTimer invalidate];
    [recordingTimer invalidate];
    [sliderTimerForAll invalidate];
    sliderTimerForAll = nil;
    sliderTimer = nil;
}


-(void)allPlay{
    
    int z;
    z=0;
    for (AVAudioPlayer *audio in soundsArray){
        InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:z inSection:0]];
        cell.slider_progress.value = 0.0;
        [audio play];
        z++;
    }
}


- (IBAction)btn_cancel_back:(id)sender{
    
}


-(void)initializesAllVaribles{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord  withOptions:AVAudioSessionCategoryOptionDuckOthers | AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers error:nil];
    arr_player_objects=[[NSMutableArray alloc]init];
    arr_slider_timer_objects=[[NSMutableArray alloc]init];
    instrument_play_status=0;
    btn_loop_isOn = NO;
    public_flag=0;
    isMelody=[[NSString alloc]init];
    indexForInstrument = 0;
    arr_instrument_ids=[[NSMutableArray alloc]init];
    arr_instrument_paths=[[NSMutableArray alloc]init];
    str_genre_id=[[NSMutableString alloc]init];
    //------------------------------------------------------------------------------
    /*SET AUDIO PLAYER VOLUME*/
    
    self.slider_volume.minimumValue = 0.0;
    self.slider_volume.maximumValue = 1.0;
    self.slider_volume.continuous = YES;
    self.slider_volume.value = 0.5;
    self.slider_volume.translatesAutoresizingMaskIntoConstraints = YES;
    [self.slider_volume addTarget:self action:@selector(sliderVolumeAction:) forControlEvents:UIControlEventValueChanged];
    
    //-------------------------------------------------------------------
    //SLIDER FOR PAN
    self.slider_pan.minimumValue = -1.0;
    self.slider_pan.maximumValue = 1.0;
    self.slider_pan.continuous = YES;
    self.slider_pan.value = 0.0;
    self.slider_pan.translatesAutoresizingMaskIntoConstraints = YES;
    [self.slider_pan addTarget:self action:@selector(sliderPanAction:) forControlEvents:UIControlEventValueChanged];
    
    //-------------------- Master Volume ---------------------
    _slider_melody_volume.minimumValue = 0.0;
    _slider_melody_volume.maximumValue = 1.0;
    _slider_melody_volume.continuous = YES;
    _slider_melody_volume.value = 0.5;
    _slider_melody_volume.translatesAutoresizingMaskIntoConstraints = YES;
     self.slider_melody_volume.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(270));
    _view_master_volume_shadow.hidden=YES;
    [audioPlayer setVolume: [_slider_melody_volume value]];
    audioVolume = [_slider_melody_volume value];
    
    [_slider_melody_volume addTarget:self action:@selector(MelodysliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    //-------------------- Recording Volume ---------------------
    _slider_recording_volume.minimumValue = 0.0;
    _slider_recording_volume.maximumValue = 1.0;
    _slider_recording_volume.continuous = YES;
    _slider_recording_volume.value = 0.5;
    _slider_recording_volume.translatesAutoresizingMaskIntoConstraints = YES;
     _slider_recording_volume.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(270));
    [_slider_recording_volume addTarget:self action:@selector(RecordingsliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    if (!_isJoinScreen) {
        _str_parentID = [[NSMutableString alloc]initWithString:@""];
    }
    if (_str_parentID != nil)
    {
        [[NSUserDefaults standardUserDefaults] setValue:_str_parentID forKey:@"parent_id"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    dic_recording = [[NSMutableDictionary alloc]init];
    arr_recordingM = [[NSMutableArray alloc]init];
    isPlayAll = NO;
    [recordingTimer invalidate];
    
}



-(void)initializesEZAudio
{
    //
//    self.recordingAudioPlot.hidden = NO;
    self.playingAudioPlot.hidden = NO;
    // Customizing the audio plot that'll show the current microphone input/recording
    //

    self.playingAudioPlot.color = [UIColor whiteColor];
    self.playingAudioPlot.plotType = EZPlotTypeBuffer;
    self.playingAudioPlot.gain = 2.5f;
    [self setupNotifications];
    
    
    self.recordingAudioPlot.backgroundColor = [UIColor clearColor];
    self.recordingAudioPlot.color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.recordingAudioPlot.plotType = EZPlotTypeBuffer;
    _microphone = [EZMicrophone microphoneWithDelegate:self];
    _inputs = [EZAudioDevice inputDevices];

}

#pragma mark - EZAudioPlayerDelegate
- (void)   microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    // Getting audio data as an array of float buffer arrays. What does that
    // mean? Because the audio is coming in as a stereo signal the data is split
    // into a left and right channel. So buffer[0] corresponds to the float* data
    // for the left channel while buffer[1] corresponds to the float* data for
    // the right channel.
    
    //
    // See the Thread Safety warning above, but in a nutshell these callbacks
    // happen on a separate audio thread. We wrap any UI updating in a GCD block
    // on the main thread to avoid blocking that audio flow.
    //
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //
        // All the audio plot needs is the buffer data (float*) and the size.
        // Internally the audio plot will handle all the drawing related code,
        // history management, and freeing its own resources. Hence, one badass
        // line of code gets you a pretty plot :)
        //
        [weakSelf.playingAudioPlot updateBuffer:buffer[0]
                                   withBufferSize:bufferSize];
    });
}

- (void)   microphone:(EZMicrophone *)microphone
        hasBufferList:(AudioBufferList *)bufferList
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    //
    // Getting audio data as a buffer list that can be directly fed into the
    // EZRecorder. This is happening on the audio thread - any UI updating needs
    // a GCD main queue block. This will keep appending data to the tail of the
    // audio file.
    //
    if (_isRecording)
    {
        [self.recorder appendDataFromBufferList:bufferList
                                 withBufferSize:bufferSize];
    }
}


- (void) audioPlayer:(EZAudioPlayer *)audioPlayer
         playedAudio:(float **)buffer
      withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
         inAudioFile:(EZAudioFile *)audioFile
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.playingAudioPlot updateBuffer:buffer[0]
                                 withBufferSize:bufferSize];
    });
}

- (void)recorderDidClose:(EZRecorder *)recorder
{
    recorder.delegate = nil;
}

- (void)audioPlayer:(EZAudioPlayer *)audioPlayer
    updatedPosition:(SInt64)framePosition
        inAudioFile:(EZAudioFile *)audioFile
{

}




//Make sure we can recieve remote control events
- (BOOL)canBecomeFirstResponder {
    return YES;
}



-(void)load_instrumentals{
    
    @try{
        dispatch_async(dispatch_get_main_queue(), ^{
        _view_messege.hidden = YES;
        });
        
        dispatch_queue_t myqueue = dispatch_queue_create("queue", NULL);
        dispatch_async(myqueue, ^{

            soundsArray = [[NSMutableArray alloc]init];
            for (int j=0; j<[arr_melodypack_instrumentals count]; j++) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0]];
                    [cell.view_activity setHidden:NO];
                    cell.slider_progress.value = 0.0;
                    NSURL *url3 = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[arr_melodypack_instrumentals objectAtIndex:j] valueForKey:@"instrument_url"]]];
                    //recording_url
                    //My New Code -----------------
                    NSArray *parts = [[NSString stringWithFormat:@"%@",[[arr_melodypack_instrumentals objectAtIndex:j] valueForKey:@"instrument_url"]] componentsSeparatedByString:@"/"];
                    NSString *filename = [parts lastObject];
                    NSString *ins_id=[NSString stringWithFormat:@"%@",[[arr_melodypack_instrumentals objectAtIndex:j] valueForKey:@"id"]];
                    NSString*type=@"admin";
                    if ([arr_instrument_ids containsObject:[[arr_melodypack_instrumentals objectAtIndex:j] valueForKey:@"id"] ]) {
//                        cell.view_activity.hidden=YES;
                        [defaults_userdata setValue:arr_melodypack_instrumentals forKey:@"instrument_array"];
                        [defaults_userdata setObject:arr_melodypack_instrumentals forKey:@"instrument_array"];
                        [defaults_userdata synchronize];
                        
                        NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:arr_melodypack_instrumentals.count];
                        for (NSMutableArray *arrayObject in arr_melodypack_instrumentals)
                        {
                            NSData *arrayEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:arrayObject];
                            [archiveArray addObject:arrayEncodedObject];
                        }
                        
                        [defaults_userdata setObject:archiveArray forKey:@"instrument_array"];
                        [defaults_userdata synchronize];
                        if (arr_melodypack_instrumentals.count-1 == j) {
                            isPlayable = YES;
                            _btn_playAll.enabled = YES;
                            
                        }
                        [Appdelegate hideProgressHudInView];
                        cell.view_activity.hidden=YES;
                    }
                    else
                    {
                        cell.view_activity.hidden=NO;

                        NSURLSessionTask *task3 = [[NSURLSession sharedSession] dataTaskWithURL:url3 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                            if (data) {
                                // UIImage *image = [UIImage imageWithData:data];
                                dispatch_async(dispatch_get_main_queue(), ^{

                                    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
                                    if (audioPlayer == nil) {
                                        [Appdelegate hideProgressHudInView];
                                        
                                    }
                                    else{
//                                        if (soundsArray.count == j) {
                                            [soundsArray addObject:audioPlayer];

//                                        }
                                        [Appdelegate hideProgressHudInView];
                                    }
                                    //-------------------------------------------
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
                                            if (arr_melodypack_instrumentals.count-1 == j) {
                                                if([arr_melodypack_instrumentals count]<=[packageLayer intValue] || [packageLayer intValue]== 0)
                                                {
                                                    isPlayable = YES;
                                                    _btn_playAll.enabled = YES;
                                                    _btn_state.enabled = YES;
                                                    
                                                }
                                                else
                                                {
                                                    [Appdelegate showMessageHudWithMessage:@"Your recording layer should be less than or equal to your subscription pack." andDelay:2.0f];
                                                    isPlayable = YES;
                                                    _btn_playAll.enabled = NO;
                                                    _btn_state.enabled = YES;
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    cell.view_activity.hidden=YES;
                                    
                                });
                            }
                            else{
                                cell.view_activity.hidden=YES;

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
        [Appdelegate hideProgressHudInView];

        NSLog(@"exception at load all instruments : %@",exception);
        
    }
    @finally{
        
    }
}
- (IBAction)btn_state:(id)sender {
    if (audioPlayer.isPlaying) {
        [audioPlayer pause];
        audioPlayer = nil;
        [sliderTimer invalidate];
        [self.player pause];
    }
    
    if ([state isEqualToString:@"RECORDED"]) {
        _lbl_timer.text=@"00:00:00";
        totalSeconds = 0;
        [self resetMuteSolo];
//        [recordingTimer invalidate];
        [sliderTimer invalidate];
        sliderTimer = nil;
        recordingTimer = nil;
        audioRecorder = nil;

        seconds=0;
        minutes=0;
        hours=0;
        [recordingTimer invalidate];
        _lbl_public.hidden=YES;
        _switch_public.hidden=YES;
        [_switch_public setOn:NO animated:YES];
        state=[NSMutableString stringWithFormat:@"IDLE"];
        [defaults_userdata setValue:state forKey:@"state_recording"];

        [_btn_record_activities setImage:[UIImage imageNamed:@"btn_ready_to_recording.png"] forState:UIControlStateNormal];
        [_view_state setBackgroundColor:[UIColor whiteColor]];
        [_btn_state setImage:[UIImage imageNamed:@"state_add_melody.png"] forState:UIControlStateNormal];
        i=1;
        isPlayable = NO;
        _btn_playAll.enabled = NO;
        [self load_instrumentals];
        indexForInstrument = 0;
    }
    else if ([state isEqualToString:@"IDLE"] && i==1) {
        
        [self performSegueWithIdentifier:@"go_to_melody_screen" sender:self];
    }
}

-(void)resetMuteSolo{
    
    for (int i= 0; i<arrIndexCounterM.count;i++) {
          InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        //--------------- Reset Mute --------------
        if ([[arrIndexCounterM objectAtIndex:i] isEqualToString:@"1"]) {
            [cell.btn_m setBackgroundColor:[UIColor whiteColor]];
            [cell.btn_m setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            audioPlayer.volume = 1.0;
        }
        //--------------- Reset Solo --------------
        if ([[arrIndexCounterL objectAtIndex:i] isEqualToString:@"1"]) {
            [cell.btn_s setBackgroundColor:[UIColor whiteColor]];
            [cell.btn_s setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            audioPlayer.volume = 1.0;
        }
        //--------------- Reset Loop --------------

        if ([[arrIndexLoopM objectAtIndex:i] isEqualToString:@"1"]) {
            [cell.btn_replay setBackgroundColor:[UIColor whiteColor]];
            audioPlayer.numberOfLoops = -1;
            [cell.btn_replay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }

    [self setCounterForIndex];

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
//                    if (isAudMixing)
//                    {
//                        [self backToChatView];
//                    }
                    
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





-(void)checkSubscriptionValidityStatus
{
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    if([defaults_userdata boolForKey:@"isUserLogged"]) {
        [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:@"user_id"];
    }
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length])
        {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    
    NSString* urlString = [NSString stringWithFormat:@"%@check_subscription_validity.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLSessionDataTask *dataTask = [session
                                      dataTaskWithRequest:request
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          if (error)
                                          {
                               
                                          }
                                          else
                                          {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  NSError *myError = nil;
                                                  NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                                                  NSLog(@"%@",requestReply);
                                                  NSData *data2=[requestReply dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                                                  id jsonObject = [NSJSONSerialization JSONObjectWithData:data2
                                                                                                  options:NSJSONReadingAllowFragments
                                                                                                    error:&myError];
                                                  NSLog(@"%@",jsonObject);
                                                  if ([[jsonObject valueForKey:@"flag"] isEqual:@"success"])
                                                  {
                                                      packageDuration=[jsonObject valueForKey:@"duration"];
                                                      packageLayer=[jsonObject valueForKey:@"layer"];                                                  }
                                                  else
                                                  {
//                                                      UIAlertController * alert=   [UIAlertController
//                                                                                    alertControllerWithTitle:@"Alert"
//                                                                                    message:[jsonObject valueForKey:@"flag"]
//                                                                                    preferredStyle:UIAlertControllerStyleAlert];
//                                                      
//                                                      UIAlertAction* yesButton = [UIAlertAction
//                                                                                  actionWithTitle:@"ok"
//                                                                                  style:UIAlertActionStyleDefault
//                                                                                  handler:^(UIAlertAction * action)
//                                                                                  {
//                                                                                      //Handel your yes please button action here
//                                                                                  }];
//                                                      [alert addAction:yesButton];
//                                                      [self presentViewController:alert animated:YES completion:nil];
                                                  }
                                              });
                                          }
                                      }];
    [dataTask resume];
}



#pragma mark - set Audio player Delegates
#pragma mark -

-(void)audioRecorderDidFinishRecording: (AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog (@"audioRecorderDidFinishRecording:successfully");
    NSLog(@"Stopped");
    totalSeconds = 0;
    audioPlayer_ofstate = nil;
    seconds=0;
    minutes=0;
    hours=0;
    [recordingTimer invalidate];
    state=[NSMutableString stringWithFormat:@"RECORDED"];
    [_btn_record_activities setImage:[UIImage imageNamed:@"btn_recorded.png"] forState:UIControlStateNormal];
    [_view_state setBackgroundColor:[UIColor whiteColor]];
    [_btn_state setImage:[UIImage imageNamed:@"state_redo_btn.png"] forState:UIControlStateNormal];
    sliderTimer = nil;
    audioPlayer = nil;
    [sliderTimer invalidate];
    sliderTimer = nil;
}
-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"Encode Error occurred");
}



-(void)audioPlayerDidFinishPlaying:
(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (audioPlayer_ofstate && !shouldInitialState) {
        _btn_done.enabled=YES;
        
        if (_isJoinScreen) {
            _switch_public.hidden=YES;
        }
        {
            _switch_public.hidden=NO;
        }
        
        //        _switch_public.hidden=NO;
        NSLog(@"Finished playing");
        totalSeconds = 0;
        [sliderTimer invalidate];
        sliderTimer = nil;
        
        seconds=0;
        minutes=0;
        hours=0;
        [audioPlayer_ofstate stop];
        //        [self.player pause];
        [recordingTimer invalidate];
        recordingTimer = nil;
        state=[NSMutableString stringWithFormat:@"RECORDED"];
        [_view_state setBackgroundColor:[UIColor whiteColor]];
        [_btn_state setImage:[UIImage imageNamed:@"state_redo_btn.png"] forState:UIControlStateNormal];
        [_btn_record_activities setImage:[UIImage imageNamed:@"btn_recorded.png"] forState:UIControlStateNormal];
        
        i=0;
    }
    else{
        
        //--------------------- For Playing/pause Status --------------------
        while (indexForInstrument < [arr_melodypack_instrumentals count]) {
//        for (int j=0; j<[arr_melodypack_instrumentals count]; j++) {
            NSInteger durationD = [[[arr_melodypack_instrumentals objectAtIndex:indexForInstrument] valueForKey:@"duration"] integerValue];
            NSInteger value = ceil(player.duration);
            
            if (value == durationD) {
                [arrIndexCounterPLayPauseM replaceObjectAtIndex:indexForInstrument withObject:@"0"];
                break;
            }
            indexForInstrument++;
        }
        [_tbl_view_instrumentals reloadData];

    }

}


-(void)audioPlayerDecodeErrorDidOccur:
(AVAudioPlayer *)player
                                error:(NSError *)error
{
    NSLog(@"error %@",error.debugDescription);
}




#pragma mark - set Play All Instruments Methods
#pragma mark -

-(void)btn_plaupause_clicked:(UIButton*)sender {
    
    @try{
//            isAllAudioPlaying = NO;
            toggle_PlayPause = !toggle_PlayPause;
            InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
        if (isAllAudioPlaying) {
            audioPlayer = [soundsArray objectAtIndex:sender.tag];
        }
        
            if ((audioPlayer && lastIndexvalue == sender.tag) || isAllAudioPlaying) {
                
                if (toggle_PlayPause) {
                    [cell.btn_play_pause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                    [audioPlayer pause];
                    [self.player pause];
                    
                }
                else{
                    [cell.btn_play_pause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
                    [audioPlayer play];
                    //                                    [self playWave];
                }
                 isAllAudioPlaying = NO;
            }
            else{
                
                
                [Appdelegate showProgressHud];
                dispatch_queue_t myqueue = dispatch_queue_create("queue", NULL);
                dispatch_async(myqueue, ^{
                    if(audioPlayer){
                        [audioPlayer stop];
                        audioPlayer = nil;
                        
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                    instrument_play_index=sender.tag;
                
                    });
                    
                    InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
                    
                    
                    NSError*error=nil;
                    //--------------------* Play Selected index *-------------------
                    
                    for (int loop_num=0; loop_num < soundsArray.count; loop_num++) {
                        InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:loop_num inSection:0]];
                        if (loop_num == sender.tag) {
                            continue;
                        }
                        else{
                            [cell.btn_play_pause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                            [audioPlayer stop];
                            audioPlayer = nil;
                            cell.slider_progress.value = 0.0;
                            
                        }
                        
                    }
                    NSString *urlstr =[[arr_melodypack_instrumentals objectAtIndex:instrument_play_index] valueForKey:@"instrument_url"];
                    urlstr = [urlstr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                    
                    NSURL *urlforPlay = [NSURL URLWithString:urlstr];

                    NSData *data = [NSData dataWithContentsOfURL:urlforPlay];
                    audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
//                    [soundsArray replaceObjectAtIndex:instrument_play_index withObject:audioPlayer];
                    
//                    audioPlayer = [soundsArray objectAtIndex:instrument_play_index];
                    [audioPlayer prepareToPlay];
                    if ([audioPlayer prepareToPlay] == YES){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            // Set a timer which keep getting the current music time and update the UISlider in 1 sec interval
                            sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerupdateSlider) userInfo:nil repeats:YES];
                            // Set the maximum value of the UISlider
                            cell.slider_progress.maximumValue=[audioPlayer duration];
                            //  cell.slider_progress.value = 0.0;
                            // Set the valueChanged target
                            [cell.slider_progress addTarget:self action:@selector(sliderChanged_Studio) forControlEvents:UIControlEventValueChanged];
                            audioPlayer.delegate = self;
                            [audioPlayer prepareToPlay];
                            [audioPlayer  stop];
                            [Appdelegate hideProgressHudInView];
                            [audioPlayer play];
                            audioVolume = [audioPlayer volume];
                            //                                    [self playWave];
                            [cell.btn_play_pause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
                            instrument_play_status=1;
                            lastIndexvalue = sender.tag;
                        });
                        
                    }else {
                        int errorCode = CFSwapInt16HostToBig ([error code]);
                        NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
                    }
                });
                
            }
        }
    
    @catch (NSException *exception) {
        NSLog(@"exception at play action :%@",exception);
    }
    @finally{
        
    }
}

-(void)playWave{
//    if ([self.player isPlaying])
//    {
//        [self.player pause];
//    }
//    else
//    {
//        if (self.audioPlot.shouldMirror && (self.audioPlot.plotType == EZPlotTypeBuffer))
//        {
//            self.audioPlot.shouldMirror = NO;
//            self.audioPlot.shouldFill = NO;
//        }
//
//        [self.player play];
//    }
}





- (IBAction)btn_playAll_Action:(id)sender {

    if (soundsArray.count > 0) {
        NSLog(audioPlayer.isPlaying?@"YES":@"NO");
        if (isAllAudioPlaying) {
            if (isPlayAll) {
                isPlayAll = !isPlayAll;
                //transparent_pause
                [_btn_playAll setImage:[UIImage imageNamed:@"btn_play_fill.png"] forState:UIControlStateNormal];
                [self pausePlay];
            }
            else{
                isPlayAll = !isPlayAll;
                [_btn_playAll setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
                [self allPlay];
            }
        }
        else{
         
            audioPlayer = nil;
            isPlayAll = YES;
            isAllAudioPlaying = YES;
            [_btn_playAll setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
            [self play_all_instruments];
        }
    }
}


-(void)changeAudioProgress
{

    //RECORDING
    if ([state isEqualToString:@"RECORDING"]) {
    }
    float volume;
    NSLog(@"changeAudioProgress");
    seconds=seconds+1;
    totalSeconds = totalSeconds+1;
    [audioRecorder updateMeters];
    if (audioRecorder.isRecording) {
        volume=[audioRecorder averagePowerForChannel:0];
    }
    else
    {
        volume=[[AVAudioSession sharedInstance] outputVolume];
    }
    if (seconds >0 && seconds<60) {
        totalDuration = seconds;
        resulttimer = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    }
    else {
        totalDuration = 1;
        minutes=minutes+1;
        seconds=0;
        if (minutes >0 && minutes<60) {
            totalDuration= minutes*60 + seconds;
            resulttimer = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
        }
        else
        {
            totalDuration = 1;
            hours=hours+1;
            minutes=0;
            if (hours >0 && hours<60) {
                totalDuration= minutes*60 + hours*60 + seconds;
                
                resulttimer = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
            }
        }
    }
    // set result as label.text
    NSLog(@"%ld -------",(long)totalDuration);
    currentDuration=totalSeconds;
    _lbl_timer.text=resulttimer;
    [self.view bringSubviewToFront:_lbl_timer];
 
    if ([state isEqualToString:@"RECORDING"]) {
        if (totalDuration >= [packageDuration integerValue] && [packageDuration integerValue]!= 0) {
            [ProgressHUD showError:@"Your recording Layer/Duration should be less than or equal to your subscription pack."];
            //--------------* RECORDING STOP ACTION *-----------
            isHeadphoneON = [self isHeadsetPluggedIn];
            [self.microphone stopFetchingAudio];
            [self stopPlay];
            if (_isJoinScreen) {
                _lbl_public.hidden=YES;
                _switch_public.hidden=YES;
            }
            else
            {
                _lbl_public.hidden=NO;
                _switch_public.hidden=NO;
            }
            state=[NSMutableString stringWithFormat:@"RECORDED"];
            [_btn_record_activities setImage:[UIImage imageNamed:@"btn_recorded.png"] forState:UIControlStateNormal];
            [_view_state setBackgroundColor:[UIColor whiteColor]];
            [_btn_state setImage:[UIImage imageNamed:@"state_redo_btn.png"] forState:UIControlStateNormal];
            [audioPlayer_ofstate stop];
            if (audioPlayer.isPlaying) {
                [audioPlayer pause];
            }
            [audioRecorder stop];
            audioPlayer = nil;
        }
    }
}



- (IBAction)btn_record_activities:(id)c {
    @try{
        if (isPlayable || arr_melodypack_instrumentals.count == 0 ) {
            if([arr_melodypack_instrumentals count]<=[packageLayer intValue] || [packageLayer intValue] == 0)
            {
                if ([state isEqualToString:@"IDLE"]) {
//                    [self initializesEZAudio];
                    [self stopPlay];
//                    [audioPlayer setVolume:1.0];
                    _playingAudioPlot.hidden = NO;
                    _microphone = [EZMicrophone microphoneWithDelegate:self];
                    _player = [EZAudioPlayer audioPlayerWithDelegate:self];
                    [_microphone startFetchingAudio];
                    // Start the microphone
//                    self.recordingAudioPlot.hidden = NO;
//                    self.playingAudioPlot.hidden = YES;

                    //--------------* RECORDING ACTION *-----------
                    [sliderTimer invalidate];
                    state=[NSMutableString stringWithFormat:@"RECORDING"];
                    [_btn_record_activities setImage:[UIImage imageNamed:@"btn_recording.png"] forState:UIControlStateNormal];
                    [_view_state setBackgroundColor:[UIColor redColor]];
                    [_btn_state setImage:[UIImage imageNamed:@"state_recording_btn.png"] forState:UIControlStateNormal];
                    [self play_all_instruments];

                    [self performSelectorOnMainThread:@selector(setUpAudioRecorder) withObject:nil waitUntilDone:YES];
                    recordingTimer= [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeAudioProgress) userInfo:nil repeats:YES];
                    NSLog(@"recordingTimer %@",recordingTimer);
                }
                else if ([state isEqualToString:@"RECORDING"]) {
                    
                    //--------------* RECORDING STOP ACTION *-----------
                    isHeadphoneON = [self isHeadsetPluggedIn];
                    [self.microphone stopFetchingAudio];
                    [self stopPlay];
                    if (_isJoinScreen) {
                        _lbl_public.hidden=YES;
                        _switch_public.hidden=YES;
                    }
                    else
                    {
                        _lbl_public.hidden=NO;
                        _switch_public.hidden=NO;
                    }
                    _btn_done.userInteractionEnabled =YES;
                    state=[NSMutableString stringWithFormat:@"RECORDED"];
                    [defaults_userdata setValue:state forKey:@"state_recording"];

                    [_btn_record_activities setImage:[UIImage imageNamed:@"btn_recorded.png"] forState:UIControlStateNormal];
                    [_view_state setBackgroundColor:[UIColor whiteColor]];
                    [_btn_state setImage:[UIImage imageNamed:@"state_redo_btn.png"] forState:UIControlStateNormal];
                    [audioPlayer_ofstate stop];
                    if (audioPlayer.isPlaying) {
                        [audioPlayer pause];
                    }
                    [audioRecorder stop];
                    audioPlayer = nil;
                    
                }
                else if ([state isEqualToString:@"RECORDED"]) {
                    //--------------* PLAY ACTION *-----------
                    audioPlayer_ofstate = nil;

//                    if (audioPlayer_ofstate) {
//
//                        recordingTimer= [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeAudioProgress) userInfo:nil repeats:YES];
//
//                        [sliderTimerForAll invalidate];
//                        sliderTimerForAll = nil;
//                        state=[NSMutableString stringWithFormat:@"PLAYING"];
//                        [_btn_record_activities setImage:[UIImage imageNamed:@"btn_playing.png"] forState:UIControlStateNormal];
//                        [_view_state setBackgroundColor:[UIColor whiteColor]];
//                        [_btn_state setImage:[UIImage imageNamed:@"new_state_listening_btn.png"] forState:UIControlStateNormal];
//                        [audioPlayer_ofstate play];
//                    }
//                    else{
//                    [audioPlayer setVolume:1.0];
//                    self.recordingAudioPlot.hidden = YES;
                    self.playingAudioPlot.hidden = NO;
                    state=[NSMutableString stringWithFormat:@"PLAYING"];
                    [defaults_userdata setValue:state forKey:@"state_recording"];

                    [_btn_record_activities setImage:[UIImage imageNamed:@"btn_playing.png"] forState:UIControlStateNormal];
                    [_view_state setBackgroundColor:[UIColor whiteColor]];
                    [_btn_state setImage:[UIImage imageNamed:@"new_state_listening_btn.png"] forState:UIControlStateNormal];
                    
                    //----------* loading files to player for playing *----------//
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sounds.wav", documentsDirectory]];
                    //
                    // Update microphone state
                    //
                    [self.microphone stopFetchingAudio];
                    //
                    // Update recording state
                    //
                    self.isRecording = YES;
                    //                self.recordingStateLabel.text = @"Not Recording";
                    //                self.recordSwitch.on = NO;
                    // Close the audio file
                    //
                    if (self.recorder)
                    {
                        [self.recorder closeAudioFile];
                    }
                    
                    EZAudioFile *audioFile = [EZAudioFile audioFileWithURL:[self testFilePathURL]];
                    [self.player playAudioFile:audioFile];
                    
                    //-------------------* Pass URL as Parameter *------------------
                    NSError *error;
//                    if (audioPlayer_ofstate == nil) {
                        audioPlayer_ofstate = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
                        audioPlayer_ofstate.numberOfLoops = 0;
                        audioPlayer_ofstate.delegate=self;
                        audioPlayer_ofstate.volume=5.0;
                        [audioPlayer_ofstate prepareToPlay];
                        
                        NSLog(@"Playing.......");
                        totalSeconds = 0;
                        seconds=0;
                        minutes=0;
                        hours=0;
                      
//                    }
                    recordingTimer= [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeAudioProgress) userInfo:nil repeats:YES];
                    [audioPlayer_ofstate play];
//                    }
                }
                else if ([state isEqualToString:@"PLAYING"]) {
                    //--------------* PAUSE ACTION *-----------
                    audioPlayer_ofstate = nil;
                    [recordingTimer invalidate];
                    totalSeconds = 0;
                    seconds=0;
                    minutes=0;
                    hours=0;
                    state=[NSMutableString stringWithFormat:@"RECORDED"];
                    [defaults_userdata setValue:state forKey:@"state_recording"];

                    [_btn_record_activities setImage:[UIImage imageNamed:@"btn_recorded.png"] forState:UIControlStateNormal];
                    [_view_state setBackgroundColor:[UIColor whiteColor]];
                    [_btn_state setImage:[UIImage imageNamed:@"state_redo_btn.png"] forState:UIControlStateNormal];
                    i=0;
                    [audioPlayer pause];
                    [audioPlayer_ofstate stop];
                    [self.player pause];
                    
                }
                else{
                    totalSeconds = 0;
                    seconds=0;
                    minutes=0;
                    hours=0;
                    [recordingTimer invalidate];
                    recordingTimer = nil;
                    state=[NSMutableString stringWithFormat:@"IDLE"];
                    [defaults_userdata setValue:state forKey:@"state_recording"];
                    [_btn_record_activities setImage:[UIImage imageNamed:@"btn_ready_to_recording.png"] forState:UIControlStateNormal];
                    [_view_state setBackgroundColor:[UIColor whiteColor]];
                    [_btn_state setImage:[UIImage imageNamed:@"state_melody_btn.png"] forState:UIControlStateNormal];
                }
                
            }
            else
            {
                [Appdelegate showMessageHudWithMessage:@"Your recording layer should be less than or equal to your subscription pack." andDelay:2.0f];
                _btn_playAll.enabled = NO;
                _btn_state.enabled = YES;
            }
            
        }
        else{
            [ProgressHUD showError:@"Instruments not loaded, Please wait..."];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at join clicked:%@",exception);
    }
    @finally{
        
    }
}



-(void)play_all_instruments{
    
    int z;
    z=0;
    for (int loop_num=0; loop_num < soundsArray.count; loop_num++) {
        InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:loop_num inSection:0]];
        [cell.btn_play_pause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
        audioPlayer = [soundsArray objectAtIndex:loop_num];
        [audioPlayer stop];
        audioPlayer = nil;
        cell.slider_progress.value = 0.0;
    }
    sliderTimerForAll = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerupdateSlider_ForAllInstruments) userInfo:nil repeats:YES];
    
    for (audioPlayer in soundsArray){
        InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:z inSection:0]];
        audioPlayer.delegate=self;
        instrument_play_index = z;
        cell.slider_progress.maximumValue=[audioPlayer duration];
        cell.slider_progress.minimumValue=0.0;
        [cell.slider_progress addTarget:self action:@selector(sliderChanged_StudioForAll) forControlEvents:UIControlEventValueChanged];
        cell.slider_progress.tag = z;
        [cell.btn_play_pause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
        [arrIndexCounterPLayPauseM replaceObjectAtIndex:z withObject:@"1"];

        instrument_play_status=1;
        [audioPlayer play];
        z++;
    }
}



- (BOOL)isHeadsetPluggedIn {
    UInt32 routeSize = sizeof (CFStringRef);
    CFStringRef route;
    
    OSStatus error = AudioSessionGetProperty (kAudioSessionProperty_AudioRoute,
                                              &routeSize,
                                              &route);
    
    /* Known values of route:
     * "Headset"
     * "Headphone"
     * "Speaker"
     * "SpeakerAndMicrophone"
     * "HeadphonesAndMicrophone"
     * "HeadsetInOut"
     * "ReceiverAndMicrophone"
     * "Lineout"
     */
    
    if (!error && (route != NULL)) {
        NSString* routeStr = (__bridge NSString*)route;
        NSRange headphoneRange = [routeStr rangeOfString : @"Head"];
        if (headphoneRange.location != NSNotFound) return YES;
    }
    
    return NO;
}


-(void)timerupdateSlider_ForAllInstruments{
    // Update the slider about the music time
    long z ;
    z=0;
    for (AVAudioPlayer *player in soundsArray){
        InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:z inSection:0]];
        cell.slider_progress.value = player.currentTime;
        z++;
        NSLog(@"timerupdateSlider_ForAllInstruments = %f",player.currentTime);
    }
}

-(void)timerupdateSlider{
    // Update the slider about the music time
    InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    //audioPlayer = [soundsArray objectAtIndex:instrument_play_index];
    cell.slider_progress.value = audioPlayer.currentTime;
    NSLog(@"audioPlayer ***** = %f",audioPlayer.currentTime);

    
}
//sliderChanged_StudioForAll
-(void)sliderChanged_StudioForAll{
    audioPlayer = [soundsArray objectAtIndex:instrument_play_index];
    InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    cell.slider_progress.value = audioPlayer.currentTime;
    [audioPlayer setCurrentTime:cell.slider_progress.value];
    instrument_play_status=1;
}


-(void)sliderChanged_Studio{
    
    InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    cell.slider_progress.value = audioPlayer.currentTime;
    [audioPlayer setCurrentTime:cell.slider_progress.value];
    instrument_play_status=1;
}


- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidChangePlayState:)
                                                 name:EZAudioPlayerDidChangePlayStateNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidReachEndOfFile:)
                                                 name:EZAudioPlayerDidReachEndOfFileNotification
                                               object:self.player];
}



#pragma mark - Notifications

- (void)playerDidChangePlayState:(NSNotification *)notification
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        EZAudioPlayer *player = [notification object];
        BOOL isPlaying = [player isPlaying];
        if (isPlaying)
        {
            weakSelf.recorder.delegate = nil;
        }
        weakSelf.playingAudioPlot.hidden = !isPlaying;
    });
}

//------------------------------------------------------------------------------

- (void)playerDidReachEndOfFile:(NSNotification *)notification
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.playingAudioPlot clear];
    });
}





- (void)openFileWithFilePathURL:(NSURL *)filePathURL
{
//    _audioFile = [EZAudioFile audioFileWithURL:filePathURL];
//    _audioPlot.plotType = EZPlotTypeBuffer;
//    _audioPlot.shouldFill = NO;
//    _audioPlot.shouldMirror = NO;
//    __weak typeof (self) weakSelf = self;
//    [self.audioFile getWaveformDataWithCompletionBlock:^(float **waveformData,
//                                                         int length)
//     {
//         [weakSelf.audioPlot updateBuffer:waveformData[0]
//                           withBufferSize:length];
//     }];
//
//    // Play the audio file
//    [self.player setAudioFile:_audioFile];
}


//------------------------------------------------------------------------------
#pragma mark - Status Bar Style
#pragma mark -
//------------------------------------------------------------------------------


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)sliderPanAction:(UISlider *)slider {
    [audioPlayer setPan:[slider value]];
}


-(void)sliderVolumeAction:(UISlider *)slider {
    [audioPlayer setVolume:[slider value]];
    audioVolume = [slider value];
}

-(void)dismissKeyboard
{
    [_tf_genre resignFirstResponder];
    [_tf_topic resignFirstResponder];
}

- (void)MelodysliderValueChanged:(UISlider *)slider {
    //Handle the slider movement
//    [audioPlayer setVolume:[slider value]];
    //[_view_circle_progress setProgress:([slider value]) animated:YES];
    
}

- (void)RecordingsliderValueChanged:(UISlider *)slider {
    //Handle the slider movement
    [audioPlayer_ofstate setVolume:[slider value]];
//    [audioRecorder setVolume:[slider value]];

}



-(void)someMethodForLaodData:(id)sender{
    [self load_instrumentals];
}


-(void)loadgenres{
    
    
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:@"saverecording" forKey:@"save_melody"];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    
    NSString* urlString = [NSString stringWithFormat:@"%@genere.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                       
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
                                                                arr_genre=[[NSMutableArray alloc]init];
                                                                arr_genre=[[NSMutableArray alloc]init];
                                                                arr_genre_id=[[NSMutableArray alloc]init];
                                                                arr_response1 = [Appdelegate valueOrNil:[jsonObject valueForKey:@"response"]];
                                                                //arr_response1=[jsonObject valueForKey:@"response"];
                                                                NSLog(@"CCount ==== %lu",(unsigned long)arr_response1.count);
                                                                arr_genre_select=[[NSMutableArray alloc]init];
                                                                // NSLog(@"%@",arr_response);
                                                                if (arr_response1.count >0)
                                                                {
                                                                    
                                                                    for (int i_loop=1; i_loop<[arr_response1 count]; i_loop++) {
                                                                        if ([[[arr_response1 objectAtIndex:i_loop] valueForKey:@"name"] isEqualToString:@"My Melodies"])
                                                                        {
                                                                            //...
                                                                        }
                                                                        else
                                                                        {
                                                                            [arr_genre addObject:[[arr_response1 objectAtIndex:i_loop] valueForKey:@"name"]];
                                                                            [arr_genre_id addObject:[[arr_response1 objectAtIndex:i_loop] valueForKey:@"id"]];
                                                                        }
                                                                        if (i_loop==1) {
                                                                            [arr_genre_select insertObject:@"0" atIndex:i_loop-1];
                                                                        }
                                                                        else
                                                                        {
                                                                            [arr_genre_select insertObject:@"0" atIndex:i_loop-1];
                                                                        }
                                                                    }
                                                                }
                                                                // [arr_genre_id addObject:@"0"];
                                                                NSLog(@"%@",arr_genre);
                                                                NSLog(@"%@",arr_genre_select);
                                                                NSLog(@"%@",arr_genre_id);
                                                                [_tbl_view_genre reloadData];
                                                            }else{
                                                                [SVProgressHUD dismiss];
                                                                
                                                            }
                                                        });
                                                    }
                                                }];
    [dataTask resume];
    
}

- (void)cancelationExample {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Set the determinate mode to show task progress.
    hud.mode = MBProgressHUDModeDeterminate;
    hud.label.text = NSLocalizedString(@"Loading...", @"HUD loading title");
    
    // Configure the button.
    [hud.button setTitle:NSLocalizedString(@"Cancel", @"HUD cancel button title") forState:UIControlStateNormal];
    [hud.button addTarget:self action:@selector(cancelWork:) forControlEvents:UIControlEventTouchUpInside];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
    });
}


- (void)cancelWork:(id)sender {
    self.canceled = YES;
}


- (void)doSomeWorkWithProgress {
    //    self.canceled = NO;
    //    // This just increases the progress indicator in a loop.
    //    float progress = 0.0f;
    //    while (progress < 1.0f) {
    //        if (self.canceled) break;
    //        progress += 0.01f;
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            // Instead we could have also passed a reference to the HUD
    //            // to the HUD to myProgressTask as a method parameter.
    //            [MBProgressHUD HUDForView:self.navigationController.view].progress = progress;
    //        });
    //        usleep(50000);
    //    }
}



- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //if it is a remote control event handle it correctly
    //    if (event.type == UIEventTypeRemoteControl) {
    //        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
    //            [self playAudio];
    //        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
    //            [self pauseAudio];
    //        } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
    //            [self togglePlayPause];
    //        }
    //    }
}

#pragma mark - FX & EQ
#pragma mark -



// ----------- Set index counter for multiple index ---------
-(void)setCounterForIndex{
    arrIndexCounterM = [[NSMutableArray alloc]init];
    arrIndexCounterPLayPauseM = [[NSMutableArray alloc]init];

    arrIndexCounterL = [[NSMutableArray alloc]init];
    arrIndexLoopM = [[NSMutableArray alloc]init];
    
    for (int i=0; i<arr_melodypack_instrumentals.count; i++) {
        [arrIndexCounterM setObject:@"0" atIndexedSubscript:i];
        [arrIndexCounterL setObject:@"0" atIndexedSubscript:i];
        [arrIndexLoopM setObject:@"0" atIndexedSubscript:i];
        [arrIndexCounterPLayPauseM setObject:@"0" atIndexedSubscript:i];

    }
    [_tbl_view_instrumentals reloadData];
}

-(void)loop_clicked:(UIButton*)sender
{
    @try{
        
        InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
        audioPlayer = [soundsArray objectAtIndex:sender.tag];
        
        if ([[arrIndexLoopM objectAtIndex:sender.tag] isEqualToString:@"0"]) {
            [arrIndexLoopM replaceObjectAtIndex:sender.tag withObject:@"1"];

            audioPlayer.numberOfLoops = -1;
            [soundsArray replaceObjectAtIndex:sender.tag withObject:audioPlayer];
            [cell.btn_replay setBackgroundColor:[UIColor redColor]];
            [cell.btn_replay setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            
        }
        else
        {
            [arrIndexLoopM replaceObjectAtIndex:sender.tag withObject:@"0"];
            audioPlayer.numberOfLoops = 0;
            [cell.btn_replay setBackgroundColor:[UIColor whiteColor]];
            [soundsArray replaceObjectAtIndex:sender.tag withObject:audioPlayer];
            [cell.btn_replay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [arrIndexCounterPLayPauseM replaceObjectAtIndex:sender.tag withObject:@"0"];

            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at loop_clicked :%@",exception);
    }
    @finally{
        [_tbl_view_instrumentals reloadData];
    }
}


-(void)btn_m_clicked:(UIButton*)sender
{
    
    @try{
        
        InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
        audioPlayer = [soundsArray objectAtIndex:sender.tag];
        if ([[arrIndexCounterM objectAtIndex:sender.tag] isEqualToString:@"0"])
        {
            if ([[arrIndexCounterL objectAtIndex:sender.tag] isEqualToString:@"1"])
            {
                [arrIndexCounterL replaceObjectAtIndex:sender.tag withObject:@"0"];
                [cell.btn_s setBackgroundColor:[UIColor whiteColor]];
                [cell.btn_s setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                int count = 0;
                for (int i=0; i<arr_melodypack_instrumentals.count; i++) {
                    audioPlayer = [soundsArray objectAtIndex:i];
                    if ([[arrIndexCounterL objectAtIndex:i] isEqualToString:@"1"]) {
                        audioPlayer.volume = 1.0;
                    }
                    else{
                        audioPlayer.volume = 0.0;
                        count = count + 1;
                    }
                    
                    [soundsArray replaceObjectAtIndex:i withObject:audioPlayer];
                }
                
            }
            
            [cell.btn_m setBackgroundColor:[UIColor redColor]];
            [cell.btn_m setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [arrIndexCounterM replaceObjectAtIndex:sender.tag withObject:@"1"];
            //        [soundsArray objectAtIndex:instrument_play_index] = 1.0;
            audioPlayer.volume = 0.0;
            [soundsArray replaceObjectAtIndex:sender.tag withObject:audioPlayer];

        }
        else
        {
            [arrIndexCounterM replaceObjectAtIndex:sender.tag withObject:@"0"];
            [cell.btn_m setBackgroundColor:[UIColor whiteColor]];
            [cell.btn_m setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            //        btn_m_isOn=YES;
            audioPlayer.volume = 1.0;
            [soundsArray replaceObjectAtIndex:sender.tag withObject:audioPlayer];

        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at btn_m_clicked :%@",exception);
    }
    @finally{
        [_tbl_view_instrumentals reloadData];

    }
}




-(void)btn_s_clicked:(UIButton*)sender
{
    @try{
        InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
        
            if ([[arrIndexCounterL objectAtIndex:sender.tag] isEqualToString:@"0"]) {
                if ([[arrIndexCounterM objectAtIndex:sender.tag] isEqualToString:@"1"]) {

                [arrIndexCounterM replaceObjectAtIndex:sender.tag withObject:@"0"];
                [cell.btn_m setBackgroundColor:[UIColor whiteColor]];
                [cell.btn_m setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                //        btn_m_isOn=YES;
                
                audioPlayer.volume = 1.0;
                [soundsArray replaceObjectAtIndex:sender.tag withObject:audioPlayer];
                }
                [arrIndexCounterL replaceObjectAtIndex:sender.tag withObject:@"1"];
                [cell.btn_s setBackgroundColor:[UIColor greenColor]];
                [cell.btn_s setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                for (int i=0; i<arr_melodypack_instrumentals.count; i++) {
                    audioPlayer = [soundsArray objectAtIndex:i];
                    if ([[arrIndexCounterL objectAtIndex:i] isEqualToString:@"0"]) {
                        audioPlayer.volume = 0.0;
                    }
                    else{
                        audioPlayer.volume = 1.0;
                    }
                    [soundsArray replaceObjectAtIndex:i withObject:audioPlayer];
                }

            }
            else
            {
                [arrIndexCounterL replaceObjectAtIndex:sender.tag withObject:@"0"];
                [cell.btn_s setBackgroundColor:[UIColor whiteColor]];
                [cell.btn_s setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                int count = 0;
                for (int i=0; i<arr_melodypack_instrumentals.count; i++) {
                    audioPlayer = [soundsArray objectAtIndex:i];
                    if ([[arrIndexCounterL objectAtIndex:i] isEqualToString:@"1"]) {
                        audioPlayer.volume = 1.0;
                    }
                    else{
                        audioPlayer.volume = 0.0;
                        count = count + 1;
                    }
                    
                    [soundsArray replaceObjectAtIndex:i withObject:audioPlayer];
                }
                if (count == arr_melodypack_instrumentals.count) {
                    for (int i=0; i<arr_melodypack_instrumentals.count; i++) {
                        if([[arrIndexCounterM objectAtIndex:i] isEqualToString:@"0"]){
                            audioPlayer = [soundsArray objectAtIndex:i];
                            audioPlayer.volume = 1.0;
                        }
                    }
                    [soundsArray replaceObjectAtIndex:i withObject:audioPlayer];
                }

        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception at btn_s_clicked :%@",exception);
    }
    @finally{
        [_tbl_view_instrumentals reloadData];

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
    InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    cell.view_delete.hidden=NO;
}


-(void)final_delete_clicked:(UIButton *)sender{
    
    [arr_melodypack_instrumentals removeObjectAtIndex:sender.tag];
    InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    cell.view_delete.hidden=YES;
//    [soundsArray removeObjectAtIndex:sender.tag];
    [_tbl_view_instrumentals reloadData];
    
    NSLog(@"count +++ %ld",(unsigned long)arr_melodypack_instrumentals.count);
    if([arr_melodypack_instrumentals count]<=[packageLayer intValue] || [packageLayer intValue] == 0)
    {
        isPlayable = YES;
        _btn_playAll.enabled = YES;
               _btn_state.enabled = YES;
        if (soundsArray.count>sender.tag) {
            [soundsArray removeObjectAtIndex:sender.tag];
        }
    }
    else
    {
        [Appdelegate showMessageHudWithMessage:@"Your recording layer should be less than or equal to your subscription pack." andDelay:2.0f];
        isPlayable = NO;
        _btn_playAll.enabled = NO;
               _btn_state.enabled = NO;
    }
}


-(void)final_delete_cancelled:(UIButton *)sender{
    InstrumentalTableViewCell *cell = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    cell.view_delete.hidden=YES;
}


- (void)select_genre:(UIButton* )sender {
    
    for (int z=0; z<[arr_genre_select count]; z++) {
        if (sender.tag==z) {
            if ([[arr_genre_select objectAtIndex:z]isEqual:@"0"]) {
                [arr_genre_select replaceObjectAtIndex:z withObject:@"1"];            }
            else{
                [arr_genre_select replaceObjectAtIndex:z withObject:@"0"];
            }
            
        }
        else
        {
            [arr_genre_select replaceObjectAtIndex:z withObject:@"0"];
        }
        
    }
    if ([arr_genre_select containsObject: @"1"]) {
        [_btn_genre_ok setTitle:@"OK" forState:UIControlStateNormal];
    }
    else{
        [_btn_genre_ok setTitle:@"Cancel" forState:UIControlStateNormal];
    }
    _btn_genre_ok.tag=sender.tag;
    [_tbl_view_genre reloadData];
}



#pragma mark - Utility
#pragma mark -


- (NSArray *)applicationDocuments
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
}


- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


- (NSURL *)testFilePathURL
{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",
                                   [self applicationDocumentsDirectory],
                                   kAudioFilePath]];
}



- (IBAction)cancel_mastervolume_popup:(id)sender {
    _view_master_volume_shadow.hidden=YES;
    
}



- (IBAction)btn_master_volume:(id)sender {
    _view_master_volume_shadow.hidden=NO;
    _view_master_volume_shadow.frame=CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
}






#pragma mark - Navigation Methods
#pragma mark -

- (IBAction)btn_back:(id)sender {
    
        [audioPlayerI stop];
        [audioPlayer stop];
        [audioRecorder stop];

    
    Appdelegate.isHomeClicked=NO;
    [audioPlayer_ofstate stop];
    [audioRecorder stop];
    [audioPlayer stop];
    [sliderTimer invalidate];
    [self stopPlay];
    soundsArray = [NSMutableArray new];
    sliderTimer = nil;
    [SVProgressHUD dismiss];
    [recordingTimer invalidate];
    recordingTimer = nil;
    [sliderTimerForAll invalidate];
    sliderTimerForAll = nil;
    
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
    
    [audioPlayerI stop];
    [audioPlayer stop];
    [audioRecorder stop];
    
    [sliderTimerForAll invalidate];
    sliderTimerForAll = nil;
    Appdelegate.isHomeClicked=NO;
    [audioPlayer_ofstate stop];
    [audioRecorder stop];
    [audioPlayer stop];
    [self stopPlay];
    soundsArray = [NSMutableArray new];
    [sliderTimer invalidate];
    sliderTimer = nil;
    [SVProgressHUD dismiss];
    [recordingTimer invalidate];
    recordingTimer = nil;
    
    if (Appdelegate.isFirstTimeSignUp)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
    }
    else{
        [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    }
}



- (IBAction)switch_public_toggle:(id)sender {
    if ([_switch_public isOn]) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Make Public?"
                                      message:@"As a moderator,feel free to make public or private anytime."
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
                                           //Handel your yes please button action here
                                           [_switch_public setOn:NO];
                                           public_flag=0;
                                       }];
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        //Handel your yes please button action here
                                        // [self makePublic];
                                        [_switch_public setOn:YES];
                                        public_flag=1;
                                    }];
        
        [alert addAction:cancelButton];
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [_switch_public setOn:NO];
        public_flag=0;
    }
}

- (IBAction)invite:(id)sender {
    contactsViewController *contactVC = [self.storyboard instantiateViewControllerWithIdentifier:@"contactsViewController"];
    [contactVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:contactVC animated:YES completion:nil];

}



#pragma mark - set IBAction Methods
#pragma mark -

- (IBAction)btn_done:(id)sender {
    
    if ([[defaults_userdata stringForKey:@"rememberme"] isEqual:@"remember"]) {
        //         _view_saveas_popup.hidden=NO;
        if (true) {
            
        }
        //--------------- New code ----------------
        if (_isJoinScreen)
        {
            shouldInitialState = YES;
            [self audioMixing];
        }
        else
        {
            NSLog(@"CURR DURA %ld",(long)currentDuration);
            NSLog(@"PACK DURA %d",[packageDuration intValue]);
            if ((currentDuration<=[packageDuration intValue] && [arr_melodypack_instrumentals count]<= [packageLayer intValue]) || [packageLayer intValue] == 0  )
            {
                _view_saveas_popup.hidden=NO;
            }
            else
            {
                if (currentDuration>[packageDuration intValue])
                {
                    [Appdelegate showMessageHudWithMessage:@"Your recording duration should be less then or equal to your subscription pack." andDelay:2.0f];
                }
      
            }
        }
        
        [_btn_record_activities setImage:[UIImage imageNamed:@"btn_ready_to_recording.png"] forState:UIControlStateNormal];
        shouldInitialState = YES;
    }
    else
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Alert"
                                      message:@"You have to login first"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [self performSegueWithIdentifier:@"go_to_login" sender:self];
                                        
                                    }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     
                                 }];
        
        [alert addAction:cancel];
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
}

-(void)makePublic
{
    //loading file//
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sounds.wav", documentsDirectory]];
    
    NSLog(@"url is %@",url);
    NSString *fileName = [url lastPathComponent];
    /****************uploading recorded file*****************/
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@uploadfile.php",BaseUrl] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:[NSData dataWithContentsOfURL:url]
                                    name:@"file1"
                                fileName:fileName mimeType:@"multipart/form-data"];
        [formData appendPartWithFormData:[@"250" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"user_id"];
        [formData appendPartWithFormData:[@"2" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:KEY_SHARE_FILETYPE];
        [formData appendPartWithFormData:[KEY_AUTH_VALUE dataUsingEncoding:NSUTF8StringEncoding]
                                    name:KEY_AUTH_KEY];
        
        // etc.
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"Response: %@", responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD dismiss];
    }];
    
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
    if (![defaults_userdata boolForKey:@"isUserLogged"]) {
        ViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        myVC.open_login=@"0";
        myVC.other_vc_flag=@"1";
        [self presentViewController:myVC animated:YES completion:nil];
    }
}

- (IBAction)btn_profile:(id)sender {

    [_btn_audiofeed setImage:[UIImage imageNamed:@"btn_audio_feed.png"] forState:UIControlStateNormal];
    [_btn_discover setImage:[UIImage imageNamed:@"btn_discover.png"] forState:UIControlStateNormal];
    [_btn_messenger setImage:[UIImage imageNamed:@"btn_messenger.png"] forState:UIControlStateNormal];
    [_btn_profile setImage:[UIImage imageNamed:@"btn_profile_bold.png"] forState:UIControlStateNormal];
    
    if (![defaults_userdata boolForKey:@"isUserLogged"]) {
        ViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        myVC.open_login=@"0";
        myVC.other_vc_flag=@"1";
        [self presentViewController:myVC animated:YES completion:nil];
    }
    
}

-(void)setUpAudioRecorder
{
    // --------------------- Setting for audio ----------------------//
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMedium],AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],AVEncoderBitRateKey,
                                    [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
                                    [NSNumber numberWithInt:44100.0],AVSampleRateKey,
                                    nil];
    NSError *error = nil;
    
    // --------------------- File save Path ----------------------//
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sounds.wav", documentsDirectory]];
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];

    _isRecording = YES;
    //----------------------------------------------------
//    [audioPlayer setVolume:1.0];
    audioRecorder.delegate = self;
    if ([audioRecorder prepareToRecord] == YES){
        [audioRecorder prepareToRecord];
        
    }else {
        int errorCode = CFSwapInt16HostToBig ([error code]);//
        NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
    }
    NSLog(@"url is %@",objectData);
    [audioRecorder setMeteringEnabled:YES];
    [audioRecorder record];
    NSLog(@"Recording...");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
}


- (IBAction)btn_save_next:(id)sender {
    if (audioPlayer.isPlaying) {
        [audioPlayer stop];
        [audioRecorder stop];
    }
    [recordingTimer invalidate];
    
    [self.view endEditing:YES];
    if (save_next_status==0)
    {//|| [[_tf_genre.text stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0
        if ([[_tf_topic.text stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0) {
            if ([[_tf_topic.text stringByReplacingOccurrencesOfString:@" " withString:@""] length]==0) {
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"Alert"
                                              message:@"Topic must not be empty!"
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"Ok"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action)
                                            {
                                                //Handel your yes please button action here
                                            }];
                
                [alert addAction:yesButton];
                [self presentViewController:alert animated:YES completion:nil];
            }

        }else{
            save_next_status=1;
            [_btn_next_save setTitle:@"Save" forState:UIControlStateNormal];
            [_btn_back_cancel setTitle:@"Back" forState:UIControlStateNormal];
            _view_select_asmelody.hidden=NO;
            _view_select_asrecording.hidden=NO;
            _view_topic.hidden=YES;
            _view_genre.hidden=YES;
            //_view_add_cover.hidden=YES;
            _lbl_text.text=@"Would you like to save as an instrumental or recording ?";
        }
    }
    else{
        if (rec_type==0) {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Alert"
                                          message:@"Please select recording type"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"Ok"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            //Handel your yes please button action here
                                        }];
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else{
            _view_saveas_popup.hidden=YES;
            _view_select_asmelody.hidden=YES;
            _view_select_asrecording.hidden=YES;
            _view_topic.hidden=NO;
            _view_genre.hidden=NO;
            [_btn_next_save setTitle:@"Next" forState:UIControlStateNormal];
            [_btn_back_cancel setTitle:@"Cancel" forState:UIControlStateNormal];
            _lbl_text.text=@"Choose topic Name and Genre if you want to be noticed";
            save_next_status=0;
            [self audioMixing];
        }
    }
}



-(void)uploadrecording{
    
    [SVProgressHUD show];
    int k;
    NSMutableArray*arr_user_instrument_ids=[[NSMutableArray alloc]init];
    NSMutableArray*arr_admin_instrument_ids=[[NSMutableArray alloc]init];
    
    for (k=0; k<[arr_melodypack_instrumentals count]; k++) {
        if ([[[arr_melodypack_instrumentals objectAtIndex:k] valueForKey:@"instruments_type"] isEqual:@"User"]) {
            [arr_user_instrument_ids addObject:[[arr_melodypack_instrumentals objectAtIndex:k] valueForKey:@"id"]];
        }
        else{
            [arr_admin_instrument_ids addObject:[[arr_melodypack_instrumentals objectAtIndex:k] valueForKey:@"id"]];
            
        }
        
    }
    
    NSDictionary* params = @{
                             KEY_AUTH_KEY:KEY_AUTH_VALUE,
                             @"user_id":[defaults_userdata valueForKey:@"user_id"],
                             @"topic_name":_tf_topic.text,
                             @"genere":str_genre_id,
                             @"public_flag":[NSString stringWithFormat:@"%d",public_flag],
                             @"admin_instruments_ids":[arr_admin_instrument_ids componentsJoinedByString:@","],
                             @"user_instruments_ids":[arr_user_instrument_ids componentsJoinedByString:@","],
                             @"recording_type":[NSString stringWithFormat:@"%d",rec_type],
                             @"duration":_lbl_timer.text,
                             @"bpm":@"46"
                             
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
    NSString* urlString = [NSString stringWithFormat:@"%@Add_Recording.php",BaseUrl];
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
            [SVProgressHUD dismiss];
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Message"
                                          message:@"Internet not available !"
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
                    dic_response=[jsonResponse objectForKey:@"response"];
                    NSLog(@"%@",dic_response);
                    
                    dic=[[NSMutableDictionary alloc]init];
                    [dic setObject:[defaults_userdata objectForKey:@"user_name"] forKey:@"username"];
                    [dic setObject:[defaults_userdata objectForKey:@"profile_pic_url"] forKey:@"profilepic"];
                    [dic setObject:_tf_topic.text forKey:@"instruments_name"];
                    [dic setObject:_tf_genre.text forKey:@"genre"];
                    [dic setObject:[[dic_response objectForKey:@"melody_data"] objectForKey:@"id"] forKey:@"id"];
                    [dic setObject:_lbl_timer.text forKey:@"duration"];
                    [dic setObject:[[dic_response objectForKey:@"melody_data"] objectForKey:@"bpm"] forKey:@"bpm"];
                    [dic setObject:@"User" forKey:@"instruments_type"];
                    
                    if (rec_type==1) {
                        isMelody=@"Melody";
                    }
                    else{
                        isMelody=@"Recording";
                    }
                    
                    //----------------------loading file------------------------------------//
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDirectory = [paths objectAtIndex:0];
                    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sounds.wav", documentsDirectory]];
                    
                    NSLog(@"url is %@",url);
                    NSString *fileName = [url lastPathComponent];
                    /****************uploading recorded file*****************/
                    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                    [manager POST:[NSString stringWithFormat:@"%@upload_cover_melody_file.php",BaseUrl] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                        [formData appendPartWithFileData:[NSData dataWithContentsOfURL:url]
                                                    name:@"file1"
                                                fileName:fileName mimeType:@"multipart/form-data"];
                        
                        [formData appendPartWithFormData:[@"3" dataUsingEncoding:NSUTF8StringEncoding]
                                                    name:KEY_SHARE_FILETYPE];
                        [formData appendPartWithFormData:[isMelody dataUsingEncoding:NSUTF8StringEncoding]
                                                    name:@"isMelody"];
                        [formData appendPartWithFormData:[[[dic_response objectForKey:@"melody_data"] objectForKey:@"id"] dataUsingEncoding:NSUTF8StringEncoding]
                                                    name:@"melodyOrRecordingID"];
                        [formData appendPartWithFormData:[KEY_AUTH_VALUE dataUsingEncoding:NSUTF8StringEncoding]
                                                    name:KEY_AUTH_KEY];
                        
                        // etc.
                    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                        
                        //[SVProgressHUD dismiss];
                        NSLog(@"Response: %@", responseObject);
                        if ([[responseObject objectForKey:@"flag"] isEqual:@"success"]) {
                            if (imageData.length>0) {
                            }
                            else
                            {
                                [arr_instrument_paths addObject:[NSString stringWithFormat:@"%@/sounds.wav", documentsDirectory]];
                                
                                [arr_melodypack_instrumentals insertObject:dic atIndex:[arr_melodypack_instrumentals count]];
                                [_tbl_view_instrumentals reloadData];
                            }
                            
                            _tbl_view_instrumentals.hidden=NO;
                            _view_messege.hidden=YES;
                            _tf_genre.text=nil;
                            _tf_topic.text=nil;
                        }
                        else{
                            
                            UIAlertController * alert=   [UIAlertController
                                                          alertControllerWithTitle:@"Message"
                                                          message:@"Error to upload file !"
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
                        
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        NSLog(@"Error: %@", error);
                        [SVProgressHUD dismiss];
                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"Error!"
                                                      message:@"internet not available!"
                                                      preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* yesButton = [UIAlertAction
                                                    actionWithTitle:@"Ok"
                                                    style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action)
                                                    {
                                                        //Handel your yes please button action here
                                                        
                                                    }];
                        
                        [alert addAction:yesButton];
                        [self presentViewController:alert animated:YES completion:nil];
                    }];
                    
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

//--------------- * For testing purpose *--------------------
-(void)uploadAudio{
    
    //--------------------------* Set JSON Array *-----------------------------
    NSData* data = [ NSJSONSerialization dataWithJSONObject:arr_recordingM options:NSJSONWritingPrettyPrinted error:nil ];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    
    //--------------------------* loading file *-------------------------------
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sounds.wav", documentsDirectory]];
    NSString *fileName = [url lastPathComponent];
    /* ----------------- ** uploading recorded file ** ----------------- */
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@test.php",BaseUrl] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:[NSData dataWithContentsOfURL:url]
                                    name:@"vocalsound"
                                fileName:fileName mimeType:@"multipart/form-data"];

        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
     
    }
         progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
             NSLog(@"Response: %@", responseObject);
             if ([[responseObject objectForKey:@"flag"] isEqualToString:@"success"]) {
                 
             }
         }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              NSLog(@"Error: %@", error);
              [Appdelegate hideProgressHudInView];
              
          }];
}

-(NSString*)bpm_count:(NSInteger)index {
    NSString *str_BPM;
    NSInteger sum = 0;
    int i;
    for (i = 0; i< arr_melodypack_instrumentals.count; i++) {
        sum = sum + [[[arr_melodypack_instrumentals objectAtIndex:i]  objectForKey:@"bpm"]integerValue];
    }
    sum = sum / i;
    str_BPM = [NSString stringWithFormat:@"%li",(long)sum];
    
    return str_BPM;
}


-(void)audioMixing
{
    
    [sliderTimer invalidate];
    sliderTimer = nil;
    
    NSString * str_totalDuration = [NSString stringWithFormat:@"%ld",(long)totalDuration];
    [Appdelegate showProgressHud];
    int k;
//    [self uploadAudio];
    dic_recording = [[NSMutableDictionary alloc]init];
    arr_recordingM = [[NSMutableArray alloc]init];
    NSInteger sum = 0;
    NSString *str_BPM;

    for (k=0; k<[arr_melodypack_instrumentals count]; k++) {
        
        sum = sum + [[[arr_melodypack_instrumentals objectAtIndex:k]  objectForKey:@"bpm"]integerValue];
        
        NSString *uploadStr=[[arr_melodypack_instrumentals objectAtIndex:k] valueForKey:@"instrument_url"];
        NSArray *uploadFileUrl=[uploadStr componentsSeparatedByString:@"uploads"];
        dic_recording = [NSMutableDictionary new];
        [dic_recording setValue:@"-5" forKey:@"Bass"];
        [dic_recording setValue:@"20" forKey:@"Treble"];
        [dic_recording setValue:@"0" forKey:@"Pan"];
        [dic_recording setValue:@"5" forKey:@"Volume"];
        [dic_recording setValue:@"44100" forKey:@"Pitch"];
        [dic_recording setValue:@"0" forKey:@"Reverb"];
        [dic_recording setValue:@"0" forKey:@"Compression"];
        [dic_recording setValue:@"0" forKey:@"Delay"];
        [dic_recording setValue:@"0" forKey:@"Tempo"];
        [dic_recording setValue:@"0" forKey:@"threshold"];
        [dic_recording setValue:@"0" forKey:@"ratio"];
        [dic_recording setValue:@"0" forKey:@"attack"];
        [dic_recording setValue:@"0" forKey:@"release"];
        [dic_recording setValue:@"0" forKey:@"makeup"];
        [dic_recording setValue:@"0" forKey:@"knee"];
        [dic_recording setValue:@"0" forKey:@"mix"];
        [dic_recording setValue:@"0" forKey:@"PositionId"];
        if ([[[arr_melodypack_instrumentals objectAtIndex:k] valueForKey:@"instruments_type"] isEqual:@"user_melody"]) {
            
            uploadStr =[NSString stringWithFormat:@"uploads%@",uploadFileUrl.lastObject];
            [dic_recording setValue:uploadStr forKey:@"fileurl"];
            [dic_recording setValue:[[arr_melodypack_instrumentals objectAtIndex:k] valueForKey:@"id"] forKey:@"id"];
        }
        else{
            if (_isJoinScreen && [_str_instrumentTYPE isEqualToString:INSTRUMENT_TYPE])
            {
                [dic_recording setValue:[[arr_melodypack_instrumentals objectAtIndex:k] valueForKey:@"instrument_id"] forKey:@"id"];
            }
            else{
                [dic_recording setValue:[[arr_melodypack_instrumentals objectAtIndex:k] valueForKey:@"id"] forKey:@"id"];
            }
            uploadStr =[NSString stringWithFormat:@"uploads%@",uploadFileUrl.lastObject];
            [dic_recording setValue:uploadStr forKey:@"fileurl"];
            [arr_recordingM insertObject:dic_recording atIndex:k];
        }
        
    }
    
    sum = sum / k;
    if (sum == 0) {
        str_BPM = @"120";
    }
    else{
        str_BPM = [NSString stringWithFormat:@"%li",(long)sum];
    }
    
    //--------------------------* Set JSON Array *-----------------------------
    NSData* data = [ NSJSONSerialization dataWithJSONObject:arr_recordingM options:NSJSONWritingPrettyPrinted error:nil ];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //--------------------------* loading file *-------------------------------
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sounds.wav", documentsDirectory]];
    
    NSLog(@"url is %@",url);
    NSString *fileName = [url lastPathComponent];
    
    if (rec_type==1) {
        isMelody=@"Melody";
    }
    else{
        isMelody=@"Recording";
    }
    if (str_genre_id == nil || [str_genre_id isEqualToString:@""]){
        [str_genre_id setString:@""];
    }
    NSString *strRecordingWithMic;
    if([self isHeadsetPluggedIn])
    {
        strRecordingWithMic = @"withMike";
    }
    else{
        strRecordingWithMic = @"withoutMike";
    }
    
    /* ----------------- ** uploading recorded file ** ----------------- */
    NSMutableDictionary *dicParamsM = [[NSMutableDictionary alloc]init];
    
    [dicParamsM setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    [dicParamsM setObject:str_totalDuration forKey:@"duration"];
    if (arr_melodypack_instrumentals.count >0) {
        [dicParamsM setObject:str_BPM forKey:@"bpm"];
    }
    else{
        [dicParamsM setObject:@"120" forKey:@"bpm"];

    }
    
    if ([str_genre_id isEqualToString:@""]) {
        [str_genre_id setString:@"1"];
    }
    [dicParamsM setObject:str_genre_id forKey:@"genere"];
    [dicParamsM setObject:strRecordingWithMic forKey:@"recordWith"];
    [dicParamsM setObject:[NSString stringWithFormat:@"%d",public_flag] forKey:@"public_flag"];
    [dicParamsM setObject:self.tf_topic.text forKey:@"topic_name"];
    [dicParamsM setObject:isMelody forKey:@"isMelody"];
    [dicParamsM setObject:str forKey:@"recording"];
    
    [dicParamsM setObject:_str_parentID forKey:@"parentRecordingID"];
    [dicParamsM setObject:@"SaveRecord" forKey:@"command"];
    [dicParamsM setObject:[defaults_userdata valueForKey:@"user_id"] forKey:@"user_id"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@audiomixing.php",BaseUrl] parameters:dicParamsM constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:[NSData dataWithContentsOfURL:url]
                                    name:@"vocalsound"
                                fileName:fileName mimeType:@"multipart/form-data"];
        
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        
        if (imageData.length > 0 ) {
            if (imageData != nil) {
                [formData appendPartWithFileData:imageData
                                            name:@"cover"
                                        fileName:imageName mimeType:@"image/jpeg"];
            }
        }
        
    }
         progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
             NSLog(@"Response: %@", responseObject);
             [self hardReset];
             audioRecorder = nil;
             arr_recordingM = [[NSMutableArray alloc]init];
             if ([[responseObject objectForKey:@"flag"] isEqualToString:@"success"]) {
                 state=[NSMutableString stringWithFormat:@"IDLE"];
                 [defaults_userdata setValue:state forKey:@"state_recording"];
                 dic_response=[responseObject objectForKey:@"response"];
                 NSString *strUrl = [NSString stringWithFormat:@"%@%@",BaseUrl,[[dic_response objectForKey:@"melody_data"]objectForKey:@"melodyurl"]];
                 dic=[[NSMutableDictionary alloc]init];
                 [dic setObject:[NSString stringWithFormat:@"%@",[defaults_userdata objectForKey:@"user_name"]] forKey:@"username"];
                 
                 [dic setObject:[NSString stringWithFormat:@"%@%@",BaseUrl,[[dic_response objectForKey:@"melody_data"] objectForKey:@"original_cover"]] forKey:@"coverpic"];
                 [dic setObject:[defaults_userdata objectForKey:@"profile_pic_url"] forKey:@"profilepic"];
                [dic setObject:[[dic_response objectForKey:@"melody_data"] objectForKey:@"public"] forKey:@"public"];
                 
                 if(_isJoinScreen)
                 {
                     [dic setObject:[[dic_response objectForKey:@"melody_data"] objectForKey:@"packname"] forKey:@"instruments_name"];
                 }
                 else
                 {
                     [dic setObject:_tf_topic.text forKey:@"instruments_name"];
                 }
                 [dic setObject:[[dic_response objectForKey:@"melody_data"] objectForKey:@"audiofilesize"] forKey:@"file_size"];
                 
                 [dic setObject:str_totalDuration forKey:@"duration"];
                 [dic setObject:[[dic_response objectForKey:@"melody_data"] objectForKey:@"bpm"] forKey:@"bpm"];
                 //-------------------------------------------------------------
                 
                 [dic setObject:[[dic_response objectForKey:@"melody_data"] objectForKey:@"duration"] forKey:@"duration"];
                 [dic setObject:strUrl forKey:@"instrument_url"];
                 [dic setObject:@"user_melody" forKey:@"instruments_type"];

                 if (rec_type==1) {
                     [dic setObject:[[dic_response objectForKey:@"melody_data"] objectForKey:@"id"] forKey:@"melodypackid"];
                     [dic setObject:[[dic_response objectForKey:@"melody_data"] objectForKey:@"added_by_user"] forKey:@"id"];

                 }
                 else{
                     [dic setObject:[[dic_response objectForKey:@"melody_data"] objectForKey:@"added_by_user"] forKey:@"melodypackid"];

                     [dic setObject:[[dic_response objectForKey:@"melody_data"] objectForKey:@"id"] forKey:@"id"];
                 }

                 [dic setObject:[[dic_response objectForKey:@"melody_data"] objectForKey:@"add_date"] forKey:@"uploadeddate"];
                 //-------------------------------------------------------------
                 [arr_melodypack_instrumentals addObject:dic];
                 [self setCounterForIndex];
                 _lbl_noinstrumentals.text=[NSString stringWithFormat:@"%lu Instrumentals",(unsigned long)[arr_melodypack_instrumentals count]];
                 _tbl_view_instrumentals.hidden=NO;
                 isAudMixing=YES;
                 _view_saveas_popup.hidden=YES;
                 _tf_topic.text=nil;
                 _tf_genre.text=nil;
                 

                 [Appdelegate hideProgressHudInView];
                 
                 /************ For Melody *************/
                 if (rec_type == 1 && ![_fromScreen isEqualToString:@"CHAT"]) {
                     [_tbl_view_instrumentals reloadData];
                     [self load_instrumentals];
                 }
                 /************ For Other *************/
                 else{
                 if (_isJoinScreen)
                 {
                     [ProgressHUD showSuccess:@"Joined Successfully !"];
                 }
                 else
                 {
                     [ProgressHUD showSuccess:@"Saved Successfully !"];
                 }
                 
                 NSLog(@"THUMBURL %@",[[dic_response objectForKey:@"melody_data"] objectForKey:@"thumbnail_url"]);
                 thumbNailUrl = [Appdelegate valueOrNil:[[dic_response objectForKey:@"melody_data"] objectForKey:@"thumbnail_url"]];
                 if (_isJoinScreen)
                 {
                     //...
                    [self backToChatView];
                     
                 }
                 else
                 {
                     if ([google_status isEqualToString:@"0"] && [fb_status isEqualToString:@"0"] && [twitter_status isEqualToString:@"0"])
                     {
                         [self backToChatView];
                     }
                     else
                     {
                         [self shareWithSocialNetwork:thumbNailUrl];
                     }
                    
                 }
                 }
              
                 
             }
             else
             {
                 [Appdelegate hideProgressHudInView];
                 
                 if ([[responseObject objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                     UIAlertController * alert=   [UIAlertController
                                                   alertControllerWithTitle:@"Message"
                                                   message:[responseObject objectForKey:@"msg"]
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
             
         }
          failure:^(NSURLSessionDataTask *task, NSError *error) {
              NSLog(@"Error: %@", error);
              arr_recordingM = [[NSMutableArray alloc]init];

              [Appdelegate hideProgressHudInView];
              
          }];
    
}


-(void)hardReset
{
    if (audioPlayer.isPlaying) {
        [audioPlayer pause];
        audioPlayer = nil;
        [sliderTimer invalidate];
        [self.player pause];
    }
    
    if ([state isEqualToString:@"RECORDED"]) {
        _lbl_timer.text=@"00:00:00";
        totalSeconds = 0;
        [self resetMuteSolo];
        //        [recordingTimer invalidate];
        [sliderTimer invalidate];
        sliderTimer = nil;
        recordingTimer = nil;
        seconds=0;
        minutes=0;
        hours=0;
        [recordingTimer invalidate];
        _lbl_public.hidden=YES;
        _switch_public.hidden=YES;
        [_switch_public setOn:NO animated:YES];
        state=[NSMutableString stringWithFormat:@"IDLE"];
        [defaults_userdata setValue:state forKey:@"state_recording"];
        
        [_btn_record_activities setImage:[UIImage imageNamed:@"btn_ready_to_recording.png"] forState:UIControlStateNormal];
        [_view_state setBackgroundColor:[UIColor whiteColor]];
        [_btn_state setImage:[UIImage imageNamed:@"state_add_melody.png"] forState:UIControlStateNormal];
        i=1;
        isPlayable = NO;
        _btn_playAll.enabled = NO;
        [self load_instrumentals];
        indexForInstrument = 0;
    }
}



-(void)backToChatView
{
    NSLog(@"SCREEN %@",_fromScreen);
    if ([_fromScreen isEqualToString:@"CHAT"]) {
        
        if (_isJoinScreen) {
            chatViewController *cv = [self.storyboard instantiateViewControllerWithIdentifier:@"chatViewController"];
            NSLog(@"CHAT DICT %@",_chatDict);
            isAudMixing=NO;
            cv.str_chat_id=[_chatDict objectForKey:@"chatID"];;
            cv.str_sender_ID=[_chatDict objectForKey:@"currentUserID"];
            cv.str_receiver_id=[_chatDict objectForKey:@"recvID"];
            cv.str_receiver_name=[_chatDict objectForKey:@"chatName"];
            cv.str_GroupName=[_chatDict objectForKey:@"chatName"];
            [self presentViewController:cv animated:YES completion:nil];
        }
        else
        {
            [self showAlertWithNoButton:@"Alert!" message:@"Do you want to share this recording/melody on YoMelody chat?"];
        }
        
    }
    else{
        if (_isJoinScreen) {
            StudioPlayViewController *studioPlayVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StudioPlayViewController"];
            studioPlayVC.stationDict=_stationDict;
            [self presentModalViewController:studioPlayVC animated:NO];
            
        }
        else
        {
            NSLog(@"REC TYPE  === %d",rec_type);//1 mel
            NSLog(@"PUBLIC TYPE === %@",[dic objectForKey:@"public"]);
            if(rec_type == 2)
            {
                if([[dic objectForKey:@"public"] isEqualToString:@"1"])
                {
                    AudioFeedViewController *audioFeedVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AudioFeedViewController"];
                    [self presentModalViewController:audioFeedVC animated:NO];
                }
                else
                {
                    MelodyViewController *recordingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MelodyViewController"];
                    recordingVC.view_recording_visible=@"YES";
                    [self presentModalViewController:recordingVC animated:NO];
                }
            }
            
        }
        
    }
}


- (void)showAlertWithNoButton:(NSString *)title message:(NSString *)message {
  
    
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *no =
    [UIAlertAction actionWithTitle:@"No"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {
         
         chatViewController *cv = [self.storyboard instantiateViewControllerWithIdentifier:@"chatViewController"];
         NSLog(@"CHAT DICT %@",_chatDict);
         isAudMixing=NO;
         cv.str_chat_id=[_chatDict objectForKey:@"chatID"];;
         cv.str_sender_ID=[_chatDict objectForKey:@"currentUserID"];
         cv.str_receiver_id=[_chatDict objectForKey:@"recvID"];
         cv.str_receiver_name=[_chatDict objectForKey:@"chatName"];
         cv.str_GroupName=[_chatDict objectForKey:@"chatName"];
         [self presentViewController:cv animated:YES completion:nil];
     }];
    UIAlertAction *yes =
    [UIAlertAction actionWithTitle:@"Yes"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {
         chatViewController *cv = [self.storyboard instantiateViewControllerWithIdentifier:@"chatViewController"];
         NSLog(@"CHAT DICT %@",_chatDict);
         isAudMixing=NO;
         cv.str_chat_id=[_chatDict objectForKey:@"chatID"];;
         cv.str_sender_ID=[_chatDict objectForKey:@"currentUserID"];
         cv.str_receiver_id=[_chatDict objectForKey:@"recvID"];
         cv.str_receiver_name=[_chatDict objectForKey:@"chatName"];
         cv.str_GroupName=[_chatDict objectForKey:@"chatName"];
         
        // new Logic
         //melodypackid

//         cv.str_file_id =[dic objectForKey:@"id"];
         if (rec_type==1)
         {
             cv.str_screen_type =@"user_melody";
             cv.str_file_id =[dic objectForKey:@"melodypackid"];

         }
         else
         {
             cv.str_file_id =[dic objectForKey:@"id"];
             cv.str_screen_type =@"station";
         }
         
         cv.isShare_Audio = YES;
         [self presentViewController:cv animated:YES completion:nil];
         
     }];
    [alert addAction:no];
    
    [alert addAction:yes];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)showGooglePlusShare:(NSURL*)shareURL {
    
    // Construct the Google+ share URL
//    GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/plus.me")
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


- (void)showTwitterShare:(NSURL*)shareURL {
    
    NSURLComponents* urlComponentsTwitter = [[NSURLComponents alloc]
                                             initWithString:@"http://www.twitter.com/share"];
    urlComponentsTwitter.queryItems = @[[[NSURLQueryItem alloc]
                                         initWithName:@"url"
                                         value:[shareURL absoluteString]]];
    NSURL* urlTwitter = [urlComponentsTwitter URL];
    NSLog(@"LINK URL TWITTER==2====    %@",urlTwitter);
    if ([SFSafariViewController class]) {
        // Open the URL in SFSafariViewController (iOS 9+)
        NSLog(@"LINK URL TWITTER==3====    %@",urlTwitter);
        SFSafariViewController* controllerTwitter = [[SFSafariViewController alloc]
                                                     initWithURL:urlTwitter];
        controllerTwitter.delegate = self;
        [controllerTwitter didMoveToParentViewController:self];
        [self presentViewController:controllerTwitter animated:YES completion:nil];
        
    } else {
        // Open the URL in the device's browser
        NSURL *linkUrl = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://post?message=%@",shareURL]];
        NSLog(@"LINK URL TWITTER==4====    %@",linkUrl);
        [[UIApplication sharedApplication] openURL:linkUrl];
    }
    
}

- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully{
  
}

- (void)safariViewController:(SFSafariViewController *)controller initialLoadDidRedirectToURL:(NSURL *)URL
{
    
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller{
    controller = nil;
    if([twitter_status isEqualToString:@"1"]){
    if (isTwitter == YES) {
        isTwitter = NO;
        TWTRComposer *composer = [[TWTRComposer alloc] init];
        [composer setURL:[NSURL URLWithString:thumbNailUrl]];
        [composer showFromViewController:self completion:^(TWTRComposerResult result) {
            if (result == TWTRComposerResultCancelled) {
                //[NSURL URLWithString:@"twitter://"]
                if (![[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
                    [self showTwitterShare:[NSURL URLWithString:thumbNailUrl]];
                }
                NSLog(@"Tweet composition cancelled");
            }
            else if(result == TWTRComposerResultDone){
                [self backToChatView];

            }
            else {
                NSLog(@"Sending Tweet!");
            }
        }];
    }
    }
    else{
        [self backToChatView];
    }
    
}

- (NSArray<UIActivity *> *)safariViewController:(SFSafariViewController *)controller activityItemsForURL:(NSURL *)URL     title:(nullable NSString *)title
{
    NSLog(@"safariViewController activityItemsForURL");
    return @[];
}



-(void)sharingMailUsing_Gmail{
    // Create the message
    
    
}

-(void)finishedSharingWithError:(NSError *)error{
    
}


-(void)finishedSharing:(BOOL)shared{
    
}

-(void)shareWithSocialNetwork:(NSString *)withThumbNailUrl
{
    NSLog(@"STATUS OF FACEBOOK %@",fb_status);
    NSLog(@"STATUS OF TWITTER %@",twitter_status);
    NSLog(@"STATUS OF GOOGLE %@",google_status);
    strThumbnailURL = withThumbNailUrl;
    
    
    if ([google_status isEqualToString:@"1"])
    {
            [self showGooglePlusShare:[NSURL URLWithString:withThumbNailUrl]];
    }
    if ([fb_status isEqualToString:@"1"])
    {
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:withThumbNailUrl];
        FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
        dialog.delegate = self;
        dialog.fromViewController= self;
        // dialog.fromViewController = viewController;
        dialog.shareContent = content;
        dialog.mode = FBSDKShareDialogModeNative; // if you don't set this before canShow call, canShow would always return YES
        if (![dialog canShow]) {
            // fallback presentation when there is no FB app
            dialog.mode = FBSDKShareDialogModeFeedBrowser;
        }
        [dialog show];
    }
    
    //3rd METHOD
    if ([twitter_status isEqualToString:@"1"] && ![google_status isEqualToString:@"1"])
    {
        [self showTwitterShare:[NSURL URLWithString:withThumbNailUrl]];
        isTwitter =NO;
    }
   

}

#pragma mark-FBSDKSharingDelegate
#pragma mark-

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    NSLog(@"completed");
}
- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"fail %@",error.description);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"cancel");
    [self backToChatView];
}


- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    if (error != nil) {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
    } else {
        self.signInButton.hidden = true;
        self.output.hidden = false;
        self.service.authorizer = user.authentication.fetcherAuthorizer;
        [self fetchLabels];
    }
}


// Construct a query and get a list of labels from the user's gmail. Display the
// label name in the UITextView
- (void)fetchLabels {
    self.output.text = strThumbnailURL;
    GTLRUploadParameters *uploadParam = [[GTLRUploadParameters alloc] init];
    uploadParam.MIMEType = @"message/rfc822";
    uploadParam.data = [self getFormattedRawMessage];
    
    GTLRGmailQuery_UsersMessagesSend *query = [GTLRGmailQuery_UsersMessagesSend queryWithObject:strThumbnailURL userId:@"me" uploadParameters:uploadParam];
    [self.service executeQuery:query completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        
        NSData *data  = callbackError.userInfo[@"data"];
        NSString *string = [[NSString alloc] initWithData:data encoding:0];
        
        NSLog(@"%@",string);
    }];
}


- (NSData *)getFormattedRawMessage
{
    // Date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z";
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    NSString *finalDate = [NSString stringWithFormat:@"Date: %@\r\n", strDate];
    
    // From string
    NSString *from = @"From: <constantin.saulenco@gmail.com>\r\n";
    
    // To string
    NSString *to = @"To: <constantin.saulenco@mobiversal.com>\r\n";
    
    // CC string
    NSString *cc = @"";
    
    // BCC string
    NSString *bcc = @"";
    
    // Subject string
    NSString *subject = @"Subject: New stuff\r\n\r\n";
    
    // Body string
    NSString *body = @"Hello my friend, \n can you please call me when have free time. \nMark. \r\n";
    
    // Final string to be returned
    NSString *rawMessage = @"";
    
    // Send as "multipart/mixed"
    NSString *contentTypeMain = @"Content-Type: multipart/mixed; boundary=\"project\"\r\n";
    
    // Reusable Boundary string
    NSString *boundary = @"\r\n--project\r\n";
    
    // Body string
    NSString *contentTypePlain = @"Content-Type: text/plain; charset=\"UTF-8\"\r\n";
    
    // Combine strings from "finalDate" to "body"
    rawMessage = [[[[[[[[[contentTypeMain stringByAppendingString:finalDate] stringByAppendingString:from]stringByAppendingString:to]stringByAppendingString:cc]stringByAppendingString:bcc]stringByAppendingString:subject]stringByAppendingString:boundary]stringByAppendingString:contentTypePlain]stringByAppendingString:body];
    
    
    // Image Content Type string
    NSString *contentTypeJPG = boundary;
    contentTypeJPG = [contentTypeJPG stringByAppendingString:[NSString stringWithFormat:@"Content-Type: image/jpeg; name=\"%@\"\r\n",@"IMG_1253.jpg"]];
    contentTypeJPG = [contentTypeJPG stringByAppendingString:@"Content-Transfer-Encoding: base64\r\n"];
    
    return [rawMessage dataUsingEncoding:NSUTF8StringEncoding];
}


- (void)displayResultWithTicket:(GTLRServiceTicket *)ticket
             finishedWithObject:(GTLRGmail_ListLabelsResponse *)labelsResponse
                          error:(NSError *)error {
    if (error == nil) {
        NSMutableString *labelString = [[NSMutableString alloc] init];
        if (labelsResponse.labels.count > 0) {
            [labelString appendString:@"Labels:\n"];
            for (GTLRGmail_Label *label in labelsResponse.labels) {
                [labelString appendFormat:@"%@\n", label.name];
            }
        } else {
            [labelString appendString:@"No labels found."];
        }
        self.output.text = labelString;
    } else {
        [self showAlert:@"Error" message:error.localizedDescription];
    }
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {
         [alert dismissViewControllerAnimated:YES completion:nil];
     }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}



- (IBAction)btn_genre:(id)sender {
    [self.view endEditing:YES];
    _view_genre_dropdown.hidden=NO;
    _img_view_errow.image=[UIImage imageNamed:@"down_arrow2.png"];
}



- (IBAction)btn_add_cover:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}


- (IBAction)btn_genre_ok:(UIButton*)sender {
    _view_genre_dropdown.hidden=YES;
    _img_view_errow.image=[UIImage imageNamed:@"right_arrow.png"];
    if ([arr_genre_select containsObject: @"1"]) {
        _tf_genre.text=[arr_genre objectAtIndex:sender.tag];
        str_genre_id=[arr_genre_id objectAtIndex:sender.tag];
        for (int z=0; z<[arr_genre_select count]; z++) {
            
            [arr_genre_select replaceObjectAtIndex:z withObject:@"0"];
        }
    }
    else
    {
        _tf_genre.text=nil;
    }
    [_btn_genre_ok setTitle:@"Cancel" forState:UIControlStateNormal];
    [_tbl_view_genre reloadData];
}






- (IBAction)btn_sync:(id)sender {
    
    if (sync_flag==0) {
        sync_flag=1;
        _btn_sync.backgroundColor=[UIColor blueColor];
    }
    else
    {
        sync_flag=0;
        _btn_sync.backgroundColor=[UIColor whiteColor];
    }
    
    
    
    
    
}
- (IBAction)btn_fxeq_hide:(id)sender {
    _view_fxeq.hidden=YES;
}
- (IBAction)btn_melody_select:(id)sender {
    
    if (rec_type!=1) {
        [_btn_melody_select setBackgroundColor:[UIColor blueColor]];
        [_btn_recording_select setBackgroundColor:[UIColor lightGrayColor]];
        rec_type=1;
    }
    else
    {
        [_btn_melody_select setBackgroundColor:[UIColor lightGrayColor]];
        rec_type=0;
    }
}

- (IBAction)btn_rec_select:(id)sender {
    if (rec_type!=2) {
        [_btn_melody_select setBackgroundColor:[UIColor lightGrayColor]];
        [_btn_recording_select setBackgroundColor:[UIColor blueColor]];
        rec_type=2;
    }
    else
    {
        [_btn_recording_select setBackgroundColor:[UIColor lightGrayColor]];
        rec_type=0;
    }
}


#pragma mark - set Wave View
#pragma mark -

- (void)initWaveViewDefault{
    
}

- (void)initAudioRecorder{
    NSArray *directories=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath=[directories objectAtIndex:0];
    NSString *recordPath=[documentPath stringByAppendingPathComponent:@"record.m4a"];
    
    NSURL *recordURL=[NSURL fileURLWithPath:recordPath];
    
    NSDictionary *setting=[NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInt:kAudioFormatMPEG4AAC],AVFormatIDKey,
                           [NSNumber numberWithFloat:44100.0],AVSampleRateKey,
                           [NSNumber numberWithInt:1],AVNumberOfChannelsKey, nil];
    
    audioRecorder=[[AVAudioRecorder alloc] initWithURL:recordURL settings:setting error:nil];
    [audioRecorder setMeteringEnabled:YES];
    [audioRecorder prepareToRecord];
    
}

@end

@implementation StudioRecViewController (Private)

- (CustomizationState)nextCustomizationState:(CustomizationState)state {
    switch (state) {
        case CustomizationStateCustomAttributed: return 0;
        default: return (state + 1);
    }
}

- (NSString*)buttonTextForState:(CustomizationState)state {
    switch ([self nextCustomizationState:state]) {
        case CustomizationStateDefault: return @"BACK TO DEFAULTS";
        case CustomizationStateCustom: return @"CUSTOMIZE";
        case CustomizationStateCustomAttributed: return @"ADD ATTRIBUTED TEXT";
    }
}

- (void)customizeAccordingToState:(CustomizationState)state {
    BOOL customized = state != CustomizationStateDefault;
    
    // Progress Bar Customization
    [_circleProgressBar setProgressBarWidth:(customized ? 12.0f : 0)];
    [_circleProgressBar setProgressBarProgressColor:(customized ? [UIColor colorWithRed:0.2 green:0.7 blue:1.0 alpha:0.8] : nil)];
    [_circleProgressBar setProgressBarTrackColor:(customized ? [UIColor colorWithWhite:0.000 alpha:0.800] : nil)];
    
    // Hint View Customization
    [_circleProgressBar setHintViewSpacing:(customized ? 10.0f : 0)];
    [_circleProgressBar setHintViewBackgroundColor:(customized ? [UIColor colorWithWhite:1.000 alpha:0.800] : nil)];
    [_circleProgressBar setHintTextFont:(customized ? [UIFont fontWithName:@"AvenirNextCondensed-Heavy" size:40.0f] : nil)];
    [_circleProgressBar setHintTextColor:(customized ? [UIColor blackColor] : nil)];
    [_circleProgressBar setHintTextGenerationBlock:(customized ? ^NSString *(CGFloat progress) {
        return [NSString stringWithFormat:@"%.0f / 255", progress * 255];
    } : nil)];
    
    // Attributed String
    [_circleProgressBar setHintAttributedGenerationBlock:(state == CustomizationStateCustomAttributed ? ^NSAttributedString *(CGFloat progress) {
        NSString *formatString = [NSString stringWithFormat:@"%.0f / 255", progress * 255];
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:formatString];
        [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNextCondensed-Heavy" size:40.0f] range:NSMakeRange(0, string.length)];
        
        NSArray *components = [formatString componentsSeparatedByString:@"/"];
        UIColor *valueColor = [UIColor colorWithRed:(0.2f) green:(0.2f) blue:(0.5f + progress * 0.5f) alpha:1.0f];
        [string addAttribute:NSForegroundColorAttributeName value:valueColor range:NSMakeRange(0, [[components firstObject] length])];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange([[components firstObject] length], 1)];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange([[components firstObject] length] + 1, [[components lastObject] length])];
        return string;
    } : nil)];
}






#define CHUNK_SIZE 1000
#define HEADER_LENGTH 251




-(void) concatFiles:(NSString*) path1 And: (NSString*) path2 SaveTo:(NSString*) combinedPath
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSFileHandle *f1Handle = [NSFileHandle fileHandleForReadingAtPath: path1];
    NSFileHandle *f2Handle = [NSFileHandle fileHandleForReadingAtPath: path2];
    
    //might need to check if file exists first, if not create it using NSFileManager's createFileAtPath
    if(![fm fileExistsAtPath:combinedPath]){
        [fm createFileAtPath:combinedPath contents:nil attributes:nil];
    }
    
    
    NSFileHandle *combinedHandle = [NSFileHandle fileHandleForWritingAtPath: combinedPath];
    
    NSMutableData *read = [[NSMutableData alloc] initWithLength:CHUNK_SIZE];
    
    // read data in small chunks to avoid hogging memory.
    [read setData:[f1Handle readDataOfLength: CHUNK_SIZE]];
    
    while([read length] != 0)
    {
        [combinedHandle writeData: read];
        [read setData:[f1Handle readDataOfLength: CHUNK_SIZE]];
    }
    //now do the same for f2Handle
    //might need to ignore a few bytes in the front of file2 that isnt audio
    [f2Handle readDataOfLength: HEADER_LENGTH];
    
    [read  setData:[f2Handle readDataOfLength: CHUNK_SIZE]];
    while([read length] != 0)
    {
        [combinedHandle writeData: read];
        [read setData:[f2Handle readDataOfLength: CHUNK_SIZE]];
    }
    [f1Handle closeFile];
    [f2Handle closeFile];
    [combinedHandle closeFile];
}



#pragma mark - Navigation
#pragma mark -

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [audioPlayer_ofstate stop];
    [audioRecorder stop];
  
        if ([segue.identifier isEqualToString:@"go_to_melody_screen"]) {
            ///<statements#>
            MelodyViewController*vc=segue.destinationViewController;
            vc.chatDict=_chatDict;
            if (_fromScreen == nil) {
                _fromScreen = @"studio";
            }
            vc.fromScreen=_fromScreen;
            /// station
            vc.stationDict = _stationDict;
            ///
            soundsArray = [NSMutableArray new];
            audioPlayer = nil;
            [sliderTimer invalidate];
            sliderTimer = nil;
            vc.arr_instruments_added=arr_melodypack_instrumentals;
            vc.isJoinScreen = _isJoinScreen;
            vc.str_parentID = _str_parentID;
            vc.isCoverImage = _isCoverImage;
            if (imageData != nil) {
                vc.imagedata_forCover = imageData;
                vc.imagename_forCover = imageName;
                
            }
        }
        if ([segue.identifier isEqualToString:@"go_to_login"]) {
            ViewController*vc=segue.destinationViewController;
            vc.open_login=@"1";
            vc.other_vc_flag=@"1";
        }
   
}

- (IBAction)btn_cancel_back:(id)sender {
    [self.view endEditing:YES];
    if (save_next_status==1)
    {
        _view_select_asmelody.hidden=YES;
        _view_select_asrecording.hidden=YES;
        _view_topic.hidden=NO;
        _view_genre.hidden=NO;
        _view_add_cover.hidden=NO;
        [_btn_back_cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [_btn_next_save  setTitle:@"Next" forState:UIControlStateNormal];
        _lbl_text.text=@"Choose topic Name and Genre if you want to be noticed";
        save_next_status=0;
    }
    else{
        _view_saveas_popup.hidden=YES;
        _tf_topic.text=nil;
        _tf_genre.text=nil;
        
    }
    if ([[defaults_userdata valueForKey:@"state_recording"]isEqualToString:@"RECORDED"]) {
        state=[[NSMutableString alloc]initWithFormat:@"RECORDED"];
        _btn_done.userInteractionEnabled = YES;
    }
    
}



#pragma mark UIImagePickerControllerDelegate
#pragma mark -


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info
{
    
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    imageData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 0.0f);
    UIImage*img12=[info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage*compressedImage = [Appdelegate scaleImage:img12 toSize:CGSizeMake(300,300)];
    compressedImage = [Appdelegate scaleAndRotateImage:compressedImage];
    [defaults_userdata setObject:UIImagePNGRepresentation(compressedImage) forKey:@"saved_image"];
    imageData = UIImagePNGRepresentation(compressedImage);
    _imagedata_forCover = imageData;
    _img_rec_cover.image = compressedImage;
    
    imageName = [imageURL lastPathComponent];
    _imagename_forCover = imageName;
    if (([imageName  length]==0)) {
        imageName=@"image.png";
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([arr_melodypack_instrumentals count]>0) {
        [self performSelectorInBackground:@selector(someMethodForLaodData:) withObject:nil];
    }
    _isCoverImage = YES;
    
}



#pragma mark - set Tableview Delegates & Datasource
#pragma mark -

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==1) {
        return [arr_melodypack_instrumentals count];
    }else if (tableView.tag==2)
    {
        return (arr_genre.count);
    }
    else{
        return 0;
        
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==1) {
        return 105;
    }else if (tableView.tag==2)
    {
        return 44;
    }
    else{
        return 0;
        
    }
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag==1) {
        return 1;
    }else if (tableView.tag==2)
    {
        return 1;
    }
    else{
        return 0;
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag==1) {
        InstrumentalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Instruments"];
        if (cell == nil)
        {
            NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"InstrumentalTableViewCell"
                                                          owner:self options:nil];
            cell.accessoryType = UITableViewCellStyleDefault;
            cell = (InstrumentalTableViewCell*)[nib2 objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.view_activity.hidden=YES;
        cell.img_view_profile.layer.cornerRadius = cell.img_view_profile.frame.size.width / 2;
        cell.img_view_profile.clipsToBounds = YES;
        [cell.slider_progress setMinimumTrackImage:[UIImage imageNamed:@"blue_bar.png"] forState:UIControlStateNormal];
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
        cell.btn_replay.tag=indexPath.row;
        [cell.btn_replay addTarget:self action:@selector(loop_clicked:) forControlEvents:UIControlEventTouchUpInside];
        //------------------------ For loop Status -----------------------
        
        if ([[arrIndexLoopM objectAtIndex:indexPath.row] isEqualToString:@"1"]) {
            [cell.btn_replay setBackgroundColor:[UIColor redColor]];
            [cell.btn_replay setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        else
        {
            [cell.btn_replay setBackgroundColor:[UIColor whiteColor]];
            [cell.btn_replay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
        //------------------------ For Play Pause Status -----------------------

   
        if ([[arrIndexCounterPLayPauseM objectAtIndex:indexPath.row] isEqualToString:@"1"]) {
                   [cell.btn_play_pause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
            }
            else{
                [cell.btn_play_pause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
            }

    
        cell.btn_cell_delete.tag = indexPath.row;
        [cell.btn_cell_delete addTarget:self action:@selector(final_delete_clicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.btn_delete_cancel.tag = indexPath.row;
        [cell.btn_delete_cancel addTarget:self action:@selector(final_delete_cancelled:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.btn_m.tag=indexPath.row;
        [cell.btn_m addTarget:self action:@selector(btn_m_clicked:) forControlEvents:UIControlEventTouchUpInside];
        
        //----------------------* For Mute Status *--------------------
        if ([[arrIndexCounterM objectAtIndex:indexPath.row] isEqualToString:@"1"]) {
            [cell.btn_m setBackgroundColor:[UIColor redColor]];
            [cell.btn_m setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        else
        {
            [cell.btn_m setBackgroundColor:[UIColor whiteColor]];
            [cell.btn_m setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        
        cell.btn_s.tag=indexPath.row;
        [cell.btn_s addTarget:self action:@selector(btn_s_clicked:) forControlEvents:UIControlEventTouchUpInside];
        //----------------------* For Solo Status *--------------------
        
        if ([[arrIndexCounterL objectAtIndex:indexPath.row] isEqualToString:@"1"]) {
            [cell.btn_s setBackgroundColor:[UIColor greenColor]];
            [cell.btn_s setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        else
        {
            [cell.btn_s setBackgroundColor:[UIColor whiteColor]];
            [cell.btn_s setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        
        
        cell.view_delete.hidden=YES;
        
        cell.lbl_bpm.text=[[arr_melodypack_instrumentals objectAtIndex:indexPath.row] valueForKey:@"bpm"];
        cell.lbl_profile_title.text=[[arr_melodypack_instrumentals objectAtIndex:indexPath.row] valueForKey:@"instruments_name"];
        
        if (![[[arr_melodypack_instrumentals objectAtIndex:indexPath.row] valueForKey:@"username"] isKindOfClass:[NSNull class]]) {
            cell.lbl_profile_title_id.text=[[arr_melodypack_instrumentals objectAtIndex:indexPath.row] valueForKey:@"username"];
        }
        else
        {
            cell.lbl_profile_title_id.text=[NSString stringWithFormat:@"@coding"];
        }
        //-------------------* Cover pic *-------------------
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[arr_melodypack_instrumentals objectAtIndex:indexPath.row] valueForKey:@"coverpic"]]];
        
        cell.img_instrumental_cover.contentMode = UIViewContentModeScaleToFill;
        [cell.img_instrumental_cover sd_setImageWithURL:url
                                       placeholderImage:[UIImage imageNamed:@"bg_cell.png"]];
        
        //------------------* Profile pic *-------------------
        NSURL *url2 = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[arr_melodypack_instrumentals objectAtIndex:indexPath.row] valueForKey:@"profilepic"]]];
        
        cell.img_view_profile.contentMode = UIViewContentModeScaleToFill;
        [cell.img_view_profile sd_setImageWithURL:url2
                                 placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        
        //   cell.lbl_timer.text=[[arr_melodypack_instrumentals objectAtIndex:indexPath.row] valueForKey:@"duration"];
        cell.lbl_timer.text=[Appdelegate timeFormatted:[[arr_melodypack_instrumentals objectAtIndex:indexPath.row] valueForKey:@"duration"]];
        return cell;
        
    }
    else if (tableView.tag==2)
    {
        
        GenreDropdownTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:nil];
        if (cell == nil)
            
        {
            NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"GenreDropdownTableViewCell"
                                                          owner:self options:nil];
            cell.accessoryType = UITableViewCellStyleDefault;
            
            cell = (GenreDropdownTableViewCell*)[nib2 objectAtIndex:0];
            cell.lbl_genre.text=[arr_genre objectAtIndex:indexPath.row];
            cell.btn_select.layer.cornerRadius=cell.btn_select.frame.size.width/2;
            cell.btn_select.tag=indexPath.row;
            if ([[arr_genre_select objectAtIndex:indexPath.row] isEqual:@"1"]) {
                cell.btn_select.backgroundColor=[UIColor blueColor];
            }
            else{
                cell.btn_select.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
            }
            [cell.btn_select addTarget:self action:@selector(select_genre:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
        return nil;
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        return cell;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==2)
    {
        for (int z=0; z<[arr_genre_select count]; z++) {
            if (z==indexPath.row) {
                if ([[arr_genre_select objectAtIndex:z]isEqual:@"0"]) {
                    [arr_genre_select replaceObjectAtIndex:z withObject:@"1"];
                }
                else{
                    [arr_genre_select replaceObjectAtIndex:z withObject:@"0"];
                }
                
            }
            else
            {
                [arr_genre_select replaceObjectAtIndex:z withObject:@"0"];        }
            
        }
        _tf_genre.text=[arr_genre objectAtIndex:indexPath.row];
        if ([arr_genre_select containsObject: @"1"]) {
            [_btn_genre_ok setTitle:@"OK" forState:UIControlStateNormal];
        }
        else{
            [_btn_genre_ok setTitle:@"Cancel" forState:UIControlStateNormal];
        }
        [_tbl_view_genre reloadData];
        
    }
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    @try{
    InstrumentalTableViewCell *cell1 = [_tbl_view_instrumentals cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
    if ([[arrIndexCounterPLayPauseM objectAtIndex:indexPath.row] isEqualToString:@"1"]) {
        [cell1.btn_play_pause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
    }
    else{
        [cell1.btn_play_pause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];

    }
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception at willDisplayCell :%@",exception);
    }
    @finally{
        
    }
}


@end

