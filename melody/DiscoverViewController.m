//
//  DiscoverViewController.m
//  melody
//
//  Created by CodingBrainsMini on 11/21/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import "DiscoverViewController.h"
#import"AudioFeedTableViewCell.h"
#import "PagedImageScrollView.h"
#import "menuCollectionViewCell.h"
#import "AudioFeedCommentsViewController.h"
#import "Constant.h"
#import "ProfileViewController.h"
#import "StudioPlayViewController.h"



@interface DiscoverViewController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    int recording_typeInt;
    //    int recordingtype;
    NSString *artistNameString;
    NSString *searchString;
    NSString *userNameString;
    NSString *filterString;
    UIActivityIndicatorView *activityIndicatorView;
    NSString *numberOfInstruments;
    NSString *BPM;
    int text_flag;
    NSMutableArray *instrumentArray;
    NSInteger index;
    NSArray *arr_Advertisement;
    PagedImageScrollView *pageScrollView;
NSInteger current_Record,limit;
    UIActivityViewController *activityController;
    AVAudioPlayer *audioPlayer;
    NSTimer *recordingTimer;
    long instrument_play_index;
    int instrument_play_status;
    NSTimer* sliderTimer;
    BOOL toggle_PlayPause;
    long last_Index;
   

}
@end


@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    instrumentArray = [[NSMutableArray alloc] init];
    limit = 0;
    // Add some data for demo purposes.
    [instrumentArray addObject:@"1"];
    [instrumentArray addObject:@"2"];
    [instrumentArray addObject:@"3"];
    [instrumentArray addObject:@"4"];
    [instrumentArray addObject:@"5"];
    last_Index = 99999999;
    current_Record=0;
    recording_typeInt = 0;
    text_flag=0;
    // Do any additional setup after loading the view.
    defaults_userdata=[NSUserDefaults standardUserDefaults];
    genre=[[NSString alloc]initWithFormat:@""];
    /********************genremenu*************************/
    self.tf_srearch.delegate=self;
    [self.tf_srearch addTarget:self
                        action:@selector(textFieldDidChange:)
              forControlEvents:UIControlEventEditingChanged];
    
    
    genre=[[NSString alloc]initWithFormat:@""];
    _cv_menu.showsHorizontalScrollIndicator=NO;
    
    /*****************************************************/
    /***********************Assigning tag number to tableviews***************************/
    status=0;
    _tbl_view_audiodeeds_filter.tag=1;
    _tbl_view_filter_data_list.tag=2;

    /************************************************************************************/
    arr_filter_data_list=[[NSMutableArray alloc]initWithObjects:@"Latest",@"Trending",@"Favorites",@"Artist",@"# of Instrumentals",@"BPM", nil];
    _view_filter_shadow.frame=CGRectMake(-800, 0, self.view.frame.size.width, self.view.frame.size.height);
    _view_filter.layer.cornerRadius=10;
    _view_search.hidden=YES;
   

    
    //************NEW DYNAMIC****************
    pageScrollView = [[PagedImageScrollView alloc] initWithFrame:CGRectMake(0, 0, self.vew_slider.frame.size.width, self.vew_slider.frame.size.height)];
    
    [pageScrollView setScrollViewContents:@[[UIImage imageNamed:@"loadingimg.jpg"]]];
    pageScrollView.pageControlPos = PageControlPositionCenterBottom;
    [self.vew_slider addSubview:pageScrollView];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    singleTap.view.tag=1;
    [pageScrollView addGestureRecognizer:singleTap];
    
   // UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    UISwipeGestureRecognizer*swipedown=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [swipedown setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:swipedown];

    [self getAdvertisement];
   
}
- (void)viewDidAppear:(BOOL)animated {

    [self loadgenres];
    [self loadRecordings];
}



- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    NSLog(@"val %ld",(long)pageScrollView.pageControl.currentPage);
    
    long counter = pageScrollView.pageControl.currentPage;
    NSString *fetchUrl=[[arr_Advertisement objectAtIndex:counter] objectForKey:@"adv_url"];
    [self openUrlInBrowser:fetchUrl];
}
-(void)openUrlInBrowser:(NSString *)withUrl
{
    NSLog(@"URL %@",withUrl);
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:withUrl]])
    {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:withUrl]];
    }
    
}




-(void)textFieldDidChange:(UITextField *)theTextField{
    NSLog( @"text changed: %@", self.tf_srearch.text);
    if ([self.tf_srearch.text length]>0) {
        text_flag=1;
        [self.btn_search_cancel setTitle:@"Send" forState:UIControlStateNormal];
    }else{
        text_flag=0;
        
    }
}


/******************************Calling Genere API*********************************/
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
                                                        } else {
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
/**********************************************************************************/
/***************************Call Recordings api**********************************/


-(void)loadRecordings
{
    @try{
    self.placeholder_img.hidden = YES;
    self.tbl_view_audiodeeds_filter.hidden = NO;
    [Appdelegate showProgressHud];
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    
    if ([defaults_userdata boolForKey:@"isUserLogged"]) {
    [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:KEY_USER_ID];
    }
    
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];

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
        [params setObject:@"station" forKey:@"key"];
        [params removeObjectForKey:@"artistname"];
        [params removeObjectForKey:@"search"];
        [params setObject:genre forKey:@"genere"];
        
    }
    [params setObject:@"station" forKey:@"key"];
    [params setObject:[NSString stringWithFormat:@"%ld",(long)limit] forKey:@"limit"];
    
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
                [self presentViewController:alert animated:YES completion:nil];                                                    }
                                                    
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                   
                    NSError *myError = nil;
                    NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                    NSLog(@"%@",requestReply);
                    NSData *data2=[requestReply dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                    
                    id jsonObject = [NSJSONSerialization
                                     JSONObjectWithData:data2
                                     options:NSJSONReadingAllowFragments error:&myError];
                    
                    if ([[jsonObject valueForKey:@"flag"] isEqual:@"success"])
                    {
                        [Appdelegate hideProgressHudInView];
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
                        arr_rec_duration=[[NSMutableArray alloc]init];
                        arr_rec_play_count=[[NSMutableArray alloc]init];
                        arr_rec_like_count=[[NSMutableArray alloc]init];
                        arr_rec_comment_count=[[NSMutableArray alloc]init];
                        arr_rec_share_count=[[NSMutableArray alloc]init];
                        arr_rec_like_status=[[NSMutableArray alloc]init];
                        arr_rec_recordings=[[NSMutableArray alloc]init];
                        followerID=[[NSMutableArray alloc]init];
                        arr_rec_recordings_url=[[NSMutableArray alloc]init];

                        arr_rec_response=[jsonObject valueForKey:@"response"];
                        current_Record=[arr_rec_response count];
                        NSLog(@"%@",arr_rec_response);
                        for (int i=0; i<[arr_rec_response count]; i++)
                        {
                            NSLog(@"%@",[arr_rec_response objectAtIndex:i]);
                            if([[[arr_rec_response objectAtIndex:i] valueForKey:@"recording_id"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"recording_id"] length]==0)
                            {
                                [arr_rec_pack_id addObject:@"0"];
                            }
                            else
                            {
                                [arr_rec_pack_id addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"recording_id"]];
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
                            
                            if([[[arr_rec_response objectAtIndex:i] valueForKey:@"cover_url"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"cover_url"] length]==0)
                            {
                                [arr_rec_cover addObject:@"http://"];
                                [arr_rec_duration addObject:@""];
                            }
                            else
                            {
                            [arr_rec_cover addObject:[NSString stringWithFormat:@"%@",[[arr_rec_response objectAtIndex:i] valueForKey:@"cover_url"]]];
                             [arr_rec_duration addObject:[NSString stringWithFormat:@"%@",[[[[arr_rec_response objectAtIndex:i] objectForKey:@"recordings"] objectAtIndex:0] objectForKey:@"duration"]]];
                            }
                            
                            if([[[arr_rec_response objectAtIndex:i] valueForKey:@"added_by"] isEqual:[NSNull null]] || [[[arr_rec_response objectAtIndex:i] valueForKey:@"added_by"] length]==0)
                            {
                                [followerID addObject:@"0"];
                            }
                            else
                            {
                                [followerID addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"added_by"]];
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
                            if([[[arr_rec_response objectAtIndex:i] valueForKey:@"like_status"] isEqual:[NSNull null]])
                            {
                                [arr_rec_like_status addObject:@"0"];
                            }
                            else
                            {
                                [arr_rec_like_status addObject:[[arr_rec_response objectAtIndex:i] valueForKey:@"like_status"] ];
                            }
                            
                        }
                        
                        [_tbl_view_audiodeeds_filter reloadData];
                    }
                    else
                    {
                        [Appdelegate hideProgressHudInView];
                        self.placeholder_img.hidden = NO;
                        self.tbl_view_audiodeeds_filter.hidden = YES;
                        self.placeholder_img.image = [UIImage imageNamed:@"NoResult_img"];
                        arr_rec_pack_id=[[NSMutableArray alloc]init];
                        [_tbl_view_audiodeeds_filter reloadData];
                    }
                    
                });
            }
            }];
    [dataTask resume];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}

-(void)dismissKeyboard
{
    [_tf_srearch resignFirstResponder];
}



#pragma mark - CollectionView Delegates and Datasource
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
    if ([[arr_tab_select objectAtIndex:indexPath.item] isEqual:@"1"]) {
        cell.img_menu.image = [UIImage imageNamed:@"underline.png"];
        cell.lbl_menu_title.text=[arr_menu_items objectAtIndex:indexPath.row];
        //        UIFont *currentFont = cell.lbl_menu_title.font;
        //        UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",currentFont.fontName] size:currentFont.pointSize];
        //        cell.lbl_menu_title.font = newFont;
    }
    else
    {
        //        UIFont *currentFont = cell.lbl_menu_title.font;
        //        UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Regular",currentFont.fontName] size:currentFont.pointSize];
        //        cell.lbl_menu_title.font = newFont;
        cell.lbl_menu_title.text=[arr_menu_items objectAtIndex:indexPath.row];
        
        cell.img_menu.image = [UIImage imageNamed:@"white.png"];
        
    }
    //    static NSString *cellIdentifier = @"Cell";
    //
    //    menuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    //
    //    if (self.selectedItemIndexPath != nil && [indexPath compare:self.selectedItemIndexPath] == NSOrderedSame) {
    //        cell.maskView.layer.borderColor = [[UIColor redColor] CGColor];
    //        cell.maskView.layer.borderWidth = 4.0;
    //    } else {
    //        cell.maskView.layer.borderColor = nil;
    //        cell.maskView.layer.borderWidth = 0.0;
    //    }
    
    
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //    NSInteger viewWidth = self.view.frame.size.width;
    //    NSInteger totalCellWidth = 67 * _numberOfCells;
    //    NSInteger totalSpacingWidth = 2 * (_numberOfCells -1);
    //
    //    NSInteger leftInset = (viewWidth - (totalCellWidth + totalSpacingWidth)) / 2;
    //    NSInteger rightInset = leftInset;
    //
    //    return UIEdgeInsetsMake(0, leftInset, 0, rightInset);
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    limit = 0;
    int i;
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
    [self loadRecordings];
    [_cv_menu reloadData];
}



#pragma mark - TableView Delegates and Datasource
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
    else if (tableView.tag==2) {
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
    else if (tableView.tag==2) {
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
    }
    else if (tableView.tag==2) {
        return 1;
    }
    else{
        return 0;
    }
   
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    @try{
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
//            [cell.btn_play_value setTitle:[arr_rec_play_count objectAtIndex:indexPath.row] forState:UIControlStateNormal];
        [cell.btn_play_value setTitle:[NSString stringWithFormat:@"%@",[arr_rec_play_count objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
            cell.btn_Profile.clipsToBounds = YES;
            cell.roundBackgroundView.layer.cornerRadius=8.0f;
            cell.layer.shadowColor = [[UIColor grayColor] CGColor];
            cell.layer.shadowOpacity = 0.4;
            cell.layer.shadowRadius = 0;
            cell.layer.shadowOffset = CGSizeMake(1.0, 1.0);
            cell.btn_join.tag=indexPath.row;
            [cell.btn_join addTarget:self action:@selector(join_clicked:) forControlEvents:UIControlEventTouchUpInside];
            cell.btn_comment.tag=indexPath.row;
            [cell.btn_comment addTarget:self action:@selector(btn_Recordings_comment_clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btn_PlayRecording.tag = indexPath.row;
            [cell.btn_PlayRecording addTarget:self action:@selector(btn_Recordings_Play_clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btn_like.tag=indexPath.row;
            [cell.btn_like addTarget:self action:@selector(btn_Recordings_like_clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btn_hide.hidden=YES;
            cell.btn_hide.tag=indexPath.row;
            [cell.btn_hide addTarget:self action:@selector(hide_cellrecording:) forControlEvents:UIControlEventTouchUpInside];
            cell.btn_other_options.tag=indexPath.row;
            [cell.btn_other_options addTarget:self action:@selector(show_options:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.btn_share addTarget:self action:@selector(openshare:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.lbl_profile_name.text=[arr_rec_name objectAtIndex:indexPath.row];
            cell.lbl_profile_twitter_id.text=[NSString stringWithFormat:@"@%@",[arr_rec_station objectAtIndex:indexPath.row]];
            cell.lbl_timer.text=[Appdelegate timeFormatted:[arr_rec_duration objectAtIndex:indexPath.row]];
            
            NSString *tempDate=[arr_rec_post_date objectAtIndex:indexPath.row];
            if (tempDate == nil || tempDate.length >0) {
                cell.lbl_date_top.text=[Appdelegate formatDateWithString:tempDate];
                cell.lbl_date_aidios.text=[Appdelegate formatDateWithString:tempDate];
            }

        
            long includeL =[[[arr_rec_response objectAtIndex:indexPath.row] valueForKey:@"join_count"]longValue];
            
            cell.lbl_included.text = [NSString stringWithFormat:@"Include : %ld",includeL];
            
            cell.lbl_oneof.text = [NSString stringWithFormat:@"( 1 of %ld )",includeL];
            
            NSInteger anIndex=[arr_genre_id indexOfObject:[arr_rec_genre objectAtIndex:indexPath.row]];
            if(NSNotFound == anIndex) {
                NSLog(@"not found");
                anIndex=0;
            }
          cell.lbl_geners.text=[NSString stringWithFormat:@"Genre : %@", [arr_menu_items objectAtIndex:anIndex]];

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
            
            //------------- Cover pic -----------------
            NSURL *url = [NSURL URLWithString:[arr_rec_cover objectAtIndex:indexPath.row]];
            cell.img_view_back_cover.contentMode = UIViewContentModeScaleToFill;
            [cell.img_view_back_cover sd_setImageWithURL:url
                                        placeholderImage:[UIImage imageNamed:@"bg_cell.png"]];
            
            
            NSURL *url2 = [NSURL URLWithString:[arr_rec_profile objectAtIndex:indexPath.row]];
            
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
    else if (tableView.tag==2) {
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
//            [button setTitle:@"Show View" forState:UIControlStateNormal];
            button.frame = CGRectMake(0,0, cell.frame.size.width, cell.frame.size.height);
            [cell addSubview:button];
            [button setTag:indexPath.row];
            
        }
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.text=[arr_filter_data_list objectAtIndex:indexPath.row];
        
        return cell;
    }
    
    else{
        return 0;
    }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 2) {
        
        filterString = [arr_filter_data_list objectAtIndex:indexPath.row];
        if (indexPath.row == 3 || indexPath.row == 5) {
            self.tbl_view_filter_data_list.hidden = YES;
            self.view_filter_shadow.hidden= YES;
            [self alertWithTextField:indexPath.row];
        }
        
        else{
            self.tbl_view_filter_data_list.hidden = YES;
            self.view_filter_shadow.hidden= YES ;
            [self loadRecordings];
        }
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
                                           
                                           [self loadRecordings];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
    
    // You can also use self.view if you don't have a sender
}


-(void)profileClicked:(UIButton*)sender{
    NSLog(@"profileClicked");
    ProfileViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    NSString *currentUserID;
        currentUserID = [followerID objectAtIndex:sender.tag];
    profileVC.follower_id = currentUserID;
    NSString * userId = [defaults_userdata objectForKey:@"user_id"];
    profileVC.user_id = userId;
    [profileVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:profileVC animated:YES completion:nil];
    
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



-(void)join_clicked:(UIButton*)sender
{
    index = sender.tag;

    [self performSegueWithIdentifier:@"discover_to_studio_play" sender:self];
}



- (void)btn_Recordings_comment_clicked:(UIButton*)sender
{
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
- (void)show_options:(UIButton*)sender
{
    //AudioFeedTableViewCell *cell = (ActivitiesTableViewCell*)[nib2 objectAtIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    AudioFeedTableViewCell *cell = (AudioFeedTableViewCell*)[_tbl_view_audiodeeds_filter cellForRowAtIndexPath:indexPath];
    
    if (status==0) {
        cell.btn_hide.hidden=NO;
        status=1;
    }
    else{
        cell.btn_hide.hidden=YES;
        status=0;
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
    [_tbl_view_audiodeeds_filter reloadData];
}

/*********************************************************************************/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
#pragma mark -
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"go_to_recording_comments"])
    {
        AudioFeedCommentsViewController*vc=segue.destinationViewController;
        vc.dic_data=[arr_rec_response objectAtIndex:[_sender_tag integerValue]];
    }
    
   else if ([segue.identifier isEqual:@"discover_to_studio_play"]) {
        //         if ([defaults_userdata boolForKey:@"isUserLogged"]) {
        StudioPlayViewController*vc=segue.destinationViewController;
        vc.str_CurrernUserId = [followerID objectAtIndex:index];
        vc.str_RecordingId = [arr_rec_pack_id objectAtIndex:index];
        vc.arr_recordings=[arr_rec_recordings objectAtIndex:index];
        //     }
    }
}

#pragma mark - Play Method


- (void)btn_Recordings_Play_clicked:(UIButton* )sender {

//    @try{
    NSLog(@"BEGIN   last_Index %ld",last_Index);
        instrument_play_index = sender.tag;
        AudioFeedTableViewCell *cell = [_tbl_view_audiodeeds_filter cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
        if(audioPlayer  && last_Index == sender.tag) {
            if (audioPlayer.isPlaying) {
                [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                [audioPlayer pause];
            }
            else{
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
            dispatch_queue_t myqueue = dispatch_queue_create("queue", NULL);
            dispatch_async(myqueue, ^{
                [self method_PlayCount:instrument_play_index];

                NSString *urlstr =[arr_rec_recordings_url objectAtIndex:instrument_play_index];
                urlstr = [urlstr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];

                NSURL *urlforPlay = [NSURL URLWithString:urlstr];
                NSData *data = [NSData dataWithContentsOfURL:urlforPlay];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError*error=nil;
                    audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];

                    [audioPlayer setDelegate:self];
                    [audioPlayer prepareToPlay];
                    if ([audioPlayer prepareToPlay] == YES){

                        if (last_Index != 99999999) {
                            AudioFeedTableViewCell *cell1 = [_tbl_view_audiodeeds_filter cellForRowAtIndexPath:[NSIndexPath indexPathForRow:last_Index inSection:0]];
                            cell1.slider_progress.value = 0.0;
                            [cell1.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                        }

                sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerupdateSlider) userInfo:nil repeats:YES];
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

                    else {
                        [Appdelegate hideProgressHudInView];

                        AudioFeedTableViewCell *cell1 = [_tbl_view_audiodeeds_filter cellForRowAtIndexPath:[NSIndexPath indexPathForRow:last_Index inSection:0]];
                        cell1.slider_progress.value = 0.0;
                        [cell1.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"Alert"
                                                      message:@"Url Not Supported"
                                                      preferredStyle:UIAlertControllerStyleAlert];

                        UIAlertAction* yesButton = [UIAlertAction
                                                    actionWithTitle:@"ok"
                                                    style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action)
                                                    {
                                                        [Appdelegate hideProgressHudInView];

                                                    }];

                        [alert addAction:yesButton];
                        [self presentViewController:alert animated:YES completion:nil];
                        int errorCode = CFSwapInt16HostToBig ([error code]);
                        NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
                    }

                });
            });
        }

//    }
//    @catch (NSException *exception) {
//        NSLog(@"exception at likes.php :%@",exception);
//    }
//    @finally{
//
//    }
    last_Index = instrument_play_index;
    NSLog(@"END   last_Index %ld",last_Index);

}


//-(void) playButtonPressed
//{
//
//}
//-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
//{
////    [self updateControls];
//
//    SampleQueueId* queueId = (SampleQueueId*)queueItemId;
//
//    NSLog(@"Finished: %@", [queueId.url description]);
//}
//
//-(void) updateControls
//{
//    if (SaudioPlayer == nil)
//    {
////        [playButton setTitle:@"" forState:UIControlStateNormal];
//    }
//    else if (SaudioPlayer.state == STKAudioPlayerStatePaused)
//    {
////        [playButton setTitle:@"Resume" forState:UIControlStateNormal];
//    }
//    else if (SaudioPlayer.state & STKAudioPlayerStatePlaying)
//    {
////        [playButton setTitle:@"Pause" forState:UIControlStateNormal];
//    }
//    else
//    {
////        [playButton setTitle:@"" forState:UIControlStateNormal];
//    }
//
//    [self tick];
//}
//
//-(void) tick
//{
//    AudioFeedTableViewCell *cell = [_tbl_view_audiodeeds_filter cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
//
//    if (!SaudioPlayer)
//    {
//        cell.slider_progress.value = 0;
//        return;
//    }
//
//    if (SaudioPlayer.currentlyPlayingQueueItemId == nil)
//    {
//        cell.slider_progress.value = 0;
//        cell.slider_progress.minimumValue = 0;
//        cell.slider_progress.maximumValue = 0;
//        return;
//    }
//
//    if (audioPlayer.duration != 0)
//    {
//        cell.slider_progress.minimumValue = 0;
//        cell.slider_progress.maximumValue = audioPlayer.duration;
//        cell.slider_progress.value = SaudioPlayer.progress;
//    }
//    else
//    {
//        cell.slider_progress.value = 0;
//        cell.slider_progress.minimumValue = 0;
//        cell.slider_progress.maximumValue = 0;
//
//    }
//
//    CGFloat newWidth = 320 * (([SaudioPlayer averagePowerInDecibelsForChannel:1] + 60) / 60);
//
////    meter.frame = CGRectMake(0, 460, newWidth, 20);
//}




//-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
//{
//    [self updateControls];
//}
//
//- (void)btn_Recordings_Play_clicked:(UIButton* )sender {
//
//    instrument_play_index = sender.tag;
//     AudioFeedTableViewCell *cell = [_tbl_view_audiodeeds_filter cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
//
//    if (!SaudioPlayer)
//    {
//        //    [self method_PlayCount:instrument_play_index];
//
//        SaudioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
//        SaudioPlayer.meteringEnabled = YES;
//        SaudioPlayer.volume = 1;
//        SaudioPlayer.delegate = self;
//        NSString *urlstr =[arr_rec_recordings_url objectAtIndex:instrument_play_index];
//        urlstr = [urlstr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
//        NSURL *urlforPlay = [NSURL URLWithString:urlstr];
//        STKDataSource* dataSource = [STKAudioPlayer dataSourceFromURL:urlforPlay];
//        [SaudioPlayer setDataSource:dataSource withQueueItemId:[[SampleQueueId alloc] initWithUrl:urlforPlay andCount:0]];
//        [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
//
//    }
//
//    if (SaudioPlayer.state == STKAudioPlayerStatePaused)
//    {
//        [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
//        [SaudioPlayer resume];
//    }
//    else
//    {
//        [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
//        [SaudioPlayer pause];
//
//    }
//
////    }
//}

-(void)timerupdateSlider{
    // Update the slider about the music time
    
    AudioFeedTableViewCell *cell = [_tbl_view_audiodeeds_filter cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    cell.slider_progress.value = audioPlayer.currentTime;
}


-(void)sliderChanged{
    // Fast skip the music when user scroll the UISlider
    AudioFeedTableViewCell *cell = [_tbl_view_audiodeeds_filter cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    [audioPlayer setCurrentTime:cell.slider_progress.value];
    [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
    instrument_play_status=1;
    
}

#pragma mark - Audio Player Delegate Method
#pragma mark -

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    AudioFeedTableViewCell *cell = [self.tbl_view_audiodeeds_filter cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
    audioPlayer = nil;
        cell.slider_progress.value = 0.0;
    [sliderTimer invalidate];
    sliderTimer = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@" player error description %@",error);
}


-(void)method_PlayCount:(NSInteger)sender{
    
    @try{
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
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error)
        {
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
                    long a = [[arr_rec_play_count objectAtIndex:sender] integerValue]+1;
                    [arr_rec_play_count replaceObjectAtIndex:sender withObject:[NSNumber numberWithInteger:a]];
                    [self.tbl_view_audiodeeds_filter reloadData];
                    
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
        NSLog(@"exception at Method playcount :%@",exception);
    }
    @finally{
        
    }
}


#pragma mark -



-(void)deAllocateAudioPLayer{
    [audioPlayer stop];
    audioPlayer = nil;
    [sliderTimer invalidate];
    sliderTimer = nil;
}


- (IBAction)btn_back:(id)sender {
    
    [self deAllocateAudioPLayer];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btn_home:(id)sender {
    
    [self deAllocateAudioPLayer];
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
- (IBAction)btn_filter_shadow_cancel:(id)sender {
    _view_filter_shadow.frame=CGRectMake(-500, 0, self.view.frame.size.width, self.view.frame.size.height);
}
- (IBAction)btn_filter:(id)sender {
     _view_filter_shadow.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.tbl_view_filter_data_list.hidden = NO;
    self.view_filter_shadow.hidden = NO;
    recording_typeInt = 1;
}
- (IBAction)btn_search_cancel:(id)sender {
    _view_search.hidden=YES;
    [_tf_srearch resignFirstResponder];
    //_view_main.hidden=NO;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view_main.frame;
        f.origin.y = 52.0f;
        self.view_main.frame = f;
    }];
    
    text_flag=0;
    current_Record=0;
    self.view_filter_shadow.hidden=NO;
    [_tf_srearch resignFirstResponder];
    searchString = self.tf_srearch.text;
    [self loadRecordings];
}
- (IBAction)btn_search:(id)sender {
    _view_search.hidden=NO;
    //_view_main.hidden=NO;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view_main.frame;
        f.origin.y = 89.0f;
        self.view_main.frame = f;
    }];
    recording_typeInt = 2;
_tf_srearch.text=@"";
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
                                        myVC.str_screen_type = @"discover";
                                        myVC.isShare_Audio = YES;
                                        Appdelegate.fromShareScreen = 2;
                                        
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
            if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
            {
                
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
                    
                    [[[arr_rec_response objectAtIndex:sender.tag] mutableCopy] removeObjectForKey:@"like_status"];
                    NSMutableDictionary*dic=[[arr_rec_response objectAtIndex:sender.tag] mutableCopy];
                    [dic setObject:like_val forKey:@"like_status"];
                    
                    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:arr_rec_response];
                    [mutableArray replaceObjectAtIndex:sender.tag withObject:dic];
                    arr_rec_response = mutableArray;
                    
                    [arr_rec_like_status replaceObjectAtIndex:sender.tag withObject:like_val];
                    [_tbl_view_audiodeeds_filter reloadData];
                    
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
    }//try

@catch (NSException *exception) {
    NSLog(@"exception at likes.php :%@",exception);
}
@finally{
    
}
}


#pragma mark - Advertisement API
#pragma mark -

-(void)getAdvertisement
{
    NSMutableDictionary * params = [[NSMutableDictionary alloc]init];
    // [params setObject:KEY_PASSED forKey:@"key"];
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
    NSString* urlString = [NSString stringWithFormat:@"%@advertisement.php",BaseUrl];
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
            NSLog(@"%@", error);
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
                    
                    
                    arr_Advertisement = [[NSArray alloc]init];
                    arr_Advertisement = [jsonResponse valueForKey:@"response"];
                    NSData *imageData= [[NSData alloc]init];
                    NSString *str_imageName;
                    NSMutableArray *ImageArray=[[NSMutableArray alloc]init];
                    for (int i=0; i<[arr_Advertisement count]; i++)
                    {
                        //NSLog(@"Img Name %@",[[arr_Advertisement objectAtIndex:i] objectForKey:@"adv_image"]);
                        str_imageName =[[arr_Advertisement objectAtIndex:i] objectForKey:@"adv_image"];
                       str_imageName =[str_imageName stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                        
                        imageData= [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:str_imageName]];
                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:str_imageName]]];;
                        if (image)
                        {
                            [ImageArray addObject:image];
                        }
                    }
                    NSArray *array = [ImageArray copy];
                    [pageScrollView setScrollViewContents:array];
                    
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

@end
