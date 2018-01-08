//
//  ProfileViewController.m
//  melody
//
//  Created by CodingBrainsMini on 11/21/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import "ProfileViewController.h"
#import "AudioFeedTableViewCell.h"
#import "ActivitiesTableViewCell.h"
#import "menuCollectionViewCell.h"
#import "AudioFeedCommentsViewController.h"
#import "Constant.h"
#import "StudioPlayViewController.h"
#import "chatViewController.h"
#import "MessengerViewController.h"
#import "imageCollectionViewCell.h"

@interface ProfileViewController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSString *artistNameString;
    NSString *searchString;
    NSString *userNameString;
    NSString *filterString;
    UIActivityIndicatorView *activityIndicatorView;
    int recording_typeInt;
    NSString *numberOfInstruments;
    NSString *BPM;
    int text_flag;
    NSMutableArray *instrumentArray;
    NSArray*arr_Actity,*arr_rev;
    NSInteger index;
    NSMutableArray*arr_users_id;
    BOOL loadingData,toggleLike;
    
    UIView *backView,*descriptionView,*descriptionBannerView;
    UILabel *descriptionLabel;
    UITextView *aTextView;
    UIButton *cancelBtn,*sendBtn;
    NSDictionary*dic_response;
    NSDictionary * dic;
    NSTimer* sliderTimer;
    BOOL toggle_PlayPause;
    int counter;

    NSMutableArray *arr_recordingResponseM;
    BOOL isActivityClicked,isProfilePic;
    UIActivityViewController *activityController;
    NSString *current_UserID;
    NSInteger current_Record,limit;


}
@end
BOOL toggleFollow = NO;
long last_Index = 99999999999;
@implementation ProfileViewController


#pragma mark - Initial Method
#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    isActivityClicked = NO;
    isProfilePic = NO;
    [Appdelegate showProgressHud];
    [self initialezesAllVaribles];
    
}



-(void)initialezesAllVaribles{
    arr_recordingResponseM=[[NSMutableArray alloc]init];
    self.btn_follow_unfollow.hidden = YES;
    toggleLike = NO;
    instrumentArray = [[NSMutableArray alloc] init];
    // Add some data for demo purposes.
    [instrumentArray addObject:@"1"];
    [instrumentArray addObject:@"2"];
    [instrumentArray addObject:@"3"];
    [instrumentArray addObject:@"4"];
    [instrumentArray addObject:@"5"];
    arr_users_id = [[NSMutableArray alloc]init];
    self.tf_srearch.delegate=self;
    [self.tf_srearch addTarget:self
                        action:@selector(textFieldDidChange:)
              forControlEvents:UIControlEventEditingChanged];
    
    genre=[[NSString alloc]initWithFormat:@""];
    counter = 1;
    limit = 0;
    recording_typeInt = 0;
    text_flag=0;
    _text_view_description.editable=NO;
    _text_view_description.scrollEnabled=YES;
    genre=[[NSString alloc]initWithFormat:@""];
    defaults_userdata=[NSUserDefaults standardUserDefaults];
    _user_id=[[NSString alloc]initWithFormat:@"%@",[defaults_userdata objectForKey:@"user_id"]];
    
    //check first
    if ([_user_id isEqual:[defaults_userdata objectForKey:@"user_id"]] && ([_follower_id isEqualToString:[defaults_userdata objectForKey:@"user_id"]] || _follower_id == nil)) {
        _btn_follow_unfollow.hidden=YES;
        _btn_chat.hidden=YES;
        
        _btn_editCover.hidden=NO;
        _btn_edit_biotab.hidden=NO;
        _img_editBtn.hidden=NO;
      /*  _img_editProfile.hidden=NO;
        UITapGestureRecognizer *tapImageBtn = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileImageTap:)];
        _img_view_profile.userInteractionEnabled=YES;
        tapImageBtn.numberOfTapsRequired = 1;
        tapImageBtn.view.tag=1001;
        
        tapImageBtn.cancelsTouchesInView = YES;
        [_img_view_profile addGestureRecognizer:tapImageBtn];*/
        
   
    }
    else
    {
        _btn_editCover.hidden=YES;
        _btn_edit_biotab.hidden=YES;
        _img_editBtn.hidden=YES;
        _btn_follow_unfollow.hidden=NO;
        _btn_chat.hidden=NO;
        [self loadUserDetails];
       // _img_editProfile.hidden=YES;
        
    }
    //_btn_editCover.hidden=YES;//
    _img_editProfile.hidden=YES;//
    _lbl_number_of_records.text=[defaults_userdata objectForKey:@"records"];
    _cv_menu.showsHorizontalScrollIndicator=NO;
    [_cv_menu setTag:1];
    /*****************************************************/
    imageData=[[NSData alloc]init];
    imageName=[[NSString alloc]init];
    
    _img_view_profile.layer.cornerRadius = _img_view_profile.frame.size.width / 2;
    _img_view_profile.clipsToBounds = YES;
    _img_view_profile_biotab.layer.cornerRadius = _img_view_profile_biotab.frame.size.width / 2;
    _img_view_profile_biotab.clipsToBounds = YES;
    arr_filter_data_list=[[NSMutableArray alloc]initWithObjects:@"Latest",@"Trending",@"Favorites",@"Artist",@"# of Instrumentals",@"BPM", nil];
    _view_filter.layer.cornerRadius=10;
    _view_filter_shadow.frame=CGRectMake(-800, 0, self.view.frame.size.width, self.view.frame.size.height);
    /***********************Assigning tag number to tableviews***************************/
    status=0;
    _tbl_view_audios.tag=1;
    _tbl_view_filter_data_list.tag=2;
    _tbl_view_activities.tag=3;
    _view_activity.hidden=YES;
    _view_bio_tab.hidden=YES;
    /************************************************************************************/
    
    // UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    UISwipeGestureRecognizer*swipedown=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [swipedown setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:swipedown];
    //  [self.view addGestureRecognizer:tap];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        //Run UI Updates
        [self getActivity];
        [self loadgenres];
        if ([defaults_userdata objectForKey:@"user_id"]) {
            [self loadUserDetails];
            
        }
      
        
    });

    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:@"Description:"];
    [attributeString addAttribute:NSUnderlineStyleAttributeName
                            value:[NSNumber numberWithInt:1]
                            range:(NSRange){0,[attributeString length]}];
    _lbl_description.attributedText=attributeString;
    
    //-----------------* For Pull to refresh *---------------------
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    [_tbl_view_audios addSubview:refreshControl];
    
}

//-----------* Logic for Pull to Refresh *-------------
- (void)refreshTable:(UIRefreshControl *)refreshControl
{
    loadingData=false;
    limit = 0;
    current_Record=0;
    arr_recordingResponseM=[[NSMutableArray alloc] init];
    [self loadRecordings];
    [refreshControl endRefreshing];
}


- (void) profileImageTap:(UITapGestureRecognizer *)gestureRecognizer
{
    NSLog(@"TAP");
    isProfilePic = YES;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    CGFloat margin = 8.0F;
    [cv_images setTag:2];
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(margin, margin, alertController.view.bounds.size.width - margin * 4.0F, 100.0F)];
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    cv_images=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 10, customView.frame.size.width-10, 100) collectionViewLayout:layout];
    cv_images.allowsSelection=YES;
    cv_images.showsHorizontalScrollIndicator=YES;
    [cv_images setDataSource:self];
    [cv_images setDelegate:self];
    [customView addSubview:cv_images];
    [cv_images registerNib:[UINib nibWithNibName:@"imageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [cv_images setBackgroundColor:[UIColor clearColor]];
    [customView addSubview:cv_images];
    
    [alertController.view addSubview:customView];
    
    UIAlertAction *somethingAction = [UIAlertAction actionWithTitle:@"Take Photo or Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self open_camera];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self open_gallery];
        
    }];
    [alertController addAction:camera];
    
    [alertController addAction:somethingAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
    
    [cv_images reloadData];
}

-(void)dismissKeyboard
{
    [_tf_srearch resignFirstResponder];
    [_text_view_description resignFirstResponder];
}


-(void)viewWillAppear:(BOOL)animated{
   // [Appdelegate showProgressHud];
    [sliderTimer invalidate];
    NSLog(@"viewWillAppear");
    [self.btn_chat setHidden:YES];
}


-(void)open_camera
{
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"camera_status"] isEqual:@"1"]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"camera_status"];
    }
    else{
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusAuthorized) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
        }
        else{
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Alert"
                                          message:@"Please allow Camera permisions!"
                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"ok"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            //Handel your yes please button action here
                                            
                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                        }];
            
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    }

}


-(void)open_gallery
{
    if ([Appdelegate hasGalleryPermission]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Alert"
                                      message:@"Please allow gallery permisions!"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        //Handel your yes please button action here
                                        
                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                        
                                    }];
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    if (arr_recordingResponseM == nil || arr_recordingResponseM.count == 0) {
        [self loadRecordings];
    }
}



-(void)viewDidDisappear:(BOOL)animated
{
    [sliderTimer invalidate];
    sliderTimer = nil;
}


- (void)viewDidUnload{
    [super viewDidUnload];
    [audioPlayer stop];
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


#pragma mark - Load Method
#pragma mark -

-(void)loadUserDetails
{
    @try{

    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    if (self.follower_id != nil) {
      NSString * UserID = ([defaults_userdata boolForKey:@"isUserLogged"])?[defaults_userdata valueForKey:@"user_id"] : @"0";
        
        [params setObject:UserID forKey:@"my_id"];
        [params setObject:self.follower_id forKey:@"user_id"];
    }
    else{
        [params setObject:[defaults_userdata valueForKey:@"user_id"] forKey:@"user_id"];
    }
    
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    [params setObject:@"passed" forKey:@"key"];

    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    
    NSString* urlString = [NSString stringWithFormat:@"%@users_bio.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                [Appdelegate hideProgressHudInView];
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
                    
                    if ([[jsonObject valueForKey:@"flag"] isEqual:@"success"]) {
                       [Appdelegate hideProgressHudInView];
                        arr_rec_response=[jsonObject valueForKey:@"result"];
                        NSLog(@"%@",arr_rec_response);
                        dic = [arr_rec_response objectAtIndex:0];
                        _lbl_user_name.text=[NSString stringWithFormat:@"%@ %@",[dic valueForKey:@"fname"],[dic valueForKey:@"lname"]];
                        _lbl_user_tweeter_id.text=[NSString stringWithFormat:@"@%@",[dic valueForKey:@"username"]];
                         current_UserID=[dic valueForKey:@"id"];
                       NSString *ImageURL =[NSString stringWithFormat:@"%@",[dic valueForKey:@"profilepic"]];
                        NSData *imageData_Profile = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
                        
                        _img_view_profile.image = [UIImage imageWithData:imageData_Profile];
                        
                        //--------------------- Set No of Followings ------------------------
                        if ([[dic valueForKey:@"following"] isKindOfClass:[NSString class]]) {
                            _lbl_number_of_followings.text=[dic valueForKey:@"following"];
                        }
                        else
                        {
                            _lbl_number_of_followings.text=@"0";
                        }
                        

                        //--------------------- Set No of Fans ------------------------

                        if ([[dic valueForKey:@"fans"] isKindOfClass:[NSString class]]) {
                            _lbl_number_of_fans.text=[dic valueForKey:@"fans"];
                        }
                        else
                        {
                            _lbl_number_of_fans.text=@"0";
                        }
                        
                        //--------------------- Set Profile profile ------------------------
                        //NSString *ImageURL_Profile = [NSString stringWithFormat:@"%@%@",BaseUrl,[dic valueForKey:@"profilepic"]];
                        NSString *ImageURL_Profile = [NSString stringWithFormat:@"%@",[dic valueForKey:@"profilepic"]];
                        NSURL *url_Profile = [NSURL URLWithString:ImageURL_Profile];
                        [_img_view_profile_biotab sd_setImageWithURL:url_Profile
                                           placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
                        
                        _lbl_number_of_records.text=[NSString stringWithFormat:@"%@",[dic valueForKey:@"records"]];
                        
                        //--------------------- Set Cover profile ------------------------
//                        NSString *ImageURL_cover = [dic valueForKey:@"coverpic"];
                      //  NSString *ImageURL_cover =[NSString stringWithFormat:@"%@%@",BaseUrl,[dic valueForKey:@"coverpic"]];
                        //NSString *ImageURL_cover =[NSString stringWithFormat:@"%@",[dic valueForKey:@"coverpic"]];
                        NSString *ImageURL_cover;
                        //
                        NSString *urlString=[dic valueForKey:@"original_cover"];
                        NSArray *UrlStrArray = [urlString componentsSeparatedByString:@"/"];
                        urlString =[UrlStrArray firstObject];
                        NSLog(@"FIRST WORD %@",urlString);
                        
                        if ([urlString isEqualToString:@"http:"]) {
                            ImageURL_cover=[NSString stringWithFormat:@"%@",[dic valueForKey:@"original_cover"]];
                        }
                        else{
                            ImageURL_cover =[NSString stringWithFormat:@"%@%@",BaseUrl,[dic valueForKey:@"original_cover"]];
                        }
                        
                        NSURL *url = [NSURL URLWithString:ImageURL_cover];
                        _img_view_cover.contentMode = UIViewContentModeScaleToFill;
                        
                        [_img_view_cover sd_setImageWithURL:url
                                                    placeholderImage:[UIImage imageNamed:@"Not_found"]];
                        
                        //follow_status
                        NSString* followStaus = [dic valueForKey:@"follow_status"];
                        long num = [followStaus longLongValue];
                        
                        NSLog(@"user id %@",[defaults_userdata objectForKey:@"user_id"]);
                        //check second
                       if ([_user_id isEqual:[defaults_userdata objectForKey:@"user_id"]] && (([_follower_id isEqualToString:[defaults_userdata objectForKey:@"user_id"]])|| _follower_id == nil)) {
                           
                           self.btn_follow_unfollow.hidden = YES;

                            }
                        else{
                            
                            self.btn_follow_unfollow.hidden = NO;
                            if (num == 1) {
                                [self.btn_follow_unfollow setImage:[UIImage imageNamed:@"following.png"] forState:UIControlStateNormal];
                                self.btn_chat.hidden = NO;
                            }
                            else{
                                self.btn_chat.hidden = YES;
                                [self.btn_follow_unfollow setImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
                            }
                            
                        }
                        
                        _lbl_artist.text=[NSString stringWithFormat:@"%@ %@",[dic valueForKey:@"fname"],[dic valueForKey:@"lname"]];
                        _lbl_station.text=[NSString stringWithFormat:@"@%@",[dic valueForKey:@"username"]];
                        
                        NSString *tempDate =[dic valueForKey:@"registerdate"];
                        if (tempDate == nil || tempDate.length >0) {
                            _lbl_created_date.text=[Appdelegate formatDateWithString:tempDate];
                        }
                        _text_view_description.text=[dic valueForKey:@"discrisption"];
                    }
                    else
                    {
                       [Appdelegate hideProgressHudInView];
                    }
                    
                });
            }
        }];
    [dataTask resume];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at userBio.php %@",exception);
    }
    @finally{
        
    }
        
}




/******************************Calling Genere API*********************************/
-(void)loadgenres
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
                  
                            [_cv_menu reloadData];
                        }
                        else{
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



-(void)loadRecordings
{
    
    @try{
        [Appdelegate showProgressHud];
    self.placeholder_img.hidden = YES;
    self.tbl_view_audios.hidden = NO;
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    [params setObject:[NSString stringWithFormat:@"%ld",(long)limit] forKey:@"limit"];

    if (self.follower_id != [defaults_userdata valueForKey:@"user_id"] && _follower_id != nil) {
        // OTHERS PROFILE
        [params setObject:self.follower_id forKey:@"ownersUserId"];
        [params setObject:@"onUserProfile" forKey:@"key"];
        [params setObject:[defaults_userdata valueForKey:@"user_id"] forKey:KEY_USER_ID];
    }
    else{
        // SELF PROFILE
        if([defaults_userdata boolForKey:@"isUserLogged"]) {
        [params setObject:[defaults_userdata valueForKey:@"user_id"] forKey:KEY_USER_ID];
            [params setObject:@"Myrecording" forKey:@"key"];

        }
    }
    if ([genre isEqualToString:@""]){
        genre = @"0";
    }
    
    if (recording_typeInt == Filter)
    {
        [params setObject:@"extrafilter" forKey:@"filter"];
        [params setObject:@"user_recording" forKey:KEY_SHARE_FILETYPE];
        [params setObject:filterString forKey:@"filter_type"];
//        [params removeObjectForKey:@"genere"];
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
        
    }
    else if(recording_typeInt == Station_list){
        [params removeObjectForKey:@"artistname"];
        [params removeObjectForKey:@"search"];
        [params setObject:genre forKey:@"genere"];
        
    }
    NSLog(@"recording .php %@",params);
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
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            [Appdelegate hideProgressHudInView];
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
                [self presentViewController:alert animated:YES completion:nil];                                                 }
                                                    
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *myError = nil;
                NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSLog(@"%@",requestReply);
                NSData *data2=[requestReply dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                id jsonObject = [NSJSONSerialization
                                 
                                 JSONObjectWithData:data2
                                 options:NSJSONReadingAllowFragments error:&myError];
                // NSLog(@"%@",jsonObject);
                if ([[jsonObject valueForKey:@"flag"] isEqual:@"success"]) {
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
                    followerID=[[NSMutableArray alloc]init];
                    arr_rec_recordings=[[NSMutableArray alloc]init];
                    arr_rec_recordings_url=[[NSMutableArray alloc]init];
                    
                    NSArray *tempArrayM = [[NSArray alloc]init];
                    tempArrayM = [jsonObject valueForKey:@"response"];
                    [arr_recordingResponseM addObjectsFromArray:tempArrayM];
                    current_Record = arr_recordingResponseM.count;
                    NSLog(@"%@",arr_recordingResponseM);
                    loadingData = true;
                    
                    for (int i=0; i<[arr_recordingResponseM count]; i++)
                    {
                        NSLog(@"%@",[arr_recordingResponseM objectAtIndex:i]);
                        if([[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"recording_id"] isEqual:[NSNull null]] || [[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"recording_id"] length]==0)
                        {
                            [arr_rec_pack_id addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_pack_id addObject:[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"recording_id"]];
                        }
                        
                        if([[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"genre"] isEqual:[NSNull null]] || [[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"genre"] length]==0)
                        {
                            [arr_rec_genre addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_genre addObject:[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"genre"]];
                        }
                        if([[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"recording_topic"] isEqual:[NSNull null]] || [[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"recording_topic"] length]==0)
                        {
                            [arr_rec_name addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_name addObject:[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"recording_topic"]];
                        }
                        if([[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"user_name"] isEqual:[NSNull null]] || [[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"user_name"] length]==0)
                        {
                            [arr_rec_station addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_station addObject:[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"user_name"]];
                        }
                        
                        if([[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"cover_url"] isEqual:[NSNull null]] || [[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"cover_url"] length]==0)
                        {
                            [arr_rec_cover addObject:@"http://"];
                            
                        }
                        else
                        {
                            [arr_rec_cover addObject:[NSString stringWithFormat:@"%@",[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"cover_url"]]];
                            
                        }
                        if([[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"recordings"] isEqual:[NSNull null]] || [[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"recordings"] count]==0)
                        {
                            [arr_rec_duration addObject:@""];
                        }
                        else
                        {
                            
                              [arr_rec_duration addObject:[NSString stringWithFormat:@"%@",[[[[arr_recordingResponseM objectAtIndex:i] objectForKey:@"recordings"] objectAtIndex:0] objectForKey:@"duration"]]];
                        }
                        if([[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"added_by"] isEqual:[NSNull null]] || [[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"added_by"] length]==0)
                        {
                            [followerID addObject:@"0"];
                        }
                        else
                        {
                            [followerID addObject:[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"added_by"]];
                        }
                        
                        if([[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"recordings"] isEqual:[NSNull null]])
                        {
                            [arr_rec_recordings addObject:@""];
                            [arr_rec_recordings_url addObject:@""];
                            
                        }
                        else
                        {
                            
                            [arr_rec_recordings addObject:[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"recording_url"]];
                            NSString *stringUrl = [arr_rec_recordings objectAtIndex:i];
                            [arr_rec_recordings_url addObject:stringUrl];
                            
                        }
                        
                        if([[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"profile_url"] isEqual:[NSNull null]] || [[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"profile_url"] length]==0)
                        {
                            [arr_rec_profile addObject:@"http://"];
                        }
                        else
                        {
                            [arr_rec_profile addObject:[NSString stringWithFormat:@"%@",[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"profile_url"]]];
                        }
                        
                        if([[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"recordings"] isEqual:[NSNull null]])
                        {
                            [arr_rec_intrumentals addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_intrumentals addObject:[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"recordings"]];
                        }
                        if([[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"date_added"] isEqual:[NSNull null]] || [[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"date_added"] length]==0)
                        {
                            [arr_rec_post_date addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_post_date addObject:[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"date_added"] ];
                        }
                        
                        if([[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"play_count"] isEqual:[NSNull null]] || [[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"play_count"] length]==0)
                        {
                            [arr_rec_play_count addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_play_count addObject:[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"play_count"] ];
                        }
                        
                        if([[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"like_count"] isEqual:[NSNull null]] || [[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"like_count"] length]==0)
                        {
                            [arr_rec_like_count addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_like_count addObject:[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"like_count"] ];
                        }
                        
                        if([[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"comment_count"] isEqual:[NSNull null]] || [[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"comment_count"] length]==0)
                        {
                            [arr_rec_comment_count addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_comment_count addObject:[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"comment_count"] ];
                        }
                        if([[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"share_count"] isEqual:[NSNull null]] || [[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"share_count"] length]==0)
                        {
                            [arr_rec_share_count addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_share_count addObject:[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"share_count"] ];
                        }
                        if([[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"like_status"] isEqual:[NSNull null]] )
                        {
                            [arr_rec_like_status addObject:@"0"];
                        }
                        else
                        {
                            [arr_rec_like_status addObject:[[arr_recordingResponseM objectAtIndex:i] valueForKey:@"like_status"] ];
                        }
                        
                    }
                    [_tbl_view_audios reloadData];
//                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//
//                    [_tbl_view_audios scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    
                }
                else
                {
                    [Appdelegate hideProgressHudInView];
                    if (!loadingData) {
                        
                        self.placeholder_img.hidden = NO;
                        _tbl_view_audios.hidden = YES;
                        self.placeholder_img.image = [UIImage imageNamed:@"NoResult_img"];
                        arr_rec_pack_id=[[NSMutableArray alloc]init];
                    }
                    else{
                        self.placeholder_img.hidden = NO;
                        _tbl_view_audios.hidden = YES;
                        self.placeholder_img.image = [UIImage imageNamed:@"NoResult_img"];                    }
                }
                
            });
        }
        }];
    [dataTask resume];

    }
    @catch (NSException *exception) {
        NSLog(@"exception at recording.php :%@",exception);
        [Appdelegate hideProgressHudInView];
    }
    @finally{
        
    }
        
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)profileClicked:(UIButton*)sender{
    NSLog(@"profileClicked");
    ProfileViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    NSString *currentUserID;
    if (self.follower_id != nil) {
        currentUserID = self.follower_id;
    }
    else{
        currentUserID = [defaults_userdata valueForKey:@"user_id"];
    }
    
    profileVC.follower_id = currentUserID;
    NSString * userId = [defaults_userdata objectForKey:@"user_id"];
    profileVC.user_id = userId;
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
                                                           arr_recordingResponseM=[[NSMutableArray alloc] init];
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
    [self performSegueWithIdentifier:@"profile_to_studio_play" sender:self];
}


- (void)btn_Recordings_comment_clicked:(UIButton*)sender
{
    _sender_tag=[NSString stringWithFormat:@"%ld",(long)sender.tag];
    id lc=[arr_rec_like_count objectAtIndex:[_sender_tag integerValue]];
    id ls=[arr_rec_like_status objectAtIndex:[_sender_tag integerValue]];
    NSMutableDictionary*dic=[NSMutableDictionary dictionaryWithDictionary:[arr_recordingResponseM objectAtIndex:[_sender_tag integerValue]]];
    [dic  setObject:lc forKey:@"like_count"];
    [dic setObject:ls forKey:@"like_status"];
    NSMutableArray*arr=[NSMutableArray arrayWithArray:arr_recordingResponseM];
    [arr replaceObjectAtIndex:[_sender_tag integerValue] withObject:dic];
    arr_rec_response=arr;
    
    [self performSegueWithIdentifier:@"go_to_recording_comments" sender:self];
}


- (void)show_options:(UIButton*)sender
{
    //AudioFeedTableViewCell *cell = (ActivitiesTableViewCell*)[nib2 objectAtIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    AudioFeedTableViewCell *cell = (AudioFeedTableViewCell*)[_tbl_view_audios cellForRowAtIndexPath:indexPath];
    
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
    [_tbl_view_audios reloadData];
}

#pragma mark - Tab Method
#pragma mark -
- (IBAction)btn_audio_tab:(id)sender {
    isActivityClicked = NO;

    _btn_filter.hidden=NO;
    _btn_search.hidden=NO;
    _view_audio.hidden=NO;
    _view_activity.hidden=YES;
    _view_bio_tab.hidden=YES;
    _view_audio.userInteractionEnabled=YES;
    _view_bio_tab.userInteractionEnabled=NO;
    _view_activity.userInteractionEnabled=NO;
    [self.btn_audio_tab setBackgroundColor:[UIColor whiteColor]];
    [self.btn_activity_tab setBackgroundColor:[UIColor clearColor]];
    [self.btn_bio_tab setBackgroundColor:[UIColor clearColor]];
    _btn_audio_tab.titleLabel.font = [UIFont fontWithName:@"Helvetica Bold"  size:15.0f];
    _btn_activity_tab.titleLabel.font = [UIFont fontWithName:@"Helvetica Medium"  size:15.0f];
    _btn_bio_tab.titleLabel.font = [UIFont fontWithName:@"Helvetica Medium"  size:15.0f];
    
}

- (IBAction)btn_activity_tab:(id)sender {
    isActivityClicked = YES;

    _tbl_view_audios.hidden = YES;
    _tbl_view_audios.hidden= NO;
    _btn_filter.hidden=YES;
    _btn_search.hidden=NO;
    _view_audio.hidden=YES;
    _view_bio_tab.hidden=YES;
    _view_activity.hidden=NO;
    _view_activity.userInteractionEnabled=YES;
    _view_audio.userInteractionEnabled=NO;
    _view_bio_tab.userInteractionEnabled=NO;
    [self.btn_activity_tab setBackgroundColor:[UIColor whiteColor]];
    [self.btn_audio_tab setBackgroundColor:[UIColor clearColor]];
    [self.btn_bio_tab setBackgroundColor:[UIColor clearColor]];
    _btn_audio_tab.titleLabel.font = [UIFont fontWithName:@"Helvetica Medium"  size:15.0f];
    _btn_bio_tab.titleLabel.font = [UIFont fontWithName:@"Helvetica Medium"  size:15.0f];
    _btn_activity_tab.titleLabel.font = [UIFont fontWithName:@"Helvetica Bold"  size:15.0f];
    
    [_tbl_view_activities reloadData];

    
}

- (IBAction)btn_bio_tab:(id)sender {
    _btn_filter.hidden=YES;
    _btn_search.hidden=YES;
    _view_audio.hidden=YES;
    _view_activity.hidden=YES;
    _view_bio_tab.hidden=NO;
    _view_activity.userInteractionEnabled=NO;
    _view_audio.userInteractionEnabled=NO;
    _view_bio_tab.userInteractionEnabled=YES;
    [self.btn_bio_tab setBackgroundColor:[UIColor whiteColor]];
    [self.btn_audio_tab setBackgroundColor:[UIColor clearColor]];
     [self.btn_activity_tab setBackgroundColor:[UIColor clearColor]];
    _btn_audio_tab.titleLabel.font = [UIFont fontWithName:@"Helvetica Medium"  size:15.0f];
    _btn_activity_tab.titleLabel.font = [UIFont fontWithName:@"Helvetica Medium"  size:15.0f];
    _btn_bio_tab.titleLabel.font = [UIFont fontWithName:@"Helvetica Bold"  size:15.0f];

}

- (IBAction)btn_filter:(id)sender {
    _view_filter_shadow.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.tbl_view_filter_data_list.hidden = NO;
    self.view_filter_shadow.hidden = NO;
    recording_typeInt = 1;
}

- (IBAction)btn_search:(id)sender {
    _view_search.hidden=NO;
    arr_recordingResponseM=[[NSMutableArray alloc]init];
    _view_main_menu.hidden=YES;
    recording_typeInt = 2;
    _tf_srearch.text=@"";

}
- (IBAction)btn_search_cancel:(id)sender {
    [_tf_srearch resignFirstResponder];
    [_text_view_description resignFirstResponder];
    _view_search.hidden=YES;
    _view_main_menu.hidden=NO;
    text_flag = 0;
    current_Record= 0;
    [_tf_srearch resignFirstResponder];
    searchString = self.tf_srearch.text;
    if (isActivityClicked) {
        [self getActivity];
    }
    else{
        [self loadRecordings];
    }

}
- (IBAction)btn_all_tab:(id)sender {
}

- (IBAction)btn_hiphop_tab:(id)sender {
}

- (IBAction)btn_pop_tab:(id)sender {
}

- (IBAction)btn_rock_tab:(id)sender {
}


- (IBAction)btn_raggae_tab:(id)sender {
}

- (IBAction)btn_edm_tab:(id)sender {
}


- (IBAction)btn_edit_description:(id)sender {
    
    CGRect frame = CGRectMake(self.view.frame.origin.x+10, self.view.frame.origin.y+64, self.view.frame.size.width-20, self.view.frame.size.height/2.5);
    backView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:backView];
    descriptionView = [[UIView alloc] initWithFrame:frame];
    descriptionView.backgroundColor =[UIColor whiteColor];
    descriptionView.layer.cornerRadius = 4.0f;
    [self.view addSubview:descriptionView];
    
    descriptionBannerView=[[UIView alloc] initWithFrame:CGRectMake(2, 2, descriptionView.frame.size.width-4, 40)];
    descriptionBannerView.backgroundColor = [UIColor blueColor];
    descriptionLabel = [[UILabel alloc] initWithFrame:descriptionBannerView.frame];
    descriptionLabel.text = @"Update your description";
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    [descriptionBannerView addSubview:descriptionLabel];
    [descriptionView  addSubview:descriptionBannerView];
    aTextView = [[UITextView alloc] initWithFrame: CGRectMake(2, 42, descriptionView.frame.size.width-4, descriptionView.frame.size.height/1.7)];
    
   // aTextView.text =[dic objectForKey:@"discrisption"];
    [aTextView becomeFirstResponder];
    aTextView.delegate=self;
    aTextView.backgroundColor=[UIColor whiteColor];
    cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(2, aTextView.frame.origin.y+aTextView.frame.size.height+10, (aTextView.frame.size.width-10)/2, 40)];
    sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(cancelBtn.frame.origin.x+cancelBtn.frame.size.width+10, aTextView.frame.origin.y+aTextView.frame.size.height+10, (aTextView.frame.size.width-10)/2, 40)];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [sendBtn setTitle:@"Update" forState:UIControlStateNormal];
    cancelBtn.backgroundColor = [UIColor blueColor];
    sendBtn.backgroundColor = [UIColor blueColor];
    [descriptionView  addSubview:aTextView];
    [descriptionView  addSubview:cancelBtn];
    [descriptionView  addSubview:sendBtn];
    [cancelBtn addTarget:self action:@selector(cancelDescriptionView) forControlEvents:UIControlEventTouchUpInside];
    [sendBtn addTarget:self action:@selector(sendDescriptionBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
//    [self performSegueWithIdentifier:@"go_to_account_screen" sender:self];
}


-(void)cancelDescriptionView
{
    //  NSLog(@"Cancel");
    [self removeDescriptionView];
    
}
-(void)sendDescriptionBtnClicked
{
    // NSLog(@"send");
    if ([aTextView.text isEqualToString:@""])
    {
    }
    else
    {
        [self sendDescriptionData];
    }
    
    
}
-(void)removeDescriptionView
{
    [backView removeFromSuperview];
    [descriptionView removeFromSuperview];
}
-(void)sendDescriptionData
{
    NSMutableDictionary * params = [[NSMutableDictionary alloc]init];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    if([defaults_userdata boolForKey:@"isUserLogged"]) {
        [params setObject:[defaults_userdata objectForKey:@"user_id"] forKey:@"user_id"];
    }
    
    [params setObject:aTextView.text forKey:@"description"];
    
    NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@description.php",BaseUrl];
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
                
                
                NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSLog(@"%@",requestReply);
                
                NSData *data = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:kNilOptions
                                                                               error:&myError];
                NSLog(@"%@",jsonResponse);
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    
                    dic_response = [jsonResponse objectForKey:@"response"];
                    [self removeDescriptionView];
                    NSLog(@"DESc %@",dic_response);
                    NSLog(@"data %@",[dic_response objectForKey:@"description"]);
                    _text_view_description.text=[dic_response objectForKey:@"description"];
                    NSDictionary *tempDict=[[NSDictionary alloc]init];
                    tempDict = [dic mutableCopy];
                    [tempDict setValue:[dic_response objectForKey:@"description"] forKey:@"discrisption"];
                    dic = tempDict;
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




- (IBAction)btn_edit_cover:(id)sender {
    
    isProfilePic = NO;
    if ([[defaults_userdata stringForKey:@"rememberme"] isEqual:@"remember"]) {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
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



- (IBAction)btn_filter_shadow_cancel:(id)sender {
    recording_typeInt=0;
    _view_filter_shadow.frame=CGRectMake(-500, 0, self.view.frame.size.width, self.view.frame.size.height);
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
                                        myVC.str_screen_type = @"profile";
                                        myVC.isShare_Audio = YES;
                                        Appdelegate.fromShareScreen = 1;

                                        [self presentViewController:myVC animated:YES completion:nil];
                                        //Handel your yes please button action here
                                    }];
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"No"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       //Handel your yes please button action here
                                       NSArray *activityItems = @[@"Hi ! this is AMAN"];
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




-(void)upload_cover{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@uploadfile.php",BaseUrl] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData
                                    name:@"file1"
                                fileName:imageName mimeType:@"multipart/form-data"];
        [formData appendPartWithFormData:[[defaults_userdata stringForKey:@"user_id"] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"user_id"];
        NSString *strType;
        strType = (isProfilePic)?@"1":@"2";
        [formData appendPartWithFormData:[strType dataUsingEncoding:NSUTF8StringEncoding]
                                    name:KEY_SHARE_FILETYPE];
        [formData appendPartWithFormData:[KEY_AUTH_VALUE dataUsingEncoding:NSUTF8StringEncoding]
                                    name:KEY_AUTH_KEY];
        // etc.
        NSLog(@"%@",[defaults_userdata stringForKey:@"user_id"]);
        
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        NSLog(@"Response: %@", [responseObject objectForKey:@"flag"]);
        if ([[responseObject objectForKey:@"flag"] isEqualToString:@"success"]) {
            [Appdelegate hideProgressHudInView];
            if (isProfilePic) {
                [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"response"] objectForKey:@"profilepic"]]]] forKey:@"profile_pic"];
                [defaults_userdata synchronize];
            }
            else{
                [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"response"] objectForKey:@"profilepic"]]]] forKey:@"cover_pic"];
                [defaults_userdata synchronize];
            }
            NSString * strInfo;
            strInfo = (isProfilePic)?@"Profile pic uploaded successfully !":@"Cover pic uploaded successfully !";
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Message"
                                          message:strInfo
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
        else if ([[responseObject objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
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
        [Appdelegate hideProgressHudInView];

        NSLog(@"Error: %@", error);
    }];
    
}



-(void)like:(UIButton *)sender{
    
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
            //[self presentViewController:alert animated:YES completion:nil];
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
                    
//                    [[[arr_rec_response objectAtIndex:sender.tag] mutableCopy] removeObjectForKey:@"like_status"];
                    NSMutableDictionary*dic=[[arr_recordingResponseM objectAtIndex:sender.tag] mutableCopy];
                    [dic setObject:like_val forKey:@"like_status"];
                    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:arr_recordingResponseM];
                    [mutableArray replaceObjectAtIndex:sender.tag withObject:dic];
                    arr_recordingResponseM = mutableArray;
                    
                    [arr_rec_like_status replaceObjectAtIndex:sender.tag withObject:like_val];
                    
                    //---------------------- Get IndexPath ---------------------
                    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tbl_view_audios];
                    NSIndexPath *indexPath = [_tbl_view_audios indexPathForRowAtPoint:buttonPosition];
                    //------------------ Reload TableView Cell -----------------
                    if(indexPath != nil)
                    {
                        [_tbl_view_audios beginUpdates];
                        [_tbl_view_audios reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [_tbl_view_audios endUpdates];
                        [self getActivity];
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
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php%@",exception);
    }
    @finally{
        
    }
}




-(void)btn_Recordings_like_clicked:(UIButton*)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    AudioFeedTableViewCell *cell = (AudioFeedTableViewCell*)[_tbl_view_audios cellForRowAtIndexPath:indexPath];
    
    if (toggleLike)
        {
            toggleLike = !toggleLike;
            [cell.btn_like setBackgroundImage:[UIImage imageNamed:@"btn_hand_fill.png"] forState:UIControlStateNormal];
        }
        else{
            toggleLike = !toggleLike;
            [cell.btn_like setBackgroundImage:[UIImage imageNamed:@"btn_hand_outline.png"] forState:UIControlStateNormal];
        }
   
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        [self like:sender];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
        });
    });
        
}
- (IBAction)btn_chat:(id)sender {
    
    [arr_users_id addObject:self.follower_id];
    
    chatViewController *chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"chatViewController"];
    NSString *chat_id = [NSString stringWithFormat:@"%@",[[arr_rec_response objectAtIndex:0]valueForKey:@"chat_id"]];
    NSString *reviever_id = [[arr_rec_response objectAtIndex:0]valueForKey:@"id"];
    chatVC.str_receiver_id = reviever_id;
    chatVC.str_chat_id = chat_id;
    chatVC.str_receiver_name = [[arr_rec_response objectAtIndex:0]valueForKey:@"username"];
    
    [self presentViewController:chatVC animated:YES completion:nil];
    
}


- (IBAction)btn_follow_unfollow:(id)sender {
    toggleFollow = !toggleFollow;
    if (toggleFollow) {
    [self.btn_follow_unfollow setImage:[UIImage imageNamed:@"following.png"] forState:UIControlStateNormal];
    }
    else{

        [self.btn_follow_unfollow setImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    }
    NSDictionary* params = @{
                             KEY_AUTH_KEY:KEY_AUTH_VALUE,
                             @"user_id":_follower_id,
                             @"followerID":_user_id
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
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    [defaults_userdata setBool:YES forKey:@"isfollow"];

                    dic_response=[jsonResponse objectForKey:@"response"];
                    NSLog(@"%@",[dic_response objectForKey:@"follow_status"]);
                    if ([[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"follow_status"]] isEqual:@"1"]) {
                        self.btn_chat.hidden = NO;
                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"follow_count"]] forKey:@"followers" ];
                        [_btn_follow_unfollow setImage:[UIImage imageNamed:@"following.png"] forState:UIControlStateNormal];
                    }
                    else
                    {
                        [defaults_userdata setBool:NO forKey:@"isfollow"];
                        self.btn_chat.hidden = YES;

                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"follow_count"]] forKey:@"followers" ];
                        [_btn_follow_unfollow setImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
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



#pragma Avtivity API

-(void)getActivity
{
    
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
                    arr_Actity = [[NSArray alloc]init];
                    arr_rev = [[NSArray alloc]init];
                    arr_rev = [jsonResponse valueForKey:@"response"];
                    //arr_Actity = [[arr_rev reverseObjectEnumerator] allObjects];
                    arr_Actity=[jsonResponse valueForKey:@"response"];
                    [_tbl_view_activities reloadData];
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



#pragma mark - Collection Delegates & Datasource
#pragma mark -
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView.tag ==1) {
        return CGSizeMake(65,self.cv_menu.frame.size.height);
    }
    else{
        UIImage *image = [Appdelegate.arr_Gallery_Items objectAtIndex:indexPath.item];
        float oldheight = image.size.height;
        float scaleFactor =cv_images.frame.size.height/ oldheight;
        float newwidth = image.size.width * scaleFactor;
        return CGSizeMake(newwidth, cv_images.frame.size.height);
    }
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView.tag ==1) {
        return [arr_menu_items count];
    }
    else{
        return Appdelegate.arr_Gallery_Items.count;
    }
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (collectionView.tag ==1) {
    menuCollectionViewCell *cell = (menuCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.lbl_menu_title.adjustsFontSizeToFitWidth=YES;
    
    if ([[arr_tab_select objectAtIndex:indexPath.item] isEqual:@"1"]) {
        cell.img_menu.image = [UIImage imageNamed:@"underline.png"];
        cell.lbl_menu_title.text=[arr_menu_items objectAtIndex:indexPath.row];
    }
    else
    {
        cell.lbl_menu_title.text=[arr_menu_items objectAtIndex:indexPath.row];
        
        cell.img_menu.image = [UIImage imageNamed:@"white.png"];
        
    }

        return cell;

    }
    else {
        imageCollectionViewCell *cell = (imageCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        
        cell.img_view.image = [Appdelegate.arr_Gallery_Items objectAtIndex:indexPath.item];
        cell.backgroundColor=[UIColor greenColor];
        return cell;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    @try{
    limit = 0;
    current_Record = 0;
    arr_recordingResponseM=[[NSMutableArray alloc]init];

    if (collectionView.tag ==1) {
    current_Record = 0;
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
    recording_typeInt=0;
    [self loadRecordings];
    [_cv_menu reloadData];
    }
    else{
        
        imageData=UIImagePNGRepresentation([Appdelegate.arr_Gallery_Items objectAtIndex:indexPath.item]);
        [_img_view_profile setImage:[Appdelegate.arr_Gallery_Items objectAtIndex:indexPath.item]];
        imageName=@"image.png";
        dp_view.hidden=YES;
        
    }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}


-(BOOL)collectionView:(UICollectionView* )collectionView shouldSelectItemAtIndexPath:(NSIndexPath* )indexPath
{
    NSLog(@"this is caled");
    return YES;
}


#pragma mark - TableView Delegates & Datasource
#pragma mark -
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==1) {
        return [arr_rec_pack_id count];
    }
    else if (tableView.tag==2) {
        return [arr_filter_data_list count];
    }
    else if (tableView.tag==3) {
        return arr_Actity.count;
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
    else if (tableView.tag==3) {
        return 85;
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
    else if (tableView.tag==3) {
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
            [cell.btn_Profile setTag:indexPath.row];
            cell.btn_Profile.layer.cornerRadius = cell.btn_Profile.frame.size.width / 2;
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
            
            [cell.btn_PlayRecording setTag:indexPath.row];
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

            [cell.btn_play_value setTitle:[NSString stringWithFormat:@"%@",[arr_rec_play_count objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
        if (arr_recordingResponseM != nil || arr_recordingResponseM.count > 0) {
            long includeL =[[[arr_recordingResponseM objectAtIndex:indexPath.row] valueForKey:@"join_count"]longValue];
            cell.lbl_included.text = [NSString stringWithFormat:@"Include : %ld",includeL];
            cell.lbl_oneof.text = [NSString stringWithFormat:@"( 1 of %ld )",includeL];
        }
        
        
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
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
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
    else if (tableView.tag==3) {
        ActivitiesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Activity"];
        
        if (cell == nil)
            
        {
            NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"ActivitiesTableViewCell"
                             
                                                          owner:self options:nil];
            cell.accessoryType = UITableViewCellStyleDefault;
            
            cell = (ActivitiesTableViewCell*)[nib2 objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.img_view_profileimage.layer.cornerRadius = cell.img_view_profileimage.frame.size.width / 2;
            cell.img_view_profileimage.clipsToBounds = YES;
            
            NSString *str_topic = [[arr_Actity objectAtIndex:indexPath.row] valueForKey:@"topic"];
            
            if ([str_topic isEqualToString:@""]) {
                cell.lbl_topic.text = @"";
            }
            else{
                cell.lbl_topic.text = str_topic;
            }
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
                str_activityName = @"N/A";
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
                NSDictionary *boldAttrib = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12]};
                NSDictionary *nonBoldAttrib = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
                
                [attributedText setAttributes:boldAttrib range:secondUserRange];
                [attributedText setAttributes:nonBoldAttrib range:activityRange];
                [attributedText setAttributes:boldAttrib range:firstUserRange];
                [cell.lbl_activity setAttributedText:attributedText];
            }
            /////==========NEW CODE FOR PROFILE NAVIGATION
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
            cell.img_view_profileimage.userInteractionEnabled=YES;
            tap.numberOfTapsRequired = 1;
            tap.view.tag=indexPath.row;
            cell.img_view_profileimage.tag = indexPath.row;
            tap.cancelsTouchesInView = YES;
            [cell.img_view_profileimage addGestureRecognizer:tap];
            if ([[arr_Actity objectAtIndex:indexPath.row] valueForKey:@"profile_pick"] != [NSNull null]) {
                //------------- Cover pic -----------------
                NSURL *url2 = [NSURL URLWithString:[[arr_Actity objectAtIndex:indexPath.row] valueForKey:@"profile_pick"]];
                cell.img_view_profileimage.contentMode = UIViewContentModeScaleToFill;
                
                [cell.img_view_profileimage sd_setImageWithURL:url2
                                            placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            }
            
            return cell;
        }
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
            arr_recordingResponseM=[[NSMutableArray alloc] init];
            [self loadRecordings];
            
        }
    }

    
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ((loadingData) && (indexPath.row == current_Record - 1) && ((current_Record % 10) == 0))
    {
        limit = arr_recordingResponseM.count;
        counter= counter+1;
        [self loadRecordings];
    }
}

- (void) handleImageTap:(UITapGestureRecognizer *)gestureRecognizer
{
    NSLog(@"imaged tab");
    CGPoint tapLocation = [gestureRecognizer locationInView:_tbl_view_activities];
    NSIndexPath *iPath = [_tbl_view_activities indexPathForRowAtPoint:tapLocation];
    NSLog(@"FINAL TAG VALUE %ld",(long)iPath.row);
    ProfileViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
     NSLog(@"usr id %@",[defaults_userdata objectForKey:@"user_id"]);
     NSLog(@"othr user id %@",[[arr_Actity objectAtIndex:iPath.row]valueForKey:@"created_by_userID"]);
     if ([defaults_userdata objectForKey:@"user_id"] == current_UserID)
     {
     if ([[arr_Actity objectAtIndex:iPath.row]valueForKey:@"created_by_userID"]==[defaults_userdata objectForKey:@"user_id"])
     {
     //...
     }
     else
     {
     myVC.follower_id = [[arr_Actity objectAtIndex:iPath.row]valueForKey:@"created_by_userID"];
     [self presentViewController:myVC animated:YES completion:nil];
     }
     }
     else
     {
     if ([[arr_Actity objectAtIndex:iPath.row]valueForKey:@"created_by_userID"]==current_UserID)
     {
     //...
     }
     else
     {
     myVC.follower_id = [[arr_Actity objectAtIndex:iPath.row]valueForKey:@"created_by_userID"];
     [self presentViewController:myVC animated:YES completion:nil];
     }
     
     }
    
}
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info
{
    if (isProfilePic) {
    _img_view_profile.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    else{
    _img_view_cover.image=[info objectForKey:UIImagePickerControllerOriginalImage];

    }
    [self dismissModalViewControllerAnimated:YES];
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    NSString *extension = [imageURL pathExtension];
    CFStringRef imageUTI = (UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(__bridge CFStringRef)extension , NULL));
    
    if (UTTypeConformsTo(imageUTI, kUTTypeJPEG))
    {
        // Handle JPG
        imageData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage],0.0f);
        
    }
    else if (UTTypeConformsTo(imageUTI, kUTTypePNG))
    {
        // Handle PNG
        imageData = UIImagePNGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage]);
    }
    else
    {
        NSLog(@"file format not vailid !");
    }
    
    imageName = [imageURL lastPathComponent];
    NSLog(@"%@",imageName);
    if (imageData) {
        NSString * strInfo;
        strInfo = (isProfilePic)?@"Proceed to upload profile pic":@"Proceed to upload cover pic";
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Confirmation"
                                      message:strInfo
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
                                           //Handel your yes please button action here
                                           
                                       }];
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        if (isProfilePic) {
                                            _img_view_profile.image = [UIImage imageWithData:imageData];
                                        }
                                        else{
                                        _img_view_cover.image=[UIImage imageWithData:imageData];
                                            
                                        }
                                        //Handel your yes please button action here
                                        [self upload_cover];
                                        
                                    }];
        
        [alert addAction:cancelButton];
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
  
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
        vc.dic_data=[arr_recordingResponseM objectAtIndex:[_sender_tag integerValue]];
    }
    
    if ([segue.identifier isEqual:@"profile_to_studio_play"]) {
        StudioPlayViewController*vc=segue.destinationViewController;
        vc.str_CurrernUserId = [followerID objectAtIndex:index];
        vc.str_RecordingId = [arr_rec_pack_id objectAtIndex:index];
        vc.arr_recordings=[arr_rec_recordings objectAtIndex:index];
    }
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
#pragma mark - Audio Player Delegate Method
#pragma mark -

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    AudioFeedTableViewCell *cell = [self.tbl_view_audios cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
    audioPlayer = nil;
    //    if([defaults_userdata boolForKey:@"isUserLogged"]) {
    toggle_PlayPause= YES;
    //    }
    cell.slider_progress.value=0.0;
    audioPlayer = nil;
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
                    [self.tbl_view_audios reloadData];
                    
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

#pragma mark - Play Method

- (void)btn_Recordings_Play_clicked:(UIButton* )sender {
    
    @try{
        instrument_play_index = sender.tag;
        AudioFeedTableViewCell *cell = [_tbl_view_audios cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
        if (audioPlayer) {
       
            if(last_Index == sender.tag && toggle_PlayPause) {
            toggle_PlayPause = !toggle_PlayPause;
            [audioPlayer play];
            [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
            }
            else {
            toggle_PlayPause = !toggle_PlayPause;
            [audioPlayer pause];
            [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
            }
            
        }
        else{
            
            [Appdelegate showProgressHud];

            dispatch_queue_t myqueue = dispatch_queue_create("queue", NULL);
            dispatch_async(myqueue, ^{
            if(audioPlayer){
                [audioPlayer stop];
                audioPlayer = nil;
            }
            //        toggle_PlayPause = !toggle_PlayPause;
            NSString *urlstr =[arr_rec_recordings_url objectAtIndex:instrument_play_index];
            urlstr = [urlstr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
            
            NSURL *urlforPlay = [NSURL URLWithString:urlstr];
            NSData *data = [NSData dataWithContentsOfURL:urlforPlay];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self method_PlayCount:instrument_play_index];

            NSError*error=nil;
            audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
            
            [audioPlayer setDelegate:self];
            [audioPlayer prepareToPlay];
            if ([audioPlayer prepareToPlay] == YES){
                
                if (last_Index != 10000) {
                    AudioFeedTableViewCell *cell1 = [_tbl_view_audios cellForRowAtIndexPath:[NSIndexPath indexPathForRow:last_Index inSection:0]];
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
                AudioFeedTableViewCell *cell1 = [_tbl_view_audios cellForRowAtIndexPath:[NSIndexPath indexPathForRow:last_Index inSection:0]];
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
        last_Index = sender.tag;
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}


-(void)timerupdateSlider{
    // Update the slider about the music time
    
    AudioFeedTableViewCell *cell = [_tbl_view_audios cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    cell.slider_progress.value = audioPlayer.currentTime;
}


-(void)sliderChanged{
    // Fast skip the music when user scroll the UISlider
    AudioFeedTableViewCell *cell = [_tbl_view_audios cellForRowAtIndexPath:[NSIndexPath indexPathForRow:instrument_play_index inSection:0]];
    [audioPlayer setCurrentTime:cell.slider_progress.value];
    [cell.btn_PlayRecording setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
    instrument_play_status=1;
    
}
@end
