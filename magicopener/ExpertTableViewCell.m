//
//  ExpertTableViewCell.m
//  magicopener
//
//  Created by wenlin on 14/11/28.
//  Copyright (c) 2014年 BRYQ. All rights reserved.
//

#import "ExpertTableViewCell.h"

@implementation ExpertTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)drawRect:(CGRect)rect{
    
    self.editorsPickedButton.layer.borderWidth = 1.0f;
    self.editorsPickedButton.layer.borderColor = [[UIColor grayColor] CGColor];
}
@end
