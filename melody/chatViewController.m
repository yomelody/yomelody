  //
//  chatViewController.m
//  melody
//
//  Created by coding Brains on 21/12/16.
//  Copyright © 2016 CodingBrainsMini. All rights reserved.
//

#import "chatViewController.h"
#import "sendMessageTableViewCell.h"
#import "receiveTableViewCell.h"
#import "imageCollectionViewCell.h"
#import "UpdateGroupVC.h"
#import "Constant.h"
#import "sendfileTableViewCell.h"
#import "receivefileTableViewCell.h"
#import "WebViewController.h"
#import "contactsViewController.h"
#import "StudioRecViewController.h"
#import "StudioPlayViewController.h"
#include <stdlib.h>
#import "ProgressHUD.h"
@import FirebaseInstanceID;
@import FirebaseMessaging;

@interface chatViewController ()<UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,AVAudioPlayerDelegate,UITextFieldDelegate>
{
    NSArray *arr_userID;
    NSString * str_result_userID;
    BOOL isText;
    BOOL isTapUpdate;
    NSUserDefaults*defaults_userdata;
    NSMutableDictionary*dic_response;
    NSArray * arr_messageList;
    NSTimer* sliderTimer;
    NSString *str_msgID;
    long index_msg;
    BOOL isShareWillShow;
    BOOL toggle_PlayPause;
    long lastIndex;
    NSString *audioUrl;
    CGRect initialFrame;
    BOOL onceExecute,toogleShare;
    int imageCounter;
    
    NSMutableArray*arr_contactList;
    NSMutableArray*arr_followerListM;
    NSMutableArray*arr_followingListM;
    NSMutableDictionary *dic_tempM;
    NSMutableArray*arr_response;
    BOOL isSharedAudioPlayed;
    long sharedFileIndex;
    NSString * contactName;
}

@end

@implementation chatViewController



- (void)viewDidLoad {
    @try{
        [super viewDidLoad];
//        [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLog(_isShare_Audio ? @"Yes" : @"No");
        arr_AudioSharedM = [[NSMutableArray alloc]init];
        isShareWillShow = NO;
        lastIndex = 999999;
        //imageCounter = 999;
        audioPlayer.delegate=self;
        onceExecute = YES;
        toogleShare = YES;
        arr_contactList = [[NSMutableArray alloc]init];
        dic_tempM = [[NSMutableDictionary alloc]init];
        isSharedAudioPlayed = NO;
        if (_isChat_type_Group) {
            if (_isChat_type_Group && [_str_GroupName isEqualToString:@""])
                {
                    contactName=@"Group";
                    _lbl_recieverName.text = contactName;

                }
            else
                {
                _lbl_recieverName.text = _str_GroupName;
                    contactName=_str_GroupName;
                }
        }
        else{
            _lbl_recieverName.text = _str_receiver_name;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@",exception);
    }
    @finally{
        
    }
 
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [audioPlayer stop];
    [sliderTimer invalidate];
    
}

-(void)initializeAllVaribles{
    
    @try{
    _view_SharePlay.hidden = YES;
    isText = NO;
    isTapUpdate = NO;
    str_result_userID = [[self.arr_msg_user_id valueForKey:@"description"] componentsJoinedByString:@","];
    arr_userID = [str_result_userID componentsSeparatedByString:@","];
    NSLog(@"Reciever Id = %@ ",str_result_userID);
    //----------- * Set Reciver Name *--------------
      
    
    Appdelegate.str_chat_status=@"1";
    if ([_str_receiver_type isEqualToString:@"message"]){
    }
    _str_receiver_profile_url=[[NSUserDefaults standardUserDefaults] objectForKey:@"profilepic"];
    msg_txt=[[NSMutableString alloc]init];
    
    _tbl_view_chat.separatorColor=[UIColor clearColor];
    flag_text=0;
//     [_tv_write_msg addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _tv_write_msg.layer.cornerRadius=5;
    _tv_write_msg.delegate=self;
    
    [_tv_write_msg setText:Placeholder];
    self.tv_write_msg.textColor = [UIColor lightGrayColor]; //optional
    self.tv_write_msg.delegate = self;
    
    // Do any additional setup after loading the view.
    _btn_cancel.hidden=YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
  
    if (_str_chat_id != nil || _str_receiver_id!=nil) {
        
        if (_isChat_type_Group) {
            if(_isShare_Audio){
                [self sendmsg];
            }
           else if ([_str_receiver_type isEqualToString:@"message"] || _str_chat_id != nil) {
                [self loadchat];
            }
            else{
                [self getChatID];
            }
        }
        else{
            [self getChatID];
        }
    }
   
    else if ([[NSUserDefaults standardUserDefaults] objectForKey:@"messege"] != nil){
        NSError*error;
        NSString*dic=[[NSUserDefaults standardUserDefaults] objectForKey:@"messege"];
//        NSData *data = [[[[dic objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonResponse=[[NSDictionary alloc]init];
        NSData *objectData = [dic dataUsingEncoding:NSUTF8StringEncoding];

        if (objectData.length>0) {
            jsonResponse = [NSJSONSerialization JSONObjectWithData:objectData
                                                           options:NSJSONReadingMutableContainers
                                                             error:&error];
            
            //_str_receiver_id=@"6";
            if ([jsonResponse objectForKey:@"chat_id"] != nil) {
                _str_chat_id = [NSString stringWithFormat:@"%@",[jsonResponse objectForKey:@"chat_id"]];
                [self loadchat];
                
            }
            
        }
       
    }
   else if ([[NSUserDefaults standardUserDefaults] objectForKey:@"notification_messege"] != nil){
       NSError*error;
       NSDictionary *dic=[[NSUserDefaults standardUserDefaults] objectForKey:@"notification_messege"];
       NSData *objectData = [[[[dic objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"] dataUsingEncoding:NSUTF8StringEncoding];
       NSDictionary *jsonResponse=[[NSDictionary alloc]init];
       if (objectData.length>0) {
           jsonResponse = [NSJSONSerialization JSONObjectWithData:objectData
                                                          options:NSJSONReadingMutableContainers
                                                            error:&error];
           if ([jsonResponse objectForKey:@"chat_id"] != nil) {
               _str_chat_id = [NSString stringWithFormat:@"%@",[jsonResponse objectForKey:@"chat_id"]];
               [self loadchat];
           }
       }
   }
    
    arr_msgWithImage = [[NSMutableArray alloc]init];
   
    
    if (_isChat_type_Group) {
        UITapGestureRecognizer *tapOn_msgView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnUpdateView)];
        [self.vew_msg addGestureRecognizer:tapOn_msgView];
    }

    
    //--------------------------- Set action on Camera Button -------------------------
    [_btn_camera addTarget:self action:@selector(btn_open_gallery) forControlEvents:UIControlEventTouchUpInside];
        
    //--------------------------- Set action on Play Button -------------------------
    [_btn_play addTarget:self action:@selector(btn_playClicked) forControlEvents:UIControlEventTouchUpInside];
        
    }
    @catch (NSException *exception) {
        NSLog(@"exception at Initializes All Varibles : %@",exception);
    }
    @finally{
        
    }
}

- (void) receiveNotification_UpdateGroup:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"updateGroup"])
    {
        NSDictionary *dic = notification.userInfo;
        NSLog(@"notification data %@",dic);
        NSURL *url = [NSURL URLWithString:[dic objectForKey:@"url"]];
        _img_view_profile.layer.cornerRadius = _img_view_profile.frame.size.width / 2;
        _img_view_profile.clipsToBounds = YES;
        [_img_view_profile sd_setImageWithURL:url
                             placeholderImage:[UIImage imageNamed:@"group.png"]];
        _lbl_recieverName.text = [dic objectForKey:@"groupName"];
        _str_chat_id = [dic objectForKey:@"chat_id"];
        _str_receiver_name  = [dic objectForKey:@"groupName"];
        _str_GroupName = _str_receiver_name;
        _str_GroupImage = [dic objectForKey:@"url"];
    }
}

-(void)tapOnUpdateView{
    isTapUpdate = YES;
    UpdateGroupVC *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"UpdateGroupVC"];
    myVC.str_GroupName = _str_GroupName;//_str_receiver_name
    myVC.str_GroupImage = _str_GroupImage;
    myVC.str_chat_id = _str_chat_id;
    [self presentViewController:myVC animated:YES completion:nil];
}


- (void)btn_playClicked{
    @try{
    [self playShareMethod:instrument_play_index url:audioUrl];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
    
}

-(void)scrollToTop{
    long lastRowNumber = [_tbl_view_chat numberOfRowsInSection:0] - 1;
    NSIndexPath* ip = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
    [_tbl_view_chat scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];
}






-(void)viewDidDisappear:(BOOL)animated
{
    Appdelegate.str_chat_status=@"0";
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"receiver_id"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device_token"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"profilepic"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"chat_id"];
    [sliderTimer invalidate];
    sliderTimer = nil;
}


#pragma mark- TextView Delegate Method
#pragma mark-

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"textField: %@",text);
    if (range.location == 0 && [text isEqualToString:@" "]) {
        return NO;
    }
    return YES;
}

- (void)setCursorToBeginning:(UITextView *)inView
{
    //you can change first parameter in NSMakeRange to wherever you want the cursor to move
    inView.selectedRange = NSMakeRange(0, 0);
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self performSelector:@selector(setCursorToBeginning:) withObject:textView afterDelay:0.01];

    
    if ([textView.text isEqualToString:Placeholder]) {
        _tv_write_msg.text = @"";
        _tv_write_msg.textColor = [UIColor lightGrayColor]; //optional
    }
    else
        if ([textView.text length]!=0 && ![textView.text isEqual:Placeholder])
        {
            [_tv_write_msg setTextColor:[UIColor blackColor]];
            flag_text=1;
            [_btn_cancel setTitle:@"Send" forState:UIControlStateNormal];
        }
        else
        {
            _tv_write_msg.text=@"";
            [_tv_write_msg setTextColor:[UIColor lightGrayColor]];
            flag_text=0;
            [_btn_cancel setTitle:@"Cancel" forState:UIControlStateNormal];
            
        }

    [textView becomeFirstResponder];
}



- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        [textView setText:Placeholder];
        [textView setTextColor:[UIColor lightGrayColor]];
        
    }
    else if([textView.text isEqual:Placeholder]){
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}




-(void)dismissKeyboard
{
    [_tv_write_msg resignFirstResponder];
    
    _tv_write_msg.text=msg_txt;
    
    [_tv_write_msg setTextColor:[UIColor blackColor]];
    
    _btn_go_to_studio_play.hidden=NO;
    _btn_cancel.hidden=YES;
}


- (void)viewWillAppear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification_UpdateGroup:)
                                                 name:@"updateGroup"
                                               object:nil];
    
    Appdelegate.str_chat_status=@"1";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self initializeAllVaribles];

}

- (void)viewWillDisappear:(BOOL)animated {
    Appdelegate.str_chat_status=@"0";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    
}
- (void)viewDidAppear:(BOOL)animated {
    
}



-(void)playAudioFile
{
    NSLog(@"PLAY");
    [self playShareMethod:instrument_play_index url:audioUrl];
}


-(void)textViewDidChange:(UITextView *)textView {
    [_tv_write_msg setTextColor:[UIColor blackColor]];
   if ([_tv_write_msg.text length]>0 && ![_tv_write_msg.text isEqual:Placeholder]) {
        
        flag_text=1;
        [_btn_cancel setTitle:@"Send" forState:UIControlStateNormal];
    }else{
     [_btn_cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    flag_text=0;
        
    }
    // get the size of the text block so we can work our magic
    
//    CGSize newSize = [_tv_write_msg.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(300,9999) lineBreakMode:NSLineBreakByWordWrapping];
//
//        NSInteger newSizeH = newSize.height;
//        CGRect viewFrame = _view_form.frame;
//        viewFrame.size.height = newSizeH+30;
//        viewFrame.origin.y=viewFrame.origin.y-(viewFrame.size.height-_view_form.frame.size.height);
//        _view_form.frame=viewFrame;
    
    //new code
//    CGFloat fixedWidth = textView.frame.size.width;
//    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
//    CGRect newFrame = textView.frame;
//    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
//    textView.frame = newFrame;
//    if (newSize.height <= 90)
//    {
//        [_tv_write_msg scrollRectToVisible:CGRectMake(0,0,0,0) animated:NO];
//        CGRect chatBoxFrame = _tv_write_msg.frame;
//        chatBoxFrame.origin.y=10;
//        chatBoxFrame.size.height = newSize.height+15;
//        _tv_write_msg.frame = chatBoxFrame;
//        msg_txt=[NSMutableString stringWithFormat:@"%@",_tv_write_msg.text];
//    }
    msg_txt=[NSMutableString stringWithFormat:@"%@",_tv_write_msg.text];
    if ([_tv_write_msg.text length]==0)
        
    {
         msg_txt=[NSMutableString stringWithFormat:Placeholder];
    }
}


#pragma mark - Navigation
#pragma mark -
- (IBAction)btn_back:(id)sender {
    
    if (audioPlayer.isPlaying) {
        [audioPlayer stop];
    }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device_token"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"profilepic"];
        Appdelegate.str_chat_status=@"0";
        [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (IBAction)btn_home:(id)sender {
    @try{
    
    if (audioPlayer.isPlaying) {
        [audioPlayer stop];
    }
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"notification_navigation"] isEqual:@"1"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"notification_navigation" ];
        
        Appdelegate.str_chat_status=@"0";
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device_token"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"profilepic"];
       
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        UITabBarController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
//        [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
        [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];

    }else
    {
       Appdelegate.str_chat_status=@"0";
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"receiver_id"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device_token"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"profilepic"];
        UIViewController *vc = self.presentingViewController;
      
//        [vc dismissViewControllerAnimated:YES completion:NULL];
        [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];

    }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}

- (IBAction)chat_Invite:(UIButton *)sender {
    
    
}

- (IBAction)btn_write_msg_open_contacts:(id)sender {
    
}



- (void)btn_open_gallery{
    @try{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    CGFloat margin = 8.0F;
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(margin, margin, alertController.view.bounds.size.width - margin * 4.0F, 100.0F)];
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    cv_images=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 10, customView.frame.size.width-10, 100) collectionViewLayout:layout];
    cv_images.allowsSelection=YES;
    cv_images.showsHorizontalScrollIndicator=YES;
    [cv_images setDataSource:self];
    [cv_images setDelegate:self];
    [customView addSubview:cv_images];
    [cv_images registerNib:[UINib nibWithNibName:@"imageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [cv_images setBackgroundColor:[UIColor clearColor]];
    [customView addSubview:cv_images];
    
    [alertController.view addSubview:customView];
    
    UIAlertAction *somethingAction = [UIAlertAction actionWithTitle:@"Take Photo or Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    
        [self open_camera];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    
    }];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self open_gallery];
        
    }];
    [alertController addAction:camera];

    [alertController addAction:somethingAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
    
    [cv_images reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
    
}

-(void)cancel_popup:(id)sender
{
    dp_view.hidden=YES;
}



-(void)open_camera
{
    @try{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"camera_status"] isEqual:@"1"]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"camera_status"];
    }
    else{
        
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(authStatus == AVAuthorizationStatusAuthorized) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
        }
        else{
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Alert"
                                          message:@"Please allow Camera permisions!"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"ok"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            //Handel your yes please button action here
                                            
                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                            
                                        }];
            
            
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    }
    
    
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
    
}
-(void)open_gallery
{
    @try{
    if ([Appdelegate hasGalleryPermission]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Alert"
                                      message:@"Please allow gallery permisions!"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        //Handel your yes please button action here
                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                    }];
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}





- (IBAction)btn_cancel:(id)sender {
    
    if (flag_text==0) {
        _btn_go_to_studio_play.hidden=NO;
            _btn_cancel.hidden=YES;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect f = self.view_bottom_write_msg.frame;
            f.origin.y = self.view.frame.size.height-49;
            self.view_bottom_write_msg.frame = f;
            [_tv_write_msg setText:Placeholder];
            [_tv_write_msg resignFirstResponder];
            self.tv_write_msg.textColor = [UIColor lightGrayColor]; //optional

        }];
    }
    else
    {
        [self dismissKeyboard];
        isText = YES;
        [self sendmsg];
    }
   
}

-(void)saveShareCount
{
        @try{
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    
    NSLog(@"userid %@",userid);
    NSLog(@"DICT %@",defaults_userdata);
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:_str_file_id forKey:@"file_id"];
    [params setObject:@"user_recording" forKey:KEY_SHARE_FILETYPE];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    [params setObject:_str_receiver_id forKey:@"shared_with"];
    [params setObject:userid forKey:@"shared_by_user"];
    
    NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@sharefile.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    
    //this is how cookies were created
    
    
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
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
                NSMutableDictionary*dic_response=[[NSMutableDictionary alloc]init];
                NSLog(@"%@",jsonResponse);
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    dic_response=[jsonResponse objectForKey:@"info"];
                    NSLog(@"%@",dic_response);
              
                }
                else
                {
                    
                    
                    if ([[jsonResponse objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
                        UIAlertController * alert=   [UIAlertController
                                                      alertControllerWithTitle:@"Alert"
                                                      message:@"Error"
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
                
            });
        }
    }];
    [task resume];
        }
        @catch (NSException *exception) {
            NSLog(@"exception at sharefile.php : %@",exception);
        }
        @finally{
    
        }
}

-(void)sendmsgWithImage_Audio{
    
    @try{
    [Appdelegate showProgressHud];
    if ( imageData.length==0)
    {
        [Appdelegate hideProgressHudInView];
    }
    else{
        if ([_str_receiver_id isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]]) {
            _str_receiver_id = _str_sender_ID;
        }
      // if chat id is in other data type then convert into string
    _str_chat_id = [NSString stringWithFormat:@"%@",_str_chat_id];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSString *urlForUpload = [NSString stringWithFormat:@"%@chat.php",BaseUrl];
        [manager POST:urlForUpload
           parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
               [formData appendPartWithFileData:imageData
                                           name:@"file"
                                       fileName:imageName mimeType:@"multipart/form-data"];
        [formData appendPartWithFormData:[[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"senderID"];
        [formData appendPartWithFormData:[_str_receiver_id dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"receiverID"];
        [formData appendPartWithFormData:[_str_chat_id dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"chat_id"];
        [formData appendPartWithFormData:[@"image" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:KEY_SHARE_FILETYPE];
        [formData appendPartWithFormData:[@"Image" dataUsingEncoding:NSUTF8StringEncoding]
                                    name:@"title"];
        [formData appendPartWithFormData:[@"1" dataUsingEncoding:NSUTF8StringEncoding]//
                                    name:@"isread"];
        [formData appendPartWithFormData:[KEY_AUTH_VALUE dataUsingEncoding:NSUTF8StringEncoding]
                                    name:KEY_AUTH_KEY];
    
    } progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary *dic = [[NSDictionary alloc]init];
        if([[responseObject objectForKey:@"flag"]isEqualToString:@"success"]){
            [Appdelegate hideProgressHudInView];
            [ProgressHUD showSuccess:@"Image uploaded successfully."];
            dic = [responseObject valueForKey:@"usermsg"];
            if ([dic valueForKey:@"chat_id"]) {
                _str_chat_id = [NSString stringWithFormat:@"%@",[dic valueForKey:@"chat_id"]];
            }
            
            _tbl_view_chat.hidden=NO;
            [arr_msg_id addObject:[NSString stringWithFormat:@"%@",[[[responseObject objectForKey:@"results"] objectAtIndex:0] objectForKey:@"message_id"]]];
            [arr_msg_sender_id addObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]];
            [UIView animateWithDuration:0.3 animations:^{
                CGRect f = self.view_bottom_write_msg.frame;
                f.origin.y = self.view.frame.size.height-49;
                self.view_bottom_write_msg.frame = f;
                [_tv_write_msg resignFirstResponder];
            }];
            
            flag_text=0;
            [_tv_write_msg setText:Placeholder];
            self.tv_write_msg.textColor = [UIColor lightGrayColor]; //optional
            [_btn_cancel setTitle:@"Cancel" forState:UIControlStateNormal];
            [self loadchat];
        }
        else if ([[responseObject objectForKey:@"flag"] isEqualToString:@"unsuccess"]) {
            [Appdelegate hideProgressHudInView];
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Message"
                                          message:@"Error to upload file !"
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
            else       {
            [Appdelegate hideProgressHudInView];
            [UIView animateWithDuration:0.3 animations:^{
                CGRect f = self.view_bottom_write_msg.frame;
                f.origin.y = self.view.frame.size.height-49;
                self.view_bottom_write_msg.frame = f;
                [_tv_write_msg resignFirstResponder];
            }];
            [_tv_write_msg setText:Placeholder];
            self.tv_write_msg.textColor = [UIColor lightGrayColor]; //optional
            flag_text=0;
            [_btn_cancel setTitle:@"Cancel" forState:UIControlStateNormal];
                [self loadchat];
        }
        
    }
         
      failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
      [Appdelegate hideProgressHudInView];

        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Error"
                                      message:@"Error in sending message"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        //Handel your yes please button action here
                                    }];
        
        [alert addAction:yesButton];
        //[self presentViewController:alert animated:YES completion:nil];
        
    }];
    }
    }

@catch (NSException *exception) {
    NSLog(@"exception at sendmsgWithImage_Audio %@",exception);
    [Appdelegate hideProgressHudInView];

}
@finally{
    
}
}




-(void)sendmsg
{
    
    @try{
    NSLog(@"chatID %@",_str_chat_id);
    NSLog(@"_str_receiver_id %@",_str_receiver_id);
    NSLog(@"file iD %@",_str_file_id);
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    if ([_str_receiver_id isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]]) {
        _str_receiver_id = _str_sender_ID;
    }
    if (_isShare_Audio) {
        [params setObject:_str_screen_type forKey:KEY_SHARE_FILETYPE];
        [params setObject:_str_file_id forKey:@"file"];
    }
    else{
  
        [params setObject:@"Message" forKey:KEY_SHARE_FILETYPE];
        if (isText) {
            [params setObject:_tv_write_msg.text forKey:@"message"];
        }
    }
    if (_str_chat_id != nil) {
        [params setObject:_str_chat_id forKey:@"chat_id"];
    }
    if (_str_receiver_id == nil) {
        _str_receiver_id = [[NSUserDefaults standardUserDefaults]objectForKey:@"receiver_id"];
    }
    
    [params setObject:_str_receiver_id forKey:@"receiverID"];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"senderID"];
    [params setObject:@"" forKey:@"isread"];
    [params setObject:@"Messege" forKey:@"title"];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];

    NSLog(@" param = %@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@chat.php",BaseUrl];
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
            [Appdelegate hideProgressHudInView];
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
                
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+<!--.*$"
                                                                                       options:NSRegularExpressionDotMatchesLineSeparators
                                                                                         error:nil];
                NSTextCheckingResult *result = [regex firstMatchInString:requestReply
                                                                 options:0
                                                                   range:NSMakeRange(0, requestReply.length)];
                if(result) {
                    NSRange range = [result rangeAtIndex:0];
                    requestReply = [requestReply stringByReplacingCharactersInRange:range withString:@""];
                }
                
                NSData *data = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
                id jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:kNilOptions
                                                                               error:&myError];
              
                if(![[jsonResponse objectForKey:@"success"] isEqual:0]) {
                    [Appdelegate hideProgressHudInView];
//                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"failed"]) {
                    NSDictionary * dic = [jsonResponse valueForKey:@"usermsg"];
                    if ([dic valueForKey:@"chat_id"]) {
                        _str_chat_id = [NSString stringWithFormat:@"%@",[dic valueForKey:@"chat_id"]];
                    }
                    if (_isShare_Audio) {
                        [[NSNotificationCenter defaultCenter]
                         postNotificationName:@"updateShareCounts"
                         object:self];
                    }
                    
                    
                    _tbl_view_chat.hidden=NO;
                    [arr_msg addObject:_tv_write_msg.text];
                    [arr_msg_id addObject:[NSString stringWithFormat:@"%@",[[[jsonResponse objectForKey:@"results"] objectAtIndex:0] objectForKey:@"message_id"]]];
                    [arr_msg_sender_id addObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]];
                    [UIView animateWithDuration:0.3 animations:^{
                        CGRect f = self.view_bottom_write_msg.frame;
                        f.origin.y = self.view.frame.size.height-49;
                        self.view_bottom_write_msg.frame = f;
                        [_tv_write_msg resignFirstResponder];
                    }];
                    
                    flag_text=0;
                    [_tv_write_msg setText:Placeholder];
                    self.tv_write_msg.textColor = [UIColor lightGrayColor]; //optional
                    [_btn_cancel setTitle:@"Cancel" forState:UIControlStateNormal];
                    if (_str_chat_id == nil) {
                        [self getChatID];
                    }
                    else{
                    [self loadchat];
                    }
                    _isShare_Audio = NO;
                    msg_txt=[[NSMutableString alloc]init];
                }
                else
                {
                    [Appdelegate hideProgressHudInView];
                    _isShare_Audio = NO;
                    [UIView animateWithDuration:0.3 animations:^{
                        CGRect f = self.view_bottom_write_msg.frame;
                        f.origin.y = self.view.frame.size.height-49;
                        self.view_bottom_write_msg.frame = f;
                        [_tv_write_msg resignFirstResponder];
                    }];
                    [_tv_write_msg setText:Placeholder];
                    self.tv_write_msg.textColor = [UIColor lightGrayColor]; //optional
                    flag_text=0;
                    [_btn_cancel setTitle:@"Cancel" forState:UIControlStateNormal];
                    msg_txt=[[NSMutableString alloc]init];
                }
                
            });
        }
    }];
    [task resume];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at chat.php without image %@",exception);
        [Appdelegate hideProgressHudInView];

    }
    @finally{
        
    }
    
}




- (IBAction)btn_go_to_studio_play:(id)sender {
    NSLog(@"TAG VALUE %ld",sharedFileIndex);
    if (audioPlayer.isPlaying) {
        [audioPlayer stop];
    }
    if (isSharedAudioPlayed)
    {
        
        NSLog(@"GO TO STUDIO PLAY");
        if ([_str_receiver_id isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]]) {
            _str_receiver_id = _str_sender_ID;
        }
        
        
        StudioPlayViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StudioPlayViewController"];
        myVC.str_RecordingId = [[arr_messageList objectAtIndex:sharedFileIndex]
                                valueForKey:@"file_ID"];
        myVC.str_CurrernUserId = [[[[arr_messageList objectAtIndex:sharedFileIndex]
                                    objectForKey:@"Audioshared"] objectAtIndex:0] objectForKey:@"added_by"];
        [self presentViewController:myVC animated:YES completion:nil];
        
    }
    else
    {
        StudioRecViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StudioRecViewController"];
        
        [self presentViewController:myVC animated:YES completion:nil];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)loadchat
{

    @try{
        [Appdelegate showProgressHud];
    NSDictionary* params = @{
                             KEY_AUTH_KEY:KEY_AUTH_VALUE,
                             @"chatID": _str_chat_id
                             };
    NSLog(@"%@",params);
    arr_msg_date=[[NSMutableArray alloc]init];
    arr_msg_id=[[NSMutableArray alloc]init];
    arr_msg_type=[[NSMutableArray alloc]init];
    arr_msg_time=[[NSMutableArray alloc]init];
    arr_msg_read_unread_status=[[NSMutableArray alloc]init];
    arr_msg=[[NSMutableArray alloc]init];
    arr_msg_sender_id=[[NSMutableArray alloc]init];
    
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@messageList.php",BaseUrl];
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
            [Appdelegate hideProgressHudInView];
            dispatch_async(dispatch_get_main_queue(), ^{

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
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *myError = nil;
                
                NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                NSData *data = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
                
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:kNilOptions
                                                                            error:&myError];
                arr_messageList = [[NSArray alloc]init];
                dic_response=[[NSMutableDictionary alloc]init];
                if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                    [Appdelegate hideProgressHudInView];
                    dic_response=[jsonResponse objectForKey:@"result"];
                    arr_messageList = [dic_response objectForKey:@"message LIst"];
                    if (arr_messageList.count > 0)
                    {
                    _tbl_view_chat.hidden=NO;
                    _view_profile.hidden=YES;
                   
                    int i;
                    for (i=0; i<[[dic_response objectForKey:@"message LIst"] count]; i++) {
                        [arr_msg_id insertObject:[[[dic_response objectForKey:@"message LIst"] objectAtIndex:i] objectForKey:@"id"] atIndex:i];
                        [arr_msg insertObject:[[[dic_response objectForKey:@"message LIst"] objectAtIndex:i] objectForKey:@"message"] atIndex:i];
                        [arr_msg_read_unread_status insertObject:[[[dic_response objectForKey:@"message LIst"] objectAtIndex:i] objectForKey:@"isread"] atIndex:i];
                        [arr_msg_date insertObject:[[[dic_response objectForKey:@"message LIst"] objectAtIndex:i] objectForKey:@"sendat"] atIndex:i];
                        [arr_msg_sender_id insertObject:[[[dic_response objectForKey:@"message LIst"] objectAtIndex:i] objectForKey:@"senderID"] atIndex:i];
                    }

                    [_tbl_view_chat reloadData];
                        [self scrollToTop];
                        
                        if (_isShare_Audio) {
                            
                            [[NSNotificationCenter defaultCenter]
                             postNotificationName:@"updateShareCount"
                             object:self];
                            [self saveShareCount];

                        }
                    }
                }
                else
                {
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
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                }
            });
        }
    }];
    [task resume];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at loadChat  %@",exception);
        [Appdelegate hideProgressHudInView];
    }
    @finally{
        
    }
}

- (IBAction)handleLogTokenTouch:(id)sender {
    // [START get_iid_token]
//    NSLog(@"InstanceID token: %@", token);
    // [END get_iid_token]
}

- (IBAction)handleSubscribeTouch:(id)sender {
    // [START subscribe_topic]
    [[FIRMessaging messaging] subscribeToTopic:@"/topics/news"];
//    NSLog(@"Subscribed to news topic");
    // [END subscribe_topic]
}



-(void)getChatID
{
    
    @try{
    if ([_str_receiver_id isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]]) {
        _str_receiver_id = _str_sender_ID;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"senderID"];
    [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
    [params setObject:_str_receiver_id forKey:@"receiverID"];
   
    NSLog(@"%@",params);
    NSMutableString* parameterString = [NSMutableString string];
    for(NSString* key in [params allKeys])
    {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@",key, params[key]];
    }
    NSString* urlString = [NSString stringWithFormat:@"%@user_chat_id.php",BaseUrl];
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLSession* session =[NSURLSession sharedSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(error)
        {
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
                NSData *data = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
                id jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:kNilOptions
                                                                    error:&myError];
                
                if ([[jsonResponse valueForKey:@"flag"]isEqualToString:@"success"]){
                    _str_chat_id = [NSString stringWithFormat:@"%@",[jsonResponse objectForKey:@"chatID"]];
                    
                    if (_isShare_Audio) {
                        [self sendmsg];
                    }
                    else if([_str_receiver_type isEqualToString:@"contact"])
                    {
                        if ([_str_chat_id isEqualToString:@"0"])
                        {
                            [self updateChatID];
                        }
                        else{
                            [self loadchat];
                        }
                    }
                    else{
                        [self loadchat];
                    }
                    
                }
                else{
                    if([[jsonResponse valueForKey:@"flag"]isEqualToString:@"No chat between both ID"] && _isChat_type_Group){
                        [self updateChatID];
                    }
                    else{
                    _str_chat_id = [NSString stringWithFormat:@"%@",[jsonResponse objectForKey:@"chatID"]];
                    if (arr_userID.count > 1) {
                        _img_view_profile.image = [UIImage imageNamed:@"img_group"];
                    }
                    if (_isShare_Audio) {
                        _str_chat_id = [NSString stringWithFormat:@"%@",[jsonResponse objectForKey:@"chatID"]];
                        [self sendmsg];
                    }
                    _tbl_view_chat.hidden=YES;
                    _view_profile.hidden=NO;
                    _img_view_profile.layer.cornerRadius = _img_view_profile.frame.size.width / 2;
                    _img_view_profile.clipsToBounds = YES;
                    NSURL *url = [NSURL URLWithString:_img_view_Profile];
                    [_img_view_profile sd_setImageWithURL:url
                        placeholderImage:[UIImage imageNamed:@"artist.png"]];
                        if (contactName == nil) {
                            contactName = _str_receiver_name;
                        }
                    _lbl_quate.text=[NSString stringWithFormat:@"\"Send %@ a Message\"",contactName];
                    NSString *strLbl= _lbl_quate.text;
                    NSRange rangeBold = [strLbl rangeOfString:contactName];
                     UIFont *fontText = [UIFont fontWithName:@"Avenir-HeavyOblique" size:14.0];
                    NSDictionary *dictBoldText = [NSDictionary dictionaryWithObjectsAndKeys:fontText, NSFontAttributeName, nil];
                    NSMutableAttributedString *mutAttrLblString = [[NSMutableAttributedString alloc] initWithString:strLbl];
                    [mutAttrLblString setAttributes:dictBoldText range:rangeBold];
                    [_lbl_quate setAttributedText:mutAttrLblString];
                    }
                }
            });
        }
    }];
    [task resume];
                           
    }
    @catch (NSException *exception) {
        NSLog(@"exception at  user_chat_id.php%@",exception);
    }
    @finally{
        
    }
}


-(void)updateChatID
{
    
    @try{
        if ([_str_receiver_id isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]]) {
            _str_receiver_id = _str_sender_ID;
        }
        NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
        [params setObject:KEY_AUTH_VALUE forKey:KEY_AUTH_KEY];
        [params setObject:_str_receiver_id forKey:@"usersId"];
        
        NSLog(@"%@",params);
        NSMutableString* parameterString = [NSMutableString string];
        for(NSString* key in [params allKeys])
        {
            if ([parameterString length]) {
                [parameterString appendString:@"&"];
            }
            [parameterString appendFormat:@"%@=%@",key, params[key]];
        }
        NSString* urlString = [NSString stringWithFormat:@"%@chatgroup.php",BaseUrl];
        NSURL* url = [NSURL URLWithString:urlString];
        
        NSURLSession* session =[NSURLSession sharedSession];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPShouldHandleCookies:NO];
        
        NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if(error)
            {
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
                    NSDictionary *dicData = [[NSDictionary alloc]init];
                    NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                    NSData *data = [requestReply dataUsingEncoding:NSUTF8StringEncoding];
                    id jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:kNilOptions
                                                                        error:&myError];
                    
                    if ([[jsonResponse valueForKey:@"flag"]isEqualToString:@"success"]){
//                        _tbl_view_chat.hidden=YES;
//                        _view_profile.hidden=NO;
//                        dicData = [jsonResponse valueForKey:@"response"];
//                        _str_chat_id = [dicData valueForKey:@"chat_id"];
//                        contactName = [dicData valueForKey:@"groupName"];
//                        NSString *imgStr = [NSString stringWithFormat:@"%@%@",BaseUrl,[dicData valueForKey:@"groupPic"]];
//                        _img_view_profile.layer.cornerRadius = _img_view_profile.frame.size.width / 2;
//                        _img_view_profile.clipsToBounds = YES;
//                        NSURL *url = [NSURL URLWithString:imgStr];
//                        [_img_view_profile sd_setImageWithURL:url
//                                             placeholderImage:[UIImage imageNamed:@"artists.png"]];
//                        _lbl_quate.text=[NSString stringWithFormat:@"\"Send %@ a Message\"",contactName];
//                        NSString *strLbl= _lbl_quate.text;
//                        NSRange rangeBold = [strLbl rangeOfString:contactName];
//                        UIFont *fontText = [UIFont fontWithName:@"Avenir-HeavyOblique" size:14.0];
//                        NSDictionary *dictBoldText = [NSDictionary dictionaryWithObjectsAndKeys:fontText, NSFontAttributeName, nil];
//                        NSMutableAttributedString *mutAttrLblString = [[NSMutableAttributedString alloc] initWithString:strLbl];
//                        [mutAttrLblString setAttributes:dictBoldText range:rangeBold];
//                        [_lbl_quate setAttributedText:mutAttrLblString];
//                        [defaults_userdata setObject:self.str_chat_id forKey:@"chat_id"];
//                        if (_isShare_Audio) {
//                            [self sendmsg];
//                        }
//                        else{
//                            [self loadchat];
//                        }
                        
                        //--------------------------------------------------------------------------
                        _tbl_view_chat.hidden=YES;
                        _view_profile.hidden=NO;
                        dicData = [jsonResponse valueForKey:@"response"];
                        _str_chat_id = [dicData valueForKey:@"chat_id"];
                        _str_GroupName = [dicData valueForKey:@"groupName"];
                        _str_receiver_name  = _str_GroupName;
                        _str_GroupImage = [NSString stringWithFormat:@"%@%@",BaseUrl,[dicData valueForKey:@"groupPic"]];

                        if (_isShare_Audio) {
                            _str_chat_id = [NSString stringWithFormat:@"%@",[jsonResponse objectForKey:@"chatID"]];
                            [self sendmsg];
                        }
                        
                        _img_view_profile.layer.cornerRadius = _img_view_profile.frame.size.width / 2;
                        _img_view_profile.clipsToBounds = YES;
                        NSURL *url = [NSURL URLWithString:_str_GroupImage];
                        [_img_view_profile sd_setImageWithURL:url
                            placeholderImage:[UIImage imageNamed:@"group.png"]];
                        _lbl_quate.text=[NSString stringWithFormat:@"\"Send %@ a Message\"",contactName];
                        NSString *strLbl= _lbl_quate.text;
                        NSRange rangeBold = [strLbl rangeOfString:contactName];
                        UIFont *fontText = [UIFont fontWithName:@"Avenir-HeavyOblique" size:14.0];
                        NSDictionary *dictBoldText = [NSDictionary dictionaryWithObjectsAndKeys:fontText, NSFontAttributeName, nil];
                        NSMutableAttributedString *mutAttrLblString = [[NSMutableAttributedString alloc] initWithString:strLbl];
                        [mutAttrLblString setAttributes:dictBoldText range:rangeBold];
                        [_lbl_quate setAttributedText:mutAttrLblString];
                    }
                });
            }
        }];
        [task resume];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at  update group.php%@",exception);
    }
    @finally{
        
    }
}


#pragma mark - keyboard movements
#pragma mark -
- (void)keyboardWillShow:(NSNotification *)notification
{
    _btn_go_to_studio_play.hidden=YES;
    _btn_cancel.hidden=NO;
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    [UIView animateWithDuration:0.3 animations:^{

        CGRect f = self.view_form.frame;
        f.origin.y = self.view.frame.size.height-
        (keyboardSize.height+self.view_form.frame.size.height);
        self.view_form.frame = f;

        if (isShareWillShow) {
            CGRect y = _view_SharePlay.frame;
            y.origin.y = self.view.frame.size.height-(keyboardSize.height+
                                                      self.view_form.frame.size.height+
            _view_SharePlay.frame.size.height);
            _view_SharePlay.frame = y;
        }
        CGRect z = self.tbl_view_chat.frame;
        z.origin.y = self.view.frame.size.height-
        (keyboardSize.height+self.tbl_view_chat.frame.size.height+
         self.view_form.frame.size.height);
        self.tbl_view_chat.frame = z;
    }];

}

-(void)keyboardWillHide:(NSNotification *)notification
{
_btn_go_to_studio_play.hidden=NO;
    [_tv_write_msg setTextColor:[UIColor blackColor]];
    _btn_cancel.hidden=YES;
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = _view_form.frame;
        f.origin.y =f.origin.y+keyboardSize.height;
        self.view_form.frame = f;
        if (isShareWillShow) {
            CGRect y = _view_SharePlay.frame;
            y.origin.y =y.origin.y+keyboardSize.height;
            _view_SharePlay.frame = y;
        }
        CGRect z = self.tbl_view_chat.frame;
        z.origin.y =z.origin.y+keyboardSize.height;
        self.tbl_view_chat.frame = z;
    }];

}


#pragma mark - UIImagePickerControllerDelegate
#pragma mark -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info
{
    imageData = [[NSData alloc]init];
    imageName=[[NSString alloc]init];
    _img_view_profile = info[UIImagePickerControllerOriginalImage];
    dp_view.hidden=YES;
    
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    NSString *extension = [imageURL pathExtension];
    CFStringRef imageUTI = (UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(__bridge CFStringRef)extension , NULL));

    UIImage*img12=[info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage*compressedImage = [Appdelegate scaleImage:img12 toSize:CGSizeMake(200, 200)];
    compressedImage = [Appdelegate scaleAndRotateImage:compressedImage];
    imageData = UIImagePNGRepresentation(compressedImage);
    long rangeLow = 1;
    long rangeHigh = 999999999999999999;
    long randomNumber = arc4random() % (rangeHigh-rangeLow+1) + rangeLow;
    imageName = [imageURL lastPathComponent];
    if (([imageName  length]==0)) {
        //imageName=@"image.png";
        
        imageName = [NSString stringWithFormat:@"%ldimage.png",randomNumber];
    }
    else
    {
        imageName = [NSString stringWithFormat:@"%ldasset.JPG",randomNumber];
    }
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Alert"
                                  message:@"Are you sure want to send this picture ?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [self sendmsgWithImage_Audio];
                                }];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                actionWithTitle:@"Cancel"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    //Handel your yes please button action here
                                }];
    [alert addAction:cancelButton];
    [alert addAction:yesButton];

    //[self presentViewController:alert animated:YES completion:nil];
    
    [self sendmsgWithImage_Audio];
    
}



#pragma mark - CollectionView Delegate & Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return Appdelegate.arr_Gallery_Items.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //return CGSizeMake(100,cv_images.frame.size.height);
    UIImage *image = [Appdelegate.arr_Gallery_Items objectAtIndex:indexPath.item];
    //You may want to create a divider to scale the size by the way..
    float oldheight = image.size.height;
    float scaleFactor =cv_images.frame.size.height/ oldheight;
    float newwidth = image.size.width * scaleFactor;
    //float newheight = oldheight * scaleFactor;
    
    return CGSizeMake(newwidth, cv_images.frame.size.height);
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    imageCollectionViewCell *cell = (imageCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.img_view.image = [Appdelegate.arr_Gallery_Items objectAtIndex:indexPath.item];
    cell.backgroundColor=[UIColor greenColor];
    return cell;
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"this is caled");
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    imageData=UIImagePNGRepresentation([Appdelegate.arr_Gallery_Items objectAtIndex:indexPath.item]);
   // imageCounter =444;
   // imageName=@"image.png";
    /*

     //long rangeLow = 1;
     //long rangeHigh = 999999999999999999;
     //long randomNumber = arc4random() % (rangeHigh-rangeLow+1) + rangeLow;
     
     */
    dp_view.hidden=YES;
     long  randomNumber = arc4random_uniform(999999999);
    NSLog(@"PRINT RANDOM %ld",randomNumber);
    imageName=@"";
    if (([imageName  length]==0)) {
        //imageName=@"image.png";
        
        
        imageName = [NSString stringWithFormat:@"%ldimage.png",randomNumber];
 
    }
    [self dismissViewControllerAnimated:YES completion:nil];
     [self sendmsgWithImage_Audio];
    

    /*UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Alert"
                                  message:@"Are you sure want to send this picture ?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    [self sendmsgWithImage_Audio];
                                }];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       //Handel your yes please button action here
                                   }];
    [alert addAction:cancelButton];
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];*/
}




#pragma mark - TableView Delegate & Datasource
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arr_messageList count];
}



-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"******* indexPath = %ld ********",(long)indexPath.row);

    receiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recieve"];
    
    if (!cell )
    {
        [tableView registerNib:[UINib nibWithNibName:@"receiveTableViewCell"
                                              bundle:nil] forCellReuseIdentifier:@"recieve"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"recieve"];
        
    }
    
    
    NSString * tweetTextString = [arr_msg objectAtIndex:indexPath.row];
    float heightToAdd = 85.0f;
  //  CGSize textSize= [self heigtForCellwithString:tweetTextString withFont:[UIFont systemFontOfSize:13.0f]];
    
    CGSize constraint;
    constraint = CGSizeMake(210, 5000.0f);
    
    CGSize size = [tweetTextString sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
   
    
    if([arr_messageList count] > 0 && [arr_messageList count] > indexPath.row){

    if ([[[arr_messageList objectAtIndex:indexPath.row]
          valueForKey:KEY_SHARE_FILETYPE] isEqualToString:@"image"] )
    {
             heightToAdd =heightToAdd+ 75+120;
    }
    else if([[arr_messageList objectAtIndex:indexPath.row]
             valueForKey:@"Audioshared"] != [NSNull null] ){
        heightToAdd = 140;
    }
    else{
         heightToAdd =heightToAdd+ size.height;
        //heightToAdd = MAX(size.height+20, 85.0f); //Some fix height is returned if height is small or change it to MAX(textSize.height, 150.0f); // whatever best fits for you
    }
    }
    //    NSLog(@"height of row %f",heightToAdd);
    return heightToAdd;
    
}

-(CGSize)heigtForCellwithString:(NSString *)stringValue withFont:(UIFont*)font{
    CGSize constraint = CGSizeMake(210,9999); // Replace 300 with your label width
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGRect rect = [stringValue boundingRectWithSize:constraint
                                            options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                         attributes:attributes
                                            context:nil];
    return rect.size;
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try{
    sendMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"send"];
    if([arr_messageList count] > 0 && [arr_messageList count] > indexPath.row){

    NSLog(@"index = %ld\n %@text is ",(long)indexPath.row,[[arr_messageList objectAtIndex:indexPath.row]valueForKey:@"message"]);
    if ([[arr_msg_sender_id objectAtIndex:indexPath.row] isEqual:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]])
    {
        
        if ([[arr_messageList objectAtIndex:indexPath.row] valueForKey:@"Audioshared"] == [NSNull null]) {
     
        if (cell == nil)
        {
            [tableView registerNib:[UINib nibWithNibName:@"sendMessageTableViewCell"
                                                  bundle:nil] forCellReuseIdentifier:@"send"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"send"];
        }
            //--------------------- * Set Frames *------------------
            cell.view_msg_bg.layer.cornerRadius = 15;
            cell.img_view_msg.clipsToBounds = YES;
            cell.accessoryType = UITableViewCellStyleDefault;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.img_view_profile.layer.cornerRadius = cell.img_view_profile.frame.size.width /2;
            cell.img_view_profile.clipsToBounds = YES;
            //-- 1 --
            //------------------- Set Text as message -------------
            NSString *str_chatText =[arr_msg objectAtIndex:indexPath.row];
            CGSize constraint;
            constraint = CGSizeMake(210, 5000.0f);
            CGSize size = [str_chatText sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:constraint
                                       lineBreakMode:NSLineBreakByWordWrapping];
            if([arr_messageList count] > 0 && [arr_messageList count] > indexPath.row && (!
                                                                                          [str_chatText isEqualToString:@""])){
                cell.lbl_text.text = str_chatText;
            }
            if (size.height < 21) {
                
                size.height = 21;
            }
            [cell.lbl_text setFrame:CGRectMake(cell.lbl_text.frame.origin.x,
                                               cell.lbl_text.frame.origin.y,
                                               cell.lbl_text.frame.size.width,
                                               size.height)];
            //-- 2 --
            //------------------- Set Image as message -------------
            if ([[[arr_messageList objectAtIndex:indexPath.row] valueForKey:KEY_SHARE_FILETYPE] isEqualToString:@"image"] ){//&& [[[arr_messageList objectAtIndex:indexPath.row] valueForKey:@"file_url"] isEqualToString:@"No url"]){//.count>0 && indexPath.row == arr_msg.count) {
                
                //Image
                //-------------- Set constraints Frame --------------------

                NSURL *url = [NSURL URLWithString:[[arr_messageList objectAtIndex:indexPath.row] valueForKey:@"file_url"]];
               // cell.img_view_msg.contentMode = UIViewContentModeScaleToFill;
                [cell.img_view_msg sd_setImageWithURL:url
                                     placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
                cell.img_view_msg.hidden=NO;
                cell.img_attached.hidden=YES;
                cell.lbl_imgAttached.hidden=NO;
                
                NSString* strImageLbl = [[arr_messageList objectAtIndex:indexPath.row] valueForKey:@"file_url"];
                strImageLbl = strImageLbl.lastPathComponent;
                cell.lbl_imgAttached.text = [NSString stringWithFormat:@"\U0001f4ce %@",strImageLbl];
               cell.img_attached.frame = CGRectMake(cell.img_view_msg.frame.origin.x - 20,
                                                     cell.img_view_msg.frame.origin.y+cell.img_view_msg.frame.size.height+5,
                                                     cell.img_attached.frame.size.width,
                                                     cell.img_attached.frame.size.height);
                
                cell.lbl_imgAttached.frame = CGRectMake(cell.img_attached.frame.origin.x+
                                                        cell.img_attached.frame.size.width+5,
                                                        cell.img_attached.frame.origin.y ,
                                                        cell.lbl_imgAttached.frame.size.width,
                                                        cell.lbl_imgAttached.frame.size.height);
                //------------------- Set Frame Double Tick -------------
                cell.img_doubleTick.frame = CGRectMake(cell.img_view_msg.frame.origin.x+
                                                       cell.img_view_msg.frame.size.width-cell.img_doubleTick.frame.size.width,
                                                       cell.img_attached.frame.origin.y,
                                                       cell.img_doubleTick.frame.size.width,
                                                       cell.img_doubleTick.frame.size.height);
            }
            else{
                cell.img_view_msg.hidden=YES;
                cell.img_attached.hidden=YES;
                cell.lbl_imgAttached.hidden=YES;
                //------------------- Set Frame Double Tick -------------
                cell.img_doubleTick.frame = CGRectMake(cell.lbl_text.frame.origin.x+
                                                       cell.view_msg_bg.frame.size.width-
                                                       (cell.img_doubleTick.frame.size.width+30),
                                                       cell.img_view_msg.frame.origin.y+cell.img_view_msg.frame.size.height+5,
                                                       cell.img_doubleTick.frame.size.width,
                                                       cell.img_doubleTick.frame.size.height);
            }
            //---3 ---
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSDate *tempDate=[formatter dateFromString:[[arr_messageList objectAtIndex:indexPath.row]valueForKey:@"sendat"]];
            NSLog(@"NEW TIME 4 %@",[self getUTCFormateDate:tempDate]);
            cell.lbl_date.text = [self getUTCFormateDate:tempDate];
            //---4 ---
            //--------------------- Cover pic ----------------------
            NSLog(@"%@",[[arr_messageList objectAtIndex:indexPath.row] valueForKey:@"sender_pic"]);
            if (([[arr_messageList objectAtIndex:indexPath.row] valueForKey:@"sender_pic"]) != [NSNull null]) {
                NSURL *url = [NSURL URLWithString:[[arr_messageList objectAtIndex:indexPath.row] valueForKey:@"sender_pic"] ];
                cell.img_view_profile.contentMode = UIViewContentModeScaleToFill;
                
                if ([[[arr_messageList objectAtIndex:indexPath.row]
                      valueForKey:@"Chat_type"]isEqualToString:@"group"]) {
                    [cell.img_view_profile sd_setImageWithURL:url
                                             placeholderImage:[UIImage imageNamed:@"artist.png"]];
                }
                else{
                    [cell.img_view_profile sd_setImageWithURL:url
                                             placeholderImage:[UIImage imageNamed:@"artist.png"]];
                }
                
            }
            else{
                
            }
            return cell;
        }
        
        else{
            sendfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"send_file"];

            if (!cell )
            {
                [tableView registerNib:[UINib nibWithNibName:@"sendfileTableViewCell"
                                                      bundle:nil] forCellReuseIdentifier:@"send_file"];
                cell = [tableView dequeueReusableCellWithIdentifier:@"send_file"];

            }
            
                cell.accessoryType = UITableViewCellStyleDefault;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.img_view_profile.layer.cornerRadius = cell.img_view_profile.frame.size.width / 2;
                cell.img_view_profile.clipsToBounds = YES;
                //--------------------- Cover pic ----------------------
            
                    if (([[arr_messageList objectAtIndex:indexPath.row] valueForKey:@"sender_pic"]) != [NSNull null]) {

                        NSURL *url = [NSURL URLWithString:[[arr_messageList objectAtIndex:indexPath.row] valueForKey:@"sender_pic"] ];
                        cell.img_view_profile.contentMode = UIViewContentModeScaleToFill;
                
                        if ([[[arr_messageList objectAtIndex:indexPath.row]valueForKey:@"Chat_type"]isEqualToString:@"group"]) {
                            [cell.img_view_profile sd_setImageWithURL:url
                                             placeholderImage:[UIImage imageNamed:@"artist.png"]];
                        }
                
                        else{
                            [cell.img_view_profile sd_setImageWithURL:url
                                             placeholderImage:[UIImage imageNamed:@"artist.png"]];
                        }
                    }
            
                NSArray *arr_shared = [[arr_messageList objectAtIndex:indexPath.row] valueForKey:@"Audioshared"];
                
                //--------------------- * Audio Title *------------------
                cell.lbl_audio_title.text= [[arr_shared objectAtIndex:0]valueForKey:@"recording_topic"];
                
                //--------------------- * User Title *------------------
                cell.lbl_user_name.text=[NSString stringWithFormat:@"@%@",[[arr_shared objectAtIndex:0]valueForKey:@"user_name"]];
                
                //--------------------- * Number of playing audio *------------------
                cell.lbl_numberOf_audio.text=[NSString stringWithFormat:@"(1 of %lu)",(unsigned long)arr_shared.count];
                
                //--------------------- * Date *------------------
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSDate *tempDate=[formatter dateFromString:[[arr_messageList objectAtIndex:indexPath.row]valueForKey:@"sendat"]];
            NSLog(@"NEW TIME 4 %@",[self getUTCFormateDate:tempDate]);
            cell.lbl_Date.text = [self getUTCFormateDate:tempDate];
            
                //--------------------- * Play Method *------------------
                [cell.btn_play setTag:indexPath.row];
                [cell.btn_play addTarget:self action:@selector(btn_Share_Play_clicked:)
                        forControlEvents:UIControlEventTouchUpInside];
                
                //--------------------- * Previous Method *------------------
                [cell.btn_previous setTag:indexPath.row];
                [cell.btn_previous addTarget:self action:@selector(btn_Recordings_Play_clicked:)
                        forControlEvents:UIControlEventTouchUpInside];
                
                //--------------------- * Next Method *------------------
                [cell.btn_next setTag:indexPath.row];
                [cell.btn_next addTarget:self action:@selector(btn_Recordings_Play_clicked:)
                            forControlEvents:UIControlEventTouchUpInside];
            
                //--------------------- * Join Share Method *------------------
                [cell.btn_AudioShare_join setTag:indexPath.row];
                [cell.btn_AudioShare_join addTarget:self action:@selector(btn_AudioShare_join_clicked:)
                    forControlEvents:UIControlEventTouchUpInside];
                return cell;

            }
            
        return cell;
    }
        
    else{
        if ([[arr_messageList objectAtIndex:indexPath.row] valueForKey:@"Audioshared"] == [NSNull null])
        {
            receiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recieve"];

            if (!cell )
            {
                [tableView registerNib:[UINib nibWithNibName:@"receiveTableViewCell"
                                                      bundle:nil] forCellReuseIdentifier:@"recieve"];
                cell = [tableView dequeueReusableCellWithIdentifier:@"recieve"];

            }
            cell.view_msg_receive_bg.layer.cornerRadius = 15;
            cell.accessoryType = UITableViewCellStyleDefault;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.img_view_profile_recevie.layer.cornerRadius = cell.img_view_profile_recevie.frame.size.width / 2;
//            cell.img_view_profile_recevie.clipsToBounds = YES;
            //------------------- Set Text as message -------------
//            NSString *str_chatText =[arr_msg objectAtIndex:indexPath.row];
//            CGSize adjustedSize= [self heigtForCellwithString:str_chatText withFont:[UIFont systemFontOfSize:13.0f]];
//            CGRect newFrame = cell.lbl_msg_receive.frame;
//            newFrame.size.height = adjustedSize.height;//adjustedSize.width;
////            cell.lbl_msg_receive.frame = newFrame;
//            cell.cons_lbl_height.constant = adjustedSize.height;
//            if([arr_messageList count] > 0 && [arr_messageList count] > indexPath.row){
//            cell.lbl_msg_receive.text = str_chatText;
//            }
            //------------------- Set Text as message -------------
            NSString *str_chatText =[arr_msg objectAtIndex:indexPath.row];
            // CGSize adjustedSize= [self heigtForCellwithString:str_chatText withFont:[UIFont systemFontOfSize:13.0f]];
            // cell.cons_lbl_height.constant = adjustedSize.height;
            CGSize constraint;
            constraint = CGSizeMake(210, 5000.0f);
            CGSize size = [str_chatText sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:constraint
                                       lineBreakMode:NSLineBreakByWordWrapping];
            if([arr_messageList count] > 0 && [arr_messageList count] > indexPath.row && (!
                                                                                          [str_chatText isEqualToString:@""])){
                cell.lbl_msg_receive.text = str_chatText;
            }
            if (size.height < 21) {
                
                size.height = 21;
            }
            [cell.lbl_msg_receive setFrame:CGRectMake(cell.lbl_msg_receive.frame.origin.x,
                                               cell.lbl_msg_receive.frame.origin.y,
                                               cell.lbl_msg_receive.frame.size.width,
                                               size.height)];
            
            //------------------- Set Image as message -------------
            if ([[[arr_messageList objectAtIndex:indexPath.row]
                  valueForKey:KEY_SHARE_FILETYPE] isEqualToString:@"image"] ){//&& [[[arr_messageList objectAtIndex:indexPath.row] valueForKey:@"file_url"] isEqualToString:@"No url"]){//.count>0 && indexPath.row == arr_msg.count) {
                
                //Image
                NSURL *url = [NSURL URLWithString:[[arr_messageList objectAtIndex:indexPath.row] valueForKey:@"file_url"]];
                cell.img_view_msg_receive.contentMode = UIViewContentModeScaleToFill;
                [cell.img_view_msg_receive sd_setImageWithURL:url
                                             placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
                cell.img_view_msg_receive.hidden=NO;
                cell.img_attached.hidden=NO;
                cell.lbl_imgAttached.hidden=NO;
                //////////////////////////////////////////////////
                NSString* strImageLbl = [[arr_messageList objectAtIndex:indexPath.row] valueForKey:@"file_url"];
                strImageLbl = strImageLbl.lastPathComponent;
                //  NSString *pc=@"\uDD87";
                cell.lbl_imgAttached.text = [NSString stringWithFormat:@"\U0001f4ce %@",strImageLbl];
                CGRect frame_view = cell.img_view_msg_receive.frame;
                cell.img_attached.frame = CGRectMake(frame_view.origin.x,
                                                     frame_view.origin.y +  cell.view_msg_receive_bg.frame.size.width-60,
                                                     cell.img_attached.frame.size.width,
                                                     cell.img_attached.frame.size.height);
                //cell.img_attached.frame = CGRectMake(cell.img_attached.frame.origin.x, cell.img_attached.frame.origin.y+cell.img_attached.frame.size.width+15,cell.img_attached.frame.size.width, cell.img_attached.frame.size.height);
                
               // cell.lbl_imgAttached.frame = CGRectMake(cell.img_attached.frame.origin.x+
                                                      //  cell.img_attached.frame.size.width+5,
                                                      //  cell.img_attached.frame.origin.y+cell.img_attached.frame.size.height+10 ,
                                                      //  cell.lbl_imgAttached.frame.size.width,
                                                      //  cell.lbl_imgAttached.frame.size.height);
                //------------------- Set Frame Double Tick -------------
               // cell.img_doubleTick.frame = CGRectMake(cell.lbl_imgAttached.frame.origin.x+
                                                     //  cell.lbl_imgAttached.frame.size.width+
                                                     //  50,
                                                      // cell.img_attached.frame.origin.y +cell.img_attached.frame.size.height+10,
                                                      // cell.img_doubleTick.frame.size.width,
                                                     //  cell.img_doubleTick.frame.size.height);
                
                /////////////////////////////////////////////////
            }
            else{
                cell.img_view_msg_receive.hidden=YES;
                cell.img_attached.hidden=YES;
                cell.lbl_imgAttached.hidden=YES;
                //------------------- Set Frame Double Tick -------------
               // cell.img_doubleTick.frame = CGRectMake(cell.lbl_msg_receive.frame.origin.x+
                                                  //     cell.view_msg_receive_bg.frame.size.width-
                                                   //    (cell.img_doubleTick.frame.size.width+30),
                                                   //    cell.lbl_msg_receive.frame.origin.y +
                                                     //  cell.lbl_msg_receive.frame.size.height+10,
                                                      // cell.img_doubleTick.frame.size.width,
                                                      // cell.img_doubleTick.frame.size.height);
            }
            
            //--------------------- * Date *------------------
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSDate *tempDate=[formatter dateFromString:[[arr_messageList objectAtIndex:indexPath.row]valueForKey:@"sendat"]];
            NSLog(@"----------- NEW TIME 4 %@",[self getUTCFormateDate:tempDate]);
            cell.lbl_date.text = [self getUTCFormateDate:tempDate];
//            cell.lbl_date.text = @"dgdslkdsgES";
            NSLog(@"*******TIME 2 %@",[[arr_messageList objectAtIndex:indexPath.row]valueForKey:@"sendat"]);
            //--------------------- Cover pic ----------------------

            NSURL *url = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults]
                                               objectForKey:@"profilepic"] ];
         //   cell.img_view_profile_recevie.contentMode = UIViewContentModeScaleAspectFit;
            
            if ([[[arr_messageList objectAtIndex:indexPath.row]
                                                valueForKey:@"Chat_type"]isEqualToString:@"group"]) {
                [cell.img_view_profile_recevie sd_setImageWithURL:url
                                                 placeholderImage:[UIImage imageNamed:@"artist.png"]];
            }
            else{
                [cell.img_view_profile_recevie sd_setImageWithURL:url
                                                 placeholderImage:[UIImage imageNamed:@"artist.png"]];
            }
            return cell;
    }
        
        else{
            receivefileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recieve_file"];
            if (!cell )
            {
                [tableView registerNib:[UINib nibWithNibName:@"receivefileTableViewCell"
                                                      bundle:nil] forCellReuseIdentifier:@"recieve_file"];
                cell = [tableView dequeueReusableCellWithIdentifier:@"recieve_file"];
            }
                cell.accessoryType = UITableViewCellStyleDefault;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.img_view_profile.layer.cornerRadius = cell.img_view_profile.frame.size.width / 2;
                cell.img_view_profile.clipsToBounds = YES;
                //--------------------- Cover pic ----------------------
                NSURL *url = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults]
                                               objectForKey:@"profilepic"] ];
                cell.img_view_profile.contentMode = UIViewContentModeScaleToFill;
                if ([[[arr_messageList objectAtIndex:indexPath.row]valueForKey:@"Chat_type"]isEqualToString:@"group"]) {
                    [cell.img_view_profile sd_setImageWithURL:url
                                             placeholderImage:[UIImage imageNamed:@"artist.png"]];
                }
                
                else{
                    [cell.img_view_profile sd_setImageWithURL:url
                                             placeholderImage:[UIImage imageNamed:@"artist.png"]];
                }
                
                NSArray *arr_shared = [[arr_messageList objectAtIndex:indexPath.row]
                                                    valueForKey:@"Audioshared"];
                //--------------------- * Audio Title *------------------
                cell.lbl_audio_title.text= [[arr_shared objectAtIndex:0]valueForKey:@"recording_topic"];
                
                //--------------------- * User Title *------------------
                cell.lbl_user_name.text=[NSString stringWithFormat:@"@%@",[[arr_shared objectAtIndex:0]valueForKey:@"user_name"]];
                
                //--------------------- * Number of playing audio *------------------
                cell.lbl_numberOf_audio.text=[NSString stringWithFormat:@"(1 of %lu)",(unsigned long)arr_shared.count];
                //--------------------- * Date *------------------
//                cell.lbl_Date.text=[[arr_messageList objectAtIndex:indexPath.row]valueForKey:@"sendat"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSDate *tempDate=[formatter dateFromString:[[arr_messageList objectAtIndex:indexPath.row]valueForKey:@"sendat"]];
            NSLog(@"NEW TIME 4 %@",[self getUTCFormateDate:tempDate]);
            cell.lbl_Date.text = [self getUTCFormateDate:tempDate];
            
                //--------------------- * Play Method *------------------
                [cell.btn_play setTag:indexPath.row];
            
                [cell.btn_play addTarget:self action:@selector(btn_Share_Play_clicked:)
                        forControlEvents:UIControlEventTouchUpInside];
                
                //--------------------- * Previous Method *------------------
                [cell.btn_previous setTag:indexPath.row];
                [cell.btn_previous addTarget:self action:@selector(btn_Recordings_Play_clicked:)
                            forControlEvents:UIControlEventTouchUpInside];
                
                //--------------------- * Next Method *------------------
                [cell.btn_next setTag:indexPath.row];
                [cell.btn_next addTarget:self action:@selector(btn_Recordings_Play_clicked:)
                        forControlEvents:UIControlEventTouchUpInside];
            
                //--------------------- * Join Share Method *------------------
                [cell.btn_AudioShare_join setTag:indexPath.row];
                [cell.btn_AudioShare_join addTarget:self action:@selector(btn_AudioShare_join_clicked:)
                               forControlEvents:UIControlEventTouchUpInside];
            
                return cell;

            }

        }

    }
    return cell;
    }
    @catch (NSException *exception) {
        NSLog(@"exception at cellfor rrow at index path:%@",exception);
    }
    @finally{
        
    }
}

-(NSString *)getUTCFormateDate:(NSDate *)localDate
{
    NSTimeInterval secondsInEightHours = 1 * 60 * 60;
    NSDate *dateEightHoursAhead = [localDate dateByAddingTimeInterval:-secondsInEightHours];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dateEightHoursAhead];
    
    return dateString;
}


-(void)btn_AudioShare_join_clicked:(UIButton *)sender{
    
//    if ([segue.identifier isEqual:@"audiofeed_to_studio_play"]) {
//        //         if ([defaults_userdata boolForKey:@"isUserLogged"]) {
//        StudioPlayViewController*vc=segue.destinationViewController;
//        vc.str_CurrernUserId = [followerID objectAtIndex:index];
//        vc.str_RecordingId = [arr_rec_pack_id objectAtIndex:index];
//        vc.arr_recordings=[arr_rec_recordings objectAtIndex:index];
//        //     }
//    }
    if ([_str_receiver_id isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]]) {
        _str_receiver_id = _str_sender_ID;
    }
    
    
    StudioPlayViewController *myVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StudioPlayViewController"];
    myVC.str_RecordingId = [[arr_messageList objectAtIndex:sender.tag]
                            valueForKey:@"file_ID"];
    myVC.str_CurrernUserId = _str_receiver_id;
    [self presentViewController:myVC animated:YES completion:nil];
}



-(NSString *)formattedDate:(NSString*)date {
    //--------------------- * Date *------------------
    NSString *str_day,*str_date,*str_time,*str_second,*str_AMorPM,*str_finalDate,*str_timeF;
    NSArray *arr_date,*arr_day,*arr_time;
    
    arr_day = [date componentsSeparatedByString:@" "];
    str_date = [arr_day objectAtIndex:0];
    str_time = [arr_day objectAtIndex:1];
    
    arr_time = [str_time componentsSeparatedByString:@":"];
    arr_date = [str_date componentsSeparatedByString:@"-"];
    
    int time;
    str_AMorPM = ([[arr_time objectAtIndex:0] integerValue] < 12)?@"AM":@"PM";
    if (([[arr_time objectAtIndex:0] intValue] < 12)) {
        str_AMorPM = @"AM";
        time = [[arr_time objectAtIndex:0] intValue];
    }
    else{
        str_AMorPM = @"PM";
        time = [[arr_time objectAtIndex:0] intValue] -12;
    }
    NSString * strDatee = [self dateFormat:date];

    str_finalDate = [NSString stringWithFormat:@"%@ %d:%@ %@",strDatee,time,[arr_time objectAtIndex:0],str_AMorPM ];
    return str_finalDate;
}

#pragma mark -

-(void)btn_Share_Play_clicked:(UIButton*)sender{
    
    @try{
        
    _view_SharePlay.hidden = NO;
    isSharedAudioPlayed = YES;
    sharedFileIndex=sender.tag;
    UITapGestureRecognizer *tapOn_ShareView = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(tapOnShareView:)];
    [_tbl_view_chat addGestureRecognizer:tapOn_ShareView];
    [Appdelegate showProgressHud];
    long view_sharePlay_Y =self.view.frame.size.height-
    (_vew_msg.frame.size.height+_view_SharePlay.frame.size.height+10);
    [_view_SharePlay setFrame:CGRectMake(0,
                                         view_sharePlay_Y ,
                                         self.view.frame.size.width ,
                                         _view_SharePlay.frame.size.height)];
    
    [self.view bringSubviewToFront:_view_SharePlay];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if (audioPlayer) {
            if(toogleShare) {
                toogleShare = !toogleShare;
                [Appdelegate hideProgressHudInView];
                [audioPlayer play];
                [_btn_play setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
            }
        
        else {
            toogleShare = !toogleShare;
            [Appdelegate hideProgressHudInView];

            [audioPlayer pause];
            [_btn_play setImage:[UIImage imageNamed:@"play_arrow.png"] forState:UIControlStateNormal];
        }
    }
    else{
    isShareWillShow = YES;
    instrument_play_index = sender.tag;

    //---------------* Get AudioSahred Array *-----------------
    arr_AudioSharedM = [NSMutableArray new];
    arr_AudioSharedM = [[arr_messageList objectAtIndex:sender.tag]valueForKey:@"Audioshared"];
    
    //----------------* Set Value on AudioShared View *--------
    //------------- Cover pic -----------------
    NSArray *recordingArray = [[NSArray alloc]init];
    if ([[arr_AudioSharedM objectAtIndex:0]valueForKey:
         @"recordings"] != [NSNull null]) {
       recordingArray  = [[arr_AudioSharedM objectAtIndex:0]valueForKey:
                                   @"recordings"];
    }
        
    _lbl_userName.text = [NSString stringWithFormat:@"@%@",[[arr_AudioSharedM objectAtIndex:0]valueForKey:@"user_name"]];
    _lbl_userFullName.text = [[arr_AudioSharedM objectAtIndex:0]valueForKey:@"name"];
    _lbl_songTitle.text = [[arr_AudioSharedM objectAtIndex:0]valueForKey:@"recording_topic"];
        
     //---------------------- * Image * --------------------------
    _img_profile.layer.cornerRadius = _img_profile.frame.size.width / 2;
    _img_profile.clipsToBounds = YES;
    _img_profile.contentMode = UIViewContentModeScaleAspectFit;
    NSURL *url = [NSURL URLWithString:[[arr_messageList objectAtIndex:0] valueForKey:@"sender_pic"] ];
    [_img_profile sd_setImageWithURL:url
                        placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    for (int iloop = 0; iloop < arr_AudioSharedM.count; iloop++) {
     
        NSString *str_notValue = @"N/A";
        if ([[arr_AudioSharedM objectAtIndex:0]valueForKey:
             @"recordings"] != [NSNull null]) {
         
            _lbl_numberOfSongs.text = [NSString stringWithFormat:@"(%d of %lu)",iloop+1,(unsigned long)recordingArray.count];
            audioUrl = [[recordingArray objectAtIndex:iloop]valueForKey:@"recording_url"];
        }
        else{
            _lbl_songTitle.text = str_notValue;
            _lbl_numberOfSongs.text = str_notValue;
            audioUrl =@"http://52.89.220.199/api/uploads/recordings/123_rec1504716548.mp3";//temporary
        }
        
        //------------------- * Common code *----------------------
     
    [self playShareMethod:instrument_play_index url:audioUrl];

    }
}
});
    }
    @catch (NSException *exception) {
        NSLog(@"exception %@",exception);
    }
    @finally{
        
    }
}


-(void)tapOnShareView:(id)sender{
    _view_SharePlay.hidden = YES;
    [audioPlayer stop];
    audioPlayer = nil;
    isShareWillShow = NO;
    [sliderTimer invalidate];
    isSharedAudioPlayed = NO;

}



-(NSString*)dateFormat:(NSString*)targetDate{

//    NSString *strServerDate =@"2013-06-27 11:51";
    NSDateFormatter *datePickerFormat1 = [[NSDateFormatter alloc] init];
    [datePickerFormat1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]]; // Prevent adjustment to user's local time zone.

    [datePickerFormat1 setDateFormat:@"dd MMM yyyy"];

    NSDateFormatter *datePickerFormat = [[NSDateFormatter alloc] init];
    [datePickerFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]]; // Prevent adjustment to user's local time zone.

    [datePickerFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDateFormatter *datePickerFormat2 = [[NSDateFormatter alloc] init];
    [datePickerFormat2 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]]; // Prevent adjustment to user's local time zone.
    [datePickerFormat2 setDateFormat:@"yyyy-MM-dd"];
    
//    NSDate *currentDate = [NSDate date];
    NSDate *serverDate = [datePickerFormat dateFromString:targetDate];
    NSString *newDateString = [datePickerFormat1 stringFromDate:serverDate];
//    NSDate *serverOriginalDate = [datePickerFormat1 dateFromString:newDateString];
    NSString *comparableDateString = [datePickerFormat2 stringFromDate:serverDate];
    NSDate *comparableDate = [datePickerFormat2 dateFromString:comparableDateString];
    
    NSString *currentDateString = [datePickerFormat2 stringFromDate:[NSDate date]];
    NSDate *currentDate = [datePickerFormat2 dateFromString:currentDateString];

    
    NSLog(@"date %@",currentDate);
    NSLog(@"date %@",serverDate);
    
    NSComparisonResult result;
    NSString *strResult;
    result = [currentDate compare:comparableDate]; // comparing two dates
    
    if(result == NSOrderedAscending){
        NSLog(@"current date is less");
    }
    else if(result == NSOrderedDescending)
    {
        strResult = [NSString stringWithFormat:@"%@",newDateString];
        NSLog(@"server date is less");
    }
    else if(result == NSOrderedSame){
        strResult = @"Today";
    
        NSLog(@"Both dates are same");
    }
    else if(result == NSOrderedSame-1){
        strResult = @"Yesterday";
        
        NSLog(@"dates are Yesterday");
    }
    else{
        strResult = [NSString stringWithFormat:@"%ld",(long)result];
        NSLog(@"Date cannot be compared");
    }
    return strResult;
}

#pragma mark - Play Method

-(void)playShareMethod:(long)index url:(NSString*)url {
    @try{
    
    if (audioPlayer) {
        
        if(audioPlayer  && lastIndex == index && toggle_PlayPause) {
            toggle_PlayPause = !toggle_PlayPause;
            [audioPlayer play];
            [_btn_play setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
        }
        
        else {
            toggle_PlayPause = !toggle_PlayPause;
            [audioPlayer pause];
            [_btn_play setImage:[UIImage imageNamed:@"play_arrow.png"] forState:UIControlStateNormal];
        }
    }
 
    else{
        [Appdelegate showProgressHud];
        dispatch_queue_t myqueue = dispatch_queue_create("queue", NULL);
        dispatch_async(myqueue, ^{
        
            
            
        toggle_PlayPause = !toggle_PlayPause;
            NSString * strurl = url;
            NSString* urlstr = [strurl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
            NSURL *urlforPlay = [NSURL URLWithString:urlstr];
            NSData *data = [NSData dataWithContentsOfURL:urlforPlay];

            dispatch_async(dispatch_get_main_queue(), ^{
            NSError*error=nil;
            audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
            [audioPlayer setDelegate:self];
            [audioPlayer prepareToPlay];
            if ([audioPlayer prepareToPlay] == YES){
                sliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerupdateSlider) userInfo:nil repeats:YES];
                
                // Set the maximum value of the UISlider
                _share_Slider.maximumValue=[audioPlayer duration];
                _share_Slider.value = 0.0;
                // Set the valueChanged target
                [_share_Slider addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];
                [_btn_play setImage:[UIImage imageNamed:@"transparent_pause.png"] forState:UIControlStateNormal];
                        [Appdelegate hideProgressHudInView];
                        [audioPlayer stop];
                        [audioPlayer play];
                }
            else {
                [Appdelegate hideProgressHudInView];

                receivefileTableViewCell *cell1 = [_tbl_view_chat cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastIndex inSection:0]];
//                cell1.slider_progress.value = 0.0;
                [_btn_play setImage:[UIImage imageNamed:@"bar_play.png"] forState:UIControlStateNormal];
//                UIAlertController * alert=   [UIAlertController
//                                              alertControllerWithTitle:@"Alert"
//                                              message:@"Url Not Supported"
//                                              preferredStyle:UIAlertControllerStyleAlert];
//                
//                UIAlertAction* yesButton = [UIAlertAction
//                                            actionWithTitle:@"ok"
//                                            style:UIAlertActionStyleDefault
//                                            handler:^(UIAlertAction * action)
//                                            {
//                                                
//                                            }];
//                
//                [alert addAction:yesButton];
//                [self presentViewController:alert animated:YES completion:nil];
                int errorCode = CFSwapInt16HostToBig ([error code]);
                NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
            }
           });
        });
        lastIndex = index;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at PlaySharedMethod :%@",exception);
    }
    @finally{
        
    }
        
}

-(void)timerupdateSlider{
    // Update the slider about the music time
    
    
    _share_Slider.value = audioPlayer.currentTime;
}


-(void)sliderChanged{
    // Fast skip the music when user scroll the UISlider
    [audioPlayer setCurrentTime:_share_Slider.value];
}


#pragma mark - Audio Player Delegate Method
#pragma mark -

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    @try{
    [_btn_play setImage:[UIImage imageNamed:@"play_arrow.png"] forState:UIControlStateNormal];
    audioPlayer = nil;
            _share_Slider.value = 0.0;
    [sliderTimer invalidate];
    sliderTimer = nil;
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@" player error description %@",error);
}





- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self performSelectorInBackground:@selector(readMSG_atBackground:) withObject:nil];
    index_msg = indexPath.row;
}


#pragma mark - API
#pragma mark -

-(void)readMSG_atBackground:(long)indexPath{
    
    @try{
    if([arr_messageList count] > 0 && [arr_messageList count] > index_msg){
        
        if([[[arr_messageList objectAtIndex:index_msg]valueForKey:@"isread"]
            isEqualToString:@"0"] && arr_messageList.count-1 == index_msg){
            
            NSString *msg_id = [[arr_messageList objectAtIndex:index_msg]valueForKey:@"id"];
            NSString *chat_id = [[arr_messageList objectAtIndex:index_msg]valueForKey:@"chatID"];
            NSString *chat_type = [[arr_messageList objectAtIndex:index_msg]valueForKey:@"Chat_type"];
            NSString *user_id = [[arr_messageList objectAtIndex:index_msg]valueForKey:@"receiverID"];
            [self seenLastMSG:msg_id chatID:chat_id chatType:chat_type userID:user_id];
        }
    }
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
}



-(void)seenLastMSG:(NSString *)msgID chatID:(NSString *)chatID chatType:(NSString *)chatType userID:(NSString *)userID
{
    @try{
    
        NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
        [params setObject:chatID forKey:@"chatID"];
        [params setObject:userID forKey:@"user_id"];
        [params setObject:msgID forKey:@"messageID"];
        [params setObject:chatType forKey:@"chat_type"];//group
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
        NSString* urlString = [NSString stringWithFormat:@"%@Readstatus.php",BaseUrl];
        NSURL* url = [NSURL URLWithString:urlString];
        
        NSURLSession* session =[NSURLSession sharedSession];
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPShouldHandleCookies:NO];
        
        NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            if(error)
            {
                
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
                    NSMutableDictionary*dic_ReadStatus=[[NSMutableDictionary alloc]init];
                    NSLog(@"%@",jsonResponse);
                    if([[jsonResponse objectForKey:@"flag"] isEqualToString:@"success"]) {
                        dic_ReadStatus=[jsonResponse objectForKey:@"response"];
                        NSLog(@"%@",dic_ReadStatus);
                        
                    }
                    else
                    {
                        
                    }
                    
                });
            }
        }];
        [task resume];
    }
    @catch (NSException *exception) {
        NSLog(@"exception at likes.php :%@",exception);
    }
    @finally{
        
    }
        
}



- (void)handleURL:(NSURL*)url
{
    WebViewController *controller = [[WebViewController alloc] initWithURL:url];
    [controller setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)btn_invite:(id)sender{
    contactsViewController *contactVC = [self.storyboard instantiateViewControllerWithIdentifier:@"contactsViewController"];
    [contactVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:contactVC animated:YES completion:nil];
    
}


@end


#pragma mark- Extension
#pragma mark-
@interface NSLayoutConstraint (Description)

@end

@implementation NSLayoutConstraint (Description)

-(NSString *)description {
    return [NSString stringWithFormat:@"id: %@, constant: %f", self.identifier, self.constant];
}

@end

