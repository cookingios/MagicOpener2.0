//
//  SelectMyExpertViewController.m
//  MagicOpener
//
//  Created by wenlin on 14-3-15.
//  Copyright (c) 2014年 isaced. All rights reserved.
//

#import "SelectMyExpertViewController.h"
#import "ExpertTableViewCell.h"
#import "MOExpert.h"

@interface SelectMyExpertViewController ()

@property (strong,nonatomic) NSMutableArray * experts;
@property (strong,nonatomic) PFUser *currentExpert;
@property (strong,nonatomic) MBProgressHUD *hud;
@property (strong,nonatomic) NSArray * editorsPicks;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)reviewEditorPicks:(id)sender;

@end

@implementation SelectMyExpertViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //获取专家列表
    [[self getExperts] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.experts = [objects mutableCopy];
            [self.tableView reloadData];
        }else{
            [TSMessage showNotificationWithTitle:@"网络连接错误"
                                        subtitle:@"请稍后再试"
                                            type:TSMessageNotificationTypeError];
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    //[MobClick beginLogPageView:@"Helper"];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    //[MobClick endLogPageView:@"Helper"];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - prepareData
-(PFQuery*)getExperts{
    PFQuery *query = [PFUser query];
    
    [query whereKey:@"isExpert" equalTo:[NSNumber numberWithBool:YES]];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query orderByAscending:@"createdAt"];
    return query;
}



#pragma mark - interaction
- (IBAction)reviewEditorPicks:(id)sender {

    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    [self.hud show:YES];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:self selector:@selector(handleHudTimeout) userInfo:nil repeats:NO];
    
    //获取当前expert
    UITableViewCell * cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    self.currentExpert = self.experts[indexPath.row];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"expert" equalTo:self.currentExpert];
    [query whereKey:@"isEditorsPicked" equalTo:[NSNumber numberWithBool:YES]];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.limit = 5;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [timer invalidate];
            [self.hud removeFromSuperview];
            self.editorsPicks = [NSArray arrayWithArray:objects];
            [self performSegueWithIdentifier:@"EditorsPicksSegue" sender:self];
        }
    }];
    
}

#pragma mark - tableview datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.experts.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ExpertTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExpertTableViewCell" forIndexPath:indexPath];
    
    PFObject *object = self.experts[indexPath.row];
    [object[@"avatar"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            cell.avatarImageView.image = [UIImage imageWithData:data];
        }
    }];
    cell.nameLabel.text = object[@"displayName"];
    cell.descriptionLabel.text = object[@"expertDescription"];
    
    return cell;
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.currentExpert = self.experts[indexPath.row];
    [self performSegueWithIdentifier:@"SelectQuestionTypeSegue" sender:self];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id dvc = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"SelectQuestionTypeSegue"]) {
        [dvc setValue:self.currentExpert forKey:@"toUser"];
        
    } else if ([segue.identifier isEqualToString:@"EditorsPicksSegue"]){
        [dvc setValue:self.currentExpert forKey:@"expert"];
        [dvc setValue:self.editorsPicks forKey:@"dataSource"];
    }
}

- (void)handleHudTimeout{
    
    self.hud.mode = MBProgressHUDModeText;
	self.hud.labelText = @"网络连接有问题";
    [self.hud hide:YES afterDelay:3];
}

@end
