//
//  AudioFeedViewController.m
//  melody
//
//  Created by CodingBrainsMini on 11/21/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import "AudioFeedViewController.h"
#define YourSound @"sound.wav"
#import "Constant.h"
#import "UsersTableViewCell.h"
@interface AudioFeedViewController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    BOOL toggle_PlayPause;
    NSMutableArray*arr_slider_timer_objects;
    int recording_typeInt;
//    int recordingtype;
    NSString *artistNameString;
    NSString *searchString;
    NSString *userNameString;
    NSString *filterString;
    UIActivityIndicatorView *activityIndicatorView;
    NSMutableArray *instrumentArray,*arrUsersM;
    int text_flag;
    UIPickerView* myPickerView;
    UIAlertController *alertWithSpinner;
    NSString *numberOfInstruments;
    NSString *BPM;
    NSArray*arr_Actity,*arr_rev;
    
    NSTimer* sliderTimer;
    long i_Path,currentIndex_user;

    BOOL loadingData,isSearch;
    NSInteger current_Record,limit;
    int counter;
    BOOL isActivityClicked,isPlayable;
    NSMutableArray *arrJoinedM;
    UIActivityIndicatorView *activityIndicator;
    NSInteger currentIndexValue;
    NSMutableArray *arrStateofRecording,*arr_PublicState;
    NSString *isPublic;
    BOOL toggleFollow,isUserTab;
    NSString *str_search;
    NSArray *searchContactList,*arrUserList;

}
@end
long lastIndex = 10000;

@implementation AudioFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    recording_typeInt = 0;
    [self initialezesAllVaribles];
    isActivityClicked = NO;
    isPlayable = NO;
    isUserTab = NO;
    str_search = nil;
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.view addSubview:activityIndicator];
    isSearch = NO;
   

}

-(void)initialezesAllVaribles{
    
    toggleFollow = NO;
    currentIndex_user = 0;
    text_flag=0;
    counter = 1;
    limit = 0;
    arr_slider_timer_objects = [[NSMutableArray alloc]init];
    instrumentArray = [[NSMutableArray alloc] init];
    
    self.placeholder_img.hidden = NO;
    self.tbl_view_audio_feed.hidden = YES;
    
    // Add some data for demo purposes.
    [instrumentArray addObject:@"1"];
    [instrumentArray addObject:@"2"];
    [instrumentArray addObject:@"3"];
    [instrumentArray addObject:@"4"];
    [instrumentArray addObject:@"5"];
    arr_rec_response=[[NSMutableArray alloc]init];
    arrUsersM=[[NSMutableArray alloc]init];

    //--------------- Initialization for Lazy loading ------------------
    current_Record= 0;
    loadingData = false;
    
    //-----------------* For Pull to refresh *---------------------
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
//    [_tbl_view_audio_feed addSubview:refreshControl];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord  withOptions:AVAudioSessionCategoryOptionDuckOthers | AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers error:nil];
    // Do any additional setup after loading the view.
    defaults_userdata=[NSUserDefaults standardUserDefaults];
    arr_rec_recordings_url = [[NSMutableArray alloc]init];
    /*------------------------ in app purchase --------------------------*/
    // Adding activity indicator
    activityIndicatorView = [[UIActivityIndicatorView alloc]
                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = self.view.center;
    [activityIndicatorView hidesWhenStopped];
    [self.view addSubview:activityIndicatorView];
    [activityIndicatorView setBackgroundColor:[UIColor darkGrayColor]];
    /*-------------------------------------------------------------------*/
    
    self.tf_srearch.delegate=self;
    [self.tf_srearch addTarget:self
                        action:@selector(textFieldDidChange:)
              forControlEvents:UIControlEventEditingChanged];
    
    genre=[[NSString alloc]initWithFormat:@""];
    
    /*---------------- Assigning tag number to tableviews ---------------*/
    status=0;
    _tbl_view_audio_feed.tag=1;
    
    _tbl_view_activity.tag=2;
    _tbl_view_filter_data_list.tag=3;
    _view_activitytab.hidden=YES;
    _view_Users_tab.hidden=YES;

    
    [self.tbl_view_audio_feed setSeparatorColor:[UIColor clearColor]];
    /*-------------------------------------------------------------------*/
    arr_filter_data_list=[[NSMutableArray alloc]initWithObjects:@"Latest",@"Trending",@"Favorites",@"Artist",@"# of Instrumentals",@"BPM", nil];
    _view_filter.layer.cornerRadius=10;
    _view_search.hidden=YES;
    _view_filter_shadow.frame=CGRectMake(-800, 0, self.view.frame.size.width, self.view.frame.size.height);
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    UISwipeGestureRecognizer*swipedown=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [swipedown setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:swipedown];
    //[self.view addGestureRecognizer:tap];
    state=[[NSMutableString alloc]initWithFormat:@"IDLE"];
    audioPlayer.delegate=self;
    //----------------------* Get Activity in Background *-------------------
  //  [self performSelectorInBackground:@selector(getActivity:) withObject:nil];
   
    
    if([[defaults_userdata valueForKey:@"navigation"]isEqualToString:@"activity"]){
        [self getActivity:[[NSUserDefaults standardUserDefaults]
                           objectForKey:@"user_id"]];
        [self activityAction];
    }
    else{
        [self getActivity:[[NSUserDefaults standardUserDefaults]
                           objectForKey:@"user_id"]];
    }
}


//-----------* Logic for Pull to Refresh *-------------
- (void)refreshTable:(UIRefreshControl *)refreshControl
{
    loadingData=false;
    limit = 0;
    current_Record=0;
    [self loadRecordings];
    [refreshControl endRefreshing];
}

-(void)viewWillAppear:(BOOL)animated{
    [sliderTimer invalidate];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"updateComments"
                                               object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(receiveNotificationForUpdateShareCount:)
//                                                 name:@"updateShareCount"
//                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotificationComment:)
                                                 name:@"updatePlayCount"
                                               object:nil];
    limit =0;
    arr_rec_response =[[NSMutableArray alloc]init];
    [self loadRecordings];
    //updatePlayCount

}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) receiveNotification:(NSNotification *) notification
{
    NSLog (@"Successfully received the test notification!");
    [self loadRecordings];
}

- (void) receiveNotificationComment:(NSNotification *) notification
{
    [self loadRecordings];
}

- (void) receiveNotificationForUpdateShareCount:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"updateShareCount"])
        NSLog (@"SHARE COUNT");
  //  [self method_ShareCount:currentIndexValue];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self loadgenres];
    if (arr_rec_response == nil || arr_rec_response.count == 0) {
//        [self loadRecordings];
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [sliderTimer invalidate];
    sliderTimer = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"navigation"];

}


- (void)viewDidUnload{
    [super viewDidUnload];
    [self playerInitializes];


}

-(void)textFieldDidChange:(UITextField *)theTextField{
    NSLog( @"text changed: %@", self.tf_srearch.text);
    if ([self.tf_srearch.text length]>0) {
        text_flag=1;
        [self.btn_search_cancel setTitle:@"Search" forState:UIControlStateNormal];
    }else{
        text_flag=0;
        
    }
}





-(void)dismissKeyboard
{
    [_tf_srearch resignFirstResponder];
}



-(void)profileClicked:(UIButton*)sender{
    [self methodProfileAction:sender.tag];
    
}


-(void)methodProfileAction:(NSInteger)sender{
    NSLog(@"profileClicked");
    ProfileViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    
    
    if (isUserTab) {
        profileVC.follower_id = [[arrUsersM objectAtIndex:sender]valueForKey:@"id"];
        NSString * userId = [defaults_userdata objectForKey:@"user_id"];
        profileVC.user_id = userId;
    }
    else{
        profileVC.follower_id = [followerID objectAtIndex:sender];
        NSString * userId = [defaults_userdata objectForKey:@"user_id"];
        profileVC.user_id = userId;
    }
    
    
    
    [profileVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:profileVC animated:YES completion:nil];
}


-(void)pickerAction:(UIButton*)sender{
    self.tbl_view_filter_data_list.hidden = YES;
    self.view_filter_shadow.hidden= YES ;
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Value"
                                            rows:instrumentArray
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           numberOfInstruments = selectedValue;
                                           NSLog(@"selected value is = %@",numberOfInstruments);
                                           filterString = @"Instruments";
                                           [self loadRecordings];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
    

}


-(void)alertWithTextField:(NSInteger)indexValue{
    NSString * title = (indexValue == 3)?MSG_FilterArtistTItle:MSG_FilterBPMTItle;
    NSString * subTitle = (indexValue == 3)?MSG_FilterArtist:MSG_FilterBPM;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:subTitle
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       
                                                       if (alert.textFields.count > 0) {
                                                           
                                                           UITextField *textField = [alert.textFields firstObject];
                                                           if (indexValue == 3) {
                                                               userNameString = textField.text;
                                                           }
                                                           else{
                                                               BPM = textField.text;
                                                           }
                                                           arr_rec_response=[[NSMutableArray alloc] init];
                                                           [self loadRecordings];
                                                       }
                                                   }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       
                                                   }];
    
    [alert addAction:submit];
    [alert addAction:cancel];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"something"; // if needs
        if (indexValue == 3)
        {
            //...
        }
        else{
            textField.keyboardType=UIKeyboardTypeNumberPad;
        }
    }];
    
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
                        myVC.str_file_id = [arr_rec_pack_id objectAtIndex:sender.tag];
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
                                       NSString *link = [NSString stringWithFormat:@"%@",[[arr_rec_response objectAtIndex:sender.tag] objectForKey:@"thumbnail_url"]];
                                      // NSString *noteStr = [NSString stringWithFormat:@""];
                                       NSString *noteStr = [NSString stringWithFormat:@"Listen to %@\nOn YoMelody.com\n",[[arr_rec_response objectAtIndex:sender.tag] objectForKey:@"recording_topic"]];

                                       NSURL *url = [NSURL URLWithString:link];
                                       
                                       UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[noteStr, url] applicationActivities:nil];
                                       [self presentViewController:activityVC animated:YES completion:nil];
                                   }];
        
                        [alert addAction:noButton];
                        [alert addAction:yesButton];
                        [self presentViewController:alert animated:YES completion:nil];
                }
    else{
        [self performSegueWithIdentifier:@"go_to_login" sender:self];
    }

}




- (void)show_options:(UIButton*)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    AudioFeedTableViewCell *cell = (AudioFeedTableViewCell*)[_tbl_view_audio_feed cellForRowAtIndexPath:indexPath];
   
    if (status==0) {
        cell.btn_hide.hidden=NO;
        status=1;
    }
    else{
        cell.btn_hide.hidden=YES;
        status=0;
    }
}


-(void)hide_cellrecording:(UIButton*)sender
{
    if ([arr_rec_pack_id count]>0)
    {
        [arr_rec_pack_id removeObjectAtIndex:sender.tag];
    }
    if ([arr_rec_name count]>0)
    {
        [arr_rec_name removeObjectAtIndex:sender.tag];
    }
    if ([arr_rec_genre count]>0)
    {
        [arr_rec_genre removeObjectAtIndex:sender.tag];
    }
    if ([arr_rec_station count]>0)
    {
        [arr_rec_station removeObjectAtIndex:sender.tag];
    }
    if ([arr_rec_cover count]>0)
    {
        [arr_rec_cover removeObjectAtIndex:sender.tag];
    }
    if ([arr_rec_profile count]>0)
    {
        [arr_rec_profile removeObjectAtIndex:sender.tag];
    }
    if ([arr_rec_intrumentals count]>0)
    {
        [arr_rec_intrumentals removeObjectAtIndex:sender.tag];
    }
    if ([arr_rec_post_date count]>0)
    {
        [arr_rec_post_date removeObjectAtIndex:sender.tag];
    }
    if ([arr_rec_play_count count]>0)
    {
        [arr_rec_play_count removeObjectAtIndex:sender.tag];
    }
    if ([arr_rec_like_count count]>0)
    {
        [arr_rec_like_count removeObjectAtIndex:sender.tag];
    }
    if ([arr_rec_comment_count count]>0)
    {
        [arr_rec_comment_count removeObjectAtIndex:sender.tag];
    }
    if ([arr_rec_share_count count]>0)
    {
        [arr_rec_share_count removeObjectAtIndex:sender.tag];
    }
    
    [_tbl_view_audio_feed reloadData];
}
//two more
//[arr_rec_instrumentals_count removeObjectAtIndex:sender.tag];
// [arr_rec_bpm removeObjectAtIndex:sender.tag];


-(void)join_clicked:(UIButton*)sender
{
    if (audioPlayer.isPlaying) {
        [self playerInitializes];

    }
    
    if (![defaults_userdata boolForKey:@"isUserLogged"]) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Alert"
                                      message:@"You have to login first"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        ViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
                                        myVC.open_login=@"0";
                                        myVC.other_vc_flag=@"1";
                                        [self presentViewController:myVC animated:YES completion:nil];
                                        
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
    else{
    index=sender.tag;
    [self performSegueWithIdentifier:@"audiofeed_to_studio_play" sender:self];
    }
    
}



- (void)btn_Recordings_comment_clicked:(UIButton*)sender
{
    
    [self playerInitializes];
    if ([defaults_userdata boolForKey:@"isUserLogged"]) {
    _sender_tag=[NSString stringWithFormat:@"%ld",(long)sender.tag];
    _sender_tag=[NSString stringWithFormat:@"%ld",(long)sender.tag];
    id lc=[arr_rec_like_count objectAtIndex:[_sender_tag integerValue]];
    id ls=[arr_rec_like_status objectAtIndex:[_sender_tag integerValue]];
    NSMutableDictionary*dic=[NSMutableDictionary dictionaryWithDictionary:[arr_rec_response objectAtIndex:[_sender_tag integerValue]]];
    [dic  setObject:lc forKey:@"like_count"];
    [dic setObject:ls forKey:@"like_status"];
    NSMutableArray*arr=[NSMutableArray arrayWithArray:arr_rec_response];
    [arr replaceObjectAtIndex:[_sender_tag integerValue] withObject:dic];
    arr_rec_response=arr;

    [self performSegueWithIdentifier:@"go_to_recording_comments" sender:self];
    }
    else{
         [self performSegueWithIdentifier:@"go_to_login" sender:self];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)btn_previousAction:(UIButton *)sender {
    NSLog(@"btn_previousAction");
    instrument_play_index = sender.tag;
    [self playerInitializes];
    AudioFeedTableViewCell *cell = [self.tbl_view_audio_feed cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
    
    if (sender.tag == lastIndex && isPlayable) {
        if ([[arr_rec_response objectAtIndex:sender.tag] valueForKey:@"joined"] == [NSNull null] )
        {
            arrJoinedM = [[arr_rec_response objectAtIndex:sender.tag] valueForKey:@"joined"];
        }
        
        if (currentIndex_user > 0) {
        currentIndex_user -= 1;
            NSLog(@"currentIndex_user %ld",currentIndex_user);
            AudioFeedTableViewCell *cell = [self.tbl_view_audio_feed cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
            long includeL =[[[arr_rec_response objectAtIndex:sender.tag] valueForKey:@"join_count"]longValue];
            
            cell.lbl_oneof.text = [NSString stringWithFormat:@"( %ld of %ld )",currentIndex_user+1,includeL];
            [self playNextOrPrevious_Tapped:sender.tag];
        }
    }
    else{
        currentIndex_user = 0;
        if ([[arr_rec_response objectAtIndex:sender.tag] valueForKey:@"joined"] == [NSNull null] )
        {
            arrJoinedM = [[arr_rec_response objectAtIndex:sender.tag] valueForKey:@"joined"];
        }
        if (currentIndex_user > 0) {
            currentIndex_user -= 1;
            NSLog(@"currentIndex_user %ld",currentIndex_user);
            AudioFeedTableViewCell *cell = [self.tbl_view_audio_feed cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
            
            long includeL =[[[arr_rec_response objectAtIndex:sender.tag] valueForKey:@"join_count"]longValue];
            
            cell.lbl_oneof.text = [NSString stringWithFormat:@"( %ld of %ld )",currentIndex_user+1,includeL];
            [self playNextOrPrevious_Tapped:sender.tag];

        }
    }
}


- (void)btn_nextAction:(UIButton *)sender {
    NSLog(@"btn_nextAction");
    instrument_play_index = sender.tag;
    [self playerInitializes];

    AudioFeedTableViewCell *cell = [self.tbl_view_audio_feed cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
    if (isPlayable) {
        
        if ([[arr_rec_response objectAtIndex:sender.tag] valueForKey:@"joined"] != [NSNull null] )
        {
            arrJoinedM = [[arr_rec_response objectAtIndex:sender.tag] valueForKey:@"joined"];
        }
        
        if (currentIndex_user < arrJoinedM.count-1) {
        currentIndex_user += 1;
        NSLog(@"currentIndex_user %ld",currentIndex_user);
            
            long includeL =[[[arr_rec_response objectAtIndex:sender.tag] valueForKey:@"join_count"]longValue];
            
            cell.lbl_oneof.text = [NSString stringWithFormat:@"( %ld of %ld )",currentIndex_user+1,includeL];
            
        [self playNextOrPrevious_Tapped:sender.tag];
      
        }
        
    }
    else{
        currentIndex_user = 0;
        if (currentIndex_user > 0) {
            currentIndex_user -= 1;
            [self playNextOrPrevious_Tapped:sender.tag];
            AudioFeedTableViewCell *cell = [self.tbl_view_audio_feed cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
            
            long includeL =[[[arr_rec_response objectAtIndex:sender.tag] valueForKey:@"join_count"]longValue];
            
            cell.lbl_oneof.text = [NSString stringWithFormat:@"( %ld of %ld )",currentIndex_user+1,includeL];
        }
    }
   
}

#pragma mark - IBAction
#pragma mark -

- (IBAction)btn_audio_tab:(id)sender {
    
    [self.view endEditing:YES];
    _search_bar.hidden = YES;
    _tf_srearch.hidden = NO;
//    arr_rec_response = [[NSMutableArray alloc]init];
    isActivityClicked = NO;
    _btn_filter.hidden=NO;
    _view_audiotab.hidden=NO;
    _view_activitytab.hidden=YES;
    _view_Users_tab.hidden=YES;

    _view_audiotab.userInteractionEnabled=YES;
    [self.btn_audio_tab setBackgroundColor:[UIColor whiteColor]];
    [self.btn_activity_tab setBackgroundColor:[UIColor clearColor]];
    [self.btn_Users_tab setBackgroundColor:[UIColor clearColor]];

    _btn_audio_tab.titleLabel.font = [UIFont fontWithName:@"Helvetica Bold"  size:15.0f];
    _btn_activity_tab.titleLabel.font = [UIFont fontWithName:@"Helvetica Medium"  size:15.0f];
//    if (arr_rec_response != nil) {
//        self.placeholder_img.hidden = YES;
//        self.tbl_view_audio_feed.hidden = NO;
//        [_tbl_view_audio_feed reloadData];
//    }
//    else{
    if (arr_rec_response == nil)
    {
        arr_rec_response = [[NSMutableArray alloc]init];
        [self loadRecordings];
        
    }
    else{
        _tbl_view_audio_feed.hidden = NO;
        _tbl_view_activity.hidden = YES;
        _tbl_Users.hidden = YES;
    }

//    }
//    [_tbl_view_audio_feed reloadData];
}


- (IBAction)btn_Users_Action:(id)sender {
    
    limit = 0;
    _search_bar.hidden = NO;
    _tf_srearch.hidden = YES;
    [self.view endEditing:YES];

    _btn_filter.hidden=YES;
    _view_audiotab.hidden=YES;
    _view_activitytab.hidden=YES;
    _view_Users_tab.hidden=NO;
    
    _view_activitytab.userInteractionEnabled=YES;
    [self.btn_activity_tab setBackgroundColor:[UIColor clearColor]];
    [self.btn_audio_tab setBackgroundColor:[UIColor clearColor]];
    [self.btn_Users_tab setBackgroundColor:[UIColor whiteColor]];
    
    _btn_audio_tab.titleLabel.font = [UIFont fontWithName:@"Helvetica Medium"  size:15.0f];
    _btn_activity_tab.titleLabel.font = [UIFont fontWithName:@"Helvetica Medium"  size:15.0f];
    _btn_Users_tab.titleLabel.font = [UIFont fontWithName:@"Helvetica Bold"  size:15.0f];
    
    isUserTab = YES;
    _tbl_view_audio_feed.hidden = YES;
    _tbl_view_activity.hidden = YES;
    _tbl_Users.hidden = NO;
    [self user_List];
    
}

- (IBAction)btn_activity_tab:(id)sender {
    [self activityAction];
}


-(void)activityAction{
    
    limit = 0;
    [self playerInitializes];
    _search_bar.hidden = YES;
    _tf_srearch.hidden = NO;
    [self.view endEditing:YES];

    if (![defaults_userdata boolForKey:@"isUserLogged"]) {
        Appdelegate.screen_After_Login = Activity;
        ViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        myVC.open_login=@"0";
        myVC.other_vc_flag=@"1";
        [self presentViewController:myVC animated:YES completion:nil];
    }
    else{
        _btn_filter.hidden=YES;
        _view_audiotab.hidden=YES;
        _view_Users_tab.hidden=YES;
        _view_activitytab.hidden=NO;
        _view_activitytab.userInteractionEnabled=YES;
        [self.btn_activity_tab setBackgroundColor:[UIColor whiteColor]];
        [self.btn_Users_tab setBackgroundColor:[UIColor clearColor]];
        [self.btn_audio_tab setBackgroundColor:[UIColor clearColor]];
        _btn_audio_tab.titleLabel.font = [UIFont fontWithName:@"Helvetica Medium"  size:15.0f];
        _btn_Users_tab.titleLabel.font = [UIFont fontWithName:@"Helvetica Medium"  size:15.0f];
        _btn_activity_tab.titleLabel.font = [UIFont fontWithName:@"Helvetica Bold"  size:15.0f];
        _tbl_view_audio_feed.hidden = YES;
        _tbl_Users.hidden = YES;

        _tbl_view_activity.hidden = NO;
        [_tbl_view_activity reloadData];
    }
}


- (IBAction)btn_filter:(id)sender {
    _view_filter_shadow.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.tbl_view_filter_data_list.hidden = NO;
    self.view_filter_shadow.hidden = NO;
    recording_typeInt = 1;
}



- (IBAction)btn_filter_shadow_cancel:(id)sender {
    _view_filter_shadow.frame=CGRectMake(-800, 0, self.view.frame.size.width, self.view.frame.size.height);
}



- (IBAction)btn_search:(id)sender {
    _view_search.hidden=NO;
    arr_rec_response=[[NSMutableArray alloc]init];
    _view_main_menu.hidden=YES;
    recording_typeInt = 2;
    _tf_srearch.text=@"";
}



- (IBAction)btn_back:(id)sender {
    
    [self playerInitializes];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"notification_navigation"] isEqual:@"1"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"notification_navigation" ];
        
        Appdelegate.str_chat_status=@"0";
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device_token"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"profilepic"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
        //   [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
        
    }
    else{
        
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
}

-(void)playerInitializes{
    [audioPlayer stop];
    [sliderTimer invalidate];
    sliderTimer = nil;
    audioPlayer = nil;
}

- (IBAction)btn_home:(id)sender {
    
    [self playerInitializes];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"notification_navigation"] isEqual:@"1"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"notification_navigation" ];
        
        Appdelegate.str_chat_status=@"0";
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device_token"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"profilepic"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
        //   [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
        
    }
    else{
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
}



- (IBAction)btn_audiofeed:(id)sender {
    
    [self playerInitializes];
    [_btn_audiofeed setImage:[UIImage imageNamed:@"btn_audio_feed_bold.png"] forState:UIControlStateNormal];
    [_btn_discover setImage:[UIImage imageNamed:@"btn_discover.png"] forState:UIControlStateNormal];
    [_btn_messenger setImage:[UIImage imageNamed:@"btn_messenger.png"] forState:UIControlStateNormal];
    [_btn_profile setImage:[UIImage imageNamed:@"btn_profile.png"] forState:UIControlStateNormal];
}



- (IBAction)btn_discover:(id)sender {
    
    [self playerInitializes];
    [_btn_audiofeed setImage:[UIImage imageNamed:@"btn_audio_feed.png"] forState:UIControlStateNormal];
    [_btn_discover setImage:[UIImage imageNamed:@"btn_discover_bold.png"] forState:UIControlStateNormal];
    [_btn_messenger setImage:[UIImage imageNamed:@"btn_messenger.png"] forState:UIControlStateNormal];
    [_btn_profile setImage:[UIImage imageNamed:@"btn_profile.png"] forState:UIControlStateNormal];
}

- (IBAction)btn_messenger:(id)sender {
    
    [self playerInitializes];
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
    
    [self playerInitializes];
    [_btn_audiofeed setImage:[UIImage imageNamed:@"btn_audio_feed.png"] forState:UIControlStateNormal];
    [_btn_discover setImage:[UIImage imageNamed:@"btn_discover.png"] forState:UIControlStateNormal];
    [_btn_messenger setImage:[UIImage imageNamed:@"btn_messenger.png"] forState:UIControlStateNormal];
    [_btn_profile setImage:[UIImage imageNamed:@"btn_profile_bold.png"] forState:UIControlStateNormal];
    if (![defaults_userdata boolForKey:@"isUserLogged"]) {
        [self performSegueWithIdentifier:@"go_to_login" sender:self];
    }
    
    
}


- (IBAction)btn_search_cancel:(id)sender {
    _view_search.hidden=YES;
    text_flag=0;
    current_Record= 0;
    _view_main_menu.hidden=NO;
    [_tf_srearch resignFirstResponder];
    searchString = self.tf_srearch.text;
    if (isActivityClicked) {
        [self getActivity:[[NSUserDefaults standardUserDefaults]
                           objectForKey:@"user_id"]];
    }
    else{
        if(isUserTab){
            text_flag = 2;
            str_search = _tf_srearch.text;
//            [self user_List];
        }
        else{
            [self loadRecordings];
        }
    }

}


- (void)switchPublicToggled:(UISwitch*)sender {
    
    //- (void)switchPublicToggled:(id)sender{
    //    UISwitch *myPublicSwitch = (UISwitch *)sender;
    UISwitch *myPublicSwitch = (UISwitch *)sender;
    
    UIAlertController * alert;
    NSString *status,*message;
    index = (long)sender.tag;
    NSLog(@"New VALUE OF INDEX === %ld",(long)sender.tag);
    NSLog(@"VALUE OF INDEX === %ld",(long)index);
    message= @"As a moderator,feel free to make public or private anytime.";
    
    if ([[arr_PublicState objectAtIndex:sender.tag] isEqual:@"0"])
    {
        status=@"Make Public?";
        alert = [UIAlertController
                 alertControllerWithTitle:status
                 message:message
                 preferredStyle:UIAlertControllerStyleAlert];
    }
    else
    {
        status=@"Make Private?";
        alert = [UIAlertController
                 alertControllerWithTitle:status
                 message:message
                 preferredStyle:UIAlertControllerStyleAlert];
    }
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       //Handel your yes please button action here
                                       if ([[arr_PublicState objectAtIndex:sender.tag] isEqual:@"1"]) {
                                           [myPublicSwitch setOn:YES];
                                       }
                                       else{
                                           [myPublicSwitch setOn:NO];
                                       }
                                   }];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    //Handel your yes please button action here
                                    NSLog(@"VALUE OF INDEX=X === %ld",(long)sender.tag);
                                    if ([[arr_PublicState objectAtIndex:sender.tag] isEqual:@"1"]) {
                                        isPublic=@"0";
                                    }
                                    else{
                                        isPublic=@"1";
                                    }
                                    [self makePublicOrPrivateRecording:sender];
                                }];
    
    [alert addAction:cancelButton];
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)makePublicOrPrivateRecording:(id)sender
{
    @try{
        [Appdelegate showProgressHud];
        NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
        [params setObject:[arr_rec_pack_id objectAtIndex:index] forKey:@"rid"];
        [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"user_id"];
        [params setObject:isPublic forKey:@"ispublic"];
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
        NSString* urlString = [NSString stringWithFormat:@"%@public.php",BaseUrl];
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
                    NSMutableDictionary*dic_response=[[NSMutableDictionary alloc]init];
                    NSLog(@"%@",jsonResponse);
                    if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"Success"]) {
                        [Appdelegate hideProgressHudInView];
                        
                        dic_response=[jsonResponse objectForKey:@"response"];
                        NSLog(@"---- Before %@",arr_PublicState);
                        
                        //                        [arr_PublicState replaceObjectAtIndex:index withObject:isPublic];
                        
                        NSLog(@"**** After %@",arr_PublicState);
                        
                        NSString *succesMSG = [jsonResponse objectForKey:@"msg"];
                        
                        [TSMessage showNotificationWithTitle:NSLocalizedString(@"Success", nil)
                                                    subtitle:NSLocalizedString(succesMSG, nil)
                                                        type:TSMessageNotificationTypeSuccess];
                        arr_rec_response=[[NSMutableArray alloc]init];
                        [self loadRecordings];
                        
                    }
                    else
                    {
                        [Appdelegate hideProgressHudInView];
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
        [Appdelegate hideProgressHudInView];
        
        NSLog(@"exception at public.php %@",exception);
    }
    @finally{
        
    }
    
}


#pragma mark - TableView Delegates & Datasource
#pragma mark -

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==1) {
        if (arr_rec_pack_id) {
            return [arr_rec_pack_id count];
        }
        else{
            return 0;
        }
        
    }
    else if (tableView.tag==2)
    {
        return [arr_Actity count];
    }
    else if (tableView.tag==3)
    {
        return [arr_filter_data_list count];
        
    }
    else if (tableView ==_tbl_Users)
    {
        if (isSearch) {
            return [searchContactList count];
        }
        else{
            return [arrUsersM count];
        }
    }
    //_tbl_Users
    else
    {
        return 0;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag==1) {
        
        return 250;
        
    }
    else if (tableView.tag==2)
    {
        return 86;
    }
    else if (tableView.tag==3)
    {
        return 44;
    }
    else if(tableView ==_tbl_Users){
        return 80;
    }
    else
    {
        return 0;
    }
    
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if (tableView.tag==1) {
        
        return 1;
        
    }
    else if (tableView.tag==2)
    {
        return 1;
    }
    else if (tableView.tag==3 || tableView ==_tbl_Users)
    {
        return 1;
    }
    else
    {
        return 0;
    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag==1) {
        
        AudioFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AudioFeed"];
        if (cell == nil)
        {
            NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"AudioFeedTableViewCell"
            owner:self options:nil];
            cell.accessoryType = UITableViewCellStyleDefault;
            cell = (AudioFeedTableViewCell*)[nib2 objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
           
        }
            [cell.slider_progress setThumbImage:[UIImage imageNamed:@"thumb_transparent.png"] forState:UIControlStateNormal];
            [cell.btn_Profile addTarget:self action:@selector(profileClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btn_Profile setTag:indexPath.row];
            cell.btn_Profile.layer.cornerRadius = cell.btn_Profile.frame.size.width / 2;
            cell.btn_Profile.clipsToBounds = YES;
            
            cell.layer.shadowColor = [[UIColor grayColor] CGColor];
            cell.layer.shadowOpacity = 0.4;
            cell.layer.shadowRadius = 0;
            cell.layer.shadowOffset = CGSizeMake(1.0, 1.0);
            cell.btn_join.tag=indexPath.row;
            [cell.btn_join addTarget:self action:@selector(join_clicked:) forControlEvents:UIControlEventTouchUpInside];
            cell.btn_comment.tag=indexPath.row;
            [cell.btn_comment addTarget:self action:@selector(btn_Recordings_comment_clicked:) forControlEvents:UIControlEventTouchUpInside];
            //---------------- * Next Button * --------------------
            cell.btn_next_audio.tag = indexPath.row;
            [cell.btn_next_audio addTarget:self action:@selector(btn_nextAction:) forControlEvents:UIControlEventTouchUpInside];
            //---------------- * Previous Button * --------------------
            cell.btn_previous_audio.tag = indexPath.row;
            [cell.btn_previous_audio addTarget:self action:@selector(btn_previousAction:) forControlEvents:UIControlEventTouchUpInside];
            
            //*********************** Play Recording Action ***************
            [cell.btn_PlayRecording setTag:indexPath.row];
            [cell.btn_PlayRecording addTarget:self action:@selector(btn_Recordings_Play_clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.roundBackgroundView.layer.cornerRadius=8.0f;
            cell.btn_like.tag=indexPath.row;
            [cell.btn_like addTarget:self action:@selector(btn_Recordings_like_clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btn_hide.hidden=YES;
            cell.btn_hide.tag=indexPath.row;
//            [cell.btn_hide addTarget:self action:@selector(hide_cellrecording:) forControlEvents:UIControlEventTouchUpInside];
            cell.btn_other_options.tag=indexPath.row;
//            [cell.btn_other_options addTarget:self action:@selector(show_options:) forControlEvents:UIControlEventTouchUpInside];
        //------------ New Code for Make Public/Private -------------
        
        NSLog(@"indexPath.row ====  %ld",(long)indexPath.row);
        cell.switch_PublicOrPrivate.tag = indexPath.row;
        NSLog(@"---- Before %@",arr_PublicState);
        
        //----* Make Public/Private only show on OWN(logged-in user) Recordings *-----
        if ([[[arr_rec_response objectAtIndex:indexPath.row] valueForKey:@"added_by"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]]) {
            
            if ([[arr_PublicState objectAtIndex:indexPath.row] isEqual:@"1"]) {
                [cell.switch_PublicOrPrivate setOn:YES];
            }
            else
            {
                [cell.switch_PublicOrPrivate setOn:NO];
            }
            [cell.switch_PublicOrPrivate addTarget:self action:@selector(switchPublicToggled:)
                                  forControlEvents:UIControlEventTouchUpInside];
            cell.switch_PublicOrPrivate.hidden=NO;

        }
        else{
            cell.switch_PublicOrPrivate.hidden=YES;

        }
        //----------------------------------------------------------------------
  
        
            i_Path = indexPath.row;
            index = indexPath.row;

            cell.btn_share.tag=indexPath.row;
            [cell.btn_share addTarget:self action:@selector(openshare:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.btn_share_value setTitle:[NSString stringWithFormat:@"%@",[arr_rec_share_count objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
            
            cell.lbl_profile_name.text=[arr_rec_name objectAtIndex:indexPath.row];
            NSLog(@"************************* value = %@ index  %ld",[arr_rec_name objectAtIndex:indexPath.row],(long)indexPath.row);
            
            cell.lbl_profile_twitter_id.text=[NSString stringWithFormat:@"@%@",[arr_rec_station objectAtIndex:indexPath.row]];
            //cell.lbl_timer
            
            NSString *tempDate =[arr_rec_post_date objectAtIndex:indexPath.row];
            if (tempDate.length >0) {
                cell.lbl_date_top.text=[Appdelegate formatDateWithString:tempDate];
            }
        if ([arr_rec_response count]>0)
        {
            long includeL =[[[arr_rec_response objectAtIndex:indexPath.row] valueForKey:@"join_count"]longValue];
            
            cell.lbl_included.text = [NSString stringWithFormat:@"Include : %ld",includeL];
            if (indexPath.row == instrument_play_index) {
                cell.lbl_oneof.text = [NSString stringWithFormat:@"( %ld of %ld )",currentIndex_user+1,includeL];
            }
            else{
                   cell.lbl_oneof.text = [NSString stringWithFormat:@"( 1 of %ld )",includeL];
            }
        }
            NSInteger anIndex=[arr_genre_id indexOfObject:[arr_rec_genre objectAtIndex:indexPath.row]];
            if(NSNotFound == anIndex) {
                anIndex=0;
            }
            if (tempDate.length >0) {
                cell.lbl_date_aidios.text=[Appdelegate formatDateWithString:tempDate];
                
            }
            cell.lbl_timer.text=[Appdelegate timeFormatted:[arr_rec_duration objectAtIndex:indexPath.row]];
            
            cell.lbl_geners.text=[NSString stringWithFormat:@"Genre : %@",[arr_menu_items objectAtIndex:anIndex]];
            cell.lbl_geners.textAlignment=NSTextAlignmentRight;
            cell.btn_Profile.contentMode = UIViewContentModeScaleToFill;
            cell.img_view_back_cover.contentMode = UIViewContentModeScaleAspectFill;
            
            [cell.btn_like_value setTitle:[NSString stringWithFormat:@"%@",[arr_rec_like_count objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
            [cell.btn_comment_value setTitle:[NSString stringWithFormat:@"%@",[arr_rec_comment_count objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
            
            [cell.btn_play_value setTitle:[NSString stringWithFormat:@"%@",[arr_rec_play_count objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
            
            if ([[arr_rec_like_status objectAtIndex:indexPath.row] isEqual:@"1"]) {
                [cell.btn_like setBackgroundImage:[UIImage imageNamed:@"btn_hand_fill.png"] forState:UIControlStateNormal];
            }
            else{
                [cell.btn_like setBackgroundImage:[UIImage imageNamed:@"btn_hand_outline.png"] forState:UIControlStateNormal];
            }
            //---------------------*** Cover pic ***------------------------
            NSString *strUrlForCover = [arr_rec_cover objectAtIndex:indexPath.row];
            strUrlForCover = [strUrlForCover stringByReplacingOccurrencesOfString:@"Mobile" withString:@"original"];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",strUrlForCover]];
            cell.img_view_back_cover.contentMode = UIViewContentModeScaleToFill;
            
            [cell.img_view_back_cover sd_setImageWithURL:url
                                        placeholderImage:[UIImage imageNamed:@"bg_cell.png"]];
            
            //---------------------*** Profile pic ***----------------------
            
//            NSURL *url2 = [NSURL URLWithString:[arr_rec_profile objectAtIndex:indexPath.row]];
        NSString *ImageURL_Profile;
        NSString *urlString=[arr_rec_profile objectAtIndex:indexPath.row];
        NSArray *UrlStrArray = [urlString componentsSeparatedByString:@"/"];
        urlString =[UrlStrArray firstObject];
        NSLog(@"FIRST WORD %@",urlString);
        
//        if ([urlString isEqualToString:@"http:"]) {
//            ImageURL_Profile=[NSString stringWithFormat:@"%@",[arr_rec_profile objectAtIndex:indexPath.row]];
//        }
//        else{
//            ImageURL_Profile =[NSString stringWithFormat:@"%@%@",BaseUrl,[arr_rec_profile objectAtIndex:indexPath.row]];
//        }
//        
//        NSURL *url2 = [NSURL URLWithString:ImageURL_Profile];
        
        
        NSURL *url2 = [NSURL URLWithString:[arr_rec_profile objectAtIndex:indexPath.row]];
        
            cell.btn_Profile.contentMode = UIViewContentModeScaleToFill;
            
            NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:url2 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [cell.btn_Profile setImage:image forState:UIControlStateNormal];
                            
                        });
                    }
                }
            }];
            [task2 resume];
        return cell;
    }
    else if (tableView.tag==2)
    {
        ActivitiesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Activity"];
        
        if (cell == nil)
        {
            NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"ActivitiesTableViewCell"
                                                          owner:self options:nil];
            cell.accessoryType = UITableViewCellStyleDefault;
            
            cell = (ActivitiesTableViewCell*)[nib2 objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            cell.img_view_profileimage.layer.cornerRadius = cell.img_view_profileimage.frame.size.width / 2;
            cell.img_view_profileimage.clipsToBounds = YES;
            
            NSString *str_topic = [[arr_Actity objectAtIndex:indexPath.row] valueForKey:@"topic"];
            
            if ([str_topic isEqualToString:@""]) {
                cell.lbl_topic.text = @"";
            }
            else{
                cell.lbl_topic.text = str_topic;
            }
            
            //------------* old code for set Date using custom method *----------
            //            NSString *time=[Appdelegate HourCalculation:[[arr_Actity objectAtIndex:indexPath.row] valueForKey:@"activity_created_time"]];
            
            //            cell.lbl_timing.text = time;
            //----------------* new code for set Date From Server side *----------
            cell.lbl_timing.text=[[arr_Actity objectAtIndex:indexPath.row]valueForKey:@"ActivityTime"];
            //------------------------------------------------------------------*
            
            NSString *str_activityName = [[arr_Actity objectAtIndex:indexPath.row] valueForKey:@"activity_name"];
            NSString *secondUser = [[[arr_Actity objectAtIndex:indexPath.row] valueForKey:@"second_user"] capitalizedString];
            NSString *firstUser;
            if ([[[arr_Actity objectAtIndex:indexPath.row] valueForKey:@"first_user"] isEqualToString:@" "])
            {
                firstUser=@"";
            }
            else
            {
                firstUser= [[NSString stringWithFormat:@"%@'s",[[arr_Actity objectAtIndex:indexPath.row] valueForKey:@"first_user"]] capitalizedString];
            }
            NSString *completeString;
            
            if ([str_activityName isEqualToString:@""])
            {
                str_activityName = @"";
            }
            else
            {
                
                completeString = [NSString stringWithFormat:@"%@ %@ %@",
                                  secondUser,str_activityName,firstUser];
                
                NSDictionary *attribs = @{
                                          NSForegroundColorAttributeName:[UIColor blackColor],
                                          NSFontAttributeName:[UIFont systemFontOfSize:12]
                                          };
                
                NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:completeString attributes:attribs];
                
                NSRange secondUserRange = [completeString rangeOfString:secondUser];
                NSRange activityRange = [completeString rangeOfString:str_activityName];
                NSRange firstUserRange = [completeString rangeOfString:firstUser];
                //CGFloat fontSize = [UIFont systemFontSize];
                NSDictionary *boldAttrib = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12]};
                NSDictionary *nonBoldAttrib = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
                
                [attributedText setAttributes:boldAttrib range:secondUserRange];
                [attributedText setAttributes:nonBoldAttrib range:activityRange];
                [attributedText setAttributes:boldAttrib range:firstUserRange];
                [cell.lbl_activity setAttributedText:attributedText];
            }
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
            cell.img_view_profileimage.userInteractionEnabled=YES;
            tap.cancelsTouchesInView = YES;
            tap.numberOfTapsRequired = 1;
            tap.view.tag=indexPath.row;
            cell.img_view_profileimage.tag = indexPath.row;
            
            [cell.img_view_profileimage addGestureRecognizer:tap];
            //////////////////////
            if ([[arr_Actity objectAtIndex:indexPath.row] valueForKey:@"profile_pick"] != [NSNull null]) {
                NSURL *url2 = [NSURL URLWithString:[[arr_Actity objectAtIndex:indexPath.row] valueForKey:@"profile_pick"]];
                
                NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:url2 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (data) {
                        UIImage *image = [UIImage imageWithData:data];
                        if (image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [cell.img_view_profileimage setImage:image];
                                
                            });
                        }
                    }
                }];
                [task2 resume];
            }
            return cell;
    }
    else if (tableView.tag==3)
    {
        static NSString *CellIdentifier = @"cellfilter";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        if (indexPath.row == 4 ){
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self
                       action:@selector(pickerAction:)
             forControlEvents:UIControlEventTouchUpInside];
            button.frame = CGRectMake(0,0, cell.frame.size.width, cell.frame.size.height);
            [cell addSubview:button];
            [button setTag:indexPath.row];
            
        }
        cell.textLabel.text=[arr_filter_data_list objectAtIndex:indexPath.row];
        
        return cell;
    }
    else if (tableView == _tbl_Users)
    {
        if (isSearch) {
            arrUsersM = [searchContactList mutableCopy];
        }
        
        static NSString *CellIdentifier = @"Users_cell";
        UsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            
            NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"UsersTableViewCell"
                                                          owner:self options:nil];
            cell.accessoryType = UITableViewCellStyleDefault;
            cell = (UsersTableViewCell*)[nib2 objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        //--------------------* Set User first name *-----------------------
        cell.lbl_userName.text=[[arrUsersM objectAtIndex:indexPath.row] valueForKey:@"user_name"];
        
        //--------------------* Set User full name *-----------------------
        cell.lbl_userFullName.text=[NSString stringWithFormat:@"@%@",[[arrUsersM objectAtIndex:indexPath.row] valueForKey:@"name"]];
        
        //--------------------* Set Profile Pic *-----------------------
        NSURL *url2 = [NSURL URLWithString:[[arrUsersM objectAtIndex:indexPath.row] valueForKey:@"profilepic"]];
        
        cell.btn_profile.contentMode = UIViewContentModeScaleToFill;
        cell.btn_profile.layer.cornerRadius = cell.btn_profile.frame.size.width / 2;
        cell.btn_profile.clipsToBounds = YES;
        
        NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:url2 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell.btn_profile setImage:image forState:UIControlStateNormal];
                        
                    });
                }
            }
        }];
        [task2 resume];
        
        [cell.btn_profile addTarget:self action:@selector(profileClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_profile setTag:indexPath.row];
        
        //--------------------* Set Follow Action *-----------------------
        cell.btn_follow.tag = indexPath.row;
        [cell.btn_follow addTarget:self action:@selector(follow_unfollow_action:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.btn_messanger.tag = indexPath.row;
        [cell.btn_messanger addTarget:self action:@selector(messenger_action:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([[[arrUsersM objectAtIndex:indexPath.row] valueForKey:@"follow_status"]isEqualToString:@"1"]) {
            [cell.btn_follow setImage:[UIImage imageNamed:@"follow_blue"] forState:UIControlStateNormal];
            cell.btn_messanger.hidden = NO;
        }
        else{
            
            [cell.btn_follow setImage:[UIImage imageNamed:@"follow_grey"] forState:UIControlStateNormal];
            cell.btn_messanger.hidden = YES;

        }
      
        return cell;
    }
    else
    {
        return 0;
    }

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 3) {
        filterString = [arr_filter_data_list objectAtIndex:indexPath.row];
        if (indexPath.row == 3 || indexPath.row == 5) {
            self.tbl_view_filter_data_list.hidden = YES;
            self.view_filter_shadow.hidden= YES;
            [self alertWithTextField:indexPath.row];
        }
        
        else{
            self.tbl_view_filter_data_list.hidden = YES;
            self.view_filter_shadow.hidden= YES ;
            arr_rec_response=[[NSMutableArray alloc] init];
            [self loadRecordings];
            
        }
    }
    if(tableView.tag == 2)
    {
        
        if ([[arr_Actity objectAtIndex:indexPath.row] objectForKey:@"recordingID"] != [NSNull null])
        {
            NSLog(@"REC ID %@",[[arr_Actity objectAtIndex:indexPath.row] objectForKey:@"recordingID"]);
            AudioFeedCommentsViewController *audioFeedVC=[self.storyboard instantiateViewControllerWithIdentifier:@"AudioFeedCommentsViewController"];
            audioFeedVC.fileID = [[arr_Actity objectAtIndex:indexPath.row] objectForKey:@"recordingID"];
            audioFeedVC.fileType = @"user_recording";
            audioFeedVC.isFrom=@"ACTIVITY";
            [self presentViewController:audioFeedVC animated:YES completion:nil];
            
        }
        else if ([[arr_Actity objectAtIndex:indexPath.row] objectForKey:@"adminmelodyid"] != [NSNull null])
        {
            NSLog(@"ADMIN MEL ID %@",[[arr_Actity objectAtIndex:indexPath.row] objectForKey:@"adminmelodyid"]);
            MelodyPackCommentsViewController*vc=[self.storyboard instantiateViewControllerWithIdentifier:@"MelodyPackCommentsViewController"];;
            vc.fileID = [[arr_Actity objectAtIndex:indexPath.row] objectForKey:@"adminmelodyid"];
            vc.fileType = @"admin_melody";
            vc.isFrom=@"ACTIVITY";
            [self presentViewController:vc animated:YES completion:nil];
        }
        else if ([[arr_Actity objectAtIndex:indexPath.row] objectForKey:@"melodyID"] != [NSNull null])
        {
            NSLog(@"USER MEL ID %@",[[arr_Actity objectAtIndex:indexPath.row] objectForKey:@"melodyID"]);
            MelodyPackCommentsViewController*vc=[self.storyboard instantiateViewControllerWithIdentifier:@"MelodyPackCommentsViewController"];;
            vc.fileID = [[arr_Actity objectAtIndex:indexPath.row] objectForKey:@"melodyID"];
            vc.fileType = @"user_melody";
            vc.isFrom=@"ACTIVITY";
            [self presentViewController:vc animated:YES completion:nil];
        }
        
        
    }
    else if (tableView == _tbl_Users)
    {
        [self methodProfileAction:indexPath.row];

    }
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==1) {
        if ((loadingData) && (indexPath.row == arr_rec_response.count - 1) && (arr_rec_response.count % 10 == 0) )
        {
            limit = arr_rec_response.count+10;
            counter= counter+1;
            [self loadRecordings];
        }
    }
}

- (void) handleImageTap:(UITapGestureRecognizer *)gestureRecognizer
{
    NSLog(@"imaged tap");
    CGPoint tapLocation = [gestureRecognizer locationInView:_tbl_view_activity];
    NSIndexPath *iPath = [_tbl_view_activity indexPathForRowAtPoint:tapLocation];
    ActivitiesTableViewCell *cell = [_tbl_view_activity cellForRowAtIndexPath:iPath];
    NSLog(@"TAG VALUE %ld",(long)cell.img_view_profileimage.tag);
    NSLog(@"FINAL TAG VALUE %ld",(long)iPath.row);
    ProfileViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    myVC.follower_id = [[arr_Actity objectAtIndex:iPath.row]valueForKey:@"created_by_userID"];
    [self presentViewController:myVC animated:YES completion:nil];
    
    
    
}
#pragma mark - Collection Delegates & Datasource
#pragma mark -

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(65,self.cv_menu.frame.size.height);
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [arr_menu_items count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    menuCollectionViewCell *cell = (menuCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.lbl_menu_title.adjustsFontSizeToFitWidth=YES;
    if ([arr_menu_items count]>0)
    {
        cell.lbl_menu_title.text=[arr_menu_items objectAtIndex:indexPath.row];

    }
    
    if ([[arr_tab_select objectAtIndex:indexPath.item] isEqual:@"1"]) {
        
        cell.img_menu.image = [UIImage imageNamed:@"underline.png"];
        cell.lbl_menu_title.textColor=[UIColor blackColor];

    }
    else
    {
        cell.img_menu.image = [UIImage imageNamed:@"white.png"];
        cell.lbl_menu_title.textColor=[UIColor grayColor];
    }

    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{

    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    limit = 0;
    current_Record = 0;
    int i;
    arr_rec_response=[[NSMutableArray alloc]init];
    
    /* --------- For Initial state --------------- */
    [self playerInitializes];
    AudioFeedTableViewCell *cell = [self.tbl_view_audio_feed cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
    cell.slider_progress.value = 0.0;
    
    //----------------------------------------------
    for (i=0; i<[arr_tab_select count]; i++)
    {
        if (i==indexPath.item) {
            [arr_tab_select replaceObjectAtIndex:i withObject:@"1"];
        }
        else
        {
            [arr_tab_select replaceObjectAtIndex:i withObject:@"0"];
        }
        
        
    }
    if ([[arr_menu_items objectAtIndex:indexPath.item] isEqual:@"All"]) {
        genre=@"0";
    }
    else
    {
        genre=[arr_genre_id objectAtIndex:indexPath.item];
    }
    recording_typeInt = 0;
    
    [self loadRecordings];
    [_cv_menu reloadData];
}



#pragma mark - Navigation
#pragma mark -
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
     if ([segue.identifier isEqualToString:@"go_to_recording_comments"])
     {
         AudioFeedCommentsViewController*vc=segue.destinationViewController;
         vc.dic_data=[arr_rec_response objectAtIndex:[_sender_tag integerValue]];
     }
     if ([segue.identifier isEqual:@"audiofeed_to_studio_play"]) {
         StudioPlayViewController*vc=segue.destinationViewController;
         vc.str_CurrernUserId = [followerID objectAtIndex:index];
         vc.str_RecordingId = [arr_rec_pack_id objectAtIndex:index];
         vc.arr_recordings=[arr_rec_recordings objectAtIndex:index];
         NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
         
         [tempDict setValue:[followerID objectAtIndex:index] forKey:@"str_currentUserID"];
         [tempDict setValue:[arr_rec_pack_id objectAtIndex:index] forKey:@"str_recordingID"];
         vc.stationDict= tempDict;
     }
     else
             if ([segue.identifier isEqualToString:@"go_to_login"]) {
                 ViewController*vc=segue.destinationViewController;
                 vc.open_login=@"0";
                 vc.other_vc_flag=@"1";
             }
     
 }




#pragma Avtivity API

-(void)btn_Recordings_like_clicked:(UIButton*)sender
{
    
    @try{

    if ([defaults_userdata boolForKey:@"isUserLogged"]) {

    NSString* like_val=[[NSString alloc]init];
    if ([[arr_rec_like_status objectAtIndex:sender.tag] isEqual:@"1"]) {
        like_val=@"0";
    }
    else{
        like_val=@"1";
    }
    
        NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
        [params setObject:[arr_rec_pack_id objectAtIndex:sender.tag] forKey:@"file_id"];
        [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"user_id"];
        [params setObject:like_val forKey:@"likes"];
        [params setObject:@"user_recording" forKey:@"type"];
        [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
        
        [params setObject:[arr_rec_name objectAtIndex:sender.tag] forKey:@"topic"];


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
                NSMutableDictionary*dic_response=[[NSMutableDictionary alloc]init];
                NSLog(@"%@",jsonResponse);
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    dic_response=[jsonResponse objectForKey:@"response"];
                    NSLog(@"%@",dic_response);
                    [arr_rec_like_count replaceObjectAtIndex:sender.tag withObject:[dic_response objectForKey:@"likes" ]];
                    
                    [[[arr_rec_response objectAtIndex:sender.tag] mutableCopy] removeObjectForKey:@"like_status"];
                    NSMutableDictionary*dic=[[arr_rec_response objectAtIndex:sender.tag] mutableCopy];
                    [dic setObject:like_val forKey:@"like_status"];
                    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:arr_rec_response];
                    [mutableArray replaceObjectAtIndex:sender.tag withObject:dic];
                    arr_rec_response = mutableArray;
                    [arr_rec_like_status replaceObjectAtIndex:sender.tag withObject:like_val];
                    
                    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tbl_view_audio_feed];
                    
                    NSIndexPath *indexPath = [_tbl_view_audio_feed indexPathForRowAtPoint:buttonPosition];
                    if(indexPath != nil)
                    {
                        [_tbl_view_audio_feed beginUpdates];
                        [_tbl_view_audio_feed reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [_tbl_view_audio_feed endUpdates];
                        [self getActivity:[[NSUserDefaults standardUserDefaults]
                                       objectForKey:@"user_id"]];
                    }
                    
                }
                else
                {
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
    else{
        ViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        myVC.open_login=@"0";
        myVC.other_vc_flag=@"1";
        [self presentViewController:myVC animated:YES completion:nil];
    }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php : %@",exception);
        [Appdelegate hideProgressHudInView];
    }
    @finally{
        
    }
}





#pragma mark - Audio Player Delegate Method
#pragma mark -

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    AudioFeedTableViewCell *cell = [self.tbl_view_audio_feed cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
    cell.slider_progress.value = 0.0;
    audioPlayer = nil;
//    if([defaults_userdata boolForKey:@"isUserLogged"]) {
        toggle_PlayPause = !toggle_PlayPause;
//    }
    audioPlayer = nil;
    [sliderTimer invalidate];
    sliderTimer = nil;
    
    //---------------- New Code for Continues play ------------------
    currentIndex_user ++;
    if (currentIndex_user < arrJoinedM.count) {
        //        currentIndex_user += 1;
        NSLog(@"currentIndex_user %ld",currentIndex_user);
        [self playNextOrPrevious_Tapped:instrument_play_index];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@" player error description %@",error);
}


#pragma mark - Play Method

- (void)btn_Recordings_Play_clicked:(UIButton* )sender {
    
    @try{
        isPlayable = YES;
        instrument_play_index = sender.tag;
        for (int i=0; i< arr_rec_response.count; i++) {
            if (instrument_play_index == i) {
                [arrStateofRecording replaceObjectAtIndex:instrument_play_index withObject:@"1"];
            }
            else{
                [arrStateofRecording replaceObjectAtIndex:instrument_play_index withObject:@"0"];
            }
        }
        
        AudioFeedTableViewCell *cell = [_tbl_view_audio_feed cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
        
        if(audioPlayer  && lastIndex == sender.tag) {
            if (audioPlayer.isPlaying) {
                [Appdelegate hideProgressHudInView];
                [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                [audioPlayer pause];
            }
            else{
                [audioPlayer play];
                [Appdelegate hideProgressHudInView];
                [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
            }
        }
        
        else{
            [Appdelegate showProgressHud];
            if(audioPlayer){
                [self playerInitializes];
            }
            
            for (int i=0; i< arr_rec_response.count; i++) {
                if ([[arrStateofRecording objectAtIndex:i] isEqualToString:@"0"]) {
                    AudioFeedTableViewCell *cell1 = [_tbl_view_audio_feed cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                    cell1.slider_progress.value = 0.0;
                    [cell1.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                }
            }
            
            //---------------- New Code for Continues play ------------------
            currentIndex_user = 0;
            long includeL =[[[arr_rec_response objectAtIndex:instrument_play_index] valueForKey:@"join_count"]longValue];
            cell.lbl_oneof.text = [NSString stringWithFormat:@"( %ld of %ld )",currentIndex_user+1,includeL];
            
            if ([[arr_rec_response objectAtIndex:instrument_play_index] valueForKey:@"joined"] != [NSNull null] )
            {
                arrJoinedM = [[arr_rec_response objectAtIndex:instrument_play_index] valueForKey:@"joined"];
            }
            
            
            dispatch_queue_t myqueue = dispatch_queue_create("queue", NULL);
            dispatch_async(myqueue, ^{
                [self method_PlayCount:instrument_play_index];
                
                NSError*error=nil;
                NSString *urlstr =[arr_rec_recordings_url objectAtIndex:instrument_play_index];
                urlstr = [urlstr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                
                NSURL *urlforPlay = [NSURL URLWithString:urlstr];
                NSData *data = [NSData dataWithContentsOfURL:urlforPlay];
                audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
                audioPlayer.delegate=self;
                [audioPlayer prepareToPlay];
                if ([audioPlayer prepareToPlay] == YES){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerupdateSlider) userInfo:nil repeats:YES];
                        // Set the maximum value of the UISlider
                        cell.slider_progress.maximumValue=[audioPlayer duration];
                        cell.slider_progress.value = 0.0;
                        // Set the valueChanged target
                        [cell.slider_progress addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];
                        [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
                        [Appdelegate hideProgressHudInView];
                        [audioPlayer prepareToPlay];
                        [audioPlayer play];
                    });
                }
                else {
                    [Appdelegate hideProgressHudInView];
                    AudioFeedTableViewCell *cell1 = [_tbl_view_audio_feed cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastIndex inSection:0]];
                    cell1.slider_progress.value = 0.0;
                    [cell1.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                    int errorCode = CFSwapInt16HostToBig ([error code]);
                    NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
                }
            });
        }
        lastIndex = sender.tag;
    }
    @catch (NSException *exception) {
        NSLog(@"exception at btn_Recordings_Play_clicked :%@",exception);
        [Appdelegate hideProgressHudInView];
        
    }
    @finally{
        
    }
    
}




-(void)playNextOrPrevious_Tapped:(long)sender{
    
    @try{
    [Appdelegate showProgressHud];
        dispatch_queue_t myqueue = dispatch_queue_create("queue", NULL);
        dispatch_async(myqueue, ^{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self playerInitializes];
        AudioFeedTableViewCell *cell = [_tbl_view_audio_feed cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender inSection:0]];
        cell.lbl_oneof.text = [NSString stringWithFormat:@"( %ld of %lu )",currentIndex_user+1,(unsigned long)arrJoinedM.count];
        
        NSString *urlstr =[[arrJoinedM objectAtIndex:currentIndex_user]valueForKey:@"recording_url"];
        urlstr = [urlstr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        
        NSURL *urlforPlay = [NSURL URLWithString:urlstr];
        NSData *data = [NSData dataWithContentsOfURL:urlforPlay];
        
        cell.lbl_timer.text=[Appdelegate timeFormatted:[[arrJoinedM objectAtIndex:currentIndex_user] valueForKey:@"recording_duration"]];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[arrJoinedM objectAtIndex:currentIndex_user] valueForKey:@"cover_url"]]];
        cell.img_view_back_cover.contentMode = UIViewContentModeScaleToFill;
        
        [cell.img_view_back_cover sd_setImageWithURL:url
                                    placeholderImage:[UIImage imageNamed:@"bg_cell.png"]];
        
        
    NSError*error=nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    [audioPlayer setDelegate:self];
    [audioPlayer prepareToPlay];
    if ([audioPlayer prepareToPlay] == YES){
        sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerupdateSlider) userInfo:nil repeats:YES];
        // Set the maximum value of the UISlider
        cell.slider_progress.maximumValue=[audioPlayer duration];
        cell.slider_progress.value = 0.0;
        // Set the valueChanged target
        [cell.slider_progress addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];
        [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
            [Appdelegate hideProgressHudInView];
            [audioPlayer stop];
            [audioPlayer play];
}
    else{
        [Appdelegate hideProgressHudInView];

    }
    });

    });

    }
    @catch (NSException *exception) {
        NSLog(@"exception %@",exception);
        [Appdelegate hideProgressHudInView];

    }
    @finally{
        
    }
}
#pragma mark - API LIST
#pragma mark -



-(void)method_ShareCount:(NSInteger)sender{
    @try{
        NSString *userid = [defaults_userdata objectForKey:@"user_id"];
        NSLog(@"userid %@",userid);
        
        NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
        [params setObject:[arr_rec_pack_id objectAtIndex:sender] forKey:@"file_id"];
        [params setObject:@"user_recording" forKey:KEY_SHARE_FILETYPE];
        [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
        [params setObject:[[arr_rec_response objectAtIndex:sender] objectForKey:@"added_by"] forKey:@"shared_with"];
        [params setObject:userid forKey:@"shared_by_user"];
        
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
                        dic_response=[jsonResponse objectForKey:@"info"];
                        NSLog(@"%@",dic_response);
                        long share_count=[[dic_response objectForKey:@"share_count"] integerValue];
                        // NSLog(@"valure of Count %ld",share_count);
                        [arr_rec_share_count replaceObjectAtIndex:sender withObject:[NSNumber numberWithInteger:share_count]];
                        [self.tbl_view_audio_feed reloadData];
                        
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
        NSLog(@"exception at sharefile.php : %@",exception);
        [Appdelegate hideProgressHudInView];
    }
    @finally{
        
    }
}



-(void)method_PlayCount:(NSInteger)sender{

    NSString *userid = [defaults_userdata objectForKey:@"user_id"];
    NSLog(@"userid %@",userid);
    
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:[arr_rec_pack_id objectAtIndex:sender] forKey:@"fileid"];
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
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(error)
        {
            //do something
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
                NSMutableDictionary*dic_response=[[NSMutableDictionary alloc]init];
                NSLog(@"%@",jsonResponse);
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    dic_response=[jsonResponse objectForKey:@"response"];
                    NSLog(@"%@",dic_response);
                    long a = [[arr_rec_play_count objectAtIndex:sender] integerValue]+1;
                    [arr_rec_play_count replaceObjectAtIndex:sender withObject:[NSNumber numberWithInteger:a]];
                    [self.tbl_view_audio_feed reloadData];
                    
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




-(void)timerupdateSlider{
    // Update the slider about the music time
    
    AudioFeedTableViewCell *cell = [_tbl_view_audio_feed cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    cell.slider_progress.value = audioPlayer.currentTime;
    
    //--------------------* Set the playlist timer *-------------------------
    cell.lbl_timer.text=[NSString stringWithFormat:@"%@",[Appdelegate timeFormatted:[NSString stringWithFormat:@"%f",audioPlayer.currentTime]]];
}


-(void)sliderChanged{
    // Fast skip the music when user scroll the UISlider
    AudioFeedTableViewCell *cell = [_tbl_view_audio_feed cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    [audioPlayer setCurrentTime:cell.slider_progress.value];
    [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
    instrument_play_status=1;
    
}




#pragma mark - Calling Genere API

-(void)loadgenres{
    {
        
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

                                                
           } else
           {
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
                       arr_menu_items=[[NSMutableArray alloc]init];
                       arr_tab_select=[[NSMutableArray alloc]init];
                       arr_genre_id=[[NSMutableArray alloc]init];
                       NSMutableArray*arr_response1=[[NSMutableArray alloc]init];
                       arr_response1=[jsonObject valueForKey:@"response"];
                       // NSLog(@"%@",arr_response);
                       for (int i=0; i<[arr_response1 count]; i++) {
                           if ([[[arr_response1 objectAtIndex:i] valueForKey:@"name"] isEqualToString:@"My Melodies"])
                           {
                               //...
                           }
                           else
                           {
                               [arr_menu_items addObject:[[arr_response1 objectAtIndex:i] valueForKey:@"name"]];
                               [arr_genre_id addObject:[[arr_response1 objectAtIndex:i] valueForKey:@"id"]];
                           }
                           if (i==0) {
                               [arr_tab_select insertObject:@"1" atIndex:i];
                           }
                           else
                           {
                               [arr_tab_select insertObject:@"0" atIndex:i];
                           }
                           
                       }
                       NSLog(@"%@",arr_menu_items);
                       NSLog(@"%@",arr_tab_select);
                       NSLog(@"%@",arr_genre_id);
                       [_cv_menu reloadData];
                   }else{
                       
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
                   
               });
           }
                            }];
        [dataTask resume];
    }
}

/***************************Call Recordings api**********************************/
-(void)loadRecordings
{
    @try{

        if([[MyManager sharedManager] isInternetAvailable])
        {
            [KSToastView ks_showToast:@"Internet connectivity issue" delay:0.1f];
            return;
        }

    [Appdelegate showProgressHud];
       
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    if ([defaults_userdata boolForKey:@"isUserLogged"]) {
        [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:KEY_USER_ID];;
    }
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    [params setObject:[NSString stringWithFormat:@"%ld",(long)limit] forKey:@"limit"];
    [params setObject:@"station" forKey:@"key"];
    
    if (recording_typeInt == Filter)
    {
        [params setObject:@"extrafilter" forKey:@"filter"];
        [params setObject:@"user_recording" forKey:KEY_SHARE_FILETYPE];
        [params setObject:filterString forKey:@"filter_type"];
        [params removeObjectForKey:@"genere"];
        if ([filterString isEqualToString:@"Artist"] ) {
            [params setObject:userNameString forKey:@"username"];
        }
        else if ([filterString isEqualToString:@"Instruments"] ) {
            [params setObject:numberOfInstruments forKey:@"count"];
        }
        
        else if ([filterString isEqualToString:@"BPM"] ) {
            [params setObject:BPM forKey:@"count"];
        }
    }
    
    else if(recording_typeInt == Search){
        [params setObject:searchString forKey:@"search"];
        [params removeObjectForKey:@"genere"];
        
    }
    else if(recording_typeInt == Station_list){
        [params removeObjectForKey:@"artistname"];
        [params removeObjectForKey:@"search"];
        [params setObject:genre forKey:@"genere"];
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
    NSString* urlString = [NSString stringWithFormat:@"%@station_recordings.php",BaseUrl];//NEW API

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
        [Appdelegate hideProgressHudInView];

            if([[MyManager sharedManager] isInternetAvailable])
            {
                [KSToastView ks_showToast:@"Internet connectivity issue" delay:0.1f];
                return;
            }

        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                    /* Your UI code */
                
                NSError *myError = nil;
                loadingData = YES;
                NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSLog(@"%@",requestReply);
                NSData *data2=[requestReply dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                id jsonObject = [NSJSONSerialization
                                 
                                 JSONObjectWithData:data2
                                 options:NSJSONReadingAllowFragments error:&myError];
                if ([[jsonObject valueForKey:@"flag"] isEqual:@"success"])
                {
                    
                    self.placeholder_img.hidden = YES;
                    self.tbl_view_audio_feed.hidden = NO;
                    
                    [Appdelegate hideProgressHudInView];
                    arr_rec_pack_id=[[NSMutableArray alloc]init];
                    arr_rec_name=[[NSMutableArray alloc]init];
                    arr_rec_recordings_count=[[NSMutableArray alloc]init];
                    arr_rec_recordings_url=[[NSMutableArray alloc]init];
                    arr_PublicState=[[NSMutableArray alloc]init];

                    arr_rec_bpm=[[NSMutableArray alloc]init];
                    arr_rec_genre=[[NSMutableArray alloc]init];
                    arr_rec_station=[[NSMutableArray alloc]init];
                    arr_rec_cover=[[NSMutableArray alloc]init];
                    arr_rec_profile=[[NSMutableArray alloc]init];
                    arr_rec_intrumentals=[[NSMutableArray alloc]init];
                    arr_rec_post_date=[[NSMutableArray alloc]init];
                    arr_rec_play_count=[[NSMutableArray alloc]init];
                    arr_rec_like_count=[[NSMutableArray alloc]init];
                    arr_rec_comment_count=[[NSMutableArray alloc]init];
                    arr_rec_share_count=[[NSMutableArray alloc]init];
                    arr_rec_like_status=[[NSMutableArray alloc]init];
                    arr_rec_recordings=[[NSMutableArray alloc]init];
                    followerID=[[NSMutableArray alloc]init];
                    arr_rec_recordings_url=[[NSMutableArray alloc]init];
                    arr_rec_thumbnail_url=[[NSMutableArray alloc]init];
                    arr_rec_duration = [[NSMutableArray alloc]init];
                    arrJoinedM = [[NSMutableArray alloc]init];
                    arrStateofRecording = [[NSMutableArray alloc]init];
//                    arr_rec_response = [[NSMutableArray alloc]init];
                    NSArray *tempArrayM = [[NSArray alloc]init];
                    tempArrayM = [jsonObject valueForKey:@"response"];
                    [arr_rec_response addObjectsFromArray:tempArrayM];
                    current_Record = arr_rec_response.count;
                    
                    NSLog(@"%@",arr_rec_response);
                    loadingData = YES;
                    currentIndex_user = 0;

                    for (int i=0; i<[arr_rec_response count]; i++)
                    {
                        [arrStateofRecording setObject:@"0" atIndexedSubscript:i];
                        NSLog(@"%@",[arr_rec_response objectAtIndex:i]);
                        if([[[arr_rec_response objectAtIndex:i] valueForKey:@"recording_id"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"recording_id"] length]==0)
                        {
                            [arr_rec_pack_id addObject:@"0"];
                        }
                        else
                        {
                            //recording_id
                            [arr_rec_pack_id addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"recording_id"]];
                        }
                        //-----------------* For PUBILC STATE *-----------------
                        if([[[arr_rec_response objectAtIndex:i] valueForKey:@"public"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"public"] length]==0)
                        {
                            [arr_PublicState addObject:@"0"];
                            
                        }
                        else
                        {
                            [arr_PublicState addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"public"]];
                            
                        }
                        
                        if([[[arr_rec_response objectAtIndex:i] valueForKey:@"added_by"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"added_by"] length]==0)
                        {
                            [followerID addObject:@"0"];
                        }
                        else
                        {
                            [followerID addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"added_by"]];
                        }
                 
                        if([[[arr_rec_response objectAtIndex:i] valueForKey:@"genre"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"genre"] length]==0)
                        {
                            [arr_rec_genre addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_genre addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"genre"]];
                        }
                        if([[[arr_rec_response objectAtIndex:i] valueForKey:@"recording_topic"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"recording_topic"] length]==0)
                        {
                            [arr_rec_name addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_name addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"recording_topic"]];
                        }
                        if([[[arr_rec_response objectAtIndex:i] valueForKey:@"user_name"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"user_name"] length]==0)
                        {
                            [arr_rec_station addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_station addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"user_name"]];
                        }
                        
        //--------------------- * Updated Code ---------------------
        if ([[arr_rec_response objectAtIndex:i] valueForKey:@"recordings"] == [NSNull null] )
        {
     
                            [arr_rec_cover addObject:@"http://"];
                            [arr_rec_duration addObject:@""];

                        }
                        else
                        {
                            [arr_rec_cover addObject:[NSString stringWithFormat:@"%@",[[arr_rec_response objectAtIndex:i] valueForKey:@"cover_url"]]];
                            
                          [arr_rec_duration addObject:[NSString stringWithFormat:@"%@",[[[[arr_rec_response objectAtIndex:i] objectForKey:@"recordings"] objectAtIndex:0] objectForKey:@"duration"]]];
                        }
                 
                        //--------------------- * Old Code ---------------------
                        
                        if([[[arr_rec_response objectAtIndex:i] valueForKey:@"profile_url"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"profile_url"] length]==0)
                        {
                            [arr_rec_profile addObject:@"http://"];
                        }
                        else
                        {
                            [arr_rec_profile addObject:[NSString stringWithFormat:@"%@",[[arr_rec_response objectAtIndex:i] valueForKey:@"profile_url"]]];
                        }

                        
                        if([[[arr_rec_response objectAtIndex:i] valueForKey:@"recordings"] isEqual:[NSNull null]])
                        {
                            [arr_rec_recordings addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"recording_url"]];
                            NSString *stringUrl = [arr_rec_recordings objectAtIndex:i];
                            [arr_rec_recordings_url addObject:stringUrl];
                            
                        }
                        else
                        {
                            
                            [arr_rec_recordings addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"recording_url"]];
                            NSString *stringUrl = [arr_rec_recordings objectAtIndex:i];
                            [arr_rec_recordings_url addObject:stringUrl];
                            
                        }
                        if([[[arr_rec_response objectAtIndex:i] valueForKey:@"thumbnail_url"] isEqual:[NSNull null]])
                        {
                            NSString *stringUrl = [arr_rec_recordings objectAtIndex:i];
                            [arr_rec_thumbnail_url addObject:stringUrl];
                            
                        }
                        else
                        {
                            
                            NSString *stringUrl = [arr_rec_recordings objectAtIndex:i];
                            [arr_rec_thumbnail_url addObject:stringUrl];
                            
                        }
                        
                        
                        if([[[arr_rec_response objectAtIndex:i] valueForKey:@"date_added"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"date_added"] length]==0)
                        {
                            [arr_rec_post_date addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_post_date addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"date_added"] ];
                        }
                        
                        //  [arr_melody_pack_bpm addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"bpm"] ];
                        if([[[arr_rec_response objectAtIndex:i] valueForKey:@"play_count"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"play_count"] length]==0)
                        {
                            [arr_rec_play_count addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_play_count addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"play_count"] ];
                        }
                        
                        if([[[arr_rec_response objectAtIndex:i] valueForKey:@"like_count"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"like_count"] length]==0)
                        {
                            [arr_rec_like_count addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_like_count addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"like_count"] ];
                        }
                        
                        if([[[arr_rec_response objectAtIndex:i] valueForKey:@"comment_count"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"comment_count"] length]==0)
                        {
                            [arr_rec_comment_count addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_comment_count addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"comment_count"] ];
                        }
                        if([[[arr_rec_response objectAtIndex:i] valueForKey:@"share_count"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"share_count"] length]==0)
                        {
                            [arr_rec_share_count addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_share_count addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"share_count"] ];
                        }
                        if([[[arr_rec_response objectAtIndex:i] valueForKey:@"like_status"] isEqual:[NSNull null]])
                        {
                            [arr_rec_like_status addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_like_status addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"like_status"] ];
                        }
                        
                    }

                    [_tbl_view_audio_feed reloadData];
                    

                }
                else
                {
                    loadingData = NO;
                    [Appdelegate hideProgressHudInView];
                    if (!loadingData && arr_rec_response.count == 0) {
                        self.placeholder_img.hidden = NO;
                        _tbl_view_audio_feed.hidden = YES;
                        self.placeholder_img.image = [UIImage imageNamed:@"NoResult_img"];
                        arr_rec_pack_id=[[NSMutableArray alloc]init];
                    }
                    else{
                        [_tbl_view_audio_feed reloadData];
                    }

                }
            });

        }
                                                }];
    [dataTask resume];
//    });

    }
    @catch (NSException *exception) {
        NSLog(@"exception at recording.php :%@",exception);
        [Appdelegate hideProgressHudInView];
    }
    @finally{
        
    }
}



-(void)uploadcover{
    
    NSString*imageName = @"Menstruation_Sisters_-_14_-_top_gun.mp3";
    
    NSString * mydataS = [[NSString alloc]init];
    mydataS = @"http://52.89.220.199/api/uploads/recordings/rec1502882927.wav";
    NSString *urlstr =[arr_rec_recordings_url objectAtIndex:instrument_play_index];
    //            urlstr = [urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    urlstr = [urlstr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSURL *urlforPlay = [NSURL URLWithString:mydataS];
    NSData*imageData = [NSData dataWithContentsOfURL:urlforPlay];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sounds.mp3", documentsDirectory]];
    imageName = [url lastPathComponent];
    if (([imageName  length]==0)) {
        imageName=@"image.png";
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@upload_cover_melody_file.php",BaseUrl] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData
                                    name:@"file1"
                                fileName:imageName mimeType:@"multipart/form-data"];
        //[formData appendPartWithFormData:[imageName dataUsingEncoding:NSUTF8StringEncoding]name:@"file1"];
        
        [formData appendPartWithFormData:[[defaults_userdata stringForKey:@"user_id"] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"user_id"];
        [formData appendPartWithFormData:[@"3" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:KEY_SHARE_FILETYPE];
        [formData appendPartWithFormData:[@"Recording" dataUsingEncoding:NSUTF8StringEncoding]//[isMelody dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"isMelody"];
        [formData appendPartWithFormData:[@"398" dataUsingEncoding:NSUTF8StringEncoding]//
                                    name:@"melodyOrRecordingID"];
        [formData appendPartWithFormData:[KEY_AUTH_VALUE dataUsingEncoding:NSUTF8StringEncoding]
                                    name:KEY_AUTH_KEY];
        
        NSLog(@"%@",[defaults_userdata stringForKey:@"user_id"]);
        
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"Response: %@", [responseObject objectForKey:@"flag"]);

        if ([[responseObject objectForKey:@"flag"] isEqualToString:@"success"]) {
   
            BOOL success = NO;
 
            //
            if (success == NO) {
            }
 
            
        }
        else if ([[responseObject objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
[Appdelegate hideProgressHudInView];
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
        else{
            [Appdelegate hideProgressHudInView];
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Error"
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
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
[Appdelegate hideProgressHudInView];
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Error"
                                      message:@"Internet not Available!"
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
        
    }];
}



//-(void)getActivity:(id)sender
-(void)getActivity:(id)sender

{
    @try{
        
    NSMutableDictionary * params = [[NSMutableDictionary alloc]init];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    
    if([defaults_userdata boolForKey:@"isUserLogged"]) {
        [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:@"user_id"];
    }
    if (isActivityClicked) {
        [params setObject:searchString forKey:@"searchKey"];
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
    NSString* urlString = [NSString stringWithFormat:@"%@activity.php",BaseUrl];
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
            [Appdelegate hideProgressHudInView];

        }
        else
        {

            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *myError = nil;
                NSDictionary*dic_response=[[NSDictionary alloc]init];
                
                NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSLog(@"%@",requestReply);
                NSData *data = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:kNilOptions
                                                                               error:&myError];
                NSLog(@"%@",jsonResponse);
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    dic_response = [jsonResponse objectForKey:@"response"];
                    [Appdelegate hideProgressHudInView];

                    arr_Actity = [[NSArray alloc]init];
                    arr_rev = [[NSArray alloc]init];
                    if([jsonResponse valueForKey:@"response"] != nil){
                        arr_rev = [jsonResponse valueForKey:@"response"];
                        if (arr_rev.count > 0) {
                          //  arr_Actity = [[arr_rev reverseObjectEnumerator] allObjects];
                            arr_Actity = [jsonResponse objectForKey:@"response"];
                        }
                    }
                    [_tbl_view_activity reloadData];
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
    @catch (NSException *exception) {
        NSLog(@"exception at activity.php :  %@",exception);
        [Appdelegate hideProgressHudInView];
    }
    @finally{
        
    }
}

-(void)user_List
{
    @try{
        [Appdelegate showProgressHud];
        NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
//        if (text_flag == 2 && ![str_search isEqualToString:@""] ) {
//            [params setObject:str_search forKey:@"search"];
//        }
        
        [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
        [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"user_id"];
        NSLog(@"%@",params);
        NSMutableString* parameterString = [NSMutableString string];
        for(NSString* key in [params allKeys])
        {
            if ([parameterString length]) {
                [parameterString appendString:@"&"];
            }
            [parameterString appendFormat:@"%@=%@",key, params[key]];
        }
        NSString* urlString = [NSString stringWithFormat:@"%@userlist.php",BaseUrl];
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
                                                options:NSJSONReadingMutableContainers
                                                error:&myError];
                    
                    NSMutableDictionary*dic_response=[[NSMutableDictionary alloc]init];
                    NSLog(@"%@",jsonResponse);
                    if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                        [Appdelegate hideProgressHudInView];
                        
                        dic_response=[jsonResponse objectForKey:@"response"];
                        arrUsersM=[jsonResponse objectForKey:@"response"];
                        arrUserList = [[NSArray alloc]init];
                        arrUserList = [jsonResponse objectForKey:@"response"];
                        [_tbl_Users reloadData];
                    }
                    else
                    {
                        [Appdelegate hideProgressHudInView];
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
        [Appdelegate hideProgressHudInView];
        
        NSLog(@"exception at public.php %@",exception);
    }
    @finally{
        
    }
    
}


-(void)follow_unfollow_action:(UIButton*)sender
{
    toggleFollow = !toggleFollow;
    UsersTableViewCell *cell = [_tbl_Users cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    
    if (toggleFollow) {
        [cell.btn_follow setImage:[UIImage imageNamed:@"follow_blue"] forState:UIControlStateNormal];
    }
    else{
        
        [cell.btn_follow setImage:[UIImage imageNamed:@"follow_grey"] forState:UIControlStateNormal];
    }
    
    NSDictionary* params = @{
                             KEY_AUTH_KEY:KEY_AUTH_VALUE,
                             @"followerID":[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"],
                             @"user_id":[[arrUsersM objectAtIndex:sender.tag]valueForKey:@"id"]
                             };//followerID
    NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@followers.php",BaseUrl];
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
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"])
                {
                    [defaults_userdata setBool:YES forKey:@"isfollow"];
                    
                    dic_response=[jsonResponse objectForKey:@"response"];
                    NSLog(@"%@",[dic_response objectForKey:@"follow_status"]);
                    if ([[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"follow_status"]] isEqual:@"1"]) {
                        cell.btn_messanger.hidden = NO;
                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"follow_count"]] forKey:@"followers" ];
                        [cell.btn_follow setImage:[UIImage imageNamed:@"follow_blue"] forState:UIControlStateNormal];
                    }
                    else
                    {
                        [defaults_userdata setBool:NO forKey:@"isfollow"];
                        cell.btn_messanger.hidden = YES;
                        
                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"follow_count"]] forKey:@"followers" ];
                        [cell.btn_follow setImage:[UIImage imageNamed:@"follow_grey"] forState:UIControlStateNormal];
                    }
                }
                else
                {
                    [Appdelegate hideProgressHudInView];
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


#pragma mark- Delegate Method Search
#pragma mark-
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    if ([searchText isEqualToString:@""])
    {
        isSearch= NO;
    }
    else
    {
        isSearch= YES;
    }
    if (searchBar == _search_bar)
    {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"user_name CONTAINS[cd] %@", searchBar.text];
        searchContactList = [arrUserList filteredArrayUsingPredicate:filterPredicate];
        NSLog(@"newSearch %@", searchContactList);
        [_tbl_Users reloadData];
    }
    
}





-(void)messenger_action:(UIButton*)sender
{
    
//    [arr_users_id addObject:self.follower_id];
    
    chatViewController *chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"chatViewController"];
//    NSString *chat_id = [NSString stringWithFormat:@"%@",[[arr_rec_response objectAtIndex:sender.tag]valueForKey:@"chat_id"]];
    NSString *reviever_id = [[arrUsersM objectAtIndex:sender.tag]valueForKey:@"id"];
    chatVC.str_receiver_id = reviever_id;
//    chatVC.str_chat_id = chat_id;
    chatVC.str_receiver_name = [[arrUsersM objectAtIndex:sender.tag]valueForKey:@"user_name"];
    
    [self presentViewController:chatVC animated:YES completion:nil];
    
}

@end
