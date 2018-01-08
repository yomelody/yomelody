//
//  MenuViewController.m
//  melody
//
//  Created by coding Brains on 23/02/17.
//  Copyright © 2017 CodingBrainsMini. All rights reserved.
//

#import "MenuViewController.h"
#import "menuCollectionViewCell.h"
@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AUGraph outGraph;
    OSStatus result = noErr;
    result = NewAUGraph ( &outGraph );
    if(result != noErr) {
        // handle it
    }
    
    
    
    // Do any additional setup after loading the view.
   // arr_menu_items=[[NSMutableArray alloc]initWithObjects:@"All",@"Hip Hop",@"Pop",@"Abc",@"Jhd",@"HSJ",@"YGUU",nil];
    arr_tab_select=[[NSMutableArray alloc]init];
    int i;
    for (i=0; i<[arr_menu_items count]; i++) {
        [arr_tab_select insertObject:@"0" atIndex:i];
    }
    _cv_menu.showsHorizontalScrollIndicator=NO;
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   NSString* library = [path objectAtIndex:0];
    arr_menu_items=[[NSMutableArray alloc]init];
    NSMutableArray*arr_menu_paths=[[NSMutableArray alloc]init];
    arr_menu_paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:library error:nil];
    NSLog(@"fileArray...%@",arr_menu_paths);
    
    
    
    for(int i = 0;i<arr_menu_paths.count;i++)
    {
        id arrayElement = [arr_menu_paths  objectAtIndex:i];
        if ([arrayElement rangeOfString:@".jpg"].location !=NSNotFound)
        {
            
            [arr_menu_items addObject:arrayElement];
           // arrayToLoad = [[NSMutableArray alloc]initWithArray:imagelist copyItems:TRUE];
        }
    }
    
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//    //return CGSizeMake( self.view.frame.size.width /12, 70);
//    return CGSizeMake(72,79);
//}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [arr_menu_items count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
   menuCollectionViewCell *cell = (menuCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

//     cell.lbl_menu_title.text=[arr_menu_items objectAtIndex:indexPath.row];
//  
//        if ([[arr_tab_select objectAtIndex:indexPath.item] isEqual:@"1"]) {
//            cell.img_menu.image = [UIImage imageNamed:@"underline.png"];
//        }
//        else
//        {
//            cell.img_menu.image = [UIImage imageNamed:@"white.png"];
//            
//        }
   
    cell.img_menu.image = [UIImage imageWithContentsOfFile:[arr_menu_items objectAtIndex:indexPath.item]];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //    NSInteger viewWidth = self.view.frame.size.width;
    //    NSInteger totalCellWidth = 67 * _numberOfCells;
    //    NSInteger totalSpacingWidth = 2 * (_numberOfCells -1);
    //
    //    NSInteger leftInset = (viewWidth - (totalCellWidth + totalSpacingWidth)) / 2;
    //    NSInteger rightInset = leftInset;
    //
    //    return UIEdgeInsetsMake(0, leftInset, 0, rightInset);
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
     int i;
     for (i=0; i<[arr_tab_select count]; i++)
     {
         if (i==indexPath.item) {
              [arr_tab_select replaceObjectAtIndex:i withObject:@"1"];
         }
         else
         {
          [arr_tab_select replaceObjectAtIndex:i withObject:@"0"];
         }
        
    
     }
    [_cv_menu reloadData];
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
