//
//  OpenerCarouselViewController.m
//  magicopener
//
//  Created by wenlin on 14/12/6.
//  Copyright (c) 2014年 BRYQ. All rights reserved.
//

#import "OpenerCarouselViewController.h"

@interface OpenerCarouselViewController ()

@end

@implementation OpenerCarouselViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.openerTextView.text = self.opener[@"opener"];
    self.descriptionTextView.text = self.opener[@"description"];
    self.openerTextView.editable = NO;
    self.openerTextView.selectable = NO;
    self.descriptionTextView.editable = NO;
    self.descriptionTextView.selectable = NO;
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
