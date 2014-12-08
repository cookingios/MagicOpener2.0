//
//  MOHomeViewController.m
//  magicopener
//
//  Created by wenlin on 14/12/9.
//  Copyright (c) 2014年 BRYQ. All rights reserved.
//

#import "MOHomeViewController.h"

@interface MOHomeViewController ()

@end

@implementation MOHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tabBar:(UITabBar *)tabBar didEndCustomizingItems:(NSArray *)items changed:(BOOL)changed{
    
    if (![PFUser currentUser]) {
        return [self performSegueWithIdentifier:@"WelcomeSegue" sender:self];
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
