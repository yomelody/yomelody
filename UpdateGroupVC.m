//
//  UpdateGroupVC.m
//  melody
//
//  Created by coding Brains on 06/09/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import "UpdateGroupVC.h"
#import "Constant.h"
#import "imageCollectionViewCell.h"
#import "ProgressHUD.h"
#import "contactsViewController.h"
#import "contactsTableViewCell.h"
@interface UpdateGroupVC ()<UITextViewDelegate,UIImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource>
{
    BOOL isEdit,isupdated;
    NSUserDefaults*defaults_userdata;
    UIView *backView;
    NSMutableArray *arrUsersM, *arrGroupMembersM;
    NSString *adminID, *memberID;
    NSString *ADD_or_REMOVE;
    UILabel *noGroupMemberLbl,*noAllMemberLbl;
    NSMutableArray *group_memberIDS;
    BOOL isAll_Table;
}

@end

@implementation UpdateGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isSearch = NO;
    [self initializeAllVaribles];
    _groupNameEditImageView.hidden = YES;
    _btn_edit.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.3];
    _btn_done.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.3];
    isAll_Table = NO;
    _addMemberView.hidden=YES;
    _addMemberView.layer.cornerRadius = 4.0f;
    // Do any additional setup after loading the view.
    arrUsersM = [[NSMutableArray alloc] init];
    arrGroupMembersM = [[NSMutableArray alloc] init];
    [self get_GroupMember_List];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];//UIBlurEffectStyleLight
    
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    
    // add the effect view to the image view
    [self.backImageView addSubview:effectView];
    // Do any additional setup after loading the view.
    
    //--------------- For All Users * Placeholder -----------------
    
    noAllMemberLbl = [[UILabel alloc] initWithFrame:CGRectMake(_addMemberView.frame.origin.x, _addMemberView.frame.size.height/2,_addMemberView.frame.size.width,40)];
    noAllMemberLbl.text= @"No Users";
    noAllMemberLbl.textAlignment= NSTextAlignmentCenter;
    noAllMemberLbl.textColor=[UIColor grayColor];
    [_addMemberView addSubview:noAllMemberLbl];
    
    //----------- For Group Members * Placeholder -------------
    noGroupMemberLbl = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height/1.5,self.view.frame.size.width,40)];
    noGroupMemberLbl.text= @"No Members";
    noGroupMemberLbl.textAlignment= NSTextAlignmentCenter;
    noGroupMemberLbl.textColor=[UIColor grayColor];
    [self.view addSubview:noGroupMemberLbl];
    
   
}

-(void)viewDidDisappear:(BOOL)animated{
    imageData = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)initializeAllVaribles{
    [Appdelegate showProgressHud];
    isupdated = NO;
    _btn_profileImage.layer.cornerRadius = _btn_profileImage.frame.size.width / 2;
    _btn_profileImage.clipsToBounds = YES;
    _btn_profileImage.layer.borderColor=[UIColor whiteColor].CGColor;
    _btn_profileImage.layer.borderWidth=2.0f;
    self.tft_GroupName.enabled = NO;
    isEdit = NO;
    _tft_GroupName.text = _str_GroupName;
    NSURL * urlForImage = [NSURL URLWithString:_str_GroupImage];
   
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:urlForImage completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                     [_btn_profileImage setImage:image forState:UIControlStateNormal];
                   [_backImageView setImage:image];
                    [Appdelegate hideProgressHudInView];
                    
                });
            }
        }
    }];
    [task resume];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
//    [self.view addGestureRecognizer:tap];
    [self.UpdateGImageView addGestureRecognizer:tap];
    picker = [[UIImagePickerController alloc] init];
}

-(void)dismissKeyboard
{
    [_tft_GroupName resignFirstResponder];
}


- (IBAction)btn_DoneAction:(id)sender {
    
    [self dismissKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)btn_EditAction:(id)sender {
    isEdit = !isEdit;
    if (isEdit) {
        [self.btn_edit setTitle:@"Update" forState:UIControlStateNormal];
        _groupNameEditImageView.hidden=NO;
        self.tft_GroupName.enabled = YES;
    }
    else{
       // imageData = nil;
        [self.btn_edit setTitle:@"Edit" forState:UIControlStateNormal];
        
        _groupNameEditImageView.hidden=YES;
        self.tft_GroupName.enabled = NO;
            if ( imageData.length>0)
            {
                [self updateGroup];
            }
            else{
                [self updateGroupWithoutImage];
            }
    }
    [self.btn_profileImage addTarget:self action:@selector(setImage:) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (IBAction)btn_AddMemberAction:(id)sender {
    
    isAll_Table = YES;

    [self.view endEditing:YES];
    backView= [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:backView];
    [backView addSubview:_addMemberView];
    _addMemberView.hidden=NO;
    searchMemberList=[[NSArray alloc]init];
    [self get_User_List];
}



-(void)setImage:(id)sender{
    NSLog(@"Welcome to Image editing");
    
    [self btn_open_gallery];
    
}



- (IBAction)closeButtonAction:(id)sender {
    [self closeMethod];
}

-(void)closeMethod
{
    isAll_Table = NO;
    [self.view endEditing:YES];
    _addMemberView.hidden = YES;
    backView.hidden= YES;
    isSearch= NO;
    [_tbl_View_GroupMembers reloadData];
}


-(void)updateGroup{
    
    @try{
    isupdated = YES;
        [Appdelegate showProgressHud];
    NSString *str_groupName = [NSString stringWithFormat:@"%@",_tft_GroupName.text];
        if ([str_groupName isEqualToString:@""])
        {
            str_groupName =@"Group";
        }
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
           [manager POST:[NSString stringWithFormat:@"%@UpdateGroup.php",BaseUrl]
              parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
               if ( imageData.length>0)
               {
               [formData appendPartWithFileData:imageData
                                           name:@"groupPic"
                                       fileName:imageName mimeType:@"image/jpeg"];
               }
               
               [formData appendPartWithFormData:[str_groupName dataUsingEncoding:NSUTF8StringEncoding]
                                           name:@"groupName"];
               [formData appendPartWithFormData:[KEY_AUTH_VALUE dataUsingEncoding:NSUTF8StringEncoding]
                                           name:KEY_AUTH_KEY];
               [formData appendPartWithFormData:[_str_chat_id dataUsingEncoding:NSUTF8StringEncoding]
                                           name:@"chatID"];
           
       } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
           [SVProgressHUD dismiss];
           if([[responseObject objectForKey:@"flag"] isEqual:@"Success"]) {
               [Appdelegate hideProgressHudInView];
               NSLog(@"%@",[responseObject objectForKey:@"success"]);
               isupdated = YES;
               NSDictionary *dicInfo = [responseObject objectForKey:@"response"];
               NSMutableDictionary *dic = [dicInfo mutableCopy];
               [dic setValue:_str_chat_id forKey:@"chat_id"];
              [ProgressHUD showSuccess:@"Succesfully Updated"];
               [self dismissKeyboard];
               [[NSNotificationCenter defaultCenter]
                postNotificationName:@"updateGroup"
                object:self userInfo:dic];
               
           }
           else if ([[responseObject objectForKey:@"flag"] isEqualToString:@"failed"]) {
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
       
           
       } failure:^(NSURLSessionDataTask *task, NSError *error) {
           NSLog(@"Error: %@", error);
           [Appdelegate hideProgressHudInView];
           UIAlertController * alert=   [UIAlertController
                                         alertControllerWithTitle:@"Error"
                                         message:@"Request failed: Could not upload"
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
    @catch (NSException *exception) {
        NSLog(@"exception at updateGroup :%@",exception);
    }
    @finally{
        
    }
}



-(void)updateGroupWithoutImage{
    
        @try{
        [Appdelegate showProgressHud];
        NSString *str_groupName = [NSString stringWithFormat:@"%@",_tft_GroupName.text];
        NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
        [params setObject:str_groupName forKey:@"groupName"];
        [params setObject:_str_chat_id forKey:@"chatID"];

        [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
        
        NSMutableString* parameterString = [NSMutableString string];
        for(NSString* key in [params allKeys])
        {
            if ([parameterString length]) {
                [parameterString appendString:@"&"];
            }
            [parameterString appendFormat:@"%@=%@",key, params[key]];
        }
        
        NSString* urlString = [NSString stringWithFormat:@"%@UpdateGroup.php",BaseUrl];
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
                            if ([[jsonObject valueForKey:@"flag"] isEqual:@"Success"]){
                                [Appdelegate hideProgressHudInView];

                                isupdated = YES;
                                NSDictionary *dicInfo = [jsonObject objectForKey:@"response"];
                                NSMutableDictionary *dic = [dicInfo mutableCopy];
                                [dic setValue:_str_chat_id forKey:@"chat_id"];
                                [dic setValue:_str_GroupImage forKey:@"url"];
                                [ProgressHUD showSuccess:@"Succesfully Updated"];
                                [self dismissKeyboard];
                                [[NSNotificationCenter defaultCenter]
                                 postNotificationName:@"updateGroup"
                                 object:self userInfo:dic];

                            }
                            else{
                                [Appdelegate hideProgressHudInView];
                    UIAlertController * alert=   [UIAlertController
                    alertControllerWithTitle:@"Alert"
                                                              message:@"Updation Failed"
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
        NSLog(@"exception at updateGroupWithoutImage :%@",exception);
    }
    @finally{
        
    }
}


- (IBAction)btn_back:(id)sender {
        Appdelegate.str_chat_status=@"0";
        [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)btn_home:(id)sender {
    @try{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"notification_navigation"] isEqual:@"1"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"notification_navigation" ];
        
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        UITabBarController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
//        [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
        [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];

        
    }else
    {
//        Appdelegate.str_chat_status=@"0";
//        UIViewController *vc = self.presentingViewController;
//
//        [vc dismissViewControllerAnimated:YES completion:NULL];
        [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];

    }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at btn_home :%@",exception);
    }
    @finally{
        
    }
}

- (IBAction)chat_Invite:(UIButton *)sender {
    contactsViewController *contactVC = [self.storyboard instantiateViewControllerWithIdentifier:@"contactsViewController"];
    [contactVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:contactVC animated:YES completion:nil];
    
}

- (IBAction)btn_write_msg_open_contacts:(id)sender {
    
}

- (IBAction)btn_invite:(id)sender{
    contactsViewController *contactVC = [self.storyboard instantiateViewControllerWithIdentifier:@"contactsViewController"];
    [contactVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:contactVC animated:YES completion:nil];
    
}



- (void)btn_open_gallery{
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    CGFloat margin = 8.0F;
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


#pragma mark -
#pragma mark - CollectionView Delegates and Datasources

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [Appdelegate.arr_Gallery_Items count];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //return CGSizeMake(100,cv_images.frame.size.height);
    UIImage *image = [Appdelegate.arr_Gallery_Items objectAtIndex:indexPath.item];
    //You may want to create a divider to scale the size by the way..
    float oldheight = image.size.height;
    float scaleFactor =cv_images.frame.size.height/ oldheight;
    float newwidth = image.size.width * scaleFactor;
    return CGSizeMake(newwidth, cv_images.frame.size.height);
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    imageCollectionViewCell *cell = (imageCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    //     {
    //         cell.img_view.image = result;
    //     }];
    cell.img_view.image = [Appdelegate.arr_Gallery_Items objectAtIndex:indexPath.item];
    cell.backgroundColor=[UIColor greenColor];
    return cell;
}


-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"this is caled");
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    imageData=UIImagePNGRepresentation([Appdelegate.arr_Gallery_Items objectAtIndex:indexPath.item]);

    
    [_btn_profileImage setImage:[Appdelegate.arr_Gallery_Items objectAtIndex:indexPath.item] forState:UIControlStateNormal];
    
    imageName=@"image.png";
    
     [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)open_camera
{
    picker.delegate=self;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"camera_status"] isEqual:@"1"]) {
        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"camera_status"];
    }
    else{
        
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusAuthorized) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
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


-(void)get_User_List
{
    @try{
        // [Appdelegate showProgressHud];
        NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
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
                        [_tbl_View_AllMember reloadData];
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
                          //  [self presentViewController:alert animated:YES completion:nil];
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


-(void)open_gallery
{
    if ([Appdelegate hasGalleryPermission]) {
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
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

#pragma mark - TableView Delegates & Datasource
#pragma mark -

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tbl_View_AllMember)
    {
        if (isSearch)
        {
            return [searchMemberList count];
        }
        else
        {
            return [arrUsersM count];
        }
    }
    else
    {
        if (isSearch)
        {
            return [searchMemberList count];
        }
        else
        {
            return [arrGroupMembersM count];
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 86;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    contactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    if (tableView == _tbl_View_AllMember)
    {
        if (cell == nil)
        {
            NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"contactsTableViewCell"
                             
                                                          owner:self options:nil];
            
            cell = (contactsTableViewCell *)[nib2 objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.img_view_profilepic.layer.cornerRadius = cell.img_view_profilepic.frame.size.width / 2;
            cell.img_view_profilepic.clipsToBounds = YES;
            cell.btn_select.clipsToBounds = YES;
            cell.btn_select.hidden= YES;
            /////==========NEW CODE FOR PROFILE NAVIGATION
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
            cell.img_view_profilepic.userInteractionEnabled=YES;
            tap.numberOfTapsRequired = 1;
            tap.view.tag=indexPath.row;
            cell.img_view_profilepic.tag = indexPath.row;
            tap.cancelsTouchesInView = YES;
            [cell.img_view_profilepic addGestureRecognizer:tap];
            ///
            //--------- set the image for alreay added member ------------
            UIImageView *alreadyAddedImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.tbl_View_AllMember.frame.size.width -35, cell.lbl_name.frame.origin.y, 20, 20)];
            [alreadyAddedImgView setImage:[UIImage imageNamed:@"Already_added"]];
            [cell addSubview:alreadyAddedImgView];
            
            if (isSearch)
            {
                if (searchMemberList.count>0)
                {
                    cell.lbl_name.text=[[searchMemberList objectAtIndex:indexPath.row] objectForKey:@"name"];
                    
                    cell.lbl_station.text=[NSString stringWithFormat:@"@%@",[[searchMemberList objectAtIndex:indexPath.row] objectForKey:@"user_name"]];
                    //                    cell.lbl_station.text=[[searchMemberList objectAtIndex:indexPath.row] objectForKey:@"user_name"];
                    
                    if ([group_memberIDS containsObject:[[searchMemberList objectAtIndex:indexPath.row] objectForKey:@"id"]])
                    {
                        alreadyAddedImgView.hidden=NO;
                        cell.backgroundColor=[[UIColor lightGrayColor] colorWithAlphaComponent:0.2];                    }
                    else
                    {
                        alreadyAddedImgView.hidden=YES;
                    }
                    
                    NSURL *url2 = [NSURL URLWithString:[[searchMemberList objectAtIndex:indexPath.row] valueForKey:@"profilepic"]];
                    NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:url2 completionHandler:^(NSData*  _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        if (data) {
                            UIImage *image = [UIImage imageWithData:data];
                            if (image) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    cell.img_view_profilepic.image= image;
                                    
                                });
                            }
                        }
                    }];
                    [task2 resume];
                }
            }
            else
            {
                if (arrUsersM.count>0)
                {
                    noAllMemberLbl.hidden=YES;
                    //--------- New code ------------
                    cell.lbl_station.text=[NSString stringWithFormat:@"@%@",[[arrUsersM objectAtIndex:indexPath.row] objectForKey:@"user_name"]];
                    cell.lbl_name.text=[[arrUsersM objectAtIndex:indexPath.row] objectForKey:@"name"];
                    
                    //--------- New code ------------

                    if ([group_memberIDS containsObject:[[arrUsersM objectAtIndex:indexPath.row] objectForKey:@"id"]])
                    {
                        alreadyAddedImgView.hidden=NO;
                        cell.backgroundColor=[[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
                    }
                    else
                    {
                        alreadyAddedImgView.hidden=YES;
                    }
                    
//                    cell.lbl_station.text=[[arrUsersM objectAtIndex:indexPath.row] objectForKey:@"user_name"];
                    
                    NSURL *url2 = [NSURL URLWithString:[[arrUsersM objectAtIndex:indexPath.row] valueForKey:@"profilepic"]];
                    NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:url2 completionHandler:^(NSData*  _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        if (data) {
                            UIImage *image = [UIImage imageWithData:data];
                            if (image) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    cell.img_view_profilepic.image= image;
                                    
                                });
                            }
                        }
                    }];
                    [task2 resume];
                }
                else
                {
                    noAllMemberLbl.hidden=NO;
                }
            }
            
            return cell;
            
        }
    }
    else
    {
        if (cell == nil)
        {
            NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"contactsTableViewCell"
                             
                                                          owner:self options:nil];
            
            cell = (contactsTableViewCell *)[nib2 objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.img_view_profilepic.layer.cornerRadius = cell.img_view_profilepic.frame.size.width / 2;
            cell.img_view_profilepic.clipsToBounds = YES;
            cell.btn_select.layer.cornerRadius=cell.btn_select.frame.size.width / 2;
            cell.btn_select.clipsToBounds = YES;
            cell.btn_select.hidden= YES;
            if (arrGroupMembersM.count>0) {
                cell.lbl_name.text=[[arrGroupMembersM objectAtIndex:indexPath.row] objectForKey:@"name"];
                noGroupMemberLbl.hidden=YES;
                
                cell.lbl_station.text=[NSString stringWithFormat:@"@%@",[[arrGroupMembersM objectAtIndex:indexPath.row] objectForKey:@"username"]];
//                cell.lbl_station.text=[[arrGroupMembersM objectAtIndex:indexPath.row] objectForKey:@"username"];
                UILabel *adminLbl = [[UILabel alloc] initWithFrame:CGRectMake(self.tbl_View_GroupMembers.frame.size.width -80, cell.lbl_name.frame.origin.y+2, 60, 30)];
                //                adminLbl.text = @"Admin";
                
                adminLbl.textAlignment = NSTextAlignmentCenter;
                
                
                if ([adminID isEqualToString:[[arrGroupMembersM objectAtIndex:indexPath.row] objectForKey:@"user_id"]])
                {
                    // adminLbl.hidden=NO;
                    adminLbl.text = @"Admin";
                    adminLbl.backgroundColor= [UIColor purpleColor];
                    adminLbl.textColor= [UIColor whiteColor];
                    adminLbl.layer.masksToBounds = YES;
                    adminLbl.layer.cornerRadius = 8.0f;
                }
                else
                {
                    // adminLbl.hidden=YES;
                    if ([adminID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]])
                    {
                        adminLbl.hidden=NO;
                    }
                    else
                    {
                        adminLbl.hidden=YES;
                    }
                    adminLbl.text = @"Remove";
                    
                    adminLbl.textColor= [UIColor blueColor];
                    adminLbl.font=[UIFont systemFontOfSize:15.0f];
                    adminLbl.layer.masksToBounds = YES;
                    adminLbl.layer.cornerRadius = 8.0f;
                }
                [cell addSubview:adminLbl];
                /////==========NEW CODE FOR PROFILE NAVIGATION
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
                cell.img_view_profilepic.userInteractionEnabled=YES;
                tap.numberOfTapsRequired = 1;
                tap.view.tag=indexPath.row;
                cell.img_view_profilepic.tag = indexPath.row;
                tap.cancelsTouchesInView = YES;
                [cell.img_view_profilepic addGestureRecognizer:tap];
                ///
                
                NSURL *url2 = [NSURL URLWithString:[[arrGroupMembersM objectAtIndex:indexPath.row] valueForKey:@"profilepic"]];
                NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:url2 completionHandler:^(NSData*  _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (data) {
                        UIImage *image = [UIImage imageWithData:data];
                        if (image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                cell.img_view_profilepic.image= image;
                                
                            });
                        }
                    }
                }];
                [task2 resume];
            }
            else
            {
                noGroupMemberLbl.hidden=NO;
            }
            
            return cell;
        }
        
    }
    return cell;
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *msg;
    // FOR ADD MEMBERS
    if (tableView == _tbl_View_AllMember)
    {
        
        if(isSearch)
        {
            msg  = [NSString stringWithFormat:@"Are you sure you want to add %@ to this group?",[[searchMemberList objectAtIndex:indexPath.row] objectForKey:@"name"]];
            memberID = [[searchMemberList objectAtIndex:indexPath.row] objectForKey:@"id"];
        }
        else
        {
            msg  = [NSString stringWithFormat:@"Are you sure you want to add %@ to this group?",[[arrUsersM objectAtIndex:indexPath.row] objectForKey:@"name"]];
            memberID = [[arrUsersM objectAtIndex:indexPath.row] objectForKey:@"id"];
        }
        
        if ([group_memberIDS containsObject:memberID])
        {
            [Appdelegate showMessageHudWithMessage:@"Already Added !" andDelay:2.0f];
        }
        else
        {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Alert !"
                                      message:msg
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Yes"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        //Handel your yes please button action here
                                        //add_member.php
                                        ADD_or_REMOVE=@"add_member.php";
                                        [self addOrRemoveMember];
                                        
                                    }];
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"No"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       //Handel your yes please button action here
                                       
                                   }];
        
        [alert addAction:noButton];
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
            
        }
    }
    else     // FOR REMOVE MEMBERS
    {
        if ([adminID isEqualToString:[[arrGroupMembersM objectAtIndex:indexPath.row] objectForKey:@"user_id"]])
        {
            msg  = [NSString stringWithFormat:@"Admin can't be remove."];
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Alert !"
                                          message:msg
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okButton = [UIAlertAction
                                       actionWithTitle:@"Ok"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action)
                                       {
                                           //Handel your yes please button action here
                                           
                                           
                                       }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            
            if ([adminID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]])
            {
                msg  = [NSString stringWithFormat:@"Are you sure you want to remove %@ from this group?",[[arrGroupMembersM objectAtIndex:indexPath.row] objectForKey:@"name"]];
                memberID = [[arrGroupMembersM objectAtIndex:indexPath.row] objectForKey:@"user_id"];
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"Alert !"
                                              message:msg
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"Yes"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action)
                                            {
                                                //Handel your yes please button action here
                                                //remove_member.php
                                                ADD_or_REMOVE=@"remove_member.php";
                                                [self addOrRemoveMember];
                                                
                                            }];
                
                UIAlertAction* noButton = [UIAlertAction
                                           actionWithTitle:@"No"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action)
                                           {
                                               //Handel your yes please button action here
                                               
                                           }];
                
                [alert addAction:noButton];
                [alert addAction:yesButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        
    }
}


- (void) handleImageTap:(UITapGestureRecognizer *)gestureRecognizer
{
    NSLog(@"imaged tab");
    ProfileViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    if (isAll_Table)
    {
        CGPoint tapLocation = [gestureRecognizer locationInView:_tbl_View_AllMember];
        NSIndexPath *iPath = [_tbl_View_AllMember indexPathForRowAtPoint:tapLocation];
        NSLog(@"FINAL TAG VALUE %ld",(long)iPath.row);
        if (isSearch)
        {
            NSLog(@"user id %@",[[searchMemberList objectAtIndex:iPath.row] objectForKey:@"id"]);
            myVC.follower_id = [[searchMemberList objectAtIndex:iPath.row] objectForKey:@"id"];
        }
        else
        {
            NSLog(@"user id %@",[[arrUsersM objectAtIndex:iPath.row] objectForKey:@"id"]);
            myVC.follower_id = [[arrUsersM objectAtIndex:iPath.row] objectForKey:@"id"];
        }
    }
    else
    {
        CGPoint tapLocation = [gestureRecognizer locationInView:_tbl_View_GroupMembers];
        NSIndexPath *iPath = [_tbl_View_GroupMembers indexPathForRowAtPoint:tapLocation];
        NSLog(@"FINAL TAG VALUE %ld",(long)iPath.row);
        NSLog(@"user id %@",[[arrGroupMembersM objectAtIndex:iPath.row] objectForKey:@"user_id"]);
        myVC.follower_id = [[arrGroupMembersM objectAtIndex:iPath.row] objectForKey:@"user_id"];
    }
    [myVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:myVC animated:YES completion:nil];
    
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info
{
    
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
//        imageData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 0.0f);
    UIImage*img12=[info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage*compressedImage = [Appdelegate scaleImage:img12 toSize:CGSizeMake(100, 100)];
    compressedImage = [Appdelegate scaleAndRotateImage:compressedImage];
    imageData = UIImagePNGRepresentation(compressedImage);
    [_btn_profileImage setImage:compressedImage forState:UIControlStateNormal];
//    _btn_profileImage.image = compressedImage;
    imageName = [imageURL lastPathComponent];
    if (([imageName  length]==0)) {
        imageName=@"image.png";
    }
    NSLog(@"%@",imageName);
//    [self dismissModalViewControllerAnimated:YES];
     [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    if ([searchText isEqualToString:@""])
    {
        isSearch = NO;
    }
    else
    {
        isSearch= YES;
    }
    if (searchBar == _Member_SearchBar)
    {
        
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchBar.text];
        searchMemberList = [arrUsersM filteredArrayUsingPredicate:filterPredicate];
        NSLog(@"newSearch %@", searchMemberList);
        if(searchMemberList.count>0)
        {
            noAllMemberLbl.hidden=YES;
        }
        else
        {
            noAllMemberLbl.hidden=NO;
        }
        
        [_tbl_View_AllMember reloadData];
    }
    //    else
    //    {
    //
    //        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchBar.text];
    //        searchMemberList = [arrGroupMembersM filteredArrayUsingPredicate:filterPredicate];
    //        NSLog(@"newSearch %@", searchMemberList);
    //        [_tbl_View_GroupMembers reloadData];
    //    }
    
}

-(void)addOrRemoveMember
{
    
    @try{
        NSString *login_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
        
        NSLog(@"DICT %@",defaults_userdata);
        NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
        [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
        [params setObject:_str_chat_id forKey:@"chat_id"];
        
        [params setObject:memberID forKey:@"member_id"];
        [params setObject:login_id forKey:@"login_id"];
        
        
        NSLog(@"%@",params);
        NSMutableString* parameterString = [NSMutableString string];
        for(NSString* key in [params allKeys])
        {
            if ([parameterString length]) {
                [parameterString appendString:@"&"];
            }
            [parameterString appendFormat:@"%@=%@",key, params[key]];
        }
        NSString* urlString;
        NSLog(@"CURRENT VALUE || %@",ADD_or_REMOVE);
        
        urlString = [NSString stringWithFormat:@"%@%@",BaseUrl,ADD_or_REMOVE];
        
        
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
                        [Appdelegate showMessageHudWithMessage:[jsonResponse objectForKey:@"message"] andDelay:4.0f];
                        if ([ADD_or_REMOVE isEqualToString:@"add_member.php"]) {
                            [self closeMethod];
                        }
                        
                        [self get_GroupMember_List];
                        
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
        NSLog(@"exception at sharefile : %@",exception);
    }
    @finally{
        
    }
}

-(void)get_GroupMember_List
{
    @try{
        // [Appdelegate showProgressHud];
        NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
        [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
        [params setObject:_str_chat_id forKey:@"chat_id"];
        NSLog(@"%@",params);
        NSMutableString* parameterString = [NSMutableString string];
        for(NSString* key in [params allKeys])
        {
            if ([parameterString length]) {
                [parameterString appendString:@"&"];
            }
            [parameterString appendFormat:@"%@=%@",key, params[key]];
        }
        NSString* urlString = [NSString stringWithFormat:@"%@group_members.php",BaseUrl];
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
                        group_memberIDS=[[NSMutableArray alloc]init];
                        
                        dic_response=[jsonResponse objectForKey:@"response"];
                        arrGroupMembersM=[[jsonResponse objectForKey:@"response"] objectForKey:@"group_members"];
                        adminID = [dic_response objectForKey:@"admin_id"];
                        _totalMembers_Lbl.text = [NSString stringWithFormat:@"%lu Members",(unsigned long)arrGroupMembersM.count];
                        for (int i=0; i<arrGroupMembersM.count; i++)
                        {
                            [group_memberIDS addObject:[[arrGroupMembersM objectAtIndex:i] valueForKey:@"user_id"]];
                        }
                        
                        if (![group_memberIDS containsObject:[[NSUserDefaults standardUserDefaults]
                                                      objectForKey:@"user_id"]])
                        {
                            _btn_edit.hidden=YES;
                        }
                        else
                        {
                            _btn_edit.hidden=NO;
                        }
                        
                        if ([adminID isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]])
                        {
                            _addMemberButtonO.hidden = NO;
                            _btn_exitGroup.hidden = YES;
                            
                        }
                        else
                        {
                            _addMemberButtonO.hidden = YES;
                            if (![group_memberIDS containsObject:[[NSUserDefaults standardUserDefaults]
                                                                  objectForKey:@"user_id"]])
                            {
                                _btn_exitGroup.hidden=YES;
                            }
                            else
                            {
                                _btn_exitGroup.hidden=NO;
                            }
                        }
                        [_tbl_View_GroupMembers reloadData];
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
                           // [self presentViewController:alert animated:YES completion:nil];
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


- (IBAction)btn_exitGroupAction:(id)sender {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Alert !"
                                  message:@"Are you sure you want to exit the group ?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    //Handle your yes please button action here
                                    [self exitFromGroupMethod];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"No"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   //Handle your No please button action here
                                   
                               }];
    
    [alert addAction:noButton];
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)exitFromGroupMethod
{
    
    @try{
        NSString *login_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
        
        NSLog(@"DICT %@",defaults_userdata);
        NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
        [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
        [params setObject:_str_chat_id forKey:@"chat_id"];
        
        [params setObject:login_id forKey:@"user_id"];
        
        
        NSLog(@"%@",params);
        NSMutableString* parameterString = [NSMutableString string];
        for(NSString* key in [params allKeys])
        {
            if ([parameterString length]) {
                [parameterString appendString:@"&"];
            }
            [parameterString appendFormat:@"%@=%@",key, params[key]];
        }
        //NSString* urlString = [NSString stringWithFormat:@"%@",BaseUrl];
        
        
        NSString* urlString = [NSString stringWithFormat:@"http://52.89.220.199/dev_api/exit_group.php"];
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
                // [self presentViewController:alert animated:YES completion:nil];
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
                        [Appdelegate showMessageHudWithMessage:[jsonResponse objectForKey:@"message"] andDelay:4.0f];
                        
                        [self get_GroupMember_List];
                        
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
                            //[self presentViewController:alert animated:YES completion:nil];
                        }
                    }
                });
            }
        }];
        [task resume];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at sharefile : %@",exception);
    }
    @finally{
        
    }
}


@end
