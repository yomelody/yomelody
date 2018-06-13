//
//  LaunchViewController.m
//  melody
//
//  Created by coding Brains on 22/02/18.
//  Copyright © 2018 CodingBrainsMini. All rights reserved.
//

#import "LaunchViewController.h"
#import "ViewController.h"
@interface LaunchViewController ()

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden=YES;
    UIImage *image1 = [UIImage imageNamed:@"i-1.tif"];
    UIImage *image2 = [UIImage imageNamed:@"i-2.tif"];
    UIImage *image3 = [UIImage imageNamed:@"i-3.tif"];
    UIImage *image4 = [UIImage imageNamed:@"i-4.tif"];
    UIImage *image5 = [UIImage imageNamed:@"i-5.tif"];
    UIImage *image6 = [UIImage imageNamed:@"i-6.tif"];
    UIImage *image7 = [UIImage imageNamed:@"i-7.tif"];
    UIImage *image8 = [UIImage imageNamed:@"i-8.tif"];
    UIImage *image9 = [UIImage imageNamed:@"i-9.tif"];
    UIImage *image10 = [UIImage imageNamed:@"i-10.tif"];
    UIImage *image11 = [UIImage imageNamed:@"i-11.tif"];
    UIImage *image12 = [UIImage imageNamed:@"i-12.tif"];
    
    self.loaderImageView.animationImages = [[NSArray alloc] initWithObjects:image1,image2,image3,image4,image5,image6,image7,image8,image9,image10,image11,image12, nil];
    self.loaderImageView.animationRepeatCount = 0;
    self.loaderImageView.animationDuration = 1;
    [self.loaderImageView startAnimating];
    [self performSelector:@selector(methodForLaunchImage) withObject:nil afterDelay:3.0];
    // Do any additional setup after loading the view.
}


-(void)methodForLaunchImage
{
    [self performSegueWithIdentifier:@"Launch" sender:self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Launch"])
    {
//        ViewController*vc=segue.destinationViewController;//old Code
        ViewController *vc= [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        [self presentViewController:vc animated:YES completion:nil];
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
