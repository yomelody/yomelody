//
//  FansOrFollowingVC.h
//  melody
//
//  Created by coding Brains on 22/05/18.
//  Copyright © 2018 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FansOrFollowingVC : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *btn_back;
@property (weak, nonatomic) IBOutlet UIButton *btn_home;
@property (weak, nonatomic) IBOutlet UIButton *btn_search;
@property (weak, nonatomic) IBOutlet UILabel *lbl_header;
@property (weak, nonatomic) IBOutlet UITableView *tbl_fans_followings;
@property (strong, nonatomic) NSString *str_type;
@property (weak, nonatomic) IBOutlet UIImageView *img_placeholder;
@property (strong, nonatomic) NSString *userID;
@property (weak, nonatomic) IBOutlet UISearchBar *search_bar;
- (IBAction)searchAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_search_cancel;
- (IBAction)btn_searchAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *view_navigation;
@property (weak, nonatomic) IBOutlet UIView *view_search;

- (IBAction)btn_back:(id)sender;
- (IBAction)btn_home:(id)sender;
@end
