//
//  OpenerPageViewController.m
//  magicopener
//
//  Created by wenlin on 14/12/6.
//  Copyright (c) 2014年 BRYQ. All rights reserved.
//

#import "OpenerPageViewController.h"
#import "OpenerCarouselViewController.h"

@interface OpenerPageViewController ()<UIPageViewControllerDataSource>

@property (strong,nonatomic) UIPageControl *pageControl;

@end

@implementation OpenerPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    OpenerCarouselViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OpenerCarouselViewController"];
    viewController.opener = self.openers[0];
    
    [self setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - pageview datasource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    OpenerCarouselViewController *oldVC = (OpenerCarouselViewController *)viewController;
    
    NSUInteger newIndex = [self.openers indexOfObject:oldVC.opener] +1;
    if (newIndex > self.openers.count - 1) return nil;
    
    OpenerCarouselViewController *newVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OpenerCarouselViewController"];
    newVC.opener = self.openers[newIndex];
    return newVC;
    
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    OpenerCarouselViewController *oldVC = (OpenerCarouselViewController *)viewController;
    NSInteger newIndex = [self.openers indexOfObject:oldVC.opener]- 1;
    if (newIndex < 0) return nil;
    
    OpenerCarouselViewController *newVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OpenerCarouselViewController"];
    newVC.opener = self.openers[newIndex];
    return newVC;
}

@end
