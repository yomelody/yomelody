//
//  messagesTableViewCell.h
//  melody
//
//  Created by CodingBrainsMini on 11/23/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface messagesTableViewCell : UITableViewCell
{

}
@property (weak, nonatomic) IBOutlet UIImageView *img_view_profileimage;
@property (weak, nonatomic) IBOutlet UILabel *lbl_sender_name;
@property (weak, nonatomic) IBOutlet UILabel *lbl_message;
@property (weak, nonatomic) IBOutlet UILabel *lbl_timing;
@property (weak, nonatomic) IBOutlet UIButton *btn_next;
@property (weak, nonatomic) IBOutlet UIImageView *img_RedCircle;
@property (weak, nonatomic) IBOutlet UILabel *lbl_MsgCount;

@end
