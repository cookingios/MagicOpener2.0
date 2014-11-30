//
//  WelcomeViewController.m
//  RACDemo
//
//  Created by wenlin on 14-1-22.
//  Copyright (c) 2014年 bryq. All rights reserved.
//

#import "WelcomeViewController.h"


@interface WelcomeViewController ()

- (IBAction)signup:(id)sender;
- (IBAction)login:(id)sender;

@end

@implementation WelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    //[MobClick beginLogPageView:@"Welcome"];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    //[MobClick endLogPageView:@"Welcome"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signup:(id)sender {
    [self performSegueWithIdentifier:@"SignUpSegue" sender:self];
}

- (IBAction)login:(id)sender {
    [self performSegueWithIdentifier:@"LoginSegue" sender:self];
}

@end
