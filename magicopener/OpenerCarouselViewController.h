//
//  OpenerCarouselViewController.h
//  magicopener
//
//  Created by wenlin on 14/12/6.
//  Copyright (c) 2014年 BRYQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenerCarouselViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *openerTextView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;


@property (strong,nonatomic) PFObject *opener;

@end
