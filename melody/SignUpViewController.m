//
//  SignUpViewController.m
//  melody
//
//  Created by CodingBrainsMini on 12/3/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import "SignUpViewController.h"
#import "imageCollectionViewCell.h"
#import "Constant.h"
@interface SignUpViewController ()
{
    NSString *currentDevice;
}
@end

@implementation SignUpViewController
@synthesize pickerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [SVProgressHUD dismiss];
    
    NSLog(@"CURR DEV %@", [[UIDevice currentDevice] model]);
    currentDevice=[[UIDevice currentDevice] model];
    [self.btn_Done setTitleColor:[UIColor colorWithRed:0.0f green:132.0f blue:200.0f alpha:.6] forState:UIControlStateNormal ];
 
    if (isiPhone5)
    {
        _croll_view_signupcontent.contentSize = CGSizeMake(0,_croll_view_signupcontent.frame.size.height+100);
        _croll_view_signupcontent.scrollEnabled=YES;
        _croll_view_signupcontent.contentInset = UIEdgeInsetsMake(0, 0, 90, 0);
//        _croll_view_signupcontent.contentOffset = CGPointMake(0, -20);
    }
    else{
    _croll_view_signupcontent.contentSize = CGSizeMake(_croll_view_signupcontent.contentSize.width,self.view.frame.size.height+100);

    }
    _croll_view_signupcontent.scrollEnabled=YES;
    dic_response=[[NSMutableDictionary alloc]init];
    imageData=[[NSData alloc]init];
    imageName=[[NSString alloc]init];
    user_type=1;
    dob=1;
    _tf_dob_date.tag=1;
    _tf_dob_month.tag=2;
    _tf_dob_year.tag=3;
    
//    UIColor *color = [UIColor whiteColor];
    UIColor *color = [UIColor grayColor];

    _tf_first_name.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"First" attributes:@{NSForegroundColorAttributeName: color}];
    _tf_last_name.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Last" attributes:@{NSForegroundColorAttributeName: color}];
    _tf_password.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    _tf_confirmpass.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Confirm Password" attributes:@{NSForegroundColorAttributeName: color}];
    _tf_email.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: color}];
    _tf_username.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: color}];
    _tf_phone.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Phone" attributes:@{NSForegroundColorAttributeName: color}];
    
    _tf_dob_date.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Day" attributes:@{NSForegroundColorAttributeName: color}];
    _tf_dob_month.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Month" attributes:@{NSForegroundColorAttributeName: color}];
    _tf_dob_year.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Year" attributes:@{NSForegroundColorAttributeName: color}];
    
    _img_view_profile.layer.masksToBounds = YES;
    _img_view_profile.layer.cornerRadius=_img_view_profile.frame.size.height/2;
    _btn_signup.layer.cornerRadius=20;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
   [_croll_view_signupcontent addGestureRecognizer:tap];
    
    UISwipeGestureRecognizer*swipedown=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [swipedown setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:swipedown];
    
    [_tf_first_name addTarget:self action:@selector(tf_first_name_change:) forControlEvents:UIControlEventEditingChanged];
    [_tf_email addTarget:self action:@selector(tf_email_change:) forControlEvents:UIControlEventEditingChanged];
    [_tf_password addTarget:self action:@selector(tf_password_change:) forControlEvents:UIControlEventEditingChanged];
    [_tf_username addTarget:self action:@selector(tf_username_change:) forControlEvents:UIControlEventEditingChanged];
    [_tf_dob_date addTarget:self action:@selector(tf_dob_day_change:) forControlEvents:UIControlEventEditingChanged];
    [_tf_dob_month addTarget:self action:@selector(tf_dob_month_change:) forControlEvents:UIControlEventEditingChanged];
    [_tf_dob_year addTarget:self action:@selector(tf_dob_year_change:) forControlEvents:UIControlEventEditingChanged];
    [_tf_phone addTarget:self action:@selector(tf_phone_change:) forControlEvents:UIControlEventEditingChanged];
    [_tf_confirmpass addTarget:self action:@selector(tf_confirmpass_change:) forControlEvents:UIControlEventEditingChanged];
    

}


-(void)tf_first_name_change :(UITextField *)theTextField{
 
    _lbl_fname_error.text=nil;
}


-(void)tf_email_change :(UITextField *)theTextField{
    _lbl_email_error.text=nil;
}


-(void)tf_password_change :(UITextField *)theTextField{
    _lbl_password_error.text=nil;
}


-(void)tf_username_change :(UITextField *)theTextField{
    _lbl_usename_error.text=nil;
}


-(void)tf_dob_day_change :(UITextField *)theTextField{
    _lbl_dob_error.text=nil;
    [self textFieldShouldReturn:_tf_dob_date];
}


-(void)tf_dob_month_change :(UITextField *)theTextField{
    _lbl_dob_error.text=nil;
    [self textFieldShouldReturn:_tf_dob_month];
}


-(void)tf_dob_year_change :(UITextField *)theTextField{
    _lbl_dob_error.text=nil;
    [self textFieldShouldReturn:_tf_dob_year];
}


-(void)tf_phone_change :(UITextField *)theTextField{
   _lbl_phone_error.text=nil;
}


-(void)tf_confirmpass_change :(UITextField *)theTextField{
    if ([_tf_password.text isEqualToString:_tf_confirmpass.text]) {
        _lbl_confirmpass_error.text=nil;
    }
}


-(void)dismissKeyboard
{
    [_tf_email resignFirstResponder];
    [_tf_phone resignFirstResponder];
    [_tf_password resignFirstResponder];
    [_tf_username resignFirstResponder];
    [_tf_first_name resignFirstResponder];
    [_tf_last_name resignFirstResponder];
    [_tf_dob_date resignFirstResponder];
    [_tf_dob_month resignFirstResponder];
    [_tf_dob_year resignFirstResponder];
    [_tf_confirmpass resignFirstResponder];
    _croll_view_signupcontent.contentSize = CGSizeMake(0, self.view.frame.size.height+100);
    [_croll_view_signupcontent setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    dp_view.hidden=YES;

}


- (void)viewDidAppear:(BOOL)animated {

}



- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    _croll_view_signupcontent.contentSize = CGSizeMake(0,self.view.frame.size.height+100);
}


#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height+90;
        self.view.frame = f;
    }];

    if (isiPhone5)
    {
        _croll_view_signupcontent.contentSize = CGSizeMake(0, self.view.frame.size.height+200);
        [_croll_view_signupcontent setFrame:CGRectMake(0, 200, self.view.frame.size.width, self.view.frame.size.height-200)];
        _croll_view_signupcontent.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

    }
    else if ([currentDevice isEqualToString:@"iPad"])
    {
        
        _croll_view_signupcontent.contentSize = CGSizeMake(0, self.view.frame.size.height+250);
        [_croll_view_signupcontent setFrame:CGRectMake(0, 200, self.view.frame.size.width, self.view.frame.size.height-250)];
    }
    else
    {
        _croll_view_signupcontent.contentSize = CGSizeMake(0, self.view.frame.size.height+100);
        [_croll_view_signupcontent setFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height-100)];
    }
    _croll_view_signupcontent.scrollEnabled=YES;
    dp_view.hidden=YES;
    
    
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
    if(isiPhone5){
        _croll_view_signupcontent.contentSize = CGSizeMake(0,self.view.frame.size.height);
        _croll_view_signupcontent.scrollEnabled=YES;
        _croll_view_signupcontent.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

    }
    else if ([currentDevice isEqualToString:@"iPad"])
    {
        
        _croll_view_signupcontent.contentSize = CGSizeMake(0, self.view.frame.size.height+300);
        [_croll_view_signupcontent setFrame:CGRectMake(0, 300, self.view.frame.size.width, self.view.frame.size.height-300)];
        _croll_view_signupcontent.scrollEnabled=YES;

    }
    else{
        _croll_view_signupcontent.contentSize = CGSizeMake(0,self.view.frame.size.height+100);
        _croll_view_signupcontent.scrollEnabled=YES;
    }

}


- (IBAction)btn_add_image:(id)sender {
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"getImages"
     object:self];
    
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


-(void)cancel_popup:(id)sender
{
    dp_view.hidden=YES;
}


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
    //float newheight = oldheight * scaleFactor;
   
    return CGSizeMake(newwidth, cv_images.frame.size.height);
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    imageCollectionViewCell *cell = (imageCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

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
    _img_view_profile.image=[Appdelegate.arr_Gallery_Items objectAtIndex:indexPath.item];
    imageName=@"image.png";
    dp_view.hidden=YES;
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


#pragma mark -
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info
{
//    _img_view_profile.image=[info objectForKey:UIImagePickerControllerOriginalImage];
    dp_view.hidden=YES;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        self.croll_view_signupcontent.contentSize = CGSizeMake(0, self.view.frame.size.height+100);
        [self.croll_view_signupcontent setScrollEnabled:YES];
        
        [self.croll_view_signupcontent setCanCancelContentTouches:NO];
        self.croll_view_signupcontent.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        self.croll_view_signupcontent.clipsToBounds = YES;
        self.croll_view_signupcontent.pagingEnabled = NO;
        self.croll_view_signupcontent.autoresizesSubviews=YES;
        [self.croll_view_signupcontent setContentMode:UIViewContentModeScaleAspectFill];
    }];
    
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    NSString *extension = [imageURL pathExtension];
    
    
        imageData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 0.0f);

        UIImage*img12=[info valueForKey:UIImagePickerControllerOriginalImage];
        UIImage*compressedImage = [Appdelegate scaleImage:img12 toSize:CGSizeMake(100, 100)];
        compressedImage = [Appdelegate scaleAndRotateImage:compressedImage];
        imageData = UIImagePNGRepresentation(compressedImage);
        _img_view_profile.image = compressedImage;
    
    
    imageName = [imageURL lastPathComponent];
    if (([imageName  length]==0)) {
        imageName=@"image.png";
    }
    NSLog(@"%@",imageName);

 
  }



- (IBAction)btn_signup:(id)sender {
   
    [self NSStringIsValidEmail:_tf_email.text];
    NSLog([self NSStringIsValidEmail:_tf_email.text] ? @"Yes" : @"No");
    
    if ([_tf_first_name.text length]!=0 && [_tf_email.text length] !=0 && [_tf_username.text length]!=0 && [_tf_password.text length]!=0 && [_tf_password.text length]>7 && [_tf_username.text length]>1 && [_tf_confirmpass.text length]!=0) {
        
        
     if ([self NSStringIsValidEmail:_tf_email.text] && [_tf_password.text isEqualToString:_tf_confirmpass.text])
        {
         [self signup_call];
        }
        else
        {
            if (![_tf_password.text isEqualToString:_tf_confirmpass.text])
            {
                _lbl_confirmpass_error.text=@"password missmatch";
            }
            if (![self NSStringIsValidEmail:_tf_email.text])
            {
                _lbl_email_error.text=@"incorrect email";
            }
        }
    }
    else
    {
        if ([_tf_username.text length]<=1)
        {
            _lbl_usename_error.text=@"Username required";
        }
        if (![_tf_password.text isEqualToString:_tf_confirmpass.text] || [_tf_password.text length]==0)
        {
            _lbl_password_error.text=@"Confirm password ";
        }
        if ([_tf_confirmpass.text length]==0)
        {
            _lbl_confirmpass_error.text=@"Required ";
        }
        if ([_tf_password.text length]<8)
            {
                _lbl_password_error.text=@"minimum 8 charecter ";
            }
        if ([_tf_first_name.text length]==0) {
            _lbl_fname_error.text=@"Required";
        }
        if ([_tf_email.text length]==0) {
            _lbl_email_error.text=@"Required";
        }
        else if (![self NSStringIsValidEmail:_tf_email.text])
        {
            _lbl_email_error.text=@"incorrect email";
        }
        if ([_tf_username.text length]==0) {
            _lbl_usename_error.text=@"Required";
        }
        if ([_tf_password.text length]==0) {
            _lbl_password_error.text=@"Required";
        }
       
        if ([_tf_phone.text length] !=0  )
        {

            if ([_tf_phone.text length] >=10 && [_tf_phone.text length] <=16 )
                  {
                      
                      _lbl_phone_error.text=@"";
                 }
            else
            {
            _lbl_phone_error.text=@"Incorrect phone";
            }
            
        }
 
    }

}


-(void)signup_call
{
    NSString *device_token = [[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"];
    if (device_token == nil){
        device_token = @"DSFVG6EW364374DFHGDIRTG45URETRYT8R8";
    }
    NSString* user_type_str=[NSString stringWithFormat:@"%d",user_type];
    NSString*DOB=[[NSString alloc]initWithFormat:@"%@/%@/%@",_tf_dob_date.text,_tf_dob_month.text,_tf_dob_year.text];
    [SVProgressHUD setForegroundColor:[UIColor greenColor]];
    [Appdelegate showProgressHud];
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:_tf_first_name.text forKey:@"f_name"];
    [params setObject:_tf_last_name.text forKey:@"l_name"];
    [params setObject:_tf_username.text forKey:@"username"];
    [params setObject:_tf_password.text forKey:@"password"];
    [params setObject:@"ios" forKey:@"device_type"];
    [params setObject:DOB forKey:@"dob"];
    [params setObject:user_type_str forKey:@"usertype"];
    
    [params setObject:device_token forKey:@"device_token"];
    [params setObject:@"passed" forKey:@"key"];
    [params setObject:_tf_email.text forKey:@"email"];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    [params setObject:_tf_phone.text forKey:@"phone"];
    NSString* appID = [[NSUserDefaults standardUserDefaults] stringForKey:@"app_id"];

    if ([user_type_str isEqualToString:@"2"]){
        [params removeObjectForKey:@"password"];
        [params setObject:@"appid" forKey:appID];
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
     NSString* urlString = [NSString stringWithFormat:@"%@registration.php",BaseUrl];
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
            dispatch_async(dispatch_get_main_queue(), ^{
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
            [self presentViewController:alert animated:YES completion:nil];
            });
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

                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"login_type"];
                    UILabel*lblmsg=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-200)/2,( self.view.frame.size.height-100)/2, 200, 100)];
                    lblmsg.backgroundColor=[UIColor redColor];

                    lblmsg.text= MSG_RegisteredSucces;
                    lblmsg.textAlignment=NSTextAlignmentCenter;
                    lblmsg.layer.cornerRadius=10;
                    lblmsg.clipsToBounds = YES;
                    
                    if ( imageData.length==0)
                    {
                        lblmsg.hidden=YES;
                        dic_response=[jsonResponse objectForKey:@"response"];
                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"Message"
                                                      message: MSG_RegisteredSucces
                                                      preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* yesButton = [UIAlertAction
                                                    actionWithTitle:@"ok"
                                                    style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action)
                                                    {
                                                        [Appdelegate hideProgressHudInView];
                                                         _img_view_profile.image=[UIImage imageNamed:@"artist-with-headphone.png"];
                                                        _tf_first_name.text=nil;
                                                        _tf_last_name.text=nil;
                                                        _tf_email.text=nil;
                                                        _tf_username.text=nil;
                                                        _tf_password.text=nil;
                                                        _tf_confirmpass.text=nil;
                                                        _tf_dob_date.text=nil;
                                                        _tf_dob_month.text=nil;
                                                        _tf_dob_year.text=nil;
                                                        _tf_phone.text=nil;
                                                        _lbl_dob_error.text=nil;
                                                        _lbl_email_error.text=nil;
                                                        _lbl_fname_error.text=nil;
                                                        _lbl_phone_error.text=nil;
                                                        _lbl_password_error.text=nil;
                                                        _lbl_confirmpass_error.text=nil;
                                                        _lbl_usename_error.text=nil;
                                                        
                                                        [self performSegueWithIdentifier:@"go_to_login" sender:nil];
                                                    }];
                        
                        [alert addAction:yesButton];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    else{
                        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
           
                        NSString *urlForUpload = [NSString stringWithFormat:@"%@uploadfile.php",BaseUrl];
                        [manager POST:urlForUpload
                           parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                            [formData appendPartWithFileData:imageData
                                                        name:@"file1"
                                                    fileName:imageName mimeType:@"multipart/form-data"];
                            
                            [formData appendPartWithFormData:[[[jsonResponse objectForKey:@"response"] objectForKey:@"id"] dataUsingEncoding:NSUTF8StringEncoding]
                                                        name:@"user_id"];
                            [formData appendPartWithFormData:[@"1" dataUsingEncoding:NSUTF8StringEncoding]
                                                        name:KEY_SHARE_FILETYPE];
                            [formData appendPartWithFormData:[KEY_AUTH_VALUE dataUsingEncoding:NSUTF8StringEncoding]
                                                           name:KEY_AUTH_KEY];
                            
                            NSLog(@"%@",formData);
                        }
                             progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                            lblmsg.hidden=YES;
                            NSLog(@"Response: %@", responseObject);
                            if ([[responseObject objectForKey:@"flag"] isEqualToString:@"success"]) {
                                [Appdelegate hideProgressHudInView];

                                UIAlertController * alert=   [UIAlertController
                                                              alertControllerWithTitle:@"Message"
                                                              message:MSG_RegisteredSucces
                                                              preferredStyle:UIAlertControllerStyleAlert];
                                
                                UIAlertAction* yesButton = [UIAlertAction
                                                            actionWithTitle:@"ok"
                                                            style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                                            {
                                                                [Appdelegate hideProgressHudInView];

                                                                //Handel your yes please button action here
                                                                _tf_first_name.text=nil;
                                                                _tf_last_name.text=nil;
                                                                _tf_email.text=nil;
                                                                _tf_username.text=nil;
                                                                _tf_password.text=nil;
                                                                _tf_confirmpass.text=nil;
                                                                _tf_dob_date.text=nil;
                                                                _tf_dob_month.text=nil;
                                                                _tf_dob_year.text=nil;
                                                                _tf_phone.text=nil;
                                                                _img_view_profile.image=[UIImage imageNamed:@"artist-with-headphone.png"];
                                                                _lbl_dob_error.text=nil;
                                                                _lbl_email_error.text=nil;
                                                                _lbl_fname_error.text=nil;
                                                                _lbl_phone_error.text=nil;
                                                                _lbl_password_error.text=nil;
                                                                _lbl_confirmpass_error.text=nil;
                                                                _lbl_usename_error.text=nil;
                                                                
                                                                [self performSegueWithIdentifier:@"go_to_login" sender:nil];
                                                                
                                                            }];
                                
                                
                                [alert addAction:yesButton];
                                [self presentViewController:alert animated:YES completion:nil];
                                
                            }
                            else if ([[responseObject objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                                [Appdelegate hideProgressHudInView];
                                UIAlertController * alert=   [UIAlertController
                                                              alertControllerWithTitle:@"Message"
                                                              message:@"Registered Successfully but unable to upload profile image !"
                                                              preferredStyle:UIAlertControllerStyleAlert];
                                
                                UIAlertAction* yesButton = [UIAlertAction
                                                            actionWithTitle:@"ok"
                                                            style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                                            {
                                                                //Handel your yes please button action here
                                                                [SVProgressHUD dismiss];
                                                            }];
                                
                                [alert addAction:yesButton];
                                [self presentViewController:alert animated:YES completion:nil];
                            }
                            else{
                                
                                UIAlertController * alert=   [UIAlertController
                                                              alertControllerWithTitle:@"Error"
                                                              message:@"Registered Successfully but unable to upload profile image !"
                                                              preferredStyle:UIAlertControllerStyleAlert];
                                
                                UIAlertAction* yesButton = [UIAlertAction
                                                            actionWithTitle:@"ok"
                                                            style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                                            {
                                                                [Appdelegate hideProgressHudInView];
                                                                [self performSegueWithIdentifier:@"go_to_login" sender:nil];
                                                            }];
                                [alert addAction:yesButton];
                                [self presentViewController:alert animated:YES completion:nil];
                            }
                            
                        } failure:^(NSURLSessionDataTask *task, NSError *error) {
                            lblmsg.hidden=YES;
                            NSLog(@"Error: %@", error);
                            [Appdelegate hideProgressHudInView];
                        }];
                    }
                    
                }
                else
                {
                    [Appdelegate hideProgressHudInView];

                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                        [Appdelegate hideProgressHudInView];

                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"Message"
                                                      message:[jsonResponse objectForKey:@"msg"]
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
                    }
                    
                    
                }
                
            });
        }
    }];
    [task resume];
    
}

- (IBAction)btn_clear_first_name:(id)sender {
    _tf_first_name.text=nil;
}

- (IBAction)btn_clear_last_name:(id)sender {
    _tf_last_name.text=nil;
}
- (IBAction)btn_clear_email:(id)sender {
    _tf_email.text=nil;
}

- (IBAction)btn_clear_username:(id)sender {
    _tf_username.text=nil;
}
- (IBAction)btn_clear_password:(id)sender {
    _tf_password.text=nil;
    _tf_confirmpass.text=nil;
}

- (IBAction)btn_clear_confirm_pass:(id)sender {
    _tf_confirmpass.text=nil;
}

- (IBAction)btn_clear_dob:(id)sender {
    _tf_dob_date.text=nil;
    _tf_dob_month.text=nil;
    _tf_dob_year.text=nil;
}

- (IBAction)btn_clear_phone:(id)sender {
    _tf_phone.text=nil;
}

- (IBAction)show_date_picker:(id)sender {
    [_tf_email resignFirstResponder];
    [_tf_phone resignFirstResponder];
    [_tf_password resignFirstResponder];
    [_tf_username resignFirstResponder];
    [_tf_first_name resignFirstResponder];
    [_tf_last_name resignFirstResponder];
    [_tf_dob_date resignFirstResponder];
    [_tf_dob_month resignFirstResponder];
    [_tf_dob_year resignFirstResponder];
    [_tf_confirmpass resignFirstResponder];
    
    dp_view=[[UIView alloc]initWithFrame:CGRectMake(0, 400,self.view.frame.size.width, self.view.frame.size.height-400)];
    dp_view.backgroundColor=[UIColor colorWithWhite:.8f alpha:.4];
   UIButton* btn_cancel=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn_cancel.frame=CGRectMake(30, dp_view.frame.size.height-80, dp_view.frame.size.width-60,50);
    [btn_cancel setBackgroundColor:[UIColor whiteColor]];
    [btn_cancel setTitle:@"Select" forState:UIControlStateNormal];
    btn_cancel.layer.cornerRadius=10;
    btn_cancel.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn_cancel addTarget:self action:@selector(hide_view:) forControlEvents:UIControlEventTouchUpInside];
    [dp_view addSubview:btn_cancel];
    
    
    UIButton*btn_cancel2=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn_cancel2.frame=CGRectMake(15,0,30,30);
    //[btn_cancel2 setTitle:@"v" forState:UIControlStateNormal];
    [btn_cancel2 setImage:[UIImage imageNamed:@"downarraow.png"] forState:UIControlStateNormal];
    [btn_cancel2 addTarget:self action:@selector(hide_view2:) forControlEvents:UIControlEventTouchUpInside];
    [dp_view addSubview:btn_cancel2];
    

    // Add the picker
    pickerView = [[UIDatePicker alloc] init];
    pickerView.datePickerMode = UIDatePickerModeDate;
    pickerView.backgroundColor=[UIColor whiteColor];
    pickerView.layer.cornerRadius=15;
    pickerView.layer.masksToBounds=YES;
     pickerView.frame=CGRectMake(30, 20,dp_view.frame.size.width-60, dp_view.frame.size.height-110);
    //[pickerView addTarget:sender action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [df setDateFormat:@"yyyy"];
    NSString *yearString = [df stringFromDate:[NSDate date]];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:[yearString integerValue]-4];
    NSDate *maxDate = [calendar dateFromComponents:comps];
    [comps setYear:1930];
    NSDate *minDate = [calendar dateFromComponents:comps];
    [df setDateFormat:@"dd/mmm/yyyy"];
    [pickerView setMaximumDate:maxDate];
    [pickerView setMinimumDate:minDate];
    
    [dp_view addSubview:pickerView];

    [self.view addSubview:dp_view];


}
-(void)hide_view:(id)sender{
    _lbl_dob_error.text=@"";
    dp_view.hidden=YES;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYY"];
    _tf_dob_year.text=[df stringFromDate:pickerView.date];
    [df setDateFormat:@"MMM"];
    _tf_dob_month.text=[df stringFromDate:pickerView.date];
    [df setDateFormat:@"dd"];
    _tf_dob_date.text=[df stringFromDate:pickerView.date];
}

-(void)hide_view2:(id)sender{
    _lbl_dob_error.text=@"";
    dp_view.hidden=YES;
   _tf_dob_year.text=nil;
    _tf_dob_month.text=nil;
    _tf_dob_date.text=nil;
}

- (IBAction) datePickerChanged:(id)sender {
    // When `setDate:` is called, if the passed date argument exactly matches the Picker's date property's value, the Picker will do nothing. So, offset the passed date argument by one second, ensuring the Picker scrolls every time.
   // NSDate* oneSecondAfterPickersDate = [pickerView.date dateByAddingTimeInterval:1] ;
    if ( [pickerView.date compare:pickerView.minimumDate] == NSOrderedSame ) {
        NSLog(@"date is at or below the minimum") ;
       // pickerView.date = oneSecondAfterPickersDate ;
    }
    else if ( [pickerView.date compare:pickerView.maximumDate] == NSOrderedSame ) {
        NSLog(@"date is at or above the maximum") ;
       // pickerView.date = oneSecondAfterPickersDate ;
    }
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
- (BOOL)validatePhone:(NSString *)phoneNumber
{
    //NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
    NSString *phoneRegex = @"[789][0-9]{9}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:phoneNumber];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS_ONLY] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return (([string isEqualToString:filtered])&&(newLength <= CHARACTER_LIMIT));
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqual:@"go_to_login"])
     {
         Appdelegate.isFirstTimeSignUp=YES;
         ViewController*vc=segue.destinationViewController;
         
         vc.open_login=@"0";
     }
     else
     {
        // ViewController*vc=segue.destinationViewController;
         //vc.open_login=@"0";

     }
 }

- (IBAction)btn_done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)btn_signin:(id)sender {
    [self performSegueWithIdentifier:@"go_to_login" sender:nil];
}
@end
