//
//  MessageDetailTableViewController.m
//  MagicOpener
//
//  Created by wenlin on 14-5-29.
//  Copyright (c) 2014年 isaced. All rights reserved.
//

#import "MessageDetailTableViewController.h"
#import <UIImageView+WebCache.h>
#import <BlocksKit+UIKit.h>
#import <RateView.h>
#import "EXPhotoViewer.h"


@interface MessageDetailTableViewController ()<RateViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *evaluateView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *questionImageView;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet UILabel *helperLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIView *rateBackgroundView;
@property (strong, nonatomic) RateView *rateView;

- (IBAction)submitEvaluation:(id)sender;

@end

@implementation MessageDetailTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //QA部分
    self.questionLabel.text = [NSString stringWithFormat:@"\"%@\"", [self.message objectForKey:@"problem"]];
    self.answerLabel.text = [NSString stringWithFormat:@"\"%@\"", [self.message objectForKey:@"reply"]];
    self.helperLabel.text = [NSString stringWithFormat:@"by %@", [[self.message objectForKey:@"expert"] objectForKey:@"displayName"]];
    
    //图片缩放
    if ([self.message objectForKey:@"screenshot"]) {
        [self.questionImageView sd_setImageWithURL:[NSURL URLWithString:[(PFFile *)[self.message objectForKey:@"screenshot"] url]]];
        UITapGestureRecognizer *tap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            [EXPhotoViewer showImageFrom:self.questionImageView];
        }];
        [self.questionImageView addGestureRecognizer:tap];
    }
    //评价部分
    if ([[self.message allKeys] containsObject:@"star"]) {
        self.evaluateView.superview.hidden = YES;
    }else{
        //ratingview
        self.rateView = [RateView rateViewWithRating:3.0f];
        self.rateView.frame = CGRectMake(0, 0, 150, 30);
        self.rateView.starSize = 30;
        self.rateView.canRate = YES;
        self.rateView.delegate = self;
        self.rateView.starNormalColor = [UIColor colorWithRed:255/255.0f green:255/255.0f
                                                  blue:255/255.0 alpha:1.0];
        self.rateView.starFillColor = [UIColor colorWithRed:255/255.0f green:209/255.0f
                                                blue:23/255.0 alpha:1.0];
        self.rateView.starBorderColor = [UIColor colorWithRed:38/255.0f green:38/255.0f
                                                  blue:38/255.0 alpha:1.0];
        [self.rateBackgroundView addSubview:self.rateView];
        
        //提交按钮
        self.submitButton.layer.masksToBounds = YES;
        self.submitButton.layer.cornerRadius = 6.0f;
        self.submitButton.layer.borderWidth = 1.0f;
        self.submitButton.layer.borderColor = [[UIColor grayColor] CGColor];
    }
    
    
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    //[MobClick beginLogPageView:@"MessageDetail"];

}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    //[MobClick endLogPageView:@"MessageDetail"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitEvaluation:(id)sender {
    
    float number = self.rateView.rating;
    if (number>0.1) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [self performBlock:^{
            if (!hud.hidden) {
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"网络连接出现问题";
                [hud hide:YES afterDelay:2];
            }
        } afterDelay:15];

        [self.message setObject:[NSNumber numberWithFloat:number] forKey:@"star"];
        [self.message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [hud hide:YES];
            if (succeeded) {
                [MOHelper showSuccessMessage:@"提交成功" inViewController:self];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
        
    }else{
        [MOHelper showErrorMessage:@"分数不能为0哦" inViewController:self];
    }
}

#pragma mark - rateview delegate
-(void)rateView:(RateView*)rateView didUpdateRating:(float)rating
{
    NSLog(@"rateViewDidUpdateRating: %.1f", rating);
}
@end
