//
//  MOExpert.h
//  MagicOpener
//
//  Created by wenlin on 14-7-25.
//  Copyright (c) 2014年 isaced. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOExpert : NSObject

@property(strong,nonatomic) NSString *userId;
@property(strong,nonatomic) NSString *name;
@property(strong,nonatomic) UIImage *avatarImage;
@property(strong,nonatomic) NSString *remark;

-(instancetype)initWithUserId:(NSString*) idnum name:(NSString*)name avatar:(UIImage*) avatarImage description:(NSString*) description;

@end
