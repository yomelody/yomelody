//
//  contactsViewController.m
//  melody
//
//  Created by coding Brains on 20/01/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import "contactsViewController.h"
#import "Constant.h"

@interface contactsViewController ()<MFMessageComposeViewControllerDelegate>
{
    BOOL isArray;
    NSInteger indexCurrentUSer;
    NSMutableArray *arr_contactListM;
    UIView *backView;
    
    UILabel *noContactsLbl,*noFolContactsLbl;
}
@end

@implementation contactsViewController

#pragma mark - Initial Method
#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tbl_view_contacts.hidden = NO;
    isSearch = NO;
    self.img_placeholderNoContact.hidden = YES;
    [self initializeAllVaribles];
    _phoneContactsView.hidden= YES;
    _phoneContactsView.layer.cornerRadius = 4.0f;
    _Pcontact_searchBar.delegate = self;
    
    //--------------- For Phone Contact * Placeholder -----------------

    noContactsLbl = [[UILabel alloc] initWithFrame:CGRectMake(_phoneContactsView.frame.origin.x, _phoneContactsView.frame.size.height/2,_phoneContactsView.frame.size.width,40)];
    noContactsLbl.text= @"No Contacts";
    noContactsLbl.textAlignment= NSTextAlignmentCenter;
    noContactsLbl.textColor=[UIColor grayColor];
    [_phoneContactsView addSubview:noContactsLbl];
    
    //----------- For Messenger(YOMelody) Contact * Placeholder -------------
    noFolContactsLbl = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height/2,self.view.frame.size.width,40)];
    noFolContactsLbl.text= @"No Contacts";
    noFolContactsLbl.textAlignment= NSTextAlignmentCenter;
    noFolContactsLbl.textColor=[UIColor grayColor];
    [self.view addSubview:noFolContactsLbl];
}

-(void)initializeAllVaribles{
    isArray = YES;
//    if (_dic_contactListM != nil) {
//
//        if([[_dic_contactListM valueForKey:@"contact_string"] isEqualToString:@"your friend list is empty"]){
//            isArray = NO;
//        }
//    }
    NSLog(@"arr = %@",arr_contactListM);
    [_btn_ok addTarget:self action:@selector(go_chat_screen:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)viewWillAppear:(BOOL)animated{
//
    arr_selected_users=[[NSMutableArray alloc]init];
    arr_user_select=[[NSMutableArray alloc]init];
     [self btn_inviteMethod];
}


#pragma mark - TableView Delegates & Datasource
#pragma mark -

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tbl_view_PhoneContacts) {
        if (isSearch) {
            return [searchContactList count];
        }
        else{
            return [contactList count];
        }    }
    else
    {
    if (arr_contactListM != nil) {
        if (isSearch) {
            return [searchContactList count];
        }
        else{
            return [arr_contactListM count];
        }    }
    else{
        return 0;
    }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 86;
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    contactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    if (tableView == _tbl_view_PhoneContacts) {
        if (cell == nil)
        {
            NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"contactsTableViewCell"
                             
                                                          owner:self options:nil];
            
            cell = (contactsTableViewCell *)[nib2 objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.img_view_profilepic.layer.cornerRadius = cell.img_view_profilepic.frame.size.width / 2;
            cell.img_view_profilepic.clipsToBounds = YES;
            // cell.btn_select.layer.cornerRadius=cell.btn_select.frame.size.width / 2;
            cell.btn_select.clipsToBounds = YES;
            cell.btn_select.hidden= YES;
            
            UILabel *inviteLbl = [[UILabel alloc] initWithFrame:CGRectMake(self.tbl_view_PhoneContacts.frame.size.width -80, cell.lbl_name.frame.origin.y+2, 60, 30)];
            
            if (isSearch) {
                if ([[searchContactList objectAtIndex:indexPath.row] objectForKey:@"Phone"]==nil) {
                    inviteLbl.backgroundColor = [UIColor lightGrayColor];
                }
                else{
                    inviteLbl.backgroundColor = [UIColor redColor];
                }
                
                inviteLbl.text = @"Invite";
                inviteLbl.textColor= [UIColor whiteColor];
                inviteLbl.layer.masksToBounds = YES;
                inviteLbl.layer.cornerRadius = 8.0f;
                inviteLbl.textAlignment = NSTextAlignmentCenter;
                [cell addSubview:inviteLbl];
                
                cell.btn_select.tag=indexPath.row;
                //[cell.btn_select addTarget:self action:@selector(select_user:) forControlEvents:UIControlEventTouchUpInside];
                cell.lbl_name.text=[[searchContactList objectAtIndex:indexPath.row] objectForKey:@"name"];
                
                if ([[searchContactList objectAtIndex:indexPath.row] objectForKey:@"image"] == nil)
                {
                    cell.img_view_profilepic.image= [UIImage imageNamed:@"artist.png"];
                }
                else
                {
                    cell.img_view_profilepic.image= [[searchContactList objectAtIndex:indexPath.row] objectForKey:@"image"];
                }
                cell.lbl_station.text=[[searchContactList objectAtIndex:indexPath.row] objectForKey:@"Phone"];
            }
            else{
                if ([[contactList objectAtIndex:indexPath.row] objectForKey:@"Phone"]==nil) {
                    inviteLbl.backgroundColor = [UIColor lightGrayColor];
                }
                else{
                    inviteLbl.backgroundColor = [UIColor redColor];
                }
                
                inviteLbl.text = @"Invite";
                inviteLbl.textColor= [UIColor whiteColor];
                inviteLbl.layer.masksToBounds = YES;
                inviteLbl.layer.cornerRadius = 8.0f;
                inviteLbl.textAlignment = NSTextAlignmentCenter;
                [cell addSubview:inviteLbl];
                cell.btn_select.tag=indexPath.row;
                //[cell.btn_select addTarget:self action:@selector(select_user:) forControlEvents:UIControlEventTouchUpInside];
                
                cell.lbl_name.text=[[contactList objectAtIndex:indexPath.row] objectForKey:@"name"];
                
                if ([[contactList objectAtIndex:indexPath.row] objectForKey:@"image"] == nil)
                {
                    cell.img_view_profilepic.image= [UIImage imageNamed:@"artist.png"];
                }
                else
                {
                    cell.img_view_profilepic.image= [[contactList objectAtIndex:indexPath.row] objectForKey:@"image"];
                }
                cell.lbl_station.text=[[contactList objectAtIndex:indexPath.row] objectForKey:@"Phone"];
            }
            
            return cell;
            
        }
    }
    else
    {
    if (cell == nil)
    {
        NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"contactsTableViewCell"
                         
                                                      owner:self options:nil];
        
        cell = (contactsTableViewCell *)[nib2 objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.img_view_profilepic.layer.cornerRadius = cell.img_view_profilepic.frame.size.width / 2;
        cell.img_view_profilepic.clipsToBounds = YES;
        cell.btn_select.layer.cornerRadius=cell.btn_select.frame.size.width / 2;
        cell.btn_select.clipsToBounds = YES;
        if (isSearch) {
            if ([[arr_user_select objectAtIndex:indexPath.row] isEqual:@"1"]) {
                cell.btn_select.backgroundColor=[UIColor blueColor];
                
            }
            else
            {
                cell.btn_select.backgroundColor=[UIColor lightGrayColor];
                
            }
            cell.btn_select.tag=indexPath.row;
            [cell.btn_select addTarget:self action:@selector(select_user:) forControlEvents:UIControlEventTouchUpInside];
            cell.lbl_name.text=[NSString stringWithFormat:@"%@",[[searchContactList objectAtIndex:indexPath.row] objectForKey:@"fname"]]; cell.lbl_station.text=[NSString stringWithFormat:@"@%@",[[searchContactList objectAtIndex:indexPath.row] objectForKey:@"username"]];
            NSURL *url = [NSURL URLWithString:[[searchContactList objectAtIndex:indexPath.row] objectForKey:@"profilepic"]];
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                      {
                                          if (data)
                                          {
                                              UIImage *image = [UIImage imageWithData:data];
                                              if (image)
                                              {
                                                  dispatch_async(dispatch_get_main_queue(), ^{ cell.img_view_profilepic.image=image;
                                                      
                                                  });
                                                  
                                              }
                                          }
                                          
                                      }];
            [task resume];
        }
        else {
            
            if ([[arr_user_select objectAtIndex:indexPath.row] isEqual:@"1"]) {
                cell.btn_select.backgroundColor=[UIColor blueColor];
            }
            else{
                cell.btn_select.backgroundColor=[UIColor lightGrayColor];
                
            }
            cell.btn_select.tag=indexPath.row;
            [cell.btn_select addTarget:self action:@selector(select_user:) forControlEvents:UIControlEventTouchUpInside];
            
            
//            cell.lbl_name.text=[NSString stringWithFormat:@"%@",[arr_users_name objectAtIndex:indexPath.row]];
            cell.lbl_name.text=[NSString stringWithFormat:@"%@ %@",[arr_users_name objectAtIndex:indexPath.row],[arr_users_lname objectAtIndex:indexPath.row]];
            
            cell.lbl_station.text=[NSString stringWithFormat:@"@%@",[arr_users_username objectAtIndex:indexPath.row]];
            
            NSURL *url = [NSURL URLWithString:[arr_users_profile objectAtIndex:indexPath.row]];
            
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data) {
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.img_view_profilepic.image=image;
                            
                        });
                    }
                }
            }];
            [task resume];
        }
        return cell;
    }
    
    }
    return cell;
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tbl_view_PhoneContacts) {
        
        if (isSearch) {
            [self showSMSWithNumber:[[searchContactList objectAtIndex:indexPath.row] objectForKey:@"Phone"] andWithName:[[searchContactList objectAtIndex:indexPath.row] objectForKey:@"name"]];
        }
        else{
            [self showSMSWithNumber:[[contactList objectAtIndex:indexPath.row] objectForKey:@"Phone"] andWithName:[[contactList objectAtIndex:indexPath.row] objectForKey:@"name"]];
        }
    }
    
}

#pragma mark- Delegate Method MFMessageComposeViewController
#pragma mark-

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showSMSWithNumber:(NSString*)withNumber andWithName:(NSString*)withName {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    //  NSArray *recipents = @[@"12345678", @"72345524"];
    if (withNumber == nil)
    {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please add phone number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    NSArray *recipents =@[withNumber];
    NSString *message = [NSString stringWithFormat:@"Hey %@,\nJoin me in #YoMelody.\nFollow this link to download the app\nhttps://itunes.apple.com/us/app/yomelody/id1329831002?ls=1&mt=8", withName];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSMutableString * str_selected_userIDM = [[NSMutableString alloc]init];
    NSString *str_selected_userID;
    if (arr_selected_users.count == 1) {
        str_selected_userIDM = [arr_selected_users objectAtIndex:0];
        str_selected_userID = [NSString stringWithFormat:@"%@",str_selected_userIDM];
        NSLog(@"imm %@",str_selected_userID);
    }
    else if(arr_selected_users.count > 1){
        str_selected_userID = [arr_selected_users componentsJoinedByString:@","];
        NSLog(@"imm %@",str_selected_userID);
    }
    if ([segue.identifier isEqual:@"contacts_to_chat"]) {
        chatViewController*vc=segue.destinationViewController;
        
        NSLog(@"before reciver id %@",str_selected_userID);
        vc.str_receiver_id = str_selected_userID;
        vc.str_receiver_type = @"contact";
        
        //-------------------------- For Group Chat --------------------------
        if (arr_selected_users.count>1){
            vc.isChat_type_Group = YES;
            vc.str_GroupName = @"Group";
            
        }
        else{
            vc.isChat_type_Group = NO;
            vc.str_receiver_name = [[arr_contactListM objectAtIndex:indexCurrentUSer] valueForKey:@"username"];
            vc.img_view_Profile = [arr_users_profile objectAtIndex:indexCurrentUSer];
            
        }
        
        if (_isShare_Audio) {
            vc.str_file_id = _str_file_id;
            vc.isShare_Audio = _isShare_Audio;
            vc.str_screen_type = _str_screen_type;
            
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[arr_users_profile objectAtIndex:receiver_index] forKey:@"profilepic"];
    }
}


- (void)select_user:(UIButton*)sender {
    @try{
        
        if([[arr_user_select objectAtIndex:sender.tag]isEqualToString:@"1"]){
            [arr_user_select replaceObjectAtIndex:sender.tag withObject:@"0"];
            [arr_selected_users removeObject:[arr_users_id objectAtIndex:sender.tag]];
        }
        else{
            [arr_user_select replaceObjectAtIndex:sender.tag withObject:@"1"];
            [arr_selected_users addObject:[arr_users_id objectAtIndex:sender.tag]];
            
            
        }
        indexCurrentUSer = sender.tag;
        
        if ([arr_user_select containsObject: @"1"]) {
            [_btn_ok setTitle:@"OK" forState:UIControlStateNormal];
        }
        else{
            [_btn_ok setTitle:@"Cancel" forState:UIControlStateNormal];
        }
        //_btn_ok.tag=sender.tag;
        receiver_index=sender.tag;
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tbl_view_contacts];
        NSIndexPath *indexPath = [_tbl_view_contacts indexPathForRowAtPoint:buttonPosition];
        if(indexPath != nil)
        {
            [_tbl_view_contacts beginUpdates];
            [_tbl_view_contacts reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [_tbl_view_contacts endUpdates];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at Select user:%@",exception);
    }
    @finally{
        
    }
}



-(void)go_chat_screen:(UIButton*)sender{
    
    if ([arr_user_select containsObject: @"1"]) {
        [_btn_ok setTitle:@"Cancel" forState:UIControlStateNormal];
        [self performSegueWithIdentifier:@"contacts_to_chat" sender:self];
        [arr_user_select replaceObjectAtIndex:sender.tag withObject:@"0"];
        //  receiver_index=sender.tag;
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];    }
}

- (IBAction)btn_home:(id)sender {
    
    //    UIViewController *vc = self.presentingViewController;
    //
    //    [vc dismissViewControllerAnimated:YES completion:NULL];
    if (Appdelegate.isFirstTimeSignUp)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
        //Appdelegate.isFirstTimeSignUp=NO; >> IF PROBLEM OCCURS AGAIN UNCOMMENT THIS LINE
    }
    else{
        [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    }
    
}

- (IBAction)btn_back:(id)sender {
        [self dismissViewControllerAnimated:YES completion:nil];
    }





-(void)loadfollowers
{
    @try{
    if(arr_contactListM.count > 0) {
        arr_users_name=[[NSMutableArray alloc]init];
        arr_users_lname=[[NSMutableArray alloc]init];
        arr_users_username=[[NSMutableArray alloc]init];
        arr_users_devicetoken=[[NSMutableArray alloc]init];
        arr_users_profile=[[NSMutableArray alloc]init];
        arr_users_id=[[NSMutableArray alloc]init];
        arr_user_select=[[NSMutableArray alloc]init];

        int i;
        for (i=0; i<[arr_contactListM count]; i++) {
            [arr_users_name insertObject:[[arr_contactListM objectAtIndex:i] objectForKey:@"fname"] atIndex:i];
            [arr_users_lname insertObject:[[arr_contactListM objectAtIndex:i] objectForKey:@"lname"] atIndex:i];
            [arr_users_username insertObject:[[arr_contactListM objectAtIndex:i] objectForKey:@"username"] atIndex:i];
            [arr_users_devicetoken insertObject:[[arr_contactListM objectAtIndex:i] objectForKey:@"devicetoken"] atIndex:i];
            [arr_users_profile insertObject:[[arr_contactListM objectAtIndex:i] objectForKey:@"profilepic"] atIndex:i];
            [arr_users_id insertObject:[[arr_contactListM objectAtIndex:i] objectForKey:@"id"] atIndex:i];
            [arr_user_select insertObject:@"0" atIndex:i];
        }
        
        
        [_tbl_view_contacts reloadData];
    }
    else
    {
        if (!arr_contactListM) {
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Alert"
                                          message:@"Unable to load users!"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"ok"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            //Handel your yes please button action here
                                            
                                        }];
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at loadFollers : %@",exception);
    }
    @finally{
        
    }
}



-(void)btn_inviteMethod{
    
    @try{
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"myid"];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    
    NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@contactList.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(error)
        {
            //do something
            NSLog(@"%@", error);
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Message"
                                          message:MSG_NoInternetMsg
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"ok"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            //Handel your yes please button action here
                                        }];
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
            
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *myError = nil;
                
                NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                
                NSLog(@"%@",requestReply);
                NSData *data = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
                id jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:kNilOptions
                                                                    error:&myError];
                
                NSLog(@"%@",jsonResponse);
                if([[jsonResponse objectForKey:@"flag"]
                    isEqual:@"success"]) {
                    arr_contactListM = [[NSMutableArray alloc]init];
                    arr_contactListM = [jsonResponse objectForKey:@"info"];
                    if (arr_contactListM) {
                        if (arr_contactListM.count > 0) {
                            [self loadfollowers];
                            noFolContactsLbl.hidden=YES;
//                            [_tbl_view_contacts reloadData];
                        }
                        else{
                            noFolContactsLbl.hidden=NO;
                            self.tbl_view_contacts.hidden = YES;
                            self.img_placeholderNoContact.hidden = NO;
                        }
                    }
                    
                }
                
            });
        }
    }];
    [task resume];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at invite contact:%@",exception);
    }
    @finally{
        
    }
}

- (IBAction)openPhoneContacts_BtnAction:(id)sender {
    
    backView= [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
    backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:backView];
    [backView addSubview:_phoneContactsView];
    _phoneContactsView.hidden = NO;
    _Pcontact_searchBar.text =@"";
    [self getPhoneContacts];
    
}
- (IBAction)closeBtn:(id)sender {
    [self.view endEditing:YES];
    _phoneContactsView.hidden = YES;
    backView.hidden= YES;
    isSearch= NO;
    _Contact_SearchBar.text = @"";
    [_tbl_view_contacts reloadData];
}


-(void)getPhoneContacts
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    __block BOOL accessGranted = NO;
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        //        dispatch_release(semaphore);
    }
    
    else { // We are on iOS 5 or Older
        accessGranted = YES;
        [self getContactsWithAddressBook:addressBook];
    }
    
    if (accessGranted) {
        [self getContactsWithAddressBook:addressBook];
    }
}


- (void)getContactsWithAddressBook:(ABAddressBookRef )addressBook {
     isSearch=NO;
    contactList = [[NSMutableArray alloc] init];
    // mainArray=[[NSMutableArray alloc]init];
    searchContactList = [[NSArray alloc] init];
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i=0;i < nPeople;i++) {
        NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
        //For username and surname
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        [dOfPerson setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
        
        // For getting the user image.
        UIImage *contactImage;
        if(ABPersonHasImageData(ref)){
            contactImage = [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageData(ref)];
            [dOfPerson setObject:contactImage forKey:@"image"];
        }
        
        //For Email ids
        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        if(ABMultiValueGetCount(eMail) > 0) {
            [dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
            
        }
        
        //For Phone number
        NSString* mobileLabel;
        
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
                break ;
            }
            
        }
        [contactList addObject:dOfPerson];
        
    }
    NSLog(@"Contacts = %@",contactList);
    NSLog(@"Contacts Count = %lu",(unsigned long)contactList.count);
    if (contactList.count == 0) {
        noContactsLbl.hidden=NO;
    }
    else
    {
        noContactsLbl.hidden=YES;
    }
    [_tbl_view_PhoneContacts reloadData];//imp
}

#pragma mark- Delegate Method Search
#pragma mark-
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    if ([searchText isEqualToString:@""])
    {
        isSearch = NO;
    }
    else
    {
        isSearch= YES;
    }
    if (searchBar == _Contact_SearchBar)
    {
        
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"fname CONTAINS[cd] %@", searchBar.text];
        searchContactList = [arr_contactListM filteredArrayUsingPredicate:filterPredicate];
        NSLog(@"newSearch %@", searchContactList);
        [_tbl_view_contacts reloadData];
    }
    else
    {
        
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchBar.text];
        searchContactList = [contactList filteredArrayUsingPredicate:filterPredicate];
        NSLog(@"newSearch %@", searchContactList);
        [_tbl_view_PhoneContacts reloadData];
    }
    
}




@end
