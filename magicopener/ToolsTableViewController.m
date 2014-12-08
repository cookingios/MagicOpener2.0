//
//  ToolsTableViewController.m
//  magicopener
//
//  Created by wenlin on 14/12/8.
//  Copyright (c) 2014年 BRYQ. All rights reserved.
//

#import "ToolsTableViewController.h"

@interface ToolsTableViewController ()<UIActionSheetDelegate>

- (IBAction)showSettings:(id)sender;

@end

@implementation ToolsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showSettings:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"设置" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"我想要新功能",@"退出登录", nil];
    
    sheet.destructiveButtonIndex = 1;
    
    [sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            NSLog(@"0");
            break;
        case 1:
            [PFUser logOut];
            [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"] animated:NO completion:nil];
            break;
            
        default:
            break;
    }
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
