//
//  contactsTableViewCell.h
//  melody
//
//  Created by coding Brains on 20/01/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface contactsTableViewCell : UITableViewCell
{

}
@property (weak, nonatomic) IBOutlet UIImageView *img_view_profilepic;
@property (weak, nonatomic) IBOutlet UILabel *lbl_name;
@property (weak, nonatomic) IBOutlet UILabel *lbl_station;
@property (weak, nonatomic) IBOutlet UIButton *btn_select;

@end
