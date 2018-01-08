//
//  MessengerViewController.h
//  melody
//
//  Created by CodingBrainsMini on 11/21/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessengerViewController : UIViewController
{
    
    NSMutableArray*arr_receiver_name;
    NSMutableArray*arr_receiver_id;
    NSMutableArray*arr_chat_id;
    NSMutableArray*arr_receiver_profile;
    NSMutableArray*arr_receiver_msg;
    NSMutableArray*arr_date_time;
    NSMutableArray*arr_isread;
    NSMutableArray*arr_sender_id;
    NSMutableArray*arr_sender_name;
    NSInteger index;

}
- (IBAction)btn_back:(id)sender;
- (IBAction)btn_home:(id)sender;

- (IBAction)btn_msg_to_new_contact:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tbl_view_messages_list;
/***************Bottom tab outlet***************/
@property (weak, nonatomic) IBOutlet UIButton *btn_audiofeed;
@property (weak, nonatomic) IBOutlet UIButton *btn_discover;
@property (weak, nonatomic) IBOutlet UIButton *btn_messenger;
@property (weak, nonatomic) IBOutlet UIButton *btn_profile;
- (IBAction)btn_audiofeed:(id)sender;
- (IBAction)btn_discover:(id)sender;
- (IBAction)btn_messenger:(id)sender;
- (IBAction)btn_profile:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *noConversationLbl;
@property (weak, nonatomic) IBOutlet UIImageView *img_placeholderNoConversation;
@property (nonatomic, assign) BOOL isBack;

/*********************************************/

@property(nonatomic , strong)NSString* str_screen_type;
@property(nonatomic , strong)NSString* str_file_id;
@property (nonatomic, assign) BOOL isShare_Audio;

@end
