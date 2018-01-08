//
//  MenuViewController.h
//  melody
//
//  Created by coding Brains on 23/02/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
@interface MenuViewController : UIViewController
{
    NSMutableArray*arr_menu_items;
    NSMutableArray*arr_tab_select;
}
@property (weak, nonatomic) IBOutlet UICollectionView *cv_menu;


@end
