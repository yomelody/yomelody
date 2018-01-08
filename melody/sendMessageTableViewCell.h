//
//  receiveMessageTableViewCell.h
//  melody
//
//  Created by coding Brains on 22/12/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sendMessageTableViewCell : UITableViewCell
{

}
@property (weak, nonatomic) IBOutlet UIImageView *img_view_profile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_text;

@property (weak, nonatomic) IBOutlet UIImageView *img_view_msg;
@property (weak, nonatomic) IBOutlet UIView *view_msg_bg;
@property (weak, nonatomic) IBOutlet UITextView *txt_view_send;
@property (weak, nonatomic) IBOutlet UIImageView *img_background;
@property (weak, nonatomic) IBOutlet UILabel *lbl_date;
@property (weak, nonatomic) IBOutlet UIView *view_super;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cons_img_topSpace;

@end
