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
}

//-------------------- IBAction ---------------------
- (IBAction)btn_back:(id)sender;
- (IBAction)btn_home:(id)sender;
- (IBAction)btn_invite:(id)sender;
- (IBAction)btn_DoneAction:(id)sender;
- (IBAction)btn_EditAction:(id)sender;

//-------------------- IBOutlet ---------------------
@property (weak, nonatomic) IBOutlet UIButton *btn_profileImage;
@property (weak, nonatomic) IBOutlet UITextField *tft_GroupName;
@property (weak, nonatomic) IBOutlet UIButton *btn_edit;
//-------------------- Property ---------------------
@property(nonatomic , strong)NSString* str_chat_id;
@property (strong, nonatomic)  NSString *str_GroupImage;
@property (strong, nonatomic)  NSString *str_GroupName;


@end
