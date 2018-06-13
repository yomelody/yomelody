//
//  FansOrFollowingVC.m
//  melody
//
//  Created by coding Brains on 22/05/18.
//  Copyright © 2018 CodingBrainsMini. All rights reserved.
//

#import "FansOrFollowingVC.h"
#import "Constant.h"
#import "UsersTableViewCell.h"
@interface FansOrFollowingVC ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    NSMutableArray *arr_fan_followingM;
    NSString *str_Header;
    NSUserDefaults*defaults_userdata;
    NSArray *searchContactList,*arrUserList;
    BOOL isSearch;

}
@end

@implementation FansOrFollowingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self intializesAllVariables];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    if ([_str_type isEqualToString:@"fan"]) {
        str_Header = @"Fans";
    }
    else{
        str_Header = @"Following";
    }
    _lbl_header.text = str_Header;
}

-(void)viewDidAppear:(BOOL)animated{
    [self get_fan_following_list];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)intializesAllVariables{
    // do initializes
    arr_fan_followingM = [[NSMutableArray alloc]init];
    _tbl_fans_followings.hidden = YES;
    _img_placeholder.hidden = NO;
    isSearch = NO;
    _view_search.hidden = YES;
    _view_navigation.hidden = NO;
    [self.btn_search_cancel setTitle:@"Search" forState:UIControlStateNormal];

}





- (IBAction)btn_back:(id)sender {
    [self.view endEditing:YES];

    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"notification_navigation"] isEqual:@"1"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"notification_navigation" ];
        
        Appdelegate.str_chat_status=@"0";
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device_token"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"profilepic"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
        //   [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)btn_home:(id)sender {
    [self.view endEditing:YES];

    if (Appdelegate.isFirstTimeSignUp)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"notification_navigation"] isEqual:@"1"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"notification_navigation" ];
        
        Appdelegate.str_chat_status=@"0";
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device_token"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"profilepic"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
        //   [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    }
    else{
        [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
    }
}



-(void)get_fan_following_list
{
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    [params setObject:_userID forKey:@"user_id"];
    [params setObject:_str_type forKey:@"type"];

    NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@followerlist.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    //this is how cookies were created
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
                                          message:@"Network Error !"
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
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:kNilOptions
                                                                               error:&myError];
                NSLog(@"%@",jsonResponse);
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"])
                {
                    _tbl_fans_followings.hidden = NO;
                    _img_placeholder.hidden = YES;
                    arr_fan_followingM = [jsonResponse objectForKey:@"response"];
                    arrUserList = [jsonResponse objectForKey:@"response"];
                    str_Header = [NSString stringWithFormat:@"%@ : %lu",str_Header,(unsigned long)arr_fan_followingM.count];
                    _lbl_header.text = str_Header;
                    [_tbl_fans_followings reloadData];
                }
                else
                {
                    _tbl_fans_followings.hidden = YES;
                    _img_placeholder.hidden = NO;
                    [Appdelegate hideProgressHudInView];
                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"Alert"
                                                      message:@"Error to like!"
                                                      preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* yesButton = [UIAlertAction
                                                    actionWithTitle:@"ok"
                                                    style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action)
                                                    {
                                                        //Handel your yes please button action here
                                                        
                                                    }];
                        
                        
                        [alert addAction:yesButton];
//                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    
                    
                }
                
            });
        }
    }];
    [task resume];
    
}



#pragma mark - TableView Delegates & Datasource
#pragma mark -

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
        return [arr_fan_followingM count];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    @try{
        
//        if (isSearch) {
//            arr_fan_followingM = [searchContactList mutableCopy];
//        }
            static NSString *CellIdentifier = @"Users_cell";
            UsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                
                NSArray *nib2 = [[NSBundle mainBundle] loadNibNamed:@"UsersTableViewCell"
                                                              owner:self options:nil];
                cell.accessoryType = UITableViewCellStyleDefault;
                cell = (UsersTableViewCell*)[nib2 objectAtIndex:0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //--------------------* Set User first name *-----------------------
        cell.lbl_userName.text=[[arr_fan_followingM objectAtIndex:indexPath.row] valueForKey:@"username"];
        
        //--------------------* Set User full name *-----------------------
        cell.lbl_userFullName.text=[NSString stringWithFormat:@"@%@",[[arr_fan_followingM objectAtIndex:indexPath.row] valueForKey:@"name"]];
        
        //--------------------* Set Profile Pic *-----------------------
        NSURL *url2 = [NSURL URLWithString:[[arr_fan_followingM objectAtIndex:indexPath.row] valueForKey:@"profilepic"]];
        
        cell.btn_profile.contentMode = UIViewContentModeScaleToFill;
        cell.btn_profile.layer.cornerRadius = cell.btn_profile.frame.size.width / 2;
        cell.btn_profile.clipsToBounds = YES;
        
        NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:url2 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [cell.btn_profile setImage:image forState:UIControlStateNormal];
                        
                    });
                }
            }
        }];
        [task2 resume];
        
        [cell.btn_profile addTarget:self action:@selector(profileClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_profile setTag:indexPath.row];
        cell.btn_profile.layer.cornerRadius = cell.btn_profile.frame.size.width / 2;
        cell.btn_profile.clipsToBounds = YES;
        
        //-------- Set hidden for NO requirement here----------
        cell.btn_messanger.hidden = YES;
        cell.btn_follow.hidden = YES;
        //-----------------------------------------------------
            return cell;
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception at TableView :%@",exception);
    }
    @finally{
        
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self methodProfileAction:indexPath.row];

}


-(void)methodProfileAction:(NSInteger)sender{
    NSLog(@"profileClicked");
    ProfileViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    
    profileVC.follower_id = [[arr_fan_followingM objectAtIndex:sender]valueForKey:@"id"];
    NSString * userId = [defaults_userdata objectForKey:@"user_id"];
    profileVC.user_id = userId;
    
    [profileVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:profileVC animated:YES completion:nil];
}


-(void)profileClicked:(UIButton*)sender{
    [self methodProfileAction:sender.tag];
    
}


#pragma mark- Delegate Method Search
#pragma mark-
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    if ([searchText isEqualToString:@""])
    {
        isSearch= NO;
    }
    else
    {
        [self.btn_search_cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        isSearch= YES;
    }
    if (searchBar == _search_bar)
    {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchBar.text];
        searchContactList = [arr_fan_followingM filteredArrayUsingPredicate:filterPredicate];
        NSLog(@"newSearch %@", searchContactList);
        if (isSearch) {
            arr_fan_followingM=[searchContactList mutableCopy];
        }
        else
        {
            arr_fan_followingM = [arrUserList mutableCopy];
        }
        
        [_tbl_fans_followings reloadData];
    }
    
}


- (IBAction)searchAction:(id)sender {
    _view_search.hidden = NO;
    _view_navigation.hidden = YES;
    isSearch=YES;

}

- (IBAction)btn_searchAction:(id)sender {
    [self.view endEditing:YES];
    _view_search.hidden=YES;
    _view_navigation.hidden = NO;
    isSearch = NO;
    
}


@end
