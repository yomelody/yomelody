//
//  CommentMessegesTableViewCell.h
//  melody
//
//  Created by coding Brains on 26/12/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentMessegesTableViewCell : UITableViewCell
{

}
@property (weak, nonatomic) IBOutlet UIImageView *img_profile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_user_name;
@property (weak, nonatomic) IBOutlet UILabel *lbl_time;
@property (weak, nonatomic) IBOutlet UILabel *lbl_name;
@property (weak, nonatomic) IBOutlet UITextView *tv_comment;
@property (weak, nonatomic) IBOutlet UIButton *btn_delete_comment;

@end
