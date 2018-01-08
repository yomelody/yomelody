//
//  SocialSettingsViewController.h
//  melody
//
//  Created by coding Brains on 24/12/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SocialSettingsViewController : UIViewController
{
    NSUserDefaults*defaults_userdata;
}
- (IBAction)btn_done:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *switch_fb;
@property (weak, nonatomic) IBOutlet UISwitch *switch_twitter;
@property (weak, nonatomic) IBOutlet UISwitch *switch_google;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_main_logo;
@property (weak, nonatomic) IBOutlet UIView *view_profile_afterlogin;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_profile_pic;
@property (weak, nonatomic) IBOutlet UILabel *lbl_username;
@property (weak, nonatomic) IBOutlet UILabel *lbl_user_station;
//------------------- Actions --------------------
- (IBAction)switch_FBAction:(id)sender;
- (IBAction)switch_TwitterAction:(id)sender;
- (IBAction)switch_GoogleAction:(id)sender;



@end
