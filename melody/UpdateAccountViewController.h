//
//  UpdateAccountViewController.h
//  melody
//
//  Created by coding Brains on 24/12/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@interface UpdateAccountViewController : UIViewController<UITextFieldDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UITextViewDelegate>
{
    int user_type;
    NSMutableDictionary*dic_response;
    NSData *imageData;
    NSString *imageName;
    int dob;
    UIView*dp_view;
    UIDatePicker*pickerView;
    NSUserDefaults*defaults_userdata;
    NSMutableArray*arr_menu_items;
    UICollectionView*cv_images;
    int flag_edit_update;
    
}


@property (weak, nonatomic) IBOutlet UIScrollView *scroll_view_Updatecontent;
@property (weak, nonatomic) IBOutlet UIButton *btn_Done;

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
@property (weak, nonatomic) IBOutlet UIButton *btn_Update_edit;
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

@property (weak, nonatomic) IBOutlet UIButton *btn_add_image;
@property (weak, nonatomic) IBOutlet UIButton *btn_clear_first_name;
@property (weak, nonatomic) IBOutlet UIButton *btn_clear_last_name;
@property (weak, nonatomic) IBOutlet UIButton *btn_clear_email;
@property (weak, nonatomic) IBOutlet UIButton *btn_clear_username;
@property (weak, nonatomic) IBOutlet UIButton *btn_clear_password;
@property (weak, nonatomic) IBOutlet UIButton *btn_clear_confirm_pass;
@property (weak, nonatomic) IBOutlet UIButton *btn_clear_dob;
@property (weak, nonatomic) IBOutlet UIButton *btn_clear_phone;

- (IBAction)btn_add_image:(id)sender;
- (IBAction)btn_Update_edit:(id)sender;
- (IBAction)btn_clear_first_name:(id)sender;
- (IBAction)btn_clear_last_name:(id)sender;
- (IBAction)btn_clear_email:(id)sender;
- (IBAction)btn_clear_username:(id)sender;
- (IBAction)btn_clear_password:(id)sender;
- (IBAction)btn_clear_confirm_pass:(id)sender;
- (IBAction)btn_clear_dob:(id)sender;
- (IBAction)btn_clear_phone:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_clear_description;
- (IBAction)btn_clear_description:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_show_datepicker;


- (IBAction)show_date_picker:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_signin;
- (IBAction)btn_signin:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *tv_description;
@property (weak, nonatomic) IBOutlet UILabel *lbl_version;



@end
