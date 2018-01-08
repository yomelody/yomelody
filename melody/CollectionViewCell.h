//
//  CollectionViewCell.h
//  melody
//
//  Created by CodingBrainsMini on 12/1/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell
{

}
@property (weak, nonatomic) IBOutlet UIImageView *img_cell_bg;
@property (weak, nonatomic) IBOutlet UIImageView *img_profile;
@property (weak, nonatomic) IBOutlet UILabel *lbl_username;
@property (weak, nonatomic) IBOutlet UIButton *btn_cancel;
@property (weak, nonatomic) IBOutlet UIView *view_username;

@end
