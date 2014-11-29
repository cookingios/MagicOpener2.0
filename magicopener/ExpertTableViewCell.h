//
//  ExpertTableViewCell.h
//  magicopener
//
//  Created by wenlin on 14/11/28.
//  Copyright (c) 2014年 BRYQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpertTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *editorsPickedButton;

@end
