//
//  ExpertMessageDetailTableViewController.h
//  MagicOpener
//
//  Created by wenlin on 14-6-6.
//  Copyright (c) 2014年 isaced. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpertMessageDetailTableViewController : UITableViewController<UITableViewDelegate>


@property (nonatomic,strong) PFObject *message;

@end
