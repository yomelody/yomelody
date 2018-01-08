//
//  SignUpViewController.h
//  melody
//
//  Created by CodingBrainsMini on 12/3/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SignUpViewController : UIViewController<UITextFieldDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    int user_type;
    NSMutableDictionary*dic_response;
     NSData *imageData;
    NSString *imageName;
    int dob;
    UIView*dp_view;
    UIDatePicker*pickerView;
  
    NSMutableArray*arr_menu_items;
    UICollectionView*cv_images;

}


@property (weak, nonatomic) IBOutlet UIButton *btn_Done;

@property (weak, nonatomic) IBOutlet UIScrollView *croll_view_signupcontent;

@property (strong, nonatomic) UIDatePicker *theDatePicker;
@property (strong, nonatomic) UIView *pickerView;
- (IBAction)btn_done:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_profile;
@property (weak, nonatomic) IBOutlet UITextField *tf_username;
@property (weak, nonatomic) IBOutlet UITextField *tf_first_name;
@property (weak, nonatomic) IBOutlet UITextField *tf_last_name;
@property (weak, nonatomic) IBOutlet UITextField *tf_email;
@property (weak, nonatomic) IBOutlet UITextField *tf_password;
@property (weak, nonatomic) IBOutlet UITextField *tf_phone;
@property (weak, nonatomic) IBOutlet UIButton *btn_signup;
@property (weak, nonatomic) IBOutlet UITextField *tf_dob_date;
@property (weak, nonatomic) IBOutlet UITextField *tf_dob_month;
@property (weak, nonatomic) IBOutlet UITextField *tf_dob_year;
@property (weak, nonatomic) IBOutlet UILabel *lbl_fname_error;
@property (weak, nonatomic) IBOutlet UILabel *lbl_email_error;
@property (weak, nonatomic) IBOutlet UILabel *lbl_password_error;
@property (weak, nonatomic) IBOutlet UILabel *lbl_dob_error;
@property (weak, nonatomic) IBOutlet UILabel *lbl_phone_error;
@property (weak, nonatomic) IBOutlet UILabel *lbl_usename_error;
@property (weak, nonatomic) IBOutlet UITextField *tf_confirmpass;
@property (weak, nonatomic) IBOutlet UILabel *lbl_confirmpass_error;


- (IBAction)btn_add_image:(id)sender;
- (IBAction)btn_signup:(id)sender;
- (IBAction)btn_clear_first_name:(id)sender;
- (IBAction)btn_clear_last_name:(id)sender;
- (IBAction)btn_clear_email:(id)sender;
- (IBAction)btn_clear_username:(id)sender;
- (IBAction)btn_clear_password:(id)sender;
- (IBAction)btn_clear_confirm_pass:(id)sender;
- (IBAction)btn_clear_dob:(id)sender;
- (IBAction)btn_clear_phone:(id)sender;
- (IBAction)show_date_picker:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_signin;
- (IBAction)btn_signin:(id)sender;



@end
