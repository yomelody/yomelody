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
@interface UpdateGroupVC ()<UITextViewDelegate,UIImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
{
    BOOL isEdit,isupdated;
    NSUserDefaults*defaults_userdata;

}

@end

@implementation UpdateGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeAllVaribles];
    
    // Do any additional setup after loading the view.
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
                    [Appdelegate hideProgressHudInView];
                });
            }
        }
    }];
    [task resume];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];

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
    }
    else{
       // imageData = nil;
        [self.btn_edit setTitle:@"Edit" forState:UIControlStateNormal];
            if ( imageData.length>0)
            {
                [self updateGroup];
            }
            else{
                [self updateGroupWithoutImage];
            }
    }
    self.tft_GroupName.enabled = YES;
    [self.btn_profileImage addTarget:self action:@selector(setImage:) forControlEvents:UIControlEventTouchUpInside];
    
    
}


-(void)setImage:(id)sender{
    NSLog(@"Welcome to Image editing");
    
    [self btn_open_gallery];
    
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
           [manager POST:[NSString stringWithFormat:@"%@UpdateGroup.php",BaseUrl] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
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
        NSLog(@"exception at likes.php :%@",exception);
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
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}

- (IBAction)chat_Invite:(UIButton *)sender {
    
    
}

- (IBAction)btn_write_msg_open_contacts:(id)sender {
    
}

- (IBAction)btn_invite:(id)sender{

    
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



@end
