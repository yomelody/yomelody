//
//  Terms_ServiceVC.m
//  melody
//
//  Created by coding Brains on 25/07/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import "Terms_ServiceVC.h"
#import "Constant.h"

@interface Terms_ServiceVC ()

@end

@implementation Terms_ServiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadWebView];
    // Do any additional setup after loading the view.
}


-(void)loadWebView{
    NSString *urlString = TERMS_SERVICE_URL;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView_TermsCondition loadRequest:urlRequest];
    [self.view addSubview:self.webView_TermsCondition];
    
}




- (IBAction)btn_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btn_home:(id)sender {
//    UIViewController *vc = self.presentingViewController;
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
