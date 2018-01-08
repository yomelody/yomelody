//
//  Terms_ServiceVC.h
//  melody
//
//  Created by coding Brains on 25/07/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Terms_ServiceVC : UIViewController

- (IBAction)btn_back:(id)sender;
- (IBAction)btn_home:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *webView_TermsCondition;

@end
