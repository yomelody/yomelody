//
//  UsersTableViewCell.h
//  melody
//
//  Created by coding Brains on 24/05/18.
//  Copyright © 2018 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UsersTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *btn_profile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_userName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_userFullName;
@property (weak, nonatomic) IBOutlet UIButton *btn_messanger;
@property (weak, nonatomic) IBOutlet UIButton *btn_follow;
- (IBAction)btn_messenger_action:(id)sender;
- (IBAction)btn_follow_action:(id)sender;

@end
