//
//  receiveTableViewCell.h
//  melody
//
//  Created by coding Brains on 12/01/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface receiveTableViewCell : UITableViewCell
{

}
@property (weak, nonatomic) IBOutlet UIView *view_msg_receive_bg;
@property (weak, nonatomic) IBOutlet UILabel *lbl_msg_receive;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_msg_receive;
@property (weak, nonatomic) IBOutlet UIImageView *img_view_profile_recevie;
@property (weak, nonatomic) IBOutlet UIImageView *img_background;
@property (weak, nonatomic) IBOutlet UILabel *lbl_date;
@property (weak, nonatomic) IBOutlet UIView *view_Super;
@property (weak, nonatomic) IBOutlet UIImageView *img_doubleTick;
@property (weak, nonatomic) IBOutlet UIImageView *img_attached;
@property (weak, nonatomic) IBOutlet UILabel *lbl_imgAttached;

//-------------- Constaraints Outlet ---------------------
//----------- For Image --------
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cons_img_leading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cons_img_height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cons_img_width;
//----------- For Label --------
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cons_lbl_height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cons_lbl_width;

@end
