//
//  HistoryViewController.h
//  MagicOpener
//
//  Created by wenlin on 14-7-25.
//  Copyright (c) 2014年 isaced. All rights reserved.
//
@class MOExpert;

#import <UIKit/UIKit.h>

@interface HistoryViewController : UIViewController

@property (strong,nonatomic) NSArray *dataSource;
@property (strong,nonatomic) PFUser *expert;

@end
