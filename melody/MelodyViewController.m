 

//
//MelodyViewController.m
// melody
//
//Created by CodingBrainsMini on 11/26/16.
//Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import "MelodyViewController.h"
#import "MelodyPacksTableViewCell.h"
#import "AudioFeedTableViewCell.h"
#import "SubscriptionPlanTableViewCell.h"
#import "StudioRecViewController.h"
#import "menuCollectionViewCell.h"
#import "MelodyPackCommentsViewController.h"
#import "StudioPlayViewController.h"
#import "AudioFeedCommentsViewController.h"
#import "Constant.h"
#import "ViewController.h"
#import "ProgressHUD.h"
#import "MelodyHomeTableViewCell.h"
#import "RageIAPHelper.h"
//#import "VerificationController.h"


@interface MelodyViewController ()<UITextFieldDelegate,UITableViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,AVAudioPlayerDelegate>
{
    BOOL toggle_PlayPause;
    long instrument_play_index;
    BOOL toggle_Play;
    NSMutableArray*arr_slider_timer_objects;
    NSTimer* sliderTimer;
    NSMutableArray *playStatusArrayM;
    
    NSString *artistNameString,*searchString,*userNameString,*filterString;
    NSString *numberOfInstruments;
    NSString *BPM;
    NSMutableArray *instrumentArray,*genreArray;
    NSMutableArray *instrumentURLArrayM,*arr_packageID;
    long lastIndex;
    BOOL isMelody,loadingData;
    NSInteger index;
    //------------- *PAypal Varibles *--------------------
    NSDictionary *resultDict;
    NSString *packageStatus,*packageID,*subscribedPack;
    NSInteger iPathRow;
    NSString *transactionID,*createTime,*paymentState,*payableAmount;
    NSInteger current_Record,limit;
    int counter,recording_typeInt,tableViewTag,text_flag;
    NSString *loadGenreFrom;
    NSString *str_Email,*clientToken;
    NSString * nonce;
    NSNumber *subscribedPackageStatus;
    UIActivityViewController *activityController;
    NSMutableArray *soundsArray,*maxDuration,*arrJoinedM;
    BOOL isMelodyPlay,isPlayable;
    long fileSize,currentIndex_user;
    NSData *tempData;

    //------- * IAP * ----------
    NSMutableArray *_objects,*_products,*arr_indexForPlayM;
    NSNumberFormatter * _priceFormatter;
    
    // 3
    SKProductsRequest * productsRequest;
    // 4
    RequestProductsCompletionHandler _completionHandler;
    NSMutableSet * _purchasedProductIdentifiers;
    NSSet * productIdentifiers;
    NSString *isPublic;
}



@end
BOOL isTableScrollable = NO;
BOOL isMyMelody = NO;

@implementation MelodyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    isMelody = YES;
    [self initialezesAllVaribles];
    loadGenreFrom = @"MELODY";
    genre =@"";
    isMelodyPlay = NO;
    arr_response=[[NSMutableArray alloc]init];
    maxDuration=[[NSMutableArray alloc]init];
    soundsArray = [NSMutableArray new];
    fileSize = 0;
    tempData = 0;
    
 

}



//Modified playSound method
-(void)addPlayerObjects:(NSString*)urlStr index:(long)index
{
    @try{
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
        NSLog(@"****** exception at adding recording :%@ ******",exception);
    }
    @finally{
    }
}

-(void)stopPlay{
    
   
    for (AVAudioPlayer *audio in soundsArray){
        MelodyPacksTableViewCell *cell = [_tbl_view_melodypacks cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
        cell.slider_progress.value = 0.0;
        [cell.btn_playpause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
        [audio stop];
    }
}

-(void)allPlay{
    
    for (AVAudioPlayer *audio in soundsArray){
        MelodyPacksTableViewCell *cell = [_tbl_view_melodypacks cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
        cell.slider_progress.value = 0.0;
     //   [cell.btn_playpause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
        [audio play];
    }
}

-(void)pausePlay{
    
    
    for (AVAudioPlayer *audio in soundsArray){
        MelodyPacksTableViewCell *cell = [_tbl_view_melodypacks cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
        cell.slider_progress.value = 0.0;
      //  [cell.btn_playpause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
        [audio pause];
    
    }
}


-(void)viewWillDisappear:(BOOL)animated{
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}



-(void)viewWillAppear:(BOOL)animated{
    
    [self initializesIAP];
    if (!isMelody)
    {
        _tbl_view_melodypacks.hidden=YES;
    }
    else
    {
        
        limit = 0;
        arr_response =[[NSMutableArray alloc]init];
        if ([_fromScreen isEqualToString:@"CHAT"])
        {
            if (_genereValue == nil)
            {
                genre=@"";
            }
            else
            {
                genre=_genereValue;
                
            }
        }
        else{
            genre=@"";
        }
        [self loadMelodyPacks];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"updateCommentsMelody"
                                               object:nil];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"updateCommentsMelody"])
    NSLog (@"Successfully received the test notification!");
    arr_rec_response=[[NSMutableArray alloc]init];
    [self loadRecordings];
}


-(void)initialezesAllVaribles{
    
    counter = 1;
    limit = 0;
    isPlayable = YES;
    currentIndex_user = 0;
    //--------------- Initialization for Lazy loading ------------------
    current_Record= 0;
    loadingData = NO;
    
    //-----------------* For Pull to refresh *---------------------
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    [_tbl_view_recordings addSubview:refreshControl];
    
    
    isMelody = YES;
    lastIndex = 10000;
    instrumentArray = [[NSMutableArray alloc] init];
    // Add some data for demo purposes.
    [instrumentArray addObject:@"1"];
    [instrumentArray addObject:@"2"];
    [instrumentArray addObject:@"3"];
    [instrumentArray addObject:@"4"];
    [instrumentArray addObject:@"5"];
    
    
    
    recording_typeInt = 0;
    text_flag=0;
    self.tbl_view_filter_data_list.delegate = self;
    
    self.tf_srearch.delegate=self;
    [self.tf_srearch addTarget:self
                        action:@selector(textFieldDidChange:)
              forControlEvents:UIControlEventEditingChanged];
    
    genre=[[NSString alloc]initWithFormat:@""];
    
    playStatusArrayM = [[NSMutableArray alloc]init];
    toggle_Play = false;
    arr_slider_timer_objects=[[NSMutableArray alloc]init];
    arr_melody_instrumentals_path  = [[NSMutableArray alloc]init];
    /***********************in app purchase****************/
    // Adding activity indicator
    activityIndicatorView = [[UIActivityIndicatorView alloc]
                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = self.view.center;
    [activityIndicatorView hidesWhenStopped];
    [self.view addSubview:activityIndicatorView];
    //    [activityIndicatorView startAnimating];
    //Hide purchase button initially
    purchaseButton.hidden = YES;
    
    /*****************************************************/
    melody_pack_tab_isOpen=YES;
    recordings_tab_isOpen=NO;
    // Do any additional setup after loading the view.
    // _sender_tag=[[NSString alloc]init];
    defaults_userdata=[NSUserDefaults standardUserDefaults];
    if ([[defaults_userdata stringForKey:@"rememberme"] isEqual:@"remember"]) {
        [_img_view_user_profile setImage:[UIImage imageWithData:[defaults_userdata objectForKey:@"profile_pic"]]];
        _lbl_title_bellow_user_profile.text=[NSString stringWithFormat:@"%@ %@",[defaults_userdata objectForKey:@"first_name"],[defaults_userdata objectForKey:@"last_name"]];
    }
    else
    {
        [_img_view_user_profile setImage:[UIImage imageNamed:@"artist-with-headphone.png"]];
    }
    genre=[[NSString alloc]initWithFormat:@""];
    _cv_menu.showsHorizontalScrollIndicator=NO;
    status1=0;
    status2=0;
    currentSoundsIndex = 0;
    _tbl_view_recordings.tag=1;
    _tbl_view_melodypacks.tag=2;
    _tbl_view_subscr_packs.tag=3;
    _tbl_view_filter_data_list.tag=4;
    
    _tbl_view_recordings.hidden=YES;
    _view_subscription_tab.hidden=YES;
    _img_view_user_profile.layer.cornerRadius =_img_view_user_profile.frame.size.width / 2;
    
    arr_filter_data_list=[[NSMutableArray alloc]initWithObjects:@"Latest",@"Trending",@"Favorites",@"Artist",@"# of Instrumentals",@"BPM", nil];
    //arr_plan_type
     arr_plan_type=[[NSMutableArray alloc]initWithObjects:@"Freemium",@"Standard",@"Premium",@"Producer", nil];
    
    _img_view_user_profile.clipsToBounds = YES;
    _view_filter_shadow.frame=CGRectMake(-800, 0, self.view.frame.size.width, self.view.frame.size.height);
    _view_filter.layer.cornerRadius=10;
    
    NSDate *currentYear=[[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    
    [_lbl_allRightsReservedYear setText:[NSString stringWithFormat:@"YoMelody, Inc. TM %@. All rights Reserved",[dateFormatter stringFromDate:currentYear]]];
    
    //  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    UISwipeGestureRecognizer*swipedown=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [swipedown setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:swipedown];
    //   [self.view addGestureRecognizer:tap];
    if ([_view_suscription_visible isEqual:@"YES"]) {
        _view_tabBar.hidden=YES;
        [self load_package_details];
        if([defaults_userdata boolForKey:@"isUserLogged"])
        {
            //[self load_package_details];
        }
       
        _view_subscription_tab.hidden=NO;
        _btn_filter.hidden=YES;
        _btn_search.hidden=YES;
        [self.btn_melodypacks_tab setBackgroundColor:[UIColor clearColor]];
        [self.btn_recording_tab setBackgroundColor:[UIColor clearColor]];
        [self.btn_subscription_tab setBackgroundColor:[UIColor whiteColor]];
        _btn_melodypacks_tab.titleLabel.font = [UIFont systemFontOfSize:15];
        _btn_recording_tab.titleLabel.font = [UIFont systemFontOfSize:15];
        _btn_subscription_tab.titleLabel.font = [UIFont boldSystemFontOfSize:14.5];
    }
    
    if ([_view_recording_visible isEqual:@"YES"]) {
        
        [self performSelector:@selector(btn_recording_tab:) withObject:nil afterDelay:1.0];
    }
}


-(void)dismissKeyboard
{
    [_tf_srearch resignFirstResponder];
}


- (void)viewDidAppear:(BOOL)animated {
     [self loadgenres];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

    if (audioPlayer.isPlaying) {
        [audioPlayer stop];
    }
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];

    [sliderTimer invalidate];
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

//-----------* Logic for Pull to Refresh *-------------
- (void)refreshTable:(UIRefreshControl *)refreshControl
{
    loadingData=NO;
    limit = 0;
    current_Record=0;
    if (isMelody) {
        [self loadMelodyPacks];

    }
    else{
        arr_rec_response=[[NSMutableArray alloc]init];

        [self loadRecordings];
    }
    [refreshControl endRefreshing];
}


#pragma mark- Calling Genere API
#pragma mark-

-(void)loadgenres{
    {
        //save_melody:saverecording
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
                        arr_menu_items=[[NSMutableArray alloc]init];
                        arr_tab_select=[[NSMutableArray alloc]init];
                        arr_genre_id=[[NSMutableArray alloc]init];
                        arr_response1=[jsonObject valueForKey:@"response"];
                        // NSLog(@"%@",arr_response);
                        for (int i=0; i<[arr_response1 count]; i++) {
                            if ([loadGenreFrom isEqualToString:@"RECORDINGS"])
                            {
                                if ([[[arr_response1 objectAtIndex:i] valueForKey:@"name"] isEqualToString:@"My Melodies"])
                                {
                                    //...
                                }
                                else
                                {
                                    [arr_menu_items addObject:[[arr_response1 objectAtIndex:i] valueForKey:@"name"]];
                                    [arr_genre_id addObject:[[arr_response1 objectAtIndex:i] valueForKey:@"id"]];
                                }
                            }
                            else{
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
                        [arr_tab_select addObject:@"0"];
                        [arr_genre_id addObject:@"0"];
                        NSLog(@"%@",arr_menu_items);
                        NSLog(@"%@",arr_tab_select);
                        NSLog(@"%@",arr_genre_id);
                        [_cv_menu reloadData];
                    }else{
                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"Alert"
                                                      message:@"Invailid Server Request!"
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



-(void)load_package_details
{
    @try{
        if([[MyManager sharedManager] isInternetAvailable])
        {
            [KSToastView ks_showToast:@"Internet connectivity issue" delay:0.1f];
            return;
        }
        [Appdelegate showProgressHud];
        
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
   // [params setObject:@"admin@123" forKey:@"key"];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    if([defaults_userdata boolForKey:@"isUserLogged"])
    {
    [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:@"user_id"];
    }
    NSLog(@"PARAMS %@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length])
        {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    
    NSString* urlString = [NSString stringWithFormat:@"%@pakages.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLSessionDataTask *dataTask = [session
                                      dataTaskWithRequest:request
                                      completionHandler:^(NSData *data, NSURLResponse* response, NSError *error)
                                      {
                                          if (error)
                                          {
                                              [Appdelegate hideProgressHudInView];
                                              NSLog(@"%@", error);

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
                                                      [Appdelegate hideProgressHudInView];
                                                      arr_plan_type=[[NSMutableArray alloc]init];
                                                      arr_layes=[[NSMutableArray alloc]init];
                                                      arr_recording_time=[[NSMutableArray alloc]init];
                                                      arr_packageID=[[NSMutableArray alloc]init];
                                                      arr_plan_price=[[NSMutableArray alloc]init];
                                                      arr_response1=[jsonObject valueForKey:@"response"];
                                                      for (int i=0; i<[arr_response1 count]; i++)
                                                      {
                                                          [arr_layes addObject:[[arr_response1 objectAtIndex:i] valueForKey:@"total_melody"]];
                                                          [arr_plan_type addObject:[[arr_response1 objectAtIndex:i] valueForKey:@"package_name"]];
                                                          [arr_plan_price addObject:[[arr_response1 objectAtIndex:i] valueForKey:@"cost"]];
                                                          [arr_recording_time addObject:[[arr_response1 objectAtIndex:i] valueForKey:@"recording_time"]];
                                                          [arr_packageID addObject:[[arr_response1 objectAtIndex:i] valueForKey:@"package_id"]];
                                                      }
                                                      subscribedPack=[jsonObject valueForKey:@"subscribedPack"];
                                                      
                                                      
                                                      [_tbl_view_subscr_packs reloadData];
                                                      
                                                  }
                                                  else
                                                  {
                                                      [Appdelegate hideProgressHudInView];

                                                      UIAlertController * alert=   [UIAlertController
                                                                                    alertControllerWithTitle:@"Alert"
                                                                                    message:@"Invailid Server Request!"
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
                                              });
                                          }
                                      }];
    [dataTask resume];
    }
    @catch (NSException *exception) {
        [Appdelegate hideProgressHudInView];
        NSLog(@"exception at pakages.php :%@",exception);
    }
    @finally{
        
    }
}


-(void)getPackagesDetailsAndStatus
{
    @try{
        if([[MyManager sharedManager] isInternetAvailable])
        {
            [KSToastView ks_showToast:@"Internet connectivity issue" delay:0.1f];
            return;
        }
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    //[params setObject:@"admin@123" forKey:@"key"];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    if([defaults_userdata boolForKey:@"isUserLogged"]) {
        [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:@"user_id"];
    }
    else
    {
        NSLog(@"PLEASE LOG IN");
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
    
    NSString* urlString = [NSString stringWithFormat:@"%@subscription_detail.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLSessionDataTask *dataTask = [session
      dataTaskWithRequest:request
      completionHandler:^(NSData* data, NSURLResponse* response, NSError *error)
      {
      if (error)
      {
      NSLog(@"%@", error);
          [Appdelegate hideProgressHudInView];

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
                  [Appdelegate hideProgressHudInView];
                  arr_packageStatusDetails=[[NSMutableArray alloc]init];
                  
                  arr_packageStatusDetails=[[jsonObject valueForKey:@"response"] objectForKey:@"subscribed"];
                  // NSLog(@"%@",arr_response);
                  [_tbl_view_subscr_packs reloadData];
              }
              else
              {
                  [Appdelegate hideProgressHudInView];
                  UIAlertController * alert=   [UIAlertController
                                                alertControllerWithTitle:@"Alert"
                                                message:@"Invailid Server Request!"
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
    @catch (NSException *exception) {
        [Appdelegate hideProgressHudInView];
        NSLog(@"exception at subscription_detail.php :%@",exception);
    }
    @finally{
        
    }
}


/***************************Call Melody Packs api**********************************/
-(void)loadMelodyPacks
{
    if([[MyManager sharedManager] isInternetAvailable])
    {
        [KSToastView ks_showToast:@"Internet connectivity issue" delay:0.1f];
        return;
    }
    [Appdelegate showProgressHud];
    @try{

    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];

    if ([defaults_userdata boolForKey:@"isUserLogged"]) {
        [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:@"users_id"];
    }
    
    [params setObject:genre forKey:@"genere"];
    [params setObject:[NSString stringWithFormat:@"%ld",(long)limit] forKey:@"limit"];

    NSString *fileType = @"admin_melody";
    if (isMyMelody) {
        //fileType = @"user_melody";
        fileType = @"admin_melody";
    }
        //7
    if ([genre1 isEqualToString:@"My Melodies"]) {
        [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:@"users_id"];
        [params removeObjectForKey:@"genere"];
        fileType = @"user_melody";
    }
    [params setObject:fileType forKey:KEY_SHARE_FILETYPE];
    if(recording_typeInt == Search){
        [params setObject:searchString forKey:@"search"];
    }
    if (recording_typeInt == Filter)
    {

        [params setObject:@"extrafilter" forKey:@"filter"];
        [params setObject:fileType forKey:KEY_SHARE_FILETYPE];
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

    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@melody.php",BaseUrl];
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
                        
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [Appdelegate hideProgressHudInView];
                            NSError *myError = nil;
                            
                            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                            NSLog(@"%@",requestReply);
                            NSData *myRequestData = [requestReply dataUsingEncoding:NSUTF8StringEncoding];

                            
                            id jsonObject = [NSJSONSerialization
                                             JSONObjectWithData:myRequestData
                                             options:NSJSONReadingAllowFragments error:&myError];
                            
                            if ([[jsonObject valueForKey:@"flag"] isEqual:@"success"]) {
                                self.placeholder_img.hidden = YES;
                                self.tbl_view_melodypacks.hidden = NO;
                                self.tbl_view_recordings.hidden = YES;

                                limit=[[jsonObject valueForKey:@"response"] count];
                                arr_melody_pack_id=[[NSMutableArray alloc]init];
                                
                                arr_melody_thumbnailURL=[[NSMutableArray alloc]init];
                                //arr_melody_thumbnailURL
                                arr_melody_pack_name=[[NSMutableArray alloc]init];
                                arr_melody_pack_instrumentals_count=[[NSMutableArray alloc]init];
                                arr_melody_pack_bpm=[[NSMutableArray alloc]init];
                                arr_melody_pack_genre=[[NSMutableArray alloc]init];
                                arr_melody_pack_station=[[NSMutableArray alloc]init];
                                arr_melody_pack_cover=[[NSMutableArray alloc]init];
                                arr_melody_pack_profile=[[NSMutableArray alloc]init];
                                arr_melody_pack_intrumentals=[[NSMutableArray alloc]init];
                                arr_melody_pack_post_date=[[NSMutableArray alloc]init];
                                arr_melody_pack_no_of_play=[[NSMutableArray alloc]init];
                                arr_melody_pack_no_of_like=[[NSMutableArray alloc]init];
                                arr_melody_pack_no_of_share=[[NSMutableArray alloc]init];
                                arr_melody_pack_no_of_coments=[[NSMutableArray alloc]init];
                                arr_melody_like_status=[[NSMutableArray alloc]init];
                                arr_melody_url=[[NSMutableArray alloc]init];
                                arr_melody_pack_timerM = [[NSMutableArray alloc]init];
                                arr_indexForPlayM = [[NSMutableArray alloc]init];

                                instrumentURLArrayM=[[NSMutableArray alloc]init];
                                NSArray *arr_temp = [[NSArray alloc]init];
                                arr_temp=[jsonObject valueForKey:@"response"];
                                [arr_response addObjectsFromArray:arr_temp];
                                current_Record = arr_response.count;
                                loadingData = YES;
                                NSLog(@"%@",arr_response);
                                for (int i=0; i<[arr_response count]; i++) {
                                //--------- initializes play index counter -----------
                                [arr_indexForPlayM setObject:@"0" atIndexedSubscript:i];
                                //----------------------------------------------------
                                    
                                [arr_melody_pack_timerM addObject:[NSString stringWithFormat:@"%@",[[arr_response objectAtIndex:i] valueForKey:@"duration"]]];
                                    
                                    NSLog(@"%@",[arr_response objectAtIndex:i]);
                                    [arr_melody_pack_id addObject:[[arr_response objectAtIndex:i] valueForKey:@"melodypackid"]];
                                    [arr_melody_pack_genre addObject:[[arr_response objectAtIndex:i] valueForKey:@"genre_name"]];
                                    [arr_melody_pack_name addObject:[[arr_response objectAtIndex:i] valueForKey:@"name"]];
                                    [arr_melody_pack_station addObject:[[arr_response objectAtIndex:i] valueForKey:@"username"]];
                                    
                                    [arr_melody_pack_cover addObject:[NSString stringWithFormat:@"%@",[[arr_response objectAtIndex:i] valueForKey:@"cover"]]];
                       
                                    [arr_melody_pack_profile addObject:[NSString stringWithFormat:@"%@",[[arr_response objectAtIndex:i] valueForKey:@"profilepic"]]];
                                    /*-------- melody@url ----------*/
                                    [arr_melody_url addObject:[[arr_response objectAtIndex:i]
                                                               valueForKey:@"melodyurl"]];
                                    
                                    [arr_melody_pack_intrumentals addObject:[[arr_response objectAtIndex:i] valueForKey:@"instruments"]];
                                    
//                                    NSArray *temparr =  [[arr_response objectAtIndex:i] valueForKey:@"instruments"];
                                    NSArray *temparr = [Appdelegate valueOrNil:[[arr_response objectAtIndex:i] valueForKey:@"instruments"]];
                                    
                                    [instrumentURLArrayM addObject:temparr];

                                    for (int i=0 ; i<temparr.count; i++) {
                                        NSLog(@" value %@",[[temparr objectAtIndex:i]valueForKey:@"instrument_url"]);
                                    }
                                    int max = 0;
                                    for (int n=0; n<[arr_melody_pack_intrumentals count]; n++)
                                    {
                                        max=0;
                                        NSArray *tempDuration=[[NSArray alloc]init];
                                        tempDuration = [[arr_melody_pack_intrumentals objectAtIndex:i] valueForKey:@"duration"];
                                        for (int j=0; j<[tempDuration count]; j++)
                                        {
                                            int num=[[tempDuration objectAtIndex:j] intValue];
                                            if (num>max)
                                            {
                                                max=num;
                                            }
                                        }
                                        
                                    }
                                    [maxDuration addObject:[NSString stringWithFormat:@"%d",max]];
                                    
                                    
                                    [arr_melody_pack_instrumentals_count addObject:[NSString stringWithFormat:@"%lu",(unsigned long)[[arr_melody_pack_intrumentals objectAtIndex:i]count]]];
                                    [arr_melody_pack_post_date addObject:[[arr_response objectAtIndex:i] valueForKey:@"date"] ];
                                    [arr_melody_pack_bpm addObject:[[arr_response objectAtIndex:i] valueForKey:@"bpm"] ];
                                    
                                    [arr_melody_pack_no_of_play addObject:[[arr_response objectAtIndex:i] valueForKey:@"playcounts"] ];
                                    [arr_melody_pack_no_of_like addObject:[[arr_response objectAtIndex:i] valueForKey:@"likescounts"] ];
                                    [arr_melody_pack_no_of_coments addObject:[[arr_response objectAtIndex:i] valueForKey:@"commentscounts"] ];
                                    [arr_melody_pack_no_of_share addObject:[[arr_response objectAtIndex:i] valueForKey:@"sharecounts"] ];
                                    
                                    if([[[arr_response objectAtIndex:i] valueForKey:@"like_status"] isEqual:[NSNull null]])
                                    {
                                        [arr_melody_like_status addObject:@"0"];
                                    }
                                    else
                                    {
                                        [arr_melody_like_status addObject:[[arr_response objectAtIndex:i] valueForKey:@"like_status"] ];
                                    }
                                  
                                    
                                }
                                isMyMelody = NO;
                                [_tbl_view_melodypacks reloadData];
                            }
                            else
                            {
                                [Appdelegate hideProgressHudInView];
                                if (!loadingData) {
                                    self.placeholder_img.hidden = NO;
                                    self.tbl_view_melodypacks.hidden = YES;
                                    self.placeholder_img.image = [UIImage imageNamed:@"NoResult_img"];
                                    arr_rec_pack_id=[[NSMutableArray alloc]init];
                                    
                                    arr_melody_pack_id=[[NSMutableArray alloc]init];
                                }
                                else{
                                    [Appdelegate hideProgressHudInView];
//                                    [_tbl_view_melodypacks reloadData];
                                }
                              
                            }
                        });
                    }
                }];
    [dataTask resume];
    }
    @catch (NSException *exception) {
        [Appdelegate hideProgressHudInView];
        NSLog(@"exception at melody.php :%@",exception);
    }
    @finally{
        
    }

}




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
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];

    if ([defaults_userdata boolForKey:@"isUserLogged"]) {
        [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:KEY_USER_ID];
    }
    [params setObject:@"Myrecording" forKey:@"key"];
        [params setObject:[NSString stringWithFormat:@"%ld",(long)limit] forKey:@"limit"];

    if (recording_typeInt == Filter)
    {
        [params setObject:@"extrafilter" forKey:@"filter"];
        [params setObject:@"user_recording" forKey:KEY_SHARE_FILETYPE];
        [params setObject:filterString forKey:@"filter_type"];
        [params removeObjectForKey:@"genere"];
//        [params setObject:[NSString stringWithFormat:@"%ld",(long)limit] forKey:@"limit"];

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
    NSLog(@"parameters = %@ ",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }

    NSString* urlString = [NSString stringWithFormat:@"%@recordings.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    //this is how cookies were created
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

            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Appdelegate hideProgressHudInView];
                    NSError *myError = nil;
                    
                    NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                    NSLog(@"%@",requestReply);
                    NSData *data2=[requestReply dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                    
                    
                    id jsonObject = [NSJSONSerialization
                                     
                                     JSONObjectWithData:data2
                                     options:NSJSONReadingAllowFragments error:&myError];
                    
                    // NSLog(@"%@",jsonObject);
                    if ([[jsonObject valueForKey:@"flag"] isEqual:@"success"]) {
                        self.placeholder_img.hidden = YES;
                        self.tbl_view_recordings.hidden  = NO;
                        
                        arr_PublicState=[[NSMutableArray alloc]init];
                        arr_rec_pack_id=[[NSMutableArray alloc]init];
                        arr_rec_name=[[NSMutableArray alloc]init];
                        arr_rec_instrumentals_count=[[NSMutableArray alloc]init];
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
                        arrJoinedM=[[NSMutableArray alloc]init];

                        
                        arr_rec_like_status=[[NSMutableArray alloc]init];
//                        arr_rec_response=[[NSMutableArray alloc]init];
                        followerID=[[NSMutableArray alloc]init];
                        genreArray = [[NSMutableArray alloc]init];
                        arr_rec_duration= [[NSMutableArray alloc]init];
                        loadingData = YES;

                        NSArray *tempArrayM = [[NSArray alloc]init];
                        tempArrayM = [jsonObject valueForKey:@"response"];
                        [arr_rec_response addObjectsFromArray:tempArrayM];
                        //followerID
                        NSLog(@"%@",arr_rec_response);
//                        current_Record = arr_rec_response.count;

                        for (int i=0; i<[arr_rec_response count]; i++)
                        {
                            NSLog(@"%@",[arr_rec_response objectAtIndex:i]);
                            if([[[arr_rec_response objectAtIndex:i] valueForKey:@"like_status"] isEqual:[NSNull null]])
                            {
                                [arr_rec_like_status addObject:@"0"];
                            }
                            else
                            {
                                [arr_rec_like_status addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"like_status"]];
                            }
                            
                            if([[[arr_rec_response objectAtIndex:i] valueForKey:@"recording_id"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"recording_id"] length]==0)
                            {
                                [arr_rec_pack_id addObject:@"0"];
                            }
                            else
                            {
                                [arr_rec_pack_id addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"recording_id"]];
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
                                [genreArray addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"genre_name"]];
                            }
                            if([[[arr_rec_response objectAtIndex:i] valueForKey:@"recording_topic"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"recording_topic"] length]==0)
                            {
                                [arr_rec_name addObject:@"0"];
                            }
                            else
                            {
                                [arr_rec_name addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"recording_topic"]];
                            }
                            //*-----For PUBILC STATE
                            if([[[arr_rec_response objectAtIndex:i] valueForKey:@"public"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"public"] length]==0)
                            {
                                [arr_PublicState addObject:@"0"];
                                
                            }
                            else
                            {
                                [arr_PublicState addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"public"]];
                                
                            }
                            //
                            if([[[arr_rec_response objectAtIndex:i] valueForKey:@"user_name"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"user_name"] length]==0)
                            {
                                [arr_rec_station addObject:@"0"];
                            }
                            else
                            {
                                [arr_rec_station addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"user_name"]];
                            }
                            
                            if([[[arr_rec_response objectAtIndex:i] valueForKey:@"cover_url"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"cover_url"] length]==0)
                            {
                                [arr_rec_cover addObject:@"http://"];
                                [arr_rec_duration addObject:@""];
                            }
                            else
                            {
                                [arr_rec_cover addObject:[NSString stringWithFormat:@"%@",[[arr_rec_response objectAtIndex:i] valueForKey:@"cover_url"]]];
                                
                                if ([[arr_rec_response objectAtIndex:i] objectForKey:@"recordings"] != [NSNull null]) {
                                   [arr_rec_duration addObject:[NSString stringWithFormat:@"%@",[[[[arr_rec_response objectAtIndex:i] objectForKey:@"recordings"] objectAtIndex:0] objectForKey:@"duration"]]];
                                }
                               
                            }
                            
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
                                [arr_rec_intrumentals addObject:@"0"];
                            }
                            else
                            {
                                [arr_rec_intrumentals addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"recordings"]];
                            }
                            
                            if([[[arr_rec_response objectAtIndex:i] valueForKey:@"date_added"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"date_added"] length]==0)
                            {
                                [arr_rec_post_date addObject:@"0"];
                            }
                            else
                            {
                                [arr_rec_post_date addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"date_added"] ];
                            }
                            
                  
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
                            
                        }
                        
                        [_tbl_view_recordings reloadData];
//                        [self.tbl_view_melodypacks reloadData];
                    }
                    else
                    {
                        loadingData = NO;
                        [Appdelegate hideProgressHudInView];
                        if (!loadingData) {
                            self.placeholder_img.hidden = NO;
                            self.tbl_view_melodypacks.hidden = YES;
                            self.tbl_view_recordings.hidden = YES;
                            self.placeholder_img.image = [UIImage imageNamed:@"NoResult_img"];
                            arr_rec_pack_id=[[NSMutableArray alloc]init];
                            [_tbl_view_recordings reloadData];
                        }
                        
                     
                    }
                    
                });
            }
                                                }];
    [dataTask resume];
        
    }
    @catch (NSException *exception) {
        [Appdelegate hideProgressHudInView];
        NSLog(@"exception  at recording.php : %@",exception);
    }
    @finally{
        
    }
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
                                           
                                           if (isMelody) {
                                               limit=0;
                                               arr_response=[[NSMutableArray alloc]init];
                                               [self loadMelodyPacks];
                                           }
                                           else{
                                               arr_rec_response=[[NSMutableArray alloc]init];
                                               [self loadRecordings];
                                           }                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
    // You can also use self.view if you don't have a sender
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
                                                           if (isMelody)
                                                           {
                                                               [self loadMelodyPacks];
                                                           }
                                                           else{
                                                               arr_rec_response=[[NSMutableArray alloc]init];
                                                               [self loadRecordings];
                                                           }                                                       }
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




-(void)join_clicked:(UIButton*)sender
{
    index=sender.tag;
[self performSegueWithIdentifier:@"melody_to_studio_play" sender:self];
    
}


- (void)show_options:(UIButton*)sender
{
    //AudioFeedTableViewCell *cell = (ActivitiesTableViewCell*)[nib2 objectAtIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];

    AudioFeedTableViewCell *cell = (AudioFeedTableViewCell*)[_tbl_view_recordings cellForRowAtIndexPath:indexPath];
    
    if (status1==0) {
        cell.btn_hide.hidden=NO;
        status1=1;
    }
    else{
        cell.btn_hide.hidden=YES;
        status1=0;
    }
}




#pragma mark- Payment API

-(void)sendPaymentDetails
{
    if([[MyManager sharedManager] isInternetAvailable])
    {
        [KSToastView ks_showToast:@"Internet connectivity issue" delay:0.1f];
        return;
    }
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    if([defaults_userdata boolForKey:@"isUserLogged"])
    {
        [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:@"user_id"];
    }
    else
    {
        NSLog(@"PLEASE LOG IN");
    }
    
    
    [params setObject:packageStatus forKey:@"status"];
    [params setObject:packageID forKey:@"package_id"];
    
    if ([packageID isEqualToString:@"0"])
    {
        //....
    }
    else
    {
        [params setObject:transactionID forKey:@"id"];
        [params setObject:createTime forKey:@"create_time"];
        [params setObject:paymentState forKey:@"state"];
        [params setObject:payableAmount forKey:@"payment"];
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
    
    NSString* urlString = [NSString stringWithFormat:@"%@sub_detail.php",BaseUrl];
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
                                              [Appdelegate hideProgressHudInView];
                                              NSLog(@"%@", error);
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
                                                  NSData *data2=[requestReply dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                                                  id jsonObject = [NSJSONSerialization JSONObjectWithData:data2
                                                                                                  options:NSJSONReadingAllowFragments
                                                                                                    error:&myError];
                                                  NSLog(@"%@",jsonObject);
                                                  resultDict=[jsonObject valueForKey:@"response"];
                                                  if ([[jsonObject valueForKey:@"flag"] isEqual:@"success"])
                                                  {
                                                      
                                                      [Appdelegate hideProgressHudInView];
                                                      [_tbl_view_subscr_packs reloadData];
                                                  }
                                                  else
                                                  {
                                                      [Appdelegate hideProgressHudInView];
                                                      UIAlertController * alert=   [UIAlertController
                                                                                    alertControllerWithTitle:@"Alert"
                                                                                    message:[resultDict objectForKey:@"msg"]
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



#pragma mark- TimerupdateSlider
#pragma mark-

-(void)timerupdateSlider{
    // Update the slider about the music time
    @try{
 
        if ([genre1 isEqualToString:@"My Melodies"]){
            MelodyPacksTableViewCell *cell = [self.tbl_view_melodypacks cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
            cell.slider_progress.value = audioPlayer.currentTime;
            
            cell.lbl_timer.text=[NSString stringWithFormat:@"%@",[Appdelegate timeFormatted:[NSString stringWithFormat:@"%f",audioPlayer.currentTime]]];
        }
        else if(isMelody)
        {
            audioPlayer = [soundsArray objectAtIndex:fileSize];
            MelodyPacksTableViewCell *cell = [self.tbl_view_melodypacks cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
            cell.slider_progress.value = audioPlayer.currentTime;
            
            cell.lbl_timer.text=[NSString stringWithFormat:@"%@",[Appdelegate timeFormatted:[NSString stringWithFormat:@"%f",audioPlayer.currentTime]]];
        }
        
        else{
            AudioFeedTableViewCell *cell = [self.tbl_view_recordings cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
            cell.slider_progress.value = audioPlayer.currentTime;
            cell.lbl_timer.text=[NSString stringWithFormat:@"%@",[Appdelegate timeFormatted:[NSString stringWithFormat:@"%f",audioPlayer.currentTime]]];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at  :%@",exception);
    }
    @finally{
        
    }
}

#pragma mark- _audioPlayer DELEGATE
#pragma mark-

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    NSLog(@"------------------ tableViewTag %d",tableViewTag);
    if (isMelody || [genre1 isEqualToString:@"My Melodies"]) {
        MelodyPacksTableViewCell *cell = [self.tbl_view_melodypacks cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
        [cell.btn_playpause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
        cell.slider_progress.value = 0.0;
        audioPlayer = nil;
        [sliderTimer invalidate];
        sliderTimer = nil;
        soundsArray = [[NSMutableArray alloc]init];
//        isMelody = NO;
    }
    else{
        AudioFeedTableViewCell *cell = [_tbl_view_recordings cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
        [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
        audioPlayer = nil;
        cell.slider_progress.value = 0.0;
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
    
}

#pragma mark-

-(void)sliderChanged:(id)sender{
    // Fast skip the music when user scroll the UISlider
    MelodyPacksTableViewCell *cell = [self.tbl_view_melodypacks cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    [audioPlayer setCurrentTime:cell.slider_progress.value];
}


#pragma mark- PLAY METHODS FOR MELODY

-(void)btn_playpause_clicked:(UIButton*)sender{
    
    @try{
        
        isTableScrollable = YES;
        instrument_play_index = sender.tag;
        MelodyPacksTableViewCell *cell = [self.tbl_view_melodypacks cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
//        if ([[arr_indexForPlayM objectAtIndex:sender.tag] isEqualToString:@"0"]) {
//            [arr_indexForPlayM replaceObjectAtIndex:sender.tag withObject:@"1"];
//
//        }
        if(audioPlayer && lastIndex == sender.tag && [genre1 isEqualToString:@"My Melodies"]){
            if(!toggle_Play)
            {
                [cell.btn_playpause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                toggle_Play = !toggle_Play;
                [ProgressHUD dismiss];
                [audioPlayer pause];
                
            }
            
            else {
                toggle_Play = !toggle_Play;
                [cell.btn_playpause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
                [ProgressHUD dismiss];
                [audioPlayer play];
                
            }
        }
        
        else  if(isMelodyPlay && lastIndex == sender.tag && ![genre1 isEqualToString:@"My Melodies"])
        {
            if(!toggle_Play)
            {
                [cell.btn_playpause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                toggle_Play = !toggle_Play;
                [ProgressHUD dismiss];
                [self pausePlay];
                
            }
            
            else {
                toggle_Play = !toggle_Play;
                [cell.btn_playpause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
                [ProgressHUD dismiss];
                [self allPlay];
                
            }
        }
        
        else{
            [self stopPlay];
            [audioPlayer stop];
            audioPlayer = nil;
            soundsArray = [[NSMutableArray alloc]init];
            [sliderTimer invalidate];
            sliderTimer = nil;
            MelodyPacksTableViewCell *cell = [_tbl_view_melodypacks cellForRowAtIndexPath:[NSIndexPath
                                                                                           indexPathForRow:instrument_play_index inSection:0]];
            [cell.btn_playpause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
            
            
            if (lastIndex != sender.tag){
                MelodyPacksTableViewCell *cell = [self.tbl_view_melodypacks cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastIndex inSection:0]];
                [cell.btn_playpause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                audioPlayer.numberOfLoops = 0;
                //                    audioPlayer = nil;
                cell.slider_progress.value = 0.0;
            }
            isMelodyPlay = YES;
            [Appdelegate showProgressHud];
            dispatch_queue_t myqueue = dispatch_queue_create("queue", NULL);
            dispatch_async(myqueue, ^{
                
                NSLog(@"sync task");
                NSArray * arr = [instrumentURLArrayM objectAtIndex:instrument_play_index];
                dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    for (int i=0; i<arr.count; i++) {
                        NSString *strUrl = [[arr objectAtIndex:i]valueForKey:@"instrument_url"];
                        [self addPlayerObjects:strUrl index:i];
                    }
                });
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    @try{
                        if([defaults_userdata boolForKey:@"isUserLogged"]) {
                            [self method_PlayCount:instrument_play_index];
                        }
                        
                        if ([genre1 isEqualToString:@"My Melodies"]){
                            NSError*error=nil;
                            NSString *urlstr =[[arr_response objectAtIndex:instrument_play_index]valueForKey:@"melodyurl"];
                            NSURL *urlforPlay = [NSURL URLWithString:urlstr];
                            NSData *data = [NSData dataWithContentsOfURL:urlforPlay];
                            audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
                            audioPlayer.delegate = self;
                            [audioPlayer prepareToPlay];
                            if ([audioPlayer prepareToPlay] == YES){
                                sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerupdateSlider) userInfo:nil repeats:YES];
                                // Set the maximum value of the UISlider
                                cell.slider_progress.maximumValue=[audioPlayer duration];
                                cell.slider_progress.value = 0.0;
                                // Set the valueChanged target
                                [cell.slider_progress addTarget:self action:@selector(sliderChangedC) forControlEvents:UIControlEventValueChanged];
                                [Appdelegate hideProgressHudInView];
                                [cell.btn_playpause setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
                                [audioPlayer stop];
                                [audioPlayer play];
                                
                            }
                            
                            else {
                                
                                [Appdelegate hideProgressHudInView];
                                MelodyPacksTableViewCell *cell1 = [_tbl_view_melodypacks cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastIndex inSection:0]];
                                cell1.slider_progress.value = 0.0;
                                [cell1.btn_playpause setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                                
                                int errorCode = CFSwapInt16HostToBig ([error code]);
                                NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
                            }
                        }
                        else{
                            audioPlayer = [soundsArray objectAtIndex:fileSize];
                            sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerupdateSlider) userInfo:nil repeats:YES];
                            
                            cell.slider_progress.maximumValue=[audioPlayer duration];
                            cell.slider_progress.minimumValue=0.0;
                            
                            for (audioPlayer in soundsArray){
                                audioPlayer.delegate=self;
                                [cell.slider_progress addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
                                cell.slider_progress.tag = instrument_play_index;
                                instrument_play_status=1;
                                [Appdelegate hideProgressHudInView];
                                [audioPlayer play];
                                
                            }
                        }
                        
                    }
                    @catch (NSException *exception) {
                        NSLog(@"exception at soundarray :%@",exception);
                        [Appdelegate hideProgressHudInView];
                    }
                    @finally{
                        
                    }
                });
            });
            
        }
        lastIndex = sender.tag;
    }
    @catch (NSException *exception) {
        NSLog(@"exception at btn_playpause_clicked :%@",exception);
        [Appdelegate hideProgressHudInView];

    }
    @finally{
        
    }
}

-(void)playerInitializes{
    [audioPlayer stop];
    [sliderTimer invalidate];
    sliderTimer = nil;
    audioPlayer = nil;
}

#pragma mark - Previous & Next Method
#pragma mark -

- (void)btn_previousAction:(UIButton *)sender {
    NSLog(@"btn_previousAction");
    instrument_play_index = sender.tag;
    [self playerInitializes];
    AudioFeedTableViewCell *cell = [self.tbl_view_recordings cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
    
    if (sender.tag == lastIndex && isPlayable) {
        if ([[arr_rec_response objectAtIndex:sender.tag] valueForKey:@"joined"] == [NSNull null] )
        {
            arrJoinedM = [[arr_rec_response objectAtIndex:sender.tag] valueForKey:@"joined"];
        }
        
        if (currentIndex_user > 0) {
            currentIndex_user -= 1;
            NSLog(@"currentIndex_user %ld",currentIndex_user);
            AudioFeedTableViewCell *cell = [self.tbl_view_recordings cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
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
            AudioFeedTableViewCell *cell = [self.tbl_view_recordings cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
            
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
    
    AudioFeedTableViewCell *cell = [self.tbl_view_recordings cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
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
            AudioFeedTableViewCell *cell = [self.tbl_view_recordings cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
            
            long includeL =[[[arr_rec_response objectAtIndex:sender.tag] valueForKey:@"join_count"]longValue];
            
            cell.lbl_oneof.text = [NSString stringWithFormat:@"( %ld of %ld )",currentIndex_user+1,includeL];
        }
    }
    
}


-(void)playNextOrPrevious_Tapped:(long)sender{
    
    @try{
        [Appdelegate showProgressHud];
        dispatch_queue_t myqueue = dispatch_queue_create("queue", NULL);
        dispatch_async(myqueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self playerInitializes];
                AudioFeedTableViewCell *cell = [_tbl_view_recordings cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender inSection:0]];
                
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
                    [cell.slider_progress addTarget:self action:@selector(sliderChangedC) forControlEvents:UIControlEventValueChanged];
                    [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
                    [Appdelegate hideProgressHudInView];
                    [audioPlayer stop];
                    [audioPlayer play];
                }
            });
            
        });
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@",exception);
    }
    @finally{
        
    }
}



#pragma mark- PLAY METHODS FOR RECORDING

- (void)btn_Recordings_Play_clicked:(UIButton* )sender {
    @try{
        instrument_play_index = sender.tag;
        isPlayable = YES;

        AudioFeedTableViewCell *cell = [_tbl_view_recordings cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
        
        if(audioPlayer && lastIndex == sender.tag) {
            if (toggle_PlayPause ) {
                toggle_PlayPause = !toggle_PlayPause;
                [audioPlayer pause];
                [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
            }
        
        else {
            toggle_PlayPause = !toggle_PlayPause;
            [audioPlayer play];
            [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
        }
            
        }
        else{
            [Appdelegate showProgressHud];
            if(audioPlayer){
                [audioPlayer stop];
                audioPlayer = nil;
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
                if([defaults_userdata boolForKey:@"isUserLogged"]) {
                    [self method_PlayCount:instrument_play_index];
                }
            NSError*error=nil;
            NSString *urlstr =[[[arr_rec_intrumentals objectAtIndex:instrument_play_index]objectAtIndex:0]valueForKey:@"recording_url"];
            NSURL *urlforPlay = [NSURL URLWithString:urlstr];
            NSData *data = [NSData dataWithContentsOfURL:urlforPlay];
                
                
            audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
            audioPlayer.delegate = self;
            [audioPlayer prepareToPlay];
            if ([audioPlayer prepareToPlay] == YES){
                dispatch_async(dispatch_get_main_queue(), ^{
                if (lastIndex != 10000) {
                    AudioFeedTableViewCell *cell1 = [_tbl_view_recordings cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastIndex inSection:0]];
                    cell1.slider_progress.value = 0.0;
                    [cell1.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                }
                
                sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerupdateSliderC) userInfo:nil repeats:YES];
                // Set the maximum value of the UISlider
                cell.slider_progress.maximumValue=[audioPlayer duration];
                cell.slider_progress.value = 0.0;
                // Set the valueChanged target
                [cell.slider_progress addTarget:self action:@selector(sliderChangedC) forControlEvents:UIControlEventValueChanged];
                [Appdelegate hideProgressHudInView];
                [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
                [audioPlayer stop];
                [audioPlayer play];
            });
            }
            
            else {
                
                [Appdelegate hideProgressHudInView];
                AudioFeedTableViewCell *cell1 = [_tbl_view_recordings cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastIndex inSection:0]];
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
        NSLog(@"exception at  :%@",exception);
        [Appdelegate hideProgressHudInView];

    }
    @finally{
        
    }
}



-(void)sliderChangedC{
    // Fast skip the music when user scroll the UISlider
    AudioFeedTableViewCell *cell = [_tbl_view_recordings cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    [audioPlayer setCurrentTime:cell.slider_progress.value];
    instrument_play_status=1;
    
}

-(void)timerupdateSliderC{
    // Update the slider about the music time
    
    AudioFeedTableViewCell *cell = [_tbl_view_recordings cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    cell.slider_progress.value = audioPlayer.currentTime;
    //--------------------* Set the playlist timer *-------------------------
    cell.lbl_timer.text=[NSString stringWithFormat:@"%@",[Appdelegate timeFormatted:[NSString stringWithFormat:@"%f",audioPlayer.currentTime]]];
    
}




-(void)method_PlayCount:(NSInteger)sender{
    @try{
    
    NSString *userid = [defaults_userdata objectForKey:@"user_id"];
    NSLog(@"userid %@",userid);
    
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:@"userid"];
    if (isMelody) {
        [params setObject:@"melody" forKey:@"type"];
        [params setObject:@"admin" forKey:@"user_type"];
        [params setObject:[arr_melody_pack_id objectAtIndex:sender] forKey:@"fileid"];
        
    }
    else{
        [params setObject:@"recording" forKey:@"type"];
        [params setObject:@"user" forKey:@"user_type"];
        [params setObject:[arr_rec_pack_id objectAtIndex:sender] forKey:@"fileid"];
        
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
                    
                    if (isMelody) {
                        long a = [[arr_melody_pack_no_of_play objectAtIndex:sender] integerValue]+1;
                        [arr_melody_pack_no_of_play replaceObjectAtIndex:sender withObject:[NSNumber numberWithInteger:a]];
                        [_tbl_view_melodypacks reloadData];
                    }
                    else{
                        long a = [[arr_rec_play_count objectAtIndex:sender] integerValue]+1;
                        [arr_rec_play_count replaceObjectAtIndex:sender withObject:[NSNumber numberWithInteger:a]];
                        [_tbl_view_recordings reloadData];
                        
                    }
                    
                }
                else
                {
                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"Alert"
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
        NSLog(@"exception at method_PlayCount :%@",exception);
    }
    @finally{
        
    }
}




- (void)hide_cellrecording:(UIButton*)sender
{
    [arr_rec_pack_id removeObjectAtIndex:sender.tag];
    [arr_rec_name removeObjectAtIndex:sender.tag];
    //[arr_rec_instrumentals_count removeObjectAtIndex:sender.tag];
   // [arr_rec_bpm removeObjectAtIndex:sender.tag];
    [arr_rec_genre removeObjectAtIndex:sender.tag];
    [arr_rec_station removeObjectAtIndex:sender.tag];
    [arr_rec_cover removeObjectAtIndex:sender.tag];
    [arr_rec_profile removeObjectAtIndex:sender.tag];
    [arr_rec_intrumentals removeObjectAtIndex:sender.tag];
    [arr_rec_post_date removeObjectAtIndex:sender.tag];
    [arr_rec_play_count removeObjectAtIndex:sender.tag];
    [arr_rec_like_count removeObjectAtIndex:sender.tag];
    [arr_rec_comment_count removeObjectAtIndex:sender.tag];
    [arr_rec_share_count removeObjectAtIndex:sender.tag];
    [_tbl_view_recordings reloadData];
}

- (void)btn_menu_clicked:(UIButton*)sender
{
    //AudioFeedTableViewCell *cell = (ActivitiesTableViewCell*)[nib2 objectAtIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    MelodyPacksTableViewCell *cell = (MelodyPacksTableViewCell*)[_tbl_view_melodypacks cellForRowAtIndexPath:indexPath];
    
    if (status2==0) {
        cell.btn_hide.hidden=NO;
        status2=1;
    }
    else{
        cell.btn_hide.hidden=YES;
        status2=0;
    }
}



- (void)hide_cellmelody:(UIButton*)sender
{
    [arr_melody_pack_id removeObjectAtIndex:sender.tag];
    [arr_melody_pack_genre removeObjectAtIndex:sender.tag];
    [arr_melody_pack_name removeObjectAtIndex:sender.tag];
    [arr_melody_pack_profile removeObjectAtIndex:sender.tag];
    [arr_melody_pack_cover removeObjectAtIndex:sender.tag];
    [arr_melody_pack_station removeObjectAtIndex:sender.tag];
    [arr_melody_pack_intrumentals removeObjectAtIndex:sender.tag];
    [arr_melody_pack_instrumentals_count removeObjectAtIndex:sender.tag];
    [arr_melody_pack_post_date removeObjectAtIndex:sender.tag];
    [_tbl_view_melodypacks reloadData];
}




-(void)btn_Recordings_like_clicked1:(UIButton*)sender
{
    @try{
    
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
    NSString* urlString = [NSString stringWithFormat:@"%@likes.php",BaseUrl_Dev];
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
                    NSLog(@"%@",dic_response);
                    [arr_rec_like_count replaceObjectAtIndex:sender.tag withObject:[dic_response objectForKey:@"likes" ]];
                    [arr_rec_like_status replaceObjectAtIndex:sender.tag withObject:like_val];
                    [_tbl_view_recordings reloadData];
                    
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
    @catch (NSException *exception) {
        NSLog(@"exception %@",exception);
    }
    @finally{
        
    }
        
}


- (void)btn_MelodyPacks_like_clicked:(UIButton*)sender
{
 
     if ([defaults_userdata boolForKey:@"isUserLogged"]) {
    NSString* like_val=[[NSString alloc]init];
    if ([[arr_melody_like_status objectAtIndex:sender.tag] isEqual:@"1"]) {
        like_val=@"0";
    }
    else{
        like_val=@"1";
    }
    
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:[arr_melody_pack_id objectAtIndex:sender.tag] forKey:@"file_id"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"user_id"];
    [params setObject:like_val forKey:@"likes"];
         //7
         if ([genre1 isEqualToString:@"My Melodies"])
         {
             [params setObject:@"user_melody" forKey:@"type"];
         }
         else
         {
             [params setObject:@"admin_melody" forKey:@"type"];
         }    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    [params setObject:[arr_melody_pack_name objectAtIndex:sender.tag] forKey:@"topic"];
    
    
    NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@likes.php",BaseUrl_Dev];
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
                    NSLog(@"%@",dic_response);
                    [arr_melody_pack_no_of_like replaceObjectAtIndex:sender.tag withObject:[dic_response objectForKey:@"likes" ]];
                    
                    [[[arr_response objectAtIndex:sender.tag] mutableCopy] removeObjectForKey:@"like_status"];
                    NSMutableDictionary*dic=[[arr_response objectAtIndex:sender.tag] mutableCopy];
                    [dic setObject:like_val forKey:@"like_status"];
                    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:arr_response];
                    [mutableArray replaceObjectAtIndex:sender.tag withObject:dic];
                    arr_response = mutableArray;
                    [arr_melody_like_status replaceObjectAtIndex:sender.tag withObject:like_val];
                    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tbl_view_melodypacks];
                    
                    NSIndexPath *indexPath = [_tbl_view_melodypacks indexPathForRowAtPoint:buttonPosition];
                    if(indexPath != nil)
                    {
                        [_tbl_view_melodypacks beginUpdates];
                        [_tbl_view_melodypacks reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [_tbl_view_melodypacks endUpdates];
                        //                        [self getActivity:[[NSUserDefaults standardUserDefaults]
                        //                                           objectForKey:@"user_id"]];
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


-(void)melodyLike_API:(long)sender{
    

}

- (IBAction)btn_filter:(id)sender {
    
    if (audioPlayer.isPlaying) {
        [audioPlayer stop];
    }
    
    _view_filter_shadow.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    recording_typeInt = 1;
    self.tbl_view_filter_data_list.hidden = NO;
    self.view_filter_shadow.hidden= NO;
}
- (IBAction)btn_filter_shadow_cancel:(id)sender {
    _view_filter_shadow.frame=CGRectMake(-800, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (IBAction)btn_search:(id)sender {
    _view_search.hidden=NO;
    _view_main_menu.hidden=YES;
    recording_typeInt = 2;
    _tf_srearch.text=@"";

}
- (IBAction)btn_search_cancel:(id)sender {
     [_tf_srearch resignFirstResponder];
    _view_search.hidden=YES;
    _view_main_menu.hidden=NO;
    
    searchString = self.tf_srearch.text;
    if (isMelody) {
        [self loadMelodyPacks];
    }
    else{
        arr_rec_response=[[NSMutableArray alloc]init];
        [self loadRecordings];
    }
}

-(void)btn_add_clicked:(UIButton*)sender
{
    if (![defaults_userdata boolForKey:@"isUserLogged"]) {
        if (arr_melody_pack_intrumentals.count<=1 ) {
            _sender_tag=[NSString stringWithFormat:@"%ld",(long)sender.tag];
            [self performSegueWithIdentifier:@"melody_to_studio_rec" sender:sender];
        }
        else{
        Appdelegate.screen_After_Login = Studio;
        ViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        myVC.open_login=@"0";
        myVC.other_vc_flag=@"1";
        [self presentViewController:myVC animated:YES completion:nil];
        }
    }
    else{
        _sender_tag=[NSString stringWithFormat:@"%ld",(long)sender.tag];
        [self performSegueWithIdentifier:@"melody_to_studio_rec" sender:sender];
    }

}





#pragma mark- Social Sharing
#pragma mark-
- (void)btn_Melodypackcomment_clicked:(UIButton*)sender
{
    if ([defaults_userdata boolForKey:@"isUserLogged"]) {
    _sender_tag=[NSString stringWithFormat:@"%ld",(long)sender.tag];
    id lc=[arr_melody_pack_no_of_like objectAtIndex:[_sender_tag integerValue]];
    id ls=[arr_melody_like_status objectAtIndex:[_sender_tag integerValue]];
        id dur=[maxDuration objectAtIndex:[_sender_tag integerValue]];
    NSMutableDictionary*dic=[NSMutableDictionary dictionaryWithDictionary:[arr_response objectAtIndex:[_sender_tag integerValue]]];
    [dic  setObject:lc forKey:@"likescounts"];
    [dic setObject:ls forKey:@"like_status"];
    [dic setObject:dur forKey:@"duration"];
    NSMutableArray*arr=[NSMutableArray arrayWithArray:arr_response];
    [arr replaceObjectAtIndex:[_sender_tag integerValue] withObject:dic];
    arr_response=arr;
    [self performSegueWithIdentifier:@"go_to_melodypack_comments" sender:self];
    }
    else
    {
        ViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        myVC.open_login=@"0";
        myVC.other_vc_flag=@"1";
        [self presentViewController:myVC animated:YES completion:nil];
    }
}

- (void)btn_Recordings_comment_clicked:(UIButton*)sender
{
    isMelody = NO;
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


-(void)openshare:(UIButton*)sender
{
//    if(!isMelody){
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
                                        if (isMelody) {
                                            myVC.str_file_id = [NSString stringWithFormat:@"%@", [arr_melody_pack_id objectAtIndex:sender.tag]];
//                                            myVC.str_screen_type = @"admin_melody";
                                            if ([genre1 isEqualToString:@"My Melodies"])
                                            {
                                                myVC.str_screen_type = @"user_melody";
                                            }
                                            else
                                            {
                                                myVC.str_screen_type = @"admin_melody";
                                            }
                                            

                                        }
                                        else{
                                            myVC.str_file_id = [arr_rec_pack_id objectAtIndex:sender.tag];
                                            myVC.str_screen_type = @"station";

                                        }
//                                        currentIndexValue=sender.tag;
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
                                       NSString *link;
                                       NSString *noteStr;
                                       if (isMelody) {

                                       link = [NSString stringWithFormat:@"%@",[[arr_response objectAtIndex:sender.tag] objectForKey:@"thumbnail_url"]];
                                    noteStr = [NSString stringWithFormat:@"Listen to %@\nOn YoMelody.com\n",[[arr_response objectAtIndex:sender.tag] objectForKey:@"name"]];
                                       }
                                       else{
                                           link = [NSString stringWithFormat:@"%@",[[arr_rec_response objectAtIndex:sender.tag] objectForKey:@"thumbnail_url"]];
                                           noteStr = [NSString stringWithFormat:@"Listen to %@\nOn YoMelody.com\n",[[arr_rec_response objectAtIndex:sender.tag] objectForKey:@"recording_topic"]];

                                       }
                                      // NSString *noteStr = [NSString stringWithFormat:@""];
                                      
                                       NSURL *url = [NSURL URLWithString:link];
                                       UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[noteStr, url] applicationActivities:nil];
                                       [self presentViewController:activityVC animated:YES completion:nil];
                                   }];

        [alert addAction:noButton];
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        ViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        myVC.open_login=@"0";
        myVC.other_vc_flag=@"1";
        [self presentViewController:myVC animated:YES completion:nil];
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"melody_to_studio_rec"]) {
        ///<statements#>
        StudioRecViewController*vc=segue.destinationViewController;
        /// station
        vc.stationDict = _stationDict;
        if ([genre1 isEqualToString:@"My Melodies"]) {
            
            NSString *originalCoverImage =[[arr_response objectAtIndex:[_sender_tag integerValue]]objectForKey:@"cover"];
            
            originalCoverImage = [originalCoverImage stringByReplacingOccurrencesOfString:@"Mobile" withString:@"original"];
//            NSLog(@"DATA %@",[[[[arr_response objectAtIndex:[_sender_tag integerValue]] objectForKey:@"Audioshared"]
//                               objectAtIndex:0] objectForKey:@"instruments"]);
            NSMutableArray *arr_InstrumentM = [[NSMutableArray alloc]init];
            NSMutableDictionary *dic_InstrumentM = [[NSMutableDictionary alloc]init];
            
//            [dic_InstrumentM setValue:[self bpm_count:[_sender_tag integerValue]] forKey:@"bpm"];//1
            [dic_InstrumentM setValue:[[arr_response objectAtIndex:[_sender_tag integerValue]]  objectForKey:@"bpm"] forKey:@"bpm"];//1
            [dic_InstrumentM setValue:originalCoverImage forKey:@"coverpic"];//2
            [dic_InstrumentM setValue:[[arr_response objectAtIndex:[_sender_tag integerValue]]  objectForKey:@"duration"] forKey:@"duration"];//3
            
            
            [dic_InstrumentM setValue:[[arr_response objectAtIndex:[_sender_tag integerValue]]  objectForKey:@"melodyurl"] forKey:@"instrument_url"];//4
                                         
            [dic_InstrumentM setValue:[[arr_response objectAtIndex:[_sender_tag integerValue]]  objectForKey:@"name"] forKey:@"instruments_name"];//5
                                       
            [dic_InstrumentM setValue:@"user_melody" forKey:@"instruments_type"];//6
            [dic_InstrumentM setValue:[[arr_response objectAtIndex:[_sender_tag integerValue]]  objectForKey:@"melodypackid"] forKey:@"melodypackid"];//7
            
            [dic_InstrumentM setValue:[[arr_response objectAtIndex:[_sender_tag integerValue]]
            objectForKey:@"profilepic"] forKey:@"profilepic"];//8
                                         
            [dic_InstrumentM setValue:[[arr_response objectAtIndex:[_sender_tag integerValue]]  objectForKey:@"date"] forKey:@"uploadeddate"];//9
            
            [dic_InstrumentM setValue:[[arr_response objectAtIndex:[_sender_tag integerValue]]  objectForKey:@"added_by_admin"] forKey:@"id"];//10
//melodypackid
            
            NSString *str_userName = [NSString stringWithFormat:@"%@",[[arr_response objectAtIndex:[_sender_tag integerValue]]
            objectForKey:@"username"]];
                                                                          
            [dic_InstrumentM setValue:str_userName forKey:@"username"];//10
            //    arr_InstrumentM = [[[[arr_messageList objectAtIndex:sender.tag]
            //                                 objectForKey:@"Audioshared"] objectAtIndex:0]
            //                               objectForKey:@"recordings"];
            
            [arr_InstrumentM addObject:dic_InstrumentM];
            vc.arr_melodypack_instrumental = arr_InstrumentM;
            vc.str_name=[arr_melody_pack_name objectAtIndex:[_sender_tag integerValue]];
            vc.str_date=[arr_melody_pack_post_date objectAtIndex:[_sender_tag integerValue]];
            vc.isJoinScreen = _isJoinScreen;
            vc.str_parentID = _str_parentID;
            vc.str_instrumentTYPE = @"id";
            vc.isCoverImage = _isCoverImage;
            vc.chatDict=_chatDict;
            vc.fromScreen=_fromScreen;
            
            if (_isCoverImage) {
                vc.imagedata_forCover = _imagedata_forCover;
                vc.imagename_forCover = _imagename_forCover;
            }
        }
        else if ([_arr_instruments_added count]<= 0 && _arr_instruments_added != nil) {
            vc.str_name=[arr_melody_pack_name objectAtIndex:[_sender_tag integerValue]];
            vc.str_date=[arr_melody_pack_post_date objectAtIndex:[_sender_tag integerValue]];
            vc.arr_melodypack_instrumental=[arr_melody_pack_intrumentals objectAtIndex:[_sender_tag integerValue]];
            vc.isJoinScreen = _isJoinScreen;
            vc.str_parentID = _str_parentID;
            vc.str_instrumentTYPE = @"id";
            vc.chatDict=_chatDict;
            vc.fromScreen=_fromScreen;
            vc.isCoverImage = _isCoverImage;

            if (_isCoverImage) {
                vc.imagedata_forCover = _imagedata_forCover;
                vc.imagename_forCover = _imagename_forCover;
            }
        }
        else{
            //vc.str_no_of_instrumentals=[arr_melody_pack_instrumentals_count objectAtIndex:[_sender_tag integerValue]];
            NSLog(@"%@",[arr_melody_pack_intrumentals objectAtIndex:[_sender_tag integerValue]]);
            //  [_arr_instruments_added addObject:[[arr_melody_pack_intrumentals objectAtIndex:[_sender_tag integerValue]] objectAtIndex:0]];
            //            NSMutableArray*new_array=[_arr_instruments_added mutableCopy];
            NSMutableArray*new_array=[[NSMutableArray alloc]init];
            int k=0;
            for (k=0; k<[ [arr_melody_pack_intrumentals objectAtIndex:[_sender_tag integerValue]] count];k++) {
                if ([new_array containsObject:[ [arr_melody_pack_intrumentals objectAtIndex:[_sender_tag integerValue]] objectAtIndex:k]]) {
                    
                }else{
                    
                    [new_array addObject:[ [arr_melody_pack_intrumentals objectAtIndex:[_sender_tag integerValue]] objectAtIndex:k]];
                }
            }
            //_arr_instruments_added=[[arr_melody_pack_intrumentals objectAtIndex:[_sender_tag integerValue]] mutableCopy];
            NSLog(@"array count %lu",(unsigned long)new_array.count);
            vc.str_name=[arr_melody_pack_name objectAtIndex:[_sender_tag integerValue]];
            vc.str_date=[arr_melody_pack_post_date objectAtIndex:[_sender_tag integerValue]];
            vc.arr_melodypack_instrumental=new_array;
            vc.isJoinScreen = _isJoinScreen;
            vc.str_parentID = _str_parentID;
            vc.str_instrumentTYPE = @"id";
            vc.isCoverImage = _isCoverImage;
            
            if (_isCoverImage) {
                vc.imagedata_forCover = _imagedata_forCover;
                vc.imagename_forCover = _imagename_forCover;
            }
        }
    }
    
  else  if ([segue.identifier isEqualToString:@"go_to_melodypack_comments"])
    {
        MelodyPackCommentsViewController*vc=segue.destinationViewController;
        vc.dic_data=[arr_response objectAtIndex:[_sender_tag integerValue]];
        if ([genre1 isEqualToString:@"My Melodies"])//7
        {
            vc.isFromMelody=@"USER";
        }
        else
        {
            vc.isFromMelody=@"ADMIN";
        }
    }
   else if ([segue.identifier isEqualToString:@"go_to_recording_comments"])
    {
        AudioFeedCommentsViewController*vc=segue.destinationViewController;
        vc.dic_data=[arr_rec_response objectAtIndex:[_sender_tag integerValue]];
    }
    
   else if ([segue.identifier isEqualToString:@"melody_to_studio_play"])
    {
        StudioPlayViewController*vc=segue.destinationViewController;
        vc.str_CurrernUserId = [followerID objectAtIndex:index];
        vc.str_RecordingId = [arr_rec_pack_id objectAtIndex:index];
//        vc.arr_recordings=[arr_rec_recordings objectAtIndex:index];
    }
}


//-(NSString*)bpm_count:(NSInteger)index {
//    NSString *str_BPM;
//    NSInteger sum = 0;
//    int i;
//    for (i = 0; i< arr_response.count; i++) {
//        sum = sum + [[[arr_response objectAtIndex:i]  objectForKey:@"bpm"]integerValue];
//    }
//    sum = sum / i;
//    str_BPM = [NSString stringWithFormat:@"%li",(long)sum];
//
//    return str_BPM;
//}

-(void)btn_share_clicked:(UIButton*)sender
{
    
    UIImage *image = [UIImage imageNamed:@"artist.png"];
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.image = image;
    NSString *textToShare = @"Click on the instrumental url :";
    NSString * url = @"<!DOCTYPE html><html><body><a href=\"http://52.41.33.64/api/uploads/pics/149937134014919391682cents.wav\" target='_blank'><div style='width: 50; height:auto; border: 1px solid; border-color: #e9ebee #e9ebee #d1d1d1;  box-shadow:1px 4px 10px 3px #DADADA; background-color:#FFFFFF'><div style='overflow: hidden;padding: 2px;'><img src=\"http://52.41.33.64/api/uploads/profilepics/1499370751Desert.jpg\" alt='banner' style='width: 100;height: auto;float: left;'></div><div style='height:auto;padding: 10px 10px;border-top: 1px solid #DADADA; clear: both;'><h3 style='float: left;font-size: 30px;margin: 5px 0px; font-weight: 500;'>Despacito</h3><div style='width: 80;font-family:Segoe UI Historic, Segoe UI, Helvetica, Arial, sans-serif;padding-right-10px;clear: both;'><p style='font-size: 14px;'>Listen to Despacito Song from Despacito (Remix)</p><p style='margin: 0px;'><a href='http://52.41.33.64/api/uploads/pics/149937134014919391682cents.wav' style='text-align: left;text-decoration: none;cursor: pointer;color: rgb(209, 209, 209);font-size: 14px;font-weight: 500; text-transform: uppercase;'>Instamelody.COM</a></p></div></div></div></a></body></html>";
    
    NSString * audio_Url = @"http://52.41.33.64/api/uploads/pics/149937134014919391682cents.wav";
    NSString * str_Url = [NSString stringWithFormat:@"<html><body><a href=\"%@\" target='_blank'><div style='width: 50%; height:auto; border: 1px solid; border-color: #e9ebee #e9ebee #d1d1d1;  box-shadow:1px 4px 10px 3px #DADADA; background-color:#FFFFFF'><div style='overflow: hidden;padding: 2px;'><img src=\"http://52.41.33.64/api/uploads/profilepics/1499370751Desert.jpg\" alt='banner' style='width: 100%;height: auto;float: left;'></div><div style='height:auto;padding: 10px 10px;border-top: 1px solid #DADADA; clear: both;'><h3 style='float: left;font-size: 30px;margin: 5px 0px; font-weight: 500;'>Despacito</h3><div style='width: 80%;font-family:Segoe UI Historic, Segoe UI, Helvetica, Arial, sans-serif;padding-right-10px;clear: both;'><p style='font-size: 14px;'>Listen to Despacito Song from Despacito (Remix)</p><p style='margin: 0px;'><a href='http://52.41.33.64/api/uploads/pics/149937134014919391682cents.wav' style='text-align: left;text-decoration: none;cursor: pointer;color: rgb(209, 209, 209);font-size: 14px;font-weight: 500; text-transform: uppercase;'>Instamelody.COM</a></p></div></div></div></a></body></html>",audio_Url];
    
    NSLog(@"str_Url =%@",str_Url);
    
    
    //    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    //    content.contentURL = [NSURL URLWithString:@"http://developers.facebook.com"];
    //    [FBSDKShareDialog showFromViewController:self
    //                                 withContent:content
    //                                    delegate:nil];
    
    //        NSURL *myWebsite = [NSURL URLWithString:strUrl];
    
    NSArray *objectsToShare = @[textToShare,url];
    
    UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    //activityViewControntroller.excludedActivityTypes = @[];
    activityViewControntroller.completionHandler = ^(NSString *activityType, BOOL completed)
    {
        NSLog(@"ActivityType: %@", activityType);
        NSLog(@"Completed: %i", completed);
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        activityViewControntroller.popoverPresentationController.sourceView = self.view;
        activityViewControntroller.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4, 0, 0);
    }
    [self presentViewController:activityViewControntroller animated:true completion:nil];
    
}



-(void)profileClicked:(UIButton*)sender{
    NSLog(@"profileClicked");
    ProfileViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    
    profileVC.follower_id = [followerID objectAtIndex:sender.tag];
    NSString * userId = [defaults_userdata objectForKey:@"user_id"];
    profileVC.user_id = userId;
    
    [profileVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:profileVC animated:YES completion:nil];
    
}


#pragma mark- TableView Delegate & Datasource
#pragma mark-

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if (tableView.tag==1 ) {
        
        return 1;
        
    }
    else if (tableView.tag==2)
    {
        return 1;
    }
    else if (tableView.tag==3)
    {
        return 1;
    }
    else if (tableView.tag==4)
    {
        return 1;
    }
    else{
        return 0;
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==1) {
        
        return [arr_rec_pack_id count];
    }
    else if (tableView.tag==2)
    {
        return [arr_melody_pack_id count];
    }
    else if (tableView.tag==3)
    {
        return [arr_plan_type count]+1;
    }
    
    else if (tableView.tag==4)
    {
        return [arr_filter_data_list count];
    }
    else{
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
        return 190;
    }
    else if (tableView.tag==3)//Supcription cell
    {
        if (indexPath.row == 0) {
        return 166;
        }
        else{
        return 60;
        }
    }
    else if (tableView.tag==4)
    {
            return 44;

    }
    else{
        return 0;
    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @try{
    //    [activityIndicatorView stopAnimating];
    
        if (tableView.tag==1) {
            tableViewTag = 1;
            AudioFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AudioFeed"];
            if (cell == nil)
            {
                NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"AudioFeedTableViewCell"
                                                              owner:self options:nil];
                cell.accessoryType = UITableViewCellStyleDefault;
                cell = (AudioFeedTableViewCell*)[nib2 objectAtIndex:0];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.roundBackgroundView.layer.cornerRadius=8.0f;
            [cell.slider_progress setThumbImage:[UIImage imageNamed:@"thumb_transparent.png"] forState:UIControlStateNormal];
            cell.imgview_profileImageView.layer.cornerRadius = cell.imgview_profileImageView.frame.size.width / 2;
            cell.imgview_profileImageView.clipsToBounds = YES;
            cell.layer.shadowColor = [[UIColor grayColor] CGColor];
            cell.layer.shadowOpacity = 0.4;
            cell.layer.shadowRadius = 0;
            cell.layer.shadowOffset = CGSizeMake(1.0, 1.0);
            cell.btn_hide.hidden=YES;
            cell.btn_comment.tag=indexPath.row;
            [cell.btn_comment addTarget:self action:@selector(btn_Recordings_comment_clicked:) forControlEvents:UIControlEventTouchUpInside];
            cell.btn_like.tag=indexPath.row;
            [cell.btn_like addTarget:self action:@selector(btn_Recordings_like_clicked1:) forControlEvents:UIControlEventTouchUpInside];
            cell.btn_hide.tag=indexPath.row;
            
            
            //---------------- * Next Button * --------------------
            cell.btn_next_audio.tag = indexPath.row;
            [cell.btn_next_audio addTarget:self action:@selector(btn_nextAction:) forControlEvents:UIControlEventTouchUpInside];
            //---------------- * Previous Button * --------------------
            cell.btn_previous_audio.tag = indexPath.row;
            [cell.btn_previous_audio addTarget:self action:@selector(btn_previousAction:) forControlEvents:UIControlEventTouchUpInside];
            
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
            //------------------ * This code for Cell Hiding *-----------------------
           // [cell.btn_hide addTarget:self action:@selector(hide_cellrecording:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btn_other_options.tag=indexPath.row;
            [cell.btn_other_options addTarget:self action:@selector(show_options:) forControlEvents:UIControlEventTouchUpInside];
            cell.btn_share.tag=indexPath.row;
            [cell.btn_share addTarget:self action:@selector(openshare:) forControlEvents:UIControlEventTouchUpInside];
            cell.btn_join.tag=indexPath.row;
            [cell.btn_join addTarget:self action:@selector(join_clicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btn_PlayRecording setTag:indexPath.row];
            [cell.btn_PlayRecording addTarget:self action:@selector(btn_Recordings_Play_clicked:) forControlEvents:UIControlEventTouchUpInside];
            cell.lbl_profile_name.text=[arr_rec_name objectAtIndex:indexPath.row];
            cell.lbl_profile_twitter_id.text=[NSString stringWithFormat:@"@%@",[arr_rec_station objectAtIndex:indexPath.row]];
            if (arr_rec_duration.count > 0 ) {
                cell.lbl_timer.text=[Appdelegate timeFormatted:[arr_rec_duration objectAtIndex:indexPath.row]];
            }
            else{
                cell.lbl_timer.text = @"";
            }
            
            index = indexPath.row;
            cell.switch_PublicOrPrivate.hidden=NO;
            
            //------------ New Code for Make Public/Private -------------
            cell.switch_PublicOrPrivate.hidden=NO;

            NSLog(@"indexPath.row ====  %ld",(long)indexPath.row);
            cell.switch_PublicOrPrivate.tag = indexPath.row;
            
            NSLog(@"---- Before %@",arr_PublicState);
        
            if ([[arr_PublicState objectAtIndex:indexPath.row] isEqual:@"1"]) {
                [cell.switch_PublicOrPrivate setOn:YES];
            }
            else
            {
                [cell.switch_PublicOrPrivate setOn:NO];
            }
            [cell.switch_PublicOrPrivate addTarget:self action:@selector(switchPublicToggled:)
                                  forControlEvents:UIControlEventTouchUpInside];
            
            NSString *tempDate = [arr_rec_post_date objectAtIndex:indexPath.row];
            if (tempDate == nil || tempDate.length >0) {
                cell.lbl_date_top.text=[Appdelegate formatDateWithString:tempDate];
                cell.lbl_date_aidios.text=[Appdelegate formatDateWithString:tempDate];
                
            }
            
            NSInteger anIndex=[arr_genre_id indexOfObject:[arr_rec_genre objectAtIndex:indexPath.row]];
            if(NSNotFound == anIndex) {
                NSLog(@"not found");
                anIndex=0;
            }
            cell.lbl_geners.textAlignment=NSTextAlignmentRight;
            //            cell.lbl_geners.text=[arr_menu_items objectAtIndex:anIndex];
            cell.lbl_geners.text=[NSString stringWithFormat:@"Genre : %@",[genreArray objectAtIndex:indexPath.row]];
            
            cell.imgview_profileImageView.contentMode = UIViewContentModeScaleToFill;
            cell.img_view_back_cover.contentMode = UIViewContentModeScaleAspectFill;
            [cell.btn_like_value setTitle:[NSString stringWithFormat:@"%@",[arr_rec_like_count objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
            [cell.btn_comment_value setTitle:[NSString stringWithFormat:@"%@",[arr_rec_comment_count objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
            if ([[arr_rec_like_status objectAtIndex:indexPath.row] isEqual:@"1"]) {
                [cell.btn_like setBackgroundImage:[UIImage imageNamed:@"btn_hand_fill.png"] forState:UIControlStateNormal];
            }
            else{
                [cell.btn_like setBackgroundImage:[UIImage imageNamed:@"btn_hand_outline.png"] forState:UIControlStateNormal];
            }
            
            // NSURL *url = [NSURL URLWithString:[arr_rec_cover objectAtIndex:indexPath.row]];
            //---------------------*** Cover pic ***------------------------
            NSString *strUrlForCover = [arr_rec_cover objectAtIndex:indexPath.row];
            strUrlForCover = [strUrlForCover stringByReplacingOccurrencesOfString:@"Mobile" withString:@"original"];

            NSURL *url = [NSURL URLWithString: strUrlForCover];
            cell.img_view_back_cover.contentMode = UIViewContentModeScaleToFill;
            [cell.img_view_back_cover sd_setImageWithURL:url
                                        placeholderImage:[UIImage imageNamed:@"bg_cell.png"]];
            
            //---------------------*** Profile pic ***------------------------
            //NSURL *url2 = [NSURL URLWithString:[arr_rec_profile objectAtIndex:indexPath.row]];
            NSString *imageProfileUrlString = [arr_rec_profile objectAtIndex:indexPath.row];
            NSString *encodedProfileImageUrlString = [imageProfileUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url2 = [NSURL URLWithString: encodedProfileImageUrlString];
            cell.btn_Profile.contentMode = UIViewContentModeScaleToFill;
            cell.btn_Profile.layer.cornerRadius = cell.btn_Profile.frame.size.width / 2;
            
            cell.btn_Profile.clipsToBounds = YES;
            
            // [cell.imgview_profileImageView sd_setImageWithURL:url2
            //placeholderImage:[UIImage //imageNamed:@"placeholder.png"]];
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
            [cell.btn_Profile addTarget:self action:@selector(profileClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btn_Profile setTag:indexPath.row];
            
            
            return cell;
        }
    else if (tableView.tag==2)
    {
        tableViewTag = 2;
        MelodyPacksTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Melody"];
        
        if (cell == nil)
        {
            NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"MelodyPacksTableViewCell"
                                                          owner:self options:nil];
            cell.accessoryType = UITableViewCellStyleDefault;
            cell = (MelodyPacksTableViewCell*)[nib2 objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

        }
        
            cell.btn_hide.hidden=YES;
            cell.btn_playpause.tag=indexPath.row;
            [cell.btn_playpause addTarget:self action:@selector(btn_playpause_clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.lbl_no_of_play setTitle:[NSString stringWithFormat:@"%@",[arr_melody_pack_no_of_play objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
            
            cell.btn_add.tag=indexPath.row;
            [cell.btn_add addTarget:self action:@selector(btn_add_clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btn_play.tag=indexPath.row;
            //*******PREVIOUS CONDITION************//
           /* if ([[defaults_userdata stringForKey:@"rememberme"] isEqual:@"remember"]) {
                
                cell.btn_like.userInteractionEnabled=YES;
                cell.btn_comment.userInteractionEnabled=YES;
                cell.btn_share.userInteractionEnabled=YES;
            }
            else{
                cell.btn_like.userInteractionEnabled=NO;
                cell.btn_comment.userInteractionEnabled=NO;
                cell.btn_share.userInteractionEnabled=NO;
                
            }*/
            cell.btn_like.tag=indexPath.row;
            [cell.btn_like addTarget:self action:@selector(btn_MelodyPacks_like_clicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.lbl_no_of_like setTitle:[NSString stringWithFormat:@"%@",[arr_melody_pack_no_of_like objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
            
            cell.btn_hide.tag=indexPath.row;
            [cell.btn_hide addTarget:self action:@selector(hide_cellmelody:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btn_menu.tag=indexPath.row;
            [cell.btn_menu addTarget:self action:@selector(btn_menu_clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btn_comment.tag=indexPath.row;
            [cell.btn_comment addTarget:self action:@selector(btn_Melodypackcomment_clicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.lbl_no_of_comments setTitle:[arr_melody_pack_no_of_coments objectAtIndex:indexPath.row] forState:UIControlStateNormal];
            
            cell.btn_share.tag=indexPath.row;
            [cell.btn_share addTarget:self action:@selector(openshare:) forControlEvents:UIControlEventTouchUpInside];//btn_share_clicked
            [cell.btn_no_of_share setTitle:[arr_melody_pack_no_of_share objectAtIndex:indexPath.row] forState:UIControlStateNormal];
            
            cell.img_view_profile.layer.cornerRadius = cell.img_view_profile.frame.size.width / 2;
            cell.img_view_profile.clipsToBounds = YES;
            [cell.slider_progress setMinimumTrackImage:[UIImage imageNamed:@"blue_bar.png"] forState:UIControlStateNormal];
            [cell.slider_progress setMaximumTrackImage:[UIImage imageNamed:@"black_bar.png"] forState:UIControlStateNormal];
            [cell.slider_progress setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateNormal];
            [cell.slider_progress setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateFocused];
            
            cell.img_melodypack_cover.contentMode = UIViewContentModeScaleToFill;
            cell.img_view_profile.contentMode = UIViewContentModeScaleAspectFill;
            //------------- Cover pic -----------------
            
            NSString *imageCoverUrlString = [arr_melody_pack_cover objectAtIndex:indexPath.row];
            NSString *encodedCoverImageUrlString = [imageCoverUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *image_Cover_URL = [NSURL URLWithString: encodedCoverImageUrlString];
        
//            NSURL *url = [NSURL URLWithString:[arr_melody_pack_cover objectAtIndex:indexPath.row]];
            cell.img_melodypack_cover.contentMode = UIViewContentModeScaleToFill;
            
            [cell.img_melodypack_cover sd_setImageWithURL:image_Cover_URL
                                         placeholderImage:[UIImage imageNamed:@"bg_cell.png"]];
        
            //------------- Profile pic -----------------
            NSString *imageProfileUrlString = [arr_melody_pack_profile objectAtIndex:indexPath.row];
            NSString *encodedProfileImageUrlString = [imageProfileUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSURL *url2 = [NSURL URLWithString: encodedProfileImageUrlString];
            
            cell.img_view_profile.contentMode = UIViewContentModeScaleToFill;
            
            [cell.img_view_profile sd_setImageWithURL:url2
                                     placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            cell.lbl_timer.textAlignment=NSTextAlignmentRight;
            cell.lbl_timer.text=[NSString stringWithFormat:@"%@",[Appdelegate timeFormatted:[arr_melody_pack_timerM objectAtIndex:indexPath.row]]];//arr_melody_pack_timerM //maxDuration
            
            if ([[arr_melody_like_status objectAtIndex:indexPath.row] isEqual:@"1"]) {
                [cell.btn_like setBackgroundImage:[UIImage imageNamed:@"btn_hand_fill.png"] forState:UIControlStateNormal];
            }
            else{
                [cell.btn_like setBackgroundImage:[UIImage imageNamed:@"btn_hand_outline.png"] forState:UIControlStateNormal];
            }
            
            cell.lbl_profile_title.text=[arr_melody_pack_name objectAtIndex:indexPath.row];
            NSLog(@"********* Melody =%@ ",[arr_melody_pack_name objectAtIndex:indexPath.row]);
            cell.lbl_profile_id.text=[arr_melody_pack_station objectAtIndex:indexPath.row];
            
            cell.lbl_genre.text=[NSString stringWithFormat:@"Genre : %@",[arr_melody_pack_genre objectAtIndex:indexPath.row]];
            
            NSString *tempDate = [arr_melody_pack_post_date objectAtIndex:indexPath.row];
            cell.lbl_date.textAlignment=NSTextAlignmentRight;
            if (tempDate == nil || tempDate.length >0) {
                cell.lbl_date.text=[Appdelegate formatDateWithString:tempDate];
            }
            cell.lbl_bpm.text=[NSString stringWithFormat:@"BPM : %@",[arr_melody_pack_bpm objectAtIndex:indexPath.row]];
            if ([[arr_melody_pack_instrumentals_count objectAtIndex:indexPath.row] isEqual:@"1"]) {
                cell.lbl_no_of_instrumentals.text=[NSString stringWithFormat:@"%@ Instrumental",[arr_melody_pack_instrumentals_count objectAtIndex:indexPath.row]];
            }
            else
            {
                cell.lbl_no_of_instrumentals.text=[NSString stringWithFormat:@"%@ Instrumentals",[arr_melody_pack_instrumentals_count objectAtIndex:indexPath.row]];
            }
        
        return cell;
    }
    else if (tableView.tag==3)
    {
        tableViewTag = 3;
        static NSString *Home_CellIdentifier = @"Home_cell";
        
        
        MelodyHomeTableViewCell *cell_home = [tableView dequeueReusableCellWithIdentifier:Home_CellIdentifier];
        if (indexPath.row == 0) {
            if (cell_home == nil) {
                cell_home = [[MelodyHomeTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Home_CellIdentifier];
            }
            [cell_home setBackgroundColor:[UIColor yellowColor]];
            defaults_userdata=[NSUserDefaults standardUserDefaults];
            cell_home.img_userProfile.layer.cornerRadius =cell_home.img_userProfile.frame.size.width / 2;
            cell_home.img_userProfile.clipsToBounds=YES;
            if ([[defaults_userdata stringForKey:@"rememberme"] isEqual:@"remember"]) {
                [cell_home.img_userProfile setImage:[UIImage imageWithData:[defaults_userdata objectForKey:@"profile_pic"]]];
                cell_home.lbl_userName.text=[NSString stringWithFormat:@"%@ %@",[defaults_userdata objectForKey:@"first_name"],[defaults_userdata objectForKey:@"last_name"]];
            }
            else
            {
                [_img_view_user_profile setImage:[UIImage imageNamed:@"artist-with-headphone.png"]];
            }
            return cell_home;
            
        }
        else{
        SubscriptionPlanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Subscription"];
        
        
        if (cell == nil)
            
        {
            NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"SubscriptionPlanTableViewCell"
                             
                                                          owner:self options:nil];
            cell.accessoryType = UITableViewCellStyleDefault;
            
            cell = (SubscriptionPlanTableViewCell*)[nib2 objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            if (_products.count > 0) {
//            NSLog(@"Products %@",_products);
//            SKProduct *product = [_products objectAtIndex:indexPath.row-1];
//            NSLog(@"localizedDescription %@",product.localizedDescription);
//            NSLog(@"price %@",product.price);
//            NSLog(@"localizedTitle %@",product.localizedTitle);
//            NSLog(@"productIdentifier %@",product.productIdentifier);
            }
            cell.switch_pan.tag=indexPath.row;
            // [cell.switch_pan addTarget:self action:@selector(switch_purchase_on_of:) forControlEvents:UIControlEventValueChanged];
            
            [cell.switch_pan addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventTouchUpInside];//switchToggled_UIControlEventTouchUpInside
            [cell.switch_pan addTarget:self action:@selector(switchToggled_UIControlEventTouchDown:) forControlEvents:UIControlEventTouchDown];
            [cell.switch_pan addTarget:self action:@selector(switchToggled_UIControlEventTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];

            
            // cell.img_view_profileimage.layer.cornerRadius = cell.img_view_profileimage.frame.size.width / 2;
            // cell.img_view_profileimage.clipsToBounds = YES;
            
            if ([[arr_plan_price objectAtIndex:indexPath.row -1] isEqual:@"0"]) {
                cell.view_free_plan.hidden=NO;
                cell.view_plan_price.hidden=YES;
            }
            if ([[arr_recording_time objectAtIndex:indexPath.row -1] isEqual:@"unlimited"]) {
                [cell.lbl_recording_time sizeToFit];
                cell.lbl_rec_time_text.text=@"Rec Time";
                cell.lbl_recording_time.frame=CGRectMake(8, 9, 70, 18);
                cell.lbl_rec_time_text.frame=CGRectMake(78, 9, 56, 18);
                
            }
            
            if ([[arr_layes objectAtIndex:indexPath.row -1] isEqual:@"unlimited"]) {
                cell.lbl_layer_text.text=@"Melody";
                cell.lbl_layers_count.frame=CGRectMake(8, 33, 70, 18);
                cell.lbl_layer_text.frame=CGRectMake(78, 33, 56, 18);
                // [cell.lbl_layers_count sizeToFit];
            }
            
            cell.lbl_plan_type.text=[arr_plan_type objectAtIndex:indexPath.row -1];
            NSString *recordTimeStr,*layerStr;
            NSString *recordValue,*layerValue;
            NSString *restRecordStr,*restLayerStr;
            if ([arr_recording_time count]>0)
            {
                recordTimeStr=[arr_recording_time objectAtIndex:indexPath.row-1];
                recordValue=[[recordTimeStr componentsSeparatedByString:@" "] objectAtIndex:0];
                restRecordStr=[recordTimeStr stringByReplacingOccurrencesOfString:recordValue withString:@""];
                
                NSDictionary *attribs = @{
                                          NSForegroundColorAttributeName:[UIColor blackColor],
                                          NSFontAttributeName:[UIFont systemFontOfSize:13]
                                          };
                NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:recordTimeStr attributes:attribs];
                
                NSRange boldRange = [recordTimeStr rangeOfString:recordValue];
                NSRange nonBoldRange = [recordTimeStr rangeOfString:restRecordStr];
                
                NSDictionary *boldAttrib = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:13]};
                NSDictionary *nonBoldAttrib = @{NSFontAttributeName:[UIFont systemFontOfSize:13]};
                
                [attributedText setAttributes:boldAttrib range:boldRange];
                [attributedText setAttributes:nonBoldAttrib range:nonBoldRange];
                
                [cell.lbl_recording_time setAttributedText:attributedText];
            }
            else
            {
                cell.lbl_recording_time.text=@"";
            }
            if ([arr_layes count]>0)
            {
                layerStr=[arr_layes objectAtIndex:indexPath.row-1];
                layerValue=[[layerStr componentsSeparatedByString:@" "] objectAtIndex:0];
                restLayerStr=[layerStr stringByReplacingOccurrencesOfString:layerValue withString:@""];
                
                NSDictionary *attribs = @{
                                          NSForegroundColorAttributeName:[UIColor blackColor],
                                          NSFontAttributeName:[UIFont systemFontOfSize:13]
                                          };
                NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:layerStr attributes:attribs];
                
                NSRange boldRange = [layerStr rangeOfString:layerValue];
                NSRange nonBoldRange = [layerStr rangeOfString:restLayerStr];
                
                NSDictionary *boldAttrib = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:13]};
                NSDictionary *nonBoldAttrib = @{NSFontAttributeName:[UIFont systemFontOfSize:13]};
                
                [attributedText setAttributes:boldAttrib range:boldRange];
                [attributedText setAttributes:nonBoldAttrib range:nonBoldRange];
                
                [cell.lbl_layers_count setAttributedText:attributedText];
            }
            else
            {
                cell.lbl_layers_count.text=@"";
            }
//            int indexValue = 0;
//            if ([arr_packageStatusDetails count]>0)
//            {
//                for (int i=0; i<[arr_packageStatusDetails count]; i++)
//                {
//                    indexValue=[[[arr_packageStatusDetails objectAtIndex:i] objectForKey:@"package_id"] intValue];
//                    if (indexPath.row == indexValue-1)
//                    {
//                        [cell.switch_pan setOn:YES animated:YES];
//                        break;
//                    }
//                    else
//                    {
//                        [cell.switch_pan setOn:NO animated:YES];
//                    }
//                }
//                NSLog(@"INDEX VALUE %ld",(long)indexValue);
//
//            }
            if(![defaults_userdata boolForKey:@"isUserLogged"])
            {
                if (indexPath.row==1)
                {
                    [cell.switch_pan setOn:YES];
                }
                else
                {
                        [cell.switch_pan setOn:NO];
                }
            }
            else
            {
                if([packageStatus longLongValue] == 201)
                {
                    if(indexPath.row-1 ==iPathRow)
                    {
                       [cell.switch_pan setOn:YES];
                    }
                    else
                    {
                        [cell.switch_pan setOn:NO];
                    }
                }
                else
                {
                    if(indexPath.row-1 == [subscribedPack longLongValue]-1)
                    {
                        [cell.switch_pan setOn:YES];
                    }
                    else
                    {
                        [cell.switch_pan setOn:NO];
                    }
                }
            }
            if ([arr_plan_price count]>0)
            {
                if (indexPath.row==1)
                {
                    cell.lbl_plan_price.text=[NSString stringWithFormat:@"%@",[arr_plan_price objectAtIndex:indexPath.row-1]];
                   // cell.lbl_plan_price.text=@"FREE";
                    cell.lbl_perMonth.hidden=YES;
                }
                else
                {
                    cell.lbl_plan_price.text=[NSString stringWithFormat:@"$%@",[arr_plan_price objectAtIndex:indexPath.row-1]];
                    cell.lbl_perMonth.hidden=NO;
                }
            }
            else
            {
                cell.lbl_plan_price.text=@"";
            }
            
            cell.lbl_plan_type.numberOfLines = 1;
            cell.lbl_plan_type.minimumFontSize = 10;
            cell.lbl_plan_type.adjustsFontSizeToFitWidth = YES;
            
            cell.lbl_plan_price.numberOfLines = 1;
            cell.lbl_plan_price.minimumFontSize = 10;
            cell.lbl_plan_price.adjustsFontSizeToFitWidth = YES;
            
            cell.lbl_layers_count.numberOfLines = 1;
            cell.lbl_layers_count.minimumFontSize = 6;
            cell.lbl_layers_count.adjustsFontSizeToFitWidth = YES;
            
            cell.lbl_layer_text.numberOfLines = 1;
            cell.lbl_layer_text.minimumFontSize = 6;
            cell.lbl_layer_text.adjustsFontSizeToFitWidth = YES;
            
            cell.lbl_rec_time_text.numberOfLines = 1;
            cell.lbl_rec_time_text.minimumFontSize = 6;
            cell.lbl_rec_time_text.adjustsFontSizeToFitWidth = YES;
            
            cell.lbl_recording_time.numberOfLines = 1;
            cell.lbl_recording_time.minimumFontSize = 6;
            cell.lbl_recording_time.adjustsFontSizeToFitWidth = YES;
        return cell;
        }
    }
    else if (tableView.tag==4)
    {
        tableViewTag = 4;
   
            static NSString *CellIdentifier = @"cellfilter1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        if (indexPath.row == 4 ){

            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button addTarget:self
                       action:@selector(pickerAction:)
             forControlEvents:UIControlEventTouchUpInside];
//            [button setTitle:@"Show View" forState:UIControlStateNormal];
            button.frame = CGRectMake(0,0, cell.frame.size.width, cell.frame.size.height);
            [cell addSubview:button];
            [button setTag:indexPath.row];

        }
        cell.textLabel.text=[arr_filter_data_list objectAtIndex:indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.detailTextLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }
    
    else
    {
        return 0;
    }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at CellforRowAtindezPath :%@",exception);
    }
    @finally{
        
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    filterString = [arr_filter_data_list objectAtIndex:indexPath.row];
    if (tableView.tag == 4 ) {
        arr_response = [[NSMutableArray alloc]init];
        limit = 0;
        current_Record = 0;
        if (indexPath.row == 3 || indexPath.row == 5) {
            self.tbl_view_filter_data_list.hidden = YES;
            self.view_filter_shadow.hidden= YES;
            limit=0;
            arr_response=[[NSMutableArray alloc]init];
            [self alertWithTextField:indexPath.row];
        }
        
        else{
            self.tbl_view_filter_data_list.hidden = YES;
            self.view_filter_shadow.hidden= YES ;
            if (isMelody) {
                [self loadMelodyPacks];
            }
            else{
                arr_rec_response=[[NSMutableArray alloc]init];
                [self loadRecordings];
            }
        }
    }
  
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    @try{
        if (isMelody) {
            if ((loadingData) && ((indexPath.row == [arr_response count] - 1)
                                  && arr_response.count % 10 == 0)){
            limit = arr_response.count+10;
            counter= counter+1;
            [self loadMelodyPacks];
            }
        }
        else{
            if ((loadingData) && (indexPath.row == arr_rec_response.count - 1) && (arr_rec_response.count % 10 == 0) )
            {
                limit = arr_rec_response.count+10;
                counter= counter+1;
                [self loadRecordings];
            }
        }
    
//    }
//    }
//    @catch (NSException *exception) {
//        NSLog(@"exception at willDisplayCell :%@",exception);
//    }
//    @finally{
//
//    }
}


#pragma mark- CollectionView Delegate & Datasource
#pragma mark-

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*) _cv_menu.collectionViewLayout;
    
    if (indexPath.item == [arr_menu_items count]-1) {
        float cellWidth = (CGRectGetWidth(_cv_menu.frame) - (flowLayout.sectionInset.left + flowLayout.sectionInset.right));
        return CGSizeMake(cellWidth/4,self.cv_menu.frame.size.height);
        
        
    }
    
    else {
        
        return CGSizeMake(65,self.cv_menu.frame.size.height);
        
    }
    
    // return [(NSString*)[arr_menu_items objectAtIndex:indexPath.row] sizeWithAttributes:NULL];
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
    
    
    if ([[arr_tab_select objectAtIndex:indexPath.item] isEqual:@"1"])
    {
        cell.img_menu.image = [UIImage imageNamed:@"underline.png"];
    }
    else
    {
        cell.img_menu.image = [UIImage imageNamed:@"white.png"];
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
    loadingData = NO;
    arr_response=[[NSMutableArray alloc]init];
    maxDuration=[[NSMutableArray alloc]init];
    self.placeholder_img.hidden = NO;
    self.tbl_view_recordings.hidden  = YES;
    self.tbl_view_melodypacks.hidden  = YES;

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
        genre1=[arr_menu_items objectAtIndex:indexPath.item];
    }
    
    if (melody_pack_tab_isOpen) {
        NSLog(@"GENRE ===%@",genre);
        if ([genre1 isEqualToString:@"My Melodies"])
        {
            if ([defaults_userdata boolForKey:@"isUserLogged"])
            {
                [self loadMelodyPacks];
            }
            else
            {
                ViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
                myVC.open_login=@"0";
                myVC.other_vc_flag=@"1";
                [self presentViewController:myVC animated:YES completion:nil];
            }
        }
        else{
        recording_typeInt=0;
        [self loadMelodyPacks];
        }
    }
    else if (recordings_tab_isOpen)
    {
        genre1=[arr_menu_items objectAtIndex:indexPath.item];
        genre=[arr_genre_id objectAtIndex:indexPath.item];
        arr_rec_response=[[NSMutableArray alloc]init];
        [self loadRecordings];
    }
    [_cv_menu reloadData];
    

}



#pragma mark - Navigation
#pragma mark-



- (IBAction)btn_back:(id)sender {
    @try{
    if (audioPlayer.isPlaying) {
        [audioPlayer stop];
    }
    [self stopPlay];
    soundsArray = [NSMutableArray new];
    audioPlayer = nil;
    [sliderTimer invalidate];
    sliderTimer = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at  :%@",exception);
    }
    @finally{
        
    }
}

- (IBAction)btn_home:(id)sender {
    @try{
    if (audioPlayer.isPlaying) {
        [audioPlayer stop];
    }
    [self stopPlay];
    soundsArray = [NSMutableArray new];
    [sliderTimer invalidate];
    sliderTimer = nil;
    audioPlayer = nil;
//
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
    @catch (NSException *exception) {
        NSLog(@"exception at  :%@",exception);
    }
    @finally{
        
    }
    
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
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



#pragma mark- Tab Selected
#pragma mark-
- (IBAction)btn_melodypacks_tab:(id)sender {
    loadGenreFrom = @"MELODY";

    [self loadgenres];
    isMelody = YES;
    _view_tabBar.hidden = NO;
    if (melody_pack_tab_isOpen) {
        
    }
    else{
        arr_response = [[NSMutableArray alloc]init];
        [self loadMelodyPacks];
        int a;
        for (a=0; a<[arr_genre_id count]; a++) {
            if (a==0) {
                [arr_tab_select insertObject:@"1" atIndex:a];
            }
            else
            {
                [arr_tab_select insertObject:@"0" atIndex:a];
            }
        }
        recordings_tab_isOpen=NO;
        melody_pack_tab_isOpen=YES;
    }
    
    [_cv_menu reloadData];
    _view_melodypacks_and_recordings_tab.hidden=NO;
    _tbl_view_melodypacks.hidden=NO;
    _tbl_view_recordings.hidden=YES;
    _view_subscription_tab.hidden=YES;
    _btn_filter.hidden=NO;
    _btn_search.hidden=NO;
    [self.btn_melodypacks_tab setBackgroundColor:[UIColor whiteColor]];
    [self.btn_recording_tab setBackgroundColor:[UIColor clearColor]];
    [self.btn_subscription_tab setBackgroundColor:[UIColor clearColor]];
    _btn_melodypacks_tab.titleLabel.font = [UIFont boldSystemFontOfSize:14.5];

    _btn_recording_tab.titleLabel.font = [UIFont systemFontOfSize:15];
    _btn_subscription_tab.titleLabel.font = [UIFont systemFontOfSize:15];
}

- (IBAction)btn_subscription_tab:(id)sender {
    
    _view_tabBar.hidden = YES;
    [self load_package_details];
    if([defaults_userdata boolForKey:@"isUserLogged"])
    {
       // [self load_package_details];
    }
    
    recordings_tab_isOpen=NO;
    melody_pack_tab_isOpen=NO;
    
    _view_subscription_tab.hidden=NO;
    _btn_filter.hidden=YES;
    _btn_search.hidden=YES;
    [self.btn_melodypacks_tab setBackgroundColor:[UIColor clearColor]];
    [self.btn_recording_tab setBackgroundColor:[UIColor clearColor]];
    [self.btn_subscription_tab setBackgroundColor:[UIColor whiteColor]];
    _btn_melodypacks_tab.titleLabel.font = [UIFont systemFontOfSize:15];
    _btn_recording_tab.titleLabel.font = [UIFont systemFontOfSize:15];
    _btn_subscription_tab.titleLabel.font = [UIFont boldSystemFontOfSize:14.5];

}



- (IBAction)btn_recording_tab:(id)sender
{
    limit = 0;
    _tbl_view_melodypacks.hidden =YES;
    isMelody = NO;
    _view_tabBar.hidden = NO;
    loadGenreFrom =@"RECORDINGS";
    [self loadgenres];
    if (recordings_tab_isOpen) {
        
    }
    else{
        arr_rec_response=[[NSMutableArray alloc]init];
        [self loadRecordings];
        int a;
        for (a=0; a<[arr_genre_id count]; a++) {
            if (a==0) {
                [arr_tab_select insertObject:@"1" atIndex:a];
            }
            else
            {
                [arr_tab_select insertObject:@"0" atIndex:a];
            }
        }
        melody_pack_tab_isOpen=NO;
        recordings_tab_isOpen=YES;
    }
    
  //  [arr_menu_items removeObjectAtIndex:[arr_menu_items count]-1];
    [_cv_menu reloadData];
    
    _view_melodypacks_and_recordings_tab.hidden=NO;
    _tbl_view_melodypacks.hidden=YES;
    _tbl_view_recordings.hidden=NO;
    _view_subscription_tab.hidden=YES;
    _btn_filter.hidden=NO;
    _btn_search.hidden=NO;
    [self.btn_melodypacks_tab setBackgroundColor:[UIColor clearColor]];
    [self.btn_recording_tab setBackgroundColor:[UIColor whiteColor]];
    [self.btn_subscription_tab setBackgroundColor:[UIColor clearColor]];
    _btn_melodypacks_tab.titleLabel.font = [UIFont systemFontOfSize:15];
    _btn_recording_tab.titleLabel.font = [UIFont boldSystemFontOfSize:14.5];
    _btn_subscription_tab.titleLabel.font = [UIFont systemFontOfSize:15];
    
}

#pragma mark- Custom Method
#pragma mark-

//--------------* Converts Second into Hour , Minutes and Seconds *----------------
- (NSString *)timeFormatted:(NSString *)totalSeconds
{
    int timeValue = [totalSeconds intValue];
    int seconds = timeValue % 60;
    int minutes = (timeValue / 60) % 60;
    int hours = timeValue / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}





#pragma Avtivity API

-(void)checkoutPaymentWithPackageId:(NSString *)COPackageID withAmount:(NSString *)COAmount andTransactionIdentifier:(NSString *)TransactionIdentifier
{
    @try{
    
        if([[MyManager sharedManager] isInternetAvailable])
        {
            [KSToastView ks_showToast:@"Internet connectivity issue" delay:0.1f];
            return;
        }
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:@"user_id"];
   
   
    [params setObject:COPackageID forKey:@"package_id"];
   // [params setObject:nonce forKey:@"payment_method_nonce"];
    [params setObject:COAmount forKey:@"amount"];
    [params setObject:@"ios" forKey:@"type"];
    [params setObject:@"1" forKey:@"status"];
        [params setObject:TransactionIdentifier forKey:@"transaction_id"];
   // params: user_id, amount, package_id, type, status, transaction_id
//    NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@braintree/files/checkout.php",BaseUrl];
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
                NSMutableDictionary*dic_response=[[NSMutableDictionary alloc]init];
//                NSLog(@"%@",jsonResponse);
//                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {

                //NSNumber * isSuccessNumber = (NSNumber *)[jsonResponse objectForKey: @"success"];
               
                
               // NSLog(@"STA %@",[jsonResponse objectForKey: @"status"]);
               // if([isSuccessNumber boolValue] == YES)
//                if([[jsonResponse objectForKey:@"status"] isEqualToNumber:[NSNumber numberWithInt:201]])
                if([[jsonResponse objectForKey:@"status"] isEqualToString:@"success"])
                {
                    [Appdelegate hideProgressHudInView];
                    dic_response=[jsonResponse objectForKey:@"response"];
//                    NSLog(@"%@",dic_response);
                    packageStatus = [jsonResponse objectForKey:@"status"];
                    //[self userDidCancelPayment];
                    [ProgressHUD showSuccess:@"Your subscription successfully activated."];
                     [self load_package_details];
                    
                    //[_tbl_view_subscr_packs reloadData];
//                    UIAlertController * alert=   [UIAlertController
//                                                  alertControllerWithTitle:@"Success"
//                                                  message:@"Your subscription successfully activated."
//                                                  preferredStyle:UIAlertControllerStyleAlert];
//
//                    UIAlertAction* yesButton = [UIAlertAction
//                                                actionWithTitle:@"ok"
//                                                style:UIAlertActionStyleDefault
//                                                handler:^(UIAlertAction * action)
//                                                {
//                                                    //Handel your yes please button action here
                    
//                                                }];
//
//                    [alert addAction:yesButton];
//                    [self presentViewController:alert animated:YES completion:nil];
                    
                    
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
        NSLog(@"exception at subscription :%@",exception);
    }
    @finally{
        
    }
}



#pragma mark- StoreKit Delegate
#pragma mark-

- (void)reload {
    _products = [[NSMutableArray alloc]init];
    [self requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = [products mutableCopy];
            [_tbl_view_subscr_packs reloadData];
        }
        [_tbl_view_subscr_packs setNeedsDisplay];
        
    }];
}



- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    _completionHandler = [completionHandler copy];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
}

- (void)switchToggled_UIControlEventTouchUpInside:(id)sender
{
    NSLog(@"switchToggled_UIControlEventTouchUpInside");

}
- (void)switchToggled_UIControlEventTouchDown:(id)sender
{
    NSLog(@"switchToggled_UIControlEventTouchDown");

}


- (void)switchToggled:(id)sender
{
    
    @try{
        UISwitch *mySwitch = (UISwitch *)sender;
        if([defaults_userdata boolForKey:@"isUserLogged"])
        {
            if([[MyManager sharedManager] isInternetAvailable])
            {
                [KSToastView ks_showToast:@"Internet connectivity issue" delay:0.1f];
                if(mySwitch.tag == [subscribedPack longLongValue])
                {
                    [mySwitch setOn:YES];
                }
                else{
                    [mySwitch setOn:NO];
                }
                return;
            }
            [Appdelegate showMessageHudWithMessage:@"Processing..." andDelay:3.0f];
            [mySwitch setEnabled:YES];
            
            packageID = [arr_packageID objectAtIndex:mySwitch.tag-1];
            NSLog(@"pacSTA %@",packageStatus);
            NSLog(@"pacID %@",packageID);
            NSLog(@"STATUS %d",mySwitch.isOn);
            NSLog(@"tag value %ld",(long)mySwitch.tag);
            
            iPathRow=mySwitch.tag;
            NSLog(@"subscribed PAck = %@",subscribedPack);
            if(mySwitch.tag == [subscribedPack longLongValue])
            {
                [mySwitch setOn:YES];
                [Appdelegate showMessageHudWithMessage:@"Already Subscribed" andDelay:2.0f];
            }
            else
            {
                [mySwitch setOn:NO];
                if (mySwitch.tag==1)
                {
                    [Appdelegate showMessageHudWithMessage:@"You can not subscribe Freemium pack. It automatically activated when user doesn't have any subscribtion pack." andDelay:4.0f];
                    
                }
                else
                {
                   
                    if (_products.count >0) {
                        SKProduct *product = [_products objectAtIndex:mySwitch.tag-2];
                        NSLog(@"Product %@",product.localizedTitle);
                        NSString *strPackName = product.localizedTitle;
                        NSString *strDescription = product.localizedDescription;
                        
//                        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//                        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
//                        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//                        [formatter setLocale:product.priceLocale];
//                        NSString *currencyString = [formatter stringFromNumber:product.price];
//                        NSLog(@"PRICE %@",currencyString);
//                        payableAmount=[NSString stringWithFormat:@"%@",currencyString];
//
//                        // NSArray *arr = [strPackName componentsSeparatedByString:@"."];
//                        NSString *msgString;// =[arr objectAtIndex:arr.count-1];
//                        msgString = [NSString stringWithFormat:@"%@ Melody Pack\n•This is one month subscription pack of %@\n•In this pack you %@.\n•Payment will be charged to iTunes Account at confirmation of purchase.\n•Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.\n•Account will be charged for renewal within 24-hours prior to the end of the current period, and identify the cost of the renewal.\n•Subscriptions may be managed by the user and auto-renewal may be turned off by going to the user’s Account Settings after purchase.\n•Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable.\n•For more info see our Privacy Policy.",strPackName,currencyString,strDescription];
                        //// ---------------------------------------------------------------------------

//                        SKProduct *product = [_products objectAtIndex:mySwitch.tag-2];
                        [self purchaseMyProduct:product];
                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                            //Background Thread
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                //Run UI Updates
                                [Appdelegate showMessageHudWithMessage:@"Processing..." andDelay:5.0f];
                            });
                        });
                        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                        [formatter setLocale:product.priceLocale];
                        NSString *currencyString = [formatter stringFromNumber:product.price];
                        NSLog(@"PRICE %@",currencyString);
                        payableAmount=[NSString stringWithFormat:@"%@",currencyString];
                        purchaseButton.enabled = NO;
                     //// ---------------------------------------------------------------------------
//                        UIAlertController * alert=   [UIAlertController
//                                                      alertControllerWithTitle:@"In-App Purchase !"
//                                                      message:msgString
//                                                      preferredStyle:UIAlertControllerStyleAlert];
//
//                        UIAlertAction* yesButton = [UIAlertAction
//                                                    actionWithTitle:@"ok"
//                                                    style:UIAlertActionStyleDefault
//                                                    handler:^(UIAlertAction * action)
//                                                    {
//                                                        SKProduct *product = [_products objectAtIndex:mySwitch.tag-2];
//                                                        [self purchaseMyProduct:product];
//                                                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
//                                                            //Background Thread
//                                                            dispatch_async(dispatch_get_main_queue(), ^(void){
//                                                                //Run UI Updates
//                                                                [Appdelegate showMessageHudWithMessage:@"Processing..." andDelay:5.0f];
//                                                            });
//                                                        });                                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//                                                        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
//                                                        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//                                                        [formatter setLocale:product.priceLocale];
//                                                        NSString *currencyString = [formatter stringFromNumber:product.price];
//                                                        NSLog(@"PRICE %@",currencyString);
//                                                        payableAmount=[NSString stringWithFormat:@"%@",currencyString];
//                                                        purchaseButton.enabled = NO;
//                                                    }];
//                        UIAlertAction* cancelButton = [UIAlertAction
//                                                       actionWithTitle:@"cancel"
//                                                       style:UIAlertActionStyleDefault
//                                                       handler:^(UIAlertAction * action)
//                                                       {
//
//                                                       }];
//                        [alert addAction:cancelButton];
//                        [alert addAction:yesButton];
//                        [self presentViewController:alert animated:YES completion:nil];
                    }
                }
            }
        }
        
        else
        {
            if([[MyManager sharedManager] isInternetAvailable])
            {
                [KSToastView ks_showToast:@"Internet connectivity issue" delay:0.1f];
                if(mySwitch.tag == [subscribedPack longLongValue])
                {
                    [mySwitch setOn:YES];
                }
                else{
                    [mySwitch setOn:NO];
                    //                [mySwitch setEnabled:NO];
                }
                return;
            }
            //        [mySwitch setEnabled:YES];
            
            [Appdelegate hideProgressHudInView];
            //[Appdelegate showMessageHudWithMessage:@"PLEASE LOGIN FIRST" andDelay:2.0f];
            NSLog(@"tag value %ld",(long)mySwitch.tag-1);
            if (mySwitch.tag-1==0)
            {
                [mySwitch setOn:YES];
            }
            else
            {
                [Appdelegate hideProgressHudInView];
                Appdelegate.screen_After_Login = Activity;
                ViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
                myVC.open_login=@"0";
                myVC.other_vc_flag=@"1";
                [self presentViewController:myVC animated:YES completion:nil];
            }
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at  :%@",exception);
    }
    @finally{
        
    }
}



- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

- (void)purchaseMyProduct:(SKProduct*)product{
    @try{
        if ([self canMakePurchases]) {
            SKPayment *payment = [SKPayment paymentWithProduct:product];
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
        else{
            NSError *err;
            NSLog(@"%@",err.description);
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                                      @"Purchases are disabled in your device" message:nil delegate:
                                      self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at  :%@",exception);
    }
    @finally{
        
    }
}


-(void)paymentQueue:(SKPaymentQueue *)queue
updatedTransactions:(NSArray *)transactions {
    @try{
        
        for (SKPaymentTransaction *transaction in transactions) {
            switch (transaction.transactionState) {
                    
                //--------------------- * Purchasing  * ------------------------
                case SKPaymentTransactionStatePurchasing:
                    if([[MyManager sharedManager] isInternetAvailable])
                    {
                        [KSToastView ks_showToast:@"Internet connectivity issue" delay:0.1f];
                        break;
                    }
//                    NSLog(@"Purchasing");
                    [Appdelegate hideProgressHudInView];
                    break;
                //--------------------- * Purchased  * ------------------------
                case SKPaymentTransactionStatePurchased:
//                    NSLog(@"Purchased ");
                    if([[MyManager sharedManager] isInternetAvailable])
                    {
                        [KSToastView ks_showToast:@"Internet connectivity issue" delay:0.1f];
                        break;
                    }
                    [Appdelegate hideProgressHudInView];
              
                    
                    for (int i =0; i<_products.count; i++) {
                        SKProduct *proDetail = [_products objectAtIndex:i];
                        NSString *strIdentifier = proDetail.productIdentifier;
                        if ([strIdentifier isEqualToString:transaction.payment.productIdentifier])
                        {
                            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
                                                      @"Purchase is completed succesfully" message:nil delegate:
                                                      self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                            [alertView show];
                        
                        }
                    }
                    [self completeTransaction:transaction];

                    break;
                    
                    //--------------------- * Restored  * ------------------------
                case SKPaymentTransactionStateRestored:
                    if([[MyManager sharedManager] isInternetAvailable])
                    {
                        [KSToastView ks_showToast:@"Internet connectivity issue" delay:0.1f];
                        break;
                    }
                    NSLog(@"Restored ");
       
                    // purchase has been restored
                    [self displayAlertViewWithMessage:@"Successfully restored your purchase"];
                    [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                    
                    break;
                    
                    //--------------------- * Failed  * ------------------------
                case SKPaymentTransactionStateFailed:
                    if([[MyManager sharedManager] isInternetAvailable])
                    {
                        [KSToastView ks_showToast:@"Internet connectivity issue" delay:0.1f];
                        break;
                    }
//                    [self failedTransaction:transaction];
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//                    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
                    [Appdelegate hideProgressHudInView];
                    NSLog(@"Purchase failed ");
//                    [self displayAlertViewWithMessage:@"There was a problem with your purchase. Please try again later."];

                    break;
                default:
                    if([[MyManager sharedManager] isInternetAvailable])
                    {
                        [KSToastView ks_showToast:@"Internet connectivity issue" delay:0.1f];
                        break;
                    }
                    [Appdelegate hideProgressHudInView];
                    break;
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at  :%@",exception);
    }
    @finally{
        
    }
}



#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

    NSLog(@"Loaded list of products... %@", response.products);
    productsRequest = nil;
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }

    _completionHandler(YES, skProducts);
    _completionHandler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}


- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    
    NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}



- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");

    [self validateReceiptWithTransaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}



- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restoreTransaction...");
    
//    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
//    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
     [KSToastView ks_showToast:@"Restore succesfully" delay:0.1f];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];

}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

// Add new method
- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
    
}

-(void)validateReceiptWithTransaction:(SKPaymentTransaction *)transaction
{
    @try{
    NSData *receipt;// = [NSData dataWithContentsOfURL:receiptUrl];
    //receipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0)
        
    {
        receipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    }
    else{
        receipt=transaction.transactionReceipt;

    }

    NSString *receiptDataString = [receipt base64EncodedStringWithOptions:0];
    NSString* urlString1 = [NSString stringWithFormat:@"%@ios/checkout.php",BaseUrl];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString1]];
        
    NSURLSession *session= [NSURLSession sharedSession];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[receiptDataString dataUsingEncoding:NSASCIIStringEncoding]];
    NSURLSessionDataTask* task =  [session dataTaskWithRequest:request
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (error) {
//                NSLog(@"%@", error);
                }
                else {
                    NSError *myError = nil;
                    NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//                    NSLog(@"%@",requestReply);
                    NSData *data2=[requestReply dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                    
                    id jsonObject = [NSJSONSerialization
                                     
                                     JSONObjectWithData:data2
                                     options:NSJSONReadingAllowFragments error:&myError];
                    if (jsonObject != nil) {
                        
                    
                    NSString *dic_receipt = [jsonObject valueForKey:@"info"];
                    NSData *data = [dic_receipt dataUsingEncoding:NSUTF8StringEncoding];
                    id jsone = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSString *str_status = [jsone valueForKey:@"status"];
                    if ([str_status intValue] == 0) {
                        [self checkoutPaymentWithPackageId:packageID withAmount:payableAmount andTransactionIdentifier:transaction.transactionIdentifier];
                        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];

                    }
                    else{
                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"In-app purchase"
                                                      message:@"Validation failed"
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
                    NSLog(@"%@",jsonObject);
                    }
                    else{
                        NSLog(@"error %@",error.description);
                    }
                }
            }];
    [task resume];
    
}
@catch (NSException *exception) {
    [Appdelegate hideProgressHudInView];
    NSLog(@"exception at validateReceiptWithTransaction :%@",exception);
}
@finally{
    
}
}

- (void)displayAlertViewWithMessage:(NSString *)message {
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}


-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    NSLog(@"Restored Products ....");
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


-(void)initializesIAP{
    productIdentifiers = [NSSet setWithObjects:
                          //@"com.Yomelody.1.FreePack",
                          @"com.Yomelody.2.Standard_Pack",
                          @"com.Yomelody.3.Premium_Pack",//com.Yomelody.3.Premium
                          @"com.Yomelody.4.Producer_Pack",//com.Yomelody.1.Freemium
                          nil];
    
    // Check for previously purchased products
    _purchasedProductIdentifiers = [NSMutableSet set];
    for (NSString * productIdentifier in productIdentifiers) {
        BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
        if (productPurchased) {
            [_purchasedProductIdentifiers addObject:productIdentifier];
            NSLog(@"Previously purchased: %@", productIdentifier);
        } else {
            NSLog(@"Not purchased: %@", productIdentifier);
        }
    }
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [self reload];
}
- (IBAction)btn_restoreAction:(id)sender {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

/*
 ApiAuthenticationKey:@_$%yomelody%audio#@mixing(app*
 ispublic   => send 1 for public and 0 for private
 user_id   => User Id
 rid  => recording id*/
-(void)makePublicOrPrivateRecording:(id)sender
{
    @try{
        [Appdelegate showProgressHud];
        NSLog(@"VALUE OF INDEX=X=X === %ld",(long)index);
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

@end
