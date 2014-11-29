//
//  HistoryViewController.m
//  MagicOpener
//
//  Created by wenlin on 14-7-25.
//  Copyright (c) 2014年 isaced. All rights reserved.
//

#import "HistoryViewController.h"
#import "MessageView.h"

@interface HistoryViewController ()

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

- (IBAction)AskQuestion:(id)sender;

@end

@implementation HistoryViewController

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
    self.pageControl.numberOfPages = [self.dataSource count];
    [self.expert[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            self.avatarImageView.image = [UIImage imageWithData:data];
        }
    }];
    self.descriptionLabel.text = [NSString stringWithFormat:@"%@的往期精选问答",self.expert[@"displayName"]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[MobClick beginLogPageView:@"EditorsPicks"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[MobClick endLogPageView:@"EditorsPicks"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)AskQuestion:(id)sender {
    
    [self performSegueWithIdentifier:@"SelectQuestionTypeSegue" sender:self];
    
}

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     id dvc = segue.destinationViewController;
     if ([segue.identifier isEqualToString:@"SelectQuestionTypeSegue"]) {
         [dvc setValue:self.expert forKey:@"toUser"];
     }else if ([segue.identifier isEqualToString:@"QAPageViewControllerSegue"]){
         [dvc setValue:self.dataSource forKey:@"messages"];
     }
     
 }


@end
