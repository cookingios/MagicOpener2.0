//
//  HistoryViewController.m
//  MagicOpener
//
//  Created by wenlin on 14-7-25.
//  Copyright (c) 2014年 isaced. All rights reserved.
//

#import "HistoryViewController.h"
#import "QAPageViewController.h"
#import "QADetailViewController.h"

@interface HistoryViewController ()<UIPageViewControllerDelegate>

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
    
    [self.expert[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            self.avatarImageView.image = [UIImage imageWithData:data];
        }
    }];
    self.descriptionLabel.text = [NSString stringWithFormat:@"%@的往期精选问答",self.expert[@"displayName"]];
    
    self.pageControl.numberOfPages = [self.dataSource count];
    self.pageControl.currentPage = 0;
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

#pragma mark - uipageview delegate
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    QADetailViewController *vc = (QADetailViewController *)pageViewController.viewControllers[0];
    NSInteger index = [self.dataSource indexOfObject:vc.message];
    return index;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    NSInteger index = [self presentationIndexForPageViewController:pageViewController];
    self.pageControl.currentPage = index;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     id dvc = segue.destinationViewController;
     if ([segue.identifier isEqualToString:@"SelectQuestionTypeSegue"]) {
         [dvc setValue:self.expert forKey:@"toUser"];
     }else if ([segue.identifier isEqualToString:@"QAPageViewControllerSegue"]){
         [dvc setValue:self.dataSource forKey:@"messages"];
         QAPageViewController* vc = (QAPageViewController*)dvc;
         vc.delegate = self;
     }
     
 }


@end
