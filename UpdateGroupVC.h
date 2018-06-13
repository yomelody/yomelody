//
//  UpdateGroupVC.h
//  melody
//
//  Created by coding Brains on 06/09/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateGroupVC : UIViewController<UIImagePickerControllerDelegate>
{
    UICollectionView*cv_images;
    NSData*imageData;
    NSString*imageName;
    UIImagePickerController *picker;
    NSArray *searchMemberList;
    BOOL isSearch;
}

//-------------------- IBAction ---------------------
- (IBAction)btn_back:(id)sender;
- (IBAction)btn_home:(id)sender;
- (IBAction)btn_invite:(id)sender;
- (IBAction)btn_DoneAction:(id)sender;
- (IBAction)btn_EditAction:(id)sender;
- (IBAction)btn_AddMemberAction:(id)sender;
- (IBAction)closeButtonAction:(id)sender;

//-------------------- IBOutlet ---------------------
@property (weak, nonatomic) IBOutlet UIButton *btn_profileImage;
@property (weak, nonatomic) IBOutlet UIView *addMemberView;
@property (weak, nonatomic) IBOutlet UISearchBar *Member_SearchBar;
@property (weak, nonatomic) IBOutlet UITableView *tbl_View_GroupMembers;
@property (weak, nonatomic) IBOutlet UITextField *tft_GroupName;
@property (weak, nonatomic) IBOutlet UITableView *tbl_View_AllMember;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIButton *btn_edit;
@property (weak, nonatomic) IBOutlet UIImageView *groupNameEditImageView;
//-------------------- Property ---------------------
@property (weak, nonatomic) IBOutlet UIView *UpdateGImageView;
@property(nonatomic , strong)NSString* str_chat_id;
@property (strong, nonatomic)  NSString *str_GroupImage;
@property (strong, nonatomic)  NSString *str_GroupName;
@property (weak, nonatomic) IBOutlet UIButton *addMemberButtonO;
@property (strong, nonatomic) IBOutlet UILabel *totalMembers_Lbl;
@property (weak, nonatomic) IBOutlet UIButton *btn_done;
@property (weak, nonatomic) IBOutlet UIButton *btn_exitGroup;
- (IBAction)btn_exitGroupAction:(id)sender;


@end
