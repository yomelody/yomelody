//
//  UpdateAccountViewController.m
//  melody
//
//  Created by coding Brains on 24/12/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import "UpdateAccountViewController.h"
#import "imageCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Constant.h"

#define rad(angle) ((angle) / 180.0 * M_PI)

#define NUMBERS_ONLY @"1234567890"
#define CHARACTER_LIMIT 3
@interface UpdateAccountViewController ()

@end

@implementation UpdateAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self intializesAllVariables];

}

-(void)setAppVersion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    
    NSString *version = infoDictionary[@"CFBundleShortVersionString"];
    NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
    NSString *bundleName = infoDictionary[(NSString *)kCFBundleNameKey];
    
    NSString * str_ver = [NSString stringWithFormat:@"Version %@",version];
    _lbl_version.text = str_ver;
}


-(void)intializesAllVariables{
    // do initializes
    //---------- Set Version number ----------
    [self setAppVersion];
    //    _btn_add_image.layer.cornerRadius=_btn_add_image.frame.size.width/2;
    //    _btn_add_image.clipsToBounds=YES;
    [SVProgressHUD dismiss];
    [self.btn_Done setTitleColor:[UIColor colorWithRed:0.0f green:132.0f blue:200.0f alpha:.6] forState:UIControlStateNormal ];
    defaults_userdata=[NSUserDefaults standardUserDefaults];
    flag_edit_update=0;
    _tv_description.layer.borderWidth=.5f;
    _tv_description.layer.borderColor=(__bridge CGColorRef _Nullable)([UIColor grayColor]);
    _tv_description.layer.cornerRadius=10;
    
    _btn_add_image.layer.cornerRadius=10;

    _tv_description.delegate=self;
    // Do any additional setup after loading the view.
    self.scroll_view_Updatecontent.contentSize = CGSizeMake(0,self.view.frame.size.height+250);
    //_croll_view_signupcontent.contentSize = CGSizeMake(375, 810);
    dic_response=[[NSMutableDictionary alloc]init];
    imageData=[[NSData alloc]init];
    imageName=[[NSString alloc]init];
    user_type=1;
    dob=1;
    _tf_dob_date.tag=1;
    _tf_dob_month.tag=2;
    _tf_dob_year.tag=3;
    
    UIColor *color = [UIColor whiteColor];
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
    
    _img_view_profile.clipsToBounds = YES;
    _img_view_profile.layer.cornerRadius=_img_view_profile.frame.size.width/2;
    //    _img_view_profile.layer.cornerRadius = 25.0f;
    //    _img_view_profile.clipsToBounds = NO;
    _img_view_profile.userInteractionEnabled = YES;
    
    //    _btn_Update_edit.layer.cornerRadius=20;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.scroll_view_Updatecontent addGestureRecognizer:tap];
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
    
    if ([[defaults_userdata stringForKey:@"rememberme"] isEqual:@"remember"]) {
        _tf_password.textColor=[UIColor grayColor];
        _tf_confirmpass.textColor=[UIColor grayColor];
        
        _tf_first_name.textColor=[UIColor grayColor];
        _tf_last_name.textColor=[UIColor grayColor];
        _tf_username.textColor=[UIColor grayColor];
        _tf_email.textColor=[UIColor grayColor];
        _tf_phone.textColor=[UIColor grayColor];
        _tf_dob_date.textColor=[UIColor grayColor];
        _tf_dob_month.textColor=[UIColor grayColor];
        _tf_dob_year.textColor=[UIColor grayColor];
        _tv_description.textColor=[UIColor grayColor];
        _tf_password.userInteractionEnabled=NO;
        _tf_confirmpass.userInteractionEnabled=NO;
        _tf_first_name.userInteractionEnabled=NO;
        _tf_last_name.userInteractionEnabled=NO;
        _tf_username.userInteractionEnabled=NO;
        _tf_email.userInteractionEnabled=NO;
        _tf_phone.userInteractionEnabled=NO;
        _btn_show_datepicker.userInteractionEnabled=NO;
        _tv_description.userInteractionEnabled=NO;
        _tf_dob_date.userInteractionEnabled=NO;
        _tf_dob_month.userInteractionEnabled=NO;
        _tf_dob_year.userInteractionEnabled=NO;
        _btn_add_image.userInteractionEnabled=NO;
        _btn_clear_first_name.hidden=YES;
        _btn_clear_last_name.hidden=YES;
        _btn_clear_email.hidden=YES;
        _btn_clear_username.hidden=YES;
        _btn_clear_password.hidden=YES;
        _btn_clear_confirm_pass.hidden=YES;
        _btn_clear_dob.hidden=YES;
        _btn_clear_phone.hidden=YES;
        _btn_clear_description.hidden=YES;
        
        _tf_password.text=[defaults_userdata stringForKey:@"email"];
        _tf_confirmpass.text=[defaults_userdata stringForKey:@"email"];
        _tf_first_name.text=[defaults_userdata stringForKey:@"first_name"];
        _tf_last_name.text=[defaults_userdata stringForKey:@"last_name"];
        _tf_username.text=[defaults_userdata stringForKey:@"user_name"];
        _tf_email.text=[defaults_userdata stringForKey:@"email"];
        
        NSString*str_mob=[defaults_userdata stringForKey:@"mobile"];
        if ([[defaults_userdata stringForKey:@"mobile"] isEqual:@"0"] || str_mob==nil || [str_mob isEqual:@"<NULL>"] || str_mob.length<=6) {
            _tf_phone.text=nil;
        }
        else{
            _tf_phone.text=[defaults_userdata stringForKey:@"mobile"];
        }
        NSLog(@"%lu",(unsigned long)str_mob.length);
        if ([[defaults_userdata stringForKey:@"dob"] isEqual:@"0"]) {
            _tf_dob_date.text=nil;
            _tf_dob_month.text=nil;
            _tf_dob_year.text=nil;
        }
        else{
            NSArray*arr_bob=[[defaults_userdata stringForKey:@"dob"] componentsSeparatedByString:@"/"];
            NSLog(@"arr %lu",(unsigned long)[[arr_bob objectAtIndex:0] length]);
            if ([[arr_bob objectAtIndex:0] length]==4)
            {
                _tf_dob_date.text=[arr_bob objectAtIndex:2];
                _tf_dob_month.text=[arr_bob objectAtIndex:1];
                _tf_dob_year.text=[arr_bob objectAtIndex:0];
            }
            else
            {
                _tf_dob_date.text=[arr_bob objectAtIndex:0];
                _tf_dob_month.text=[arr_bob objectAtIndex:1];
                _tf_dob_year.text=[arr_bob objectAtIndex:2];
            }
        }
        
        NSData*data=[defaults_userdata objectForKey:@"profile_pic"];
        if (data.length!=0) {
            [_img_view_profile setImage:[UIImage imageWithData:[defaults_userdata objectForKey:@"profile_pic"]]];
            [_btn_add_image setTitle:@"" forState:UIControlStateNormal];
        }
        else
        {
            [_btn_add_image setTitle:@"Add image" forState:UIControlStateNormal];
        }
        if ([[defaults_userdata stringForKey:@"discription"] isEqual:@""]) {
            _tv_description.text=@"Add description";
        }else{
            _tv_description.text=[defaults_userdata stringForKey:@"discription"];
            
        }
        [SVProgressHUD dismiss];
    }
    
    
}

#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    //handle user taps text view to type text
    if ([_tv_description.text isEqual:@"Add description"]) {
        _tv_description.text=nil;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    //handle text editing finished
    if ([_tv_description.text isEqualToString:@""]) {
        _tv_description.text=@"Add description";
    }
    
}

/********end UITextViewDelegate ***************/

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
    [_tv_description resignFirstResponder];
    dp_view.hidden=YES;
}

- (void)viewDidAppear:(BOOL)animated {
    self.scroll_view_Updatecontent.frame = self.view.frame;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.scroll_view_Updatecontent.contentSize = CGSizeMake(0,self.view.frame.size.height+250);
    self.scroll_view_Updatecontent.scrollEnabled=YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -keyboardSize.height+90;
    }];

    self.scroll_view_Updatecontent.contentSize = CGSizeMake(0,self.view.frame.size.height+200+keyboardSize.height);
    self.scroll_view_Updatecontent.scrollEnabled=YES;
    dp_view.hidden=YES;
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
    self.scroll_view_Updatecontent.contentSize = CGSizeMake(0,self.view.frame.size.height+100);
}



- (IBAction)btn_add_image:(id)sender {
    
    
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
    UIImage *image = [Appdelegate.arr_Gallery_Items objectAtIndex:indexPath.item];
    float oldheight = image.size.height;
    float scaleFactor =cv_images.frame.size.height/ oldheight;
    float newwidth = image.size.width * scaleFactor;
    
    return CGSizeMake(newwidth, cv_images.frame.size.height);
}


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
    [_img_view_profile setImage:[Appdelegate.arr_Gallery_Items objectAtIndex:indexPath.item]];
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
    
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
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
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



-(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (UIImage *) scaleAndRotateImage: (UIImage *)image
{
    int kMaxResolution = 3000; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef),      CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}



- (IBAction)btn_Update_edit:(id)sender
{
    if (flag_edit_update==0) {
        _tf_password.textColor=[UIColor whiteColor];
        _tf_confirmpass.textColor=[UIColor whiteColor];
        
        if ([[defaults_userdata objectForKey:@"login_type"] isEqualToString:@"2"]) {
            _tf_username.userInteractionEnabled = NO;
            _tf_first_name.userInteractionEnabled=NO;
            _tf_last_name.userInteractionEnabled=NO;
            _tf_email.userInteractionEnabled=NO;//
            _tf_phone.userInteractionEnabled=YES;
            _btn_show_datepicker.userInteractionEnabled=YES;
            _tv_description.userInteractionEnabled=YES;
            
            _btn_add_image.userInteractionEnabled=NO;
            
            _tf_email.textColor=[UIColor whiteColor];
            _tf_phone.textColor=[UIColor whiteColor];
            //_tf_username.textColor=[UIColor whiteColor];
            _tf_first_name.textColor=[UIColor grayColor];
            
            _tf_last_name.textColor=[UIColor grayColor];
            _tf_username.textColor=[UIColor grayColor];
            _btn_add_image.hidden = YES;
            
            _btn_clear_first_name.hidden=YES;
            _btn_clear_last_name.hidden=YES;
            _btn_clear_username.hidden=YES;
            _btn_clear_phone.hidden=NO;
            flag_edit_update=1;
            [_btn_Update_edit setTitle:@"Update" forState:UIControlStateNormal];
            
            _tf_password.text=nil;
            _tf_confirmpass.text=nil;
        }
        else if ([[defaults_userdata objectForKey:@"login_type"] isEqualToString:@"3"])
        {
            _tf_username.userInteractionEnabled = NO;
            _tf_first_name.userInteractionEnabled=NO;
            _tf_last_name.userInteractionEnabled=NO;
            _tf_email.userInteractionEnabled=NO;//14Nov
            _tf_phone.userInteractionEnabled=YES;
            _btn_show_datepicker.userInteractionEnabled=YES;
            _tv_description.userInteractionEnabled=YES;
            
            _btn_add_image.userInteractionEnabled=NO;
            
            _tf_email.textColor=[UIColor whiteColor];
            _tf_phone.textColor=[UIColor whiteColor];
            
            _tf_first_name.textColor=[UIColor grayColor];
            
            _tf_last_name.textColor=[UIColor grayColor];
            _tf_username.textColor=[UIColor grayColor];
            _btn_add_image.hidden = YES;
            _btn_clear_email.hidden=YES;//14Nov
            _btn_clear_first_name.hidden=YES;
            _btn_clear_last_name.hidden=YES;
            _btn_clear_username.hidden=YES;
            flag_edit_update=1;
            [_btn_Update_edit setTitle:@"Update" forState:UIControlStateNormal];
            
            _tf_password.text=nil;
            _tf_confirmpass.text=nil;
        }
        else
        {
            _tf_first_name.textColor=[UIColor whiteColor];
            _tf_last_name.textColor=[UIColor whiteColor];
            _tf_username.textColor=[UIColor whiteColor];
            _tf_phone.textColor=[UIColor whiteColor];
            _tf_dob_date.textColor=[UIColor whiteColor];
            _tf_dob_month.textColor=[UIColor whiteColor];
            _tf_dob_year.textColor=[UIColor whiteColor];
            _tv_description.textColor=[UIColor whiteColor];
            
            _tf_password.userInteractionEnabled=YES;
            _tf_confirmpass.userInteractionEnabled=YES;
            _tf_first_name.userInteractionEnabled=YES;
            _tf_last_name.userInteractionEnabled=YES;
            _tf_username.userInteractionEnabled=NO;
            _tf_email.userInteractionEnabled=NO;//14Nov
            _tf_phone.userInteractionEnabled=YES;
            _btn_show_datepicker.userInteractionEnabled=YES;
            _tv_description.userInteractionEnabled=YES;
            
            _btn_add_image.userInteractionEnabled=YES;
            _btn_clear_first_name.hidden=NO;
            _btn_clear_last_name.hidden=NO;
            _btn_clear_email.hidden=YES;//14Nov
            _btn_clear_username.hidden=YES;
            _btn_clear_password.hidden=NO;
            _btn_clear_confirm_pass.hidden=NO;
            _btn_clear_dob.hidden=NO;
            _btn_clear_phone.hidden=NO;
            _btn_clear_description.hidden=NO;
            _tf_password.text=nil;
            _tf_confirmpass.text=nil;
            
            _btn_add_image.hidden = NO;
            [_btn_add_image setBackgroundImage:[UIImage imageNamed:@"profile_shadow.png"] forState:UIControlStateNormal];
            
            [_btn_add_image setTitle:@"Add image" forState:UIControlStateNormal];
            
            [_btn_Update_edit setTitle:@"Update" forState:UIControlStateNormal];
            flag_edit_update=1;
            
        }
    }
    else if(flag_edit_update==1){
        
        
        [self NSStringIsValidEmail:_tf_email.text];
        if ([_tf_first_name.text length]!=0 && [_tf_email.text length] !=0 && [_tf_username.text length]!=0  && [_tf_username.text length]>1) {
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
            
            if ([_tf_phone.text length]==0) {
                _lbl_phone_error.text=@"Required";
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
            
            if ([_tf_dob_date.text length]==0 || [_tf_dob_month.text length]==0 || [_tf_dob_year.text length]==0 ) {
                _lbl_dob_error.text=@"Required";
            }
            
        }
        
    }
}
- (IBAction)btn_signup:(id)sender {
    
    [self NSStringIsValidEmail:_tf_email.text];
    NSLog([self NSStringIsValidEmail:_tf_email.text] ? @"Yes" : @"No");
    
    if ([_tf_first_name.text length]!=0 && [_tf_email.text length] !=0 && [_tf_username.text length]!=0 && [_tf_password.text length]!=0 && [_tf_dob_date.text length]!=0  && [_tf_dob_month.text length]!=0 && [_tf_dob_year.text length]!=0 && [_tf_password.text length]>7) {
        
        if ([self NSStringIsValidEmail:_tf_email.text] && [_tf_password.text isEqualToString:_tf_confirmpass.text])
        {
            if ([_tf_phone.text length]!=0) {
                if ([_tf_phone.text length] >=10 && [_tf_phone.text length] <=16)
                {
                    if ([_tf_username.text length]>1 && [_tf_confirmpass.text length]!=0) {
                        if ([_tf_username.text isEqualToString:_tf_email.text] && [_tf_confirmpass.text isEqualToString:_tf_email.text]) {
                            [self signup_call];
                        }
                        else
                        {
                            if ([_tf_password.text isEqualToString:_tf_confirmpass.text]) {
                                [self signup_call];
                            }
                            else
                            {
                                _lbl_password_error.text=@"Confirm password ";
                            }
                        }
                    }
                    else
                    {
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
                    }
                    
                }
                else{
                    _lbl_phone_error.text=@"incorrect phone number";
                }

            }
            else
            {
                if ([_tf_username.text length]>1 && [_tf_confirmpass.text length]!=0) {
                    if ([_tf_username.text isEqualToString:_tf_email.text] && [_tf_confirmpass.text isEqualToString:_tf_email.text]) {
                        [self signup_call];
                    }
                    else
                    {
                        if ([_tf_password.text isEqualToString:_tf_confirmpass.text]) {
                            [self signup_call];
                        }
                        else
                        {
                            _lbl_password_error.text=@"Confirm password ";
                        }
                    }
                }
                else
                {
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
                }
                
            }
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
        if ([_tf_dob_date.text length]==0 || [_tf_dob_month.text length]==0 || [_tf_dob_year.text length]==0 ) {
            _lbl_dob_error.text=@"Required";
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
    
    NSString * DOB = [[NSString alloc]initWithFormat:@"%@/%@/%@",_tf_dob_date.text,_tf_dob_month.text,_tf_dob_year.text];
    NSString*str_pass=[[NSString alloc]init];
    if ([_tf_password.text isEqualToString:_tf_email.text]) {
        str_pass=@"";
    }
    else{
        str_pass=_tf_password.text;
    }
    NSString*str_description=[[NSString alloc]init];
    if ([_tv_description.text isEqualToString:@"Add description"]) {
        str_description=@"";
    }
    else{
        str_description=_tv_description.text;
    }
    [SVProgressHUD setForegroundColor:[UIColor greenColor]];
    [SVProgressHUD show];
    NSDictionary* params = @{
                             KEY_AUTH_KEY:KEY_AUTH_VALUE,
                             @"user_id":[defaults_userdata objectForKey:@"user_id"],
                             @"fname":_tf_first_name.text,
                             @"lname":_tf_last_name.text,
                             @"email":_tf_email.text,
                             @"password":str_pass,
                             @"username":_tf_username.text,
                             @"dob":DOB ,
                             @"phone":_tf_phone.text,
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
    NSString* urlString = [NSString stringWithFormat:@"%@updateprofile.php",BaseUrl];
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
            [SVProgressHUD dismiss];
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
        }
        else
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                NSError *myError = nil;
                
                NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSLog(@"%@",requestReply);
                NSData *data = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:kNilOptions
                                                                               error:&myError];
                
                
                NSLog(@"%@",jsonResponse);
                if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    UILabel*lblmsg=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-200)/2,( self.view.frame.size.height-100)/2, 200, 100)];
                    lblmsg.backgroundColor=[UIColor colorWithWhite:1 alpha:.5];
                    lblmsg.text=@"Registered Successfuly!";
                    lblmsg.textAlignment=NSTextAlignmentCenter;
                    lblmsg.layer.cornerRadius=10;
                    lblmsg.clipsToBounds = YES;
                    [self.view addSubview:lblmsg];
                    
                    if ( imageData.length==0)
                    {
                        lblmsg.hidden=YES;
                        dic_response=[jsonResponse objectForKey:@"response"];
                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"Message"
                                                      message:@"Information Updated Successfully!"
                                                      preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* yesButton = [UIAlertAction
                                                    actionWithTitle:@"ok"
                                                    style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action)
                                                    {
                                                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"username"]] forKey:@"user_name"];
                                                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"fname"]] forKey:@"first_name"];
                                                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"lname"]] forKey:@"last_name"];
                                                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"description"]] forKey:@"discription"];
                                                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"email"]] forKey:@"email"];
                                                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"dob"]] forKey:@"dob"];
                                                        [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"mobile"]] forKey:@"mobile"];
                                                       

                                                        _tf_password.textColor=[UIColor grayColor];
                                                        _tf_confirmpass.textColor=[UIColor grayColor];
                                                        
                                                        _tf_first_name.textColor=[UIColor grayColor];
                                                        _tf_last_name.textColor=[UIColor grayColor];
                                                        _tf_username.textColor=[UIColor grayColor];
                                                        _tf_email.textColor=[UIColor grayColor];
                                                        _tf_phone.textColor=[UIColor grayColor];
                                                        _tf_dob_date.textColor=[UIColor grayColor];
                                                        _tf_dob_month.textColor=[UIColor grayColor];
                                                        _tf_dob_year.textColor=[UIColor grayColor];
                                                        _tv_description.textColor=[UIColor grayColor];
                                                        
                                                        _tf_password.userInteractionEnabled=NO;
                                                        _tf_confirmpass.userInteractionEnabled=NO;
                                                        _tf_first_name.userInteractionEnabled=NO;
                                                        _tf_last_name.userInteractionEnabled=NO;
                                                        _tf_username.userInteractionEnabled=NO;
                                                        _tf_email.userInteractionEnabled=NO;
                                                        _tf_phone.userInteractionEnabled=NO;
                                                        _btn_show_datepicker.userInteractionEnabled=NO;
                                                        _tv_description.userInteractionEnabled=NO;
                                                        
                                                        _btn_add_image.userInteractionEnabled=NO;
                                                        _btn_clear_first_name.hidden=YES;
                                                        _btn_clear_last_name.hidden=YES;
                                                        _btn_clear_email.hidden=YES;
                                                        _btn_clear_username.hidden=YES;
                                                        _btn_clear_password.hidden=YES;
                                                        _btn_clear_confirm_pass.hidden=YES;
                                                        _btn_clear_dob.hidden=YES;
                                                        _btn_clear_phone.hidden=YES;
                                                        _btn_clear_description.hidden=YES;
                                                        
                                                        _tf_password.text=[defaults_userdata stringForKey:@"email"];
                                                        _tf_confirmpass.text=[defaults_userdata stringForKey:@"email"];
                                                        
                                                        [_btn_add_image setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                                                        [_btn_add_image setTitle:@"" forState:UIControlStateNormal];
                                                        [_btn_Update_edit setTitle:@"Edit profile" forState:UIControlStateNormal];
                                                        flag_edit_update=0;
                                                        
                                                    }];
                        
                        
                        [alert addAction:yesButton];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    else{
                         dic_response=[jsonResponse objectForKey:@"response"];
                        
                        [SVProgressHUD show];
                        lblmsg.text=@"Uploading profile image!";
                        
                        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                        [manager POST:[NSString stringWithFormat:@"%@uploadfile.php",BaseUrl] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                            [formData appendPartWithFileData:imageData
                                                        name:@"file1"
                                                    fileName:imageName mimeType:@"multipart/form-data"];
                            
                            [formData appendPartWithFormData:[[[jsonResponse objectForKey:@"response"] objectForKey:@"id"] dataUsingEncoding:NSUTF8StringEncoding]
                                                        name:@"user_id"];
                            [formData appendPartWithFormData:[@"1" dataUsingEncoding:NSUTF8StringEncoding]
                                                        name:KEY_SHARE_FILETYPE];
                            [formData appendPartWithFormData:[KEY_AUTH_VALUE dataUsingEncoding:NSUTF8StringEncoding]
                                                        name:KEY_AUTH_KEY];
                            
                            // etc.
                            NSLog(@"%@",formData);
                        } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                            lblmsg.hidden=YES;
                            NSLog(@"Response: %@", responseObject);
                            [SVProgressHUD dismiss];
                            if ([[responseObject objectForKey:@"flag"] isEqualToString:@"success"]) {
                                imageData=[[NSData alloc]init];
                                UIAlertController * alert=   [UIAlertController
                                                              alertControllerWithTitle:@"Message"
                                                              message:@"Information Updated Successfully !"
                                                              preferredStyle:UIAlertControllerStyleAlert];
                                
                                UIAlertAction* yesButton = [UIAlertAction
                                                            actionWithTitle:@"ok"
                                                            style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action)
                                                            {
                                                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"username"]] forKey:@"user_name"];
                                                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"fname"]] forKey:@"first_name"];
                                                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"lname"]] forKey:@"last_name"];
                                                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"description"]] forKey:@"discription"];
                                                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"email"]] forKey:@"email"];
                                                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"dob"]] forKey:@"dob"];
                                                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[dic_response objectForKey:@"mobile"]] forKey:@"mobile"];
                                                                [defaults_userdata setObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"response"] objectForKey:@"profilepic"]]]] forKey:@"profile_pic"];
                                                                [defaults_userdata setObject:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"response"] objectForKey:@"profilepic"]] forKey:@"profile_pic_url"];
                                                                [defaults_userdata synchronize];
                                                                _tf_password.textColor=[UIColor grayColor];
                                                                _tf_confirmpass.textColor=[UIColor grayColor];
                                                                
                                                                _tf_first_name.textColor=[UIColor grayColor];
                                                                _tf_last_name.textColor=[UIColor grayColor];
                                                                _tf_username.textColor=[UIColor grayColor];
                                                                _tf_email.textColor=[UIColor grayColor];
                                                                _tf_phone.textColor=[UIColor grayColor];
                                                                _tf_dob_date.textColor=[UIColor grayColor];
                                                                _tf_dob_month.textColor=[UIColor grayColor];
                                                                _tf_dob_year.textColor=[UIColor grayColor];
                                                                _tv_description.textColor=[UIColor grayColor];
                                                                
                                                                _tf_password.userInteractionEnabled=NO;
                                                                _tf_confirmpass.userInteractionEnabled=NO;
                                                                _tf_first_name.userInteractionEnabled=NO;
                                                                _tf_last_name.userInteractionEnabled=NO;
                                                                _tf_username.userInteractionEnabled=NO;
                                                                _tf_email.userInteractionEnabled=NO;
                                                                _tf_phone.userInteractionEnabled=NO;
                                                                _btn_show_datepicker.userInteractionEnabled=NO;
                                                                _tv_description.userInteractionEnabled=NO;
                                                                
                                                                _btn_add_image.userInteractionEnabled=NO;
                                                                _btn_clear_first_name.hidden=YES;
                                                                _btn_clear_last_name.hidden=YES;
                                                                _btn_clear_email.hidden=YES;
                                                                _btn_clear_username.hidden=YES;
                                                                _btn_clear_password.hidden=YES;
                                                                _btn_clear_confirm_pass.hidden=YES;
                                                                _btn_clear_dob.hidden=YES;
                                                                _btn_clear_phone.hidden=YES;
                                                                _btn_clear_description.hidden=YES;
                                                                
                                                                _tf_password.text=[defaults_userdata stringForKey:@"email"];
                                                                _tf_confirmpass.text=[defaults_userdata stringForKey:@"email"];
                                                                
                                                                [_btn_add_image setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                                                                [_btn_add_image setTitle:@"" forState:UIControlStateNormal];
                                                                [_btn_Update_edit setTitle:@"Edit profile" forState:UIControlStateNormal];
                                                                flag_edit_update=0;
                                                            }];
                                
                                
                                [alert addAction:yesButton];
                                [self presentViewController:alert animated:YES completion:nil];
                                
                            }
                            else if ([[responseObject objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                                [SVProgressHUD dismiss];
                                UIAlertController * alert=   [UIAlertController
                                                              alertControllerWithTitle:@"Message"
                                                              message:@"Information Updated Successfully but unable to upload profile image !"
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
                                [SVProgressHUD dismiss];
                                
                                UIAlertController * alert=   [UIAlertController
                                                              alertControllerWithTitle:@"Error"
                                                              message:@"Request error!"
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
                            lblmsg.hidden=YES;
                            NSLog(@"Error: %@", error);
                            [SVProgressHUD dismiss];
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
                            [self presentViewController:alert animated:YES completion:nil];                        }];
                        
                    }
                    
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

- (IBAction)btn_clear_description:(id)sender {
    _tv_description.text=@"Add description";
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
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


- (BOOL)validatePhone:(NSString *)phoneNumber
{
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
    if ([segue.identifier isEqual:@"go_to_login"]) {
        //         ViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];
        ViewController*vc=segue.destinationViewController;
        vc.open_login=@"1";
    }
    else{
        ViewController*vc=segue.destinationViewController;
        vc.open_login=@"0";
        
    }
}


- (IBAction)btn_done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)btn_signin:(id)sender {
    [self performSegueWithIdentifier:@"go_to_login" sender:nil];
}
@end
