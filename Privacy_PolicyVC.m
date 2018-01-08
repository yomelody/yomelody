//
//  Privacy_PolicyVC.m
//  melody
//
//  Created by coding Brains on 25/07/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import "Privacy_PolicyVC.h"
#import "Constant.h"
@interface Privacy_PolicyVC ()

@end

@implementation Privacy_PolicyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //------------------------ * Web View * -------------------------
    [self loadWebView];
    
    //---------------------------------------------------------------
}

-(void)loadWebView{
    NSString *urlString = PRIVACY_POLICY_URL;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView_PrivacyPolicy loadRequest:urlRequest];
     [self.view addSubview:self.webView_PrivacyPolicy];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btn_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
@end
