//
//  contactsViewController.h
//  melody
//
//  Created by coding Brains on 20/01/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface contactsViewController : UIViewController<UISearchBarDelegate>
{
    NSMutableArray*arr_user_select;
    NSMutableArray*arr_users_name,*arr_users_lname;
    NSMutableArray*arr_users_username;
    NSMutableArray*arr_users_devicetoken;
    NSMutableArray*arr_users_profile;
    NSMutableArray*arr_users_id;
    NSMutableArray*arr_selected_users;
    NSString *str_receiver_name;

    //arr_receiver_name
    NSArray *searchContactList;
    long receiver_index;
    NSMutableArray *contactList;
    BOOL isSearch;
}
- (IBAction)btn_home:(id)sender;
- (IBAction)btn_back:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn_ok;
@property (weak, nonatomic) IBOutlet UITableView *tbl_view_contacts;
@property (weak, nonatomic) NSString *str_contactListEMPTY;
@property (weak, nonatomic) IBOutlet UIImageView *img_placeholderNoContact;
@property (weak, nonatomic) NSMutableDictionary *dic_contactListM;

@property(nonatomic , strong)NSString* str_screen_type;
@property(nonatomic , strong)NSString* str_file_id;
@property (nonatomic, assign) BOOL isShare_Audio;
- (IBAction)openPhoneContacts_BtnAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *phoneContactsView;
@property (weak, nonatomic) IBOutlet UITableView *tbl_view_PhoneContacts;
- (IBAction)closeBtn:(id)sender;

@property (strong, nonatomic) IBOutlet UISearchBar *Pcontact_searchBar;
@property (strong, nonatomic) IBOutlet UISearchBar *Contact_SearchBar;


@end
