//
//  QAPageViewController.m
//  magicopener
//
//  Created by wenlin on 14/11/29.
//  Copyright (c) 2014年 BRYQ. All rights reserved.
//

#import "QAPageViewController.h"
#import "QADetailViewController.h"

@interface QAPageViewController ()<UIPageViewControllerDataSource>

@end

@implementation QAPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    QADetailViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"QADetailViewController"];
    viewController.message = self.messages[0];
    
    [self setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.dataSource = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - pageview datasource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    QADetailViewController *oldVC = (QADetailViewController *)viewController;
    
    NSUInteger newIndex = [self.messages indexOfObject:oldVC.message] +1;
    if (newIndex > self.messages.count - 1) return nil;
    
    QADetailViewController *newVC = [self.storyboard instantiateViewControllerWithIdentifier:@"QADetailViewController"];
    newVC.message = self.messages[newIndex];
    return newVC;
    
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    QADetailViewController *oldVC = (QADetailViewController *)viewController;
    NSInteger newIndex = [self.messages indexOfObject:oldVC.message]- 1;
    if (newIndex < 0) return nil;
    
    QADetailViewController *newVC = [self.storyboard instantiateViewControllerWithIdentifier:@"QADetailViewController"];
    newVC.message = self.messages[newIndex];
    return newVC;
}

@end
