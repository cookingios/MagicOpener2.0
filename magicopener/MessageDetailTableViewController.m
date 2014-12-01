//
//  MessageDetailTableViewController.m
//  MagicOpener
//
//  Created by wenlin on 14-5-29.
//  Copyright (c) 2014年 isaced. All rights reserved.
//

#import "MessageDetailTableViewController.h"
#import <UIImageView+WebCache.h>

@interface MessageDetailTableViewController ()

@property (weak, nonatomic) IBOutlet UIView *evaluateView;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *questionImageView;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet UILabel *helperLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (strong,nonatomic) NSNumber *score;


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
    self.questionLabel.text = [NSString stringWithFormat:@"\"%@\"", [self.message objectForKey:@"problem"]];
    self.answerLabel.text = [NSString stringWithFormat:@"\"%@\"", [self.message objectForKey:@"reply"]];
    self.helperLabel.text = [NSString stringWithFormat:@"by %@", [[self.message objectForKey:@"expert"] objectForKey:@"displayName"]];
    [self.questionImageView sd_setImageWithURL:[NSURL URLWithString:[(PFFile *)[self.message objectForKey:@"screenshot"] url]]];
    
    if ([[self.message allKeys] containsObject:@"star"]) {
        self.evaluateView.superview.superview.hidden = YES;
    }
    
    self.submitButton.layer.masksToBounds = YES;
    self.submitButton.layer.cornerRadius = 6.0f;
    self.submitButton.layer.borderWidth = 1.0f;
    self.submitButton.layer.borderColor = [[UIColor grayColor] CGColor];
    
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
    /*
    float number = [self.score floatValue];
    if (number>0.1) {
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
        [self.hud show:YES];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(handleHudTimeout) userInfo:nil repeats:NO];

        [self.message setObject:self.score forKey:@"star"];
        [self.message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [timer invalidate];
                _hud.mode = MBProgressHUDModeText;
                _hud.labelText = @"成功提交";
                [_hud hide:YES afterDelay:2];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分数不能为0哦" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
     */
}
@end
