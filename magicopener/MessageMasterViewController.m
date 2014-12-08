//
//  MessageMasterViewController.m
//  moon
//
//  Created by wenlin on 13-9-17.
//  Copyright (c) 2013年 wenlin. All rights reserved.
//

#import "MessageMasterViewController.h"
#import "ExpertMessageTableViewCell.h"
#import "MessageCell.h"



@interface MessageMasterViewController ()

@property (nonatomic) NSNumber * queryStatus;
@property (nonatomic) PFObject * selectedMessage;

@end

@implementation MessageMasterViewController

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Custom initialization
        self.parseClassName = @"Message";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 15;
        self.loadingViewEnabled = YES;
        self.queryStatus = @0;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    //[MobClick beginLogPageView:@"MessageList"];
    
    [self loadObjects];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    //[MobClick endLogPageView:@"MessageList"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (PFQuery *)queryForTable {
    if ([PFUser currentUser]) {
        if (![[PFUser currentUser] objectForKey:@"isExpert"]) {
            //一般用户
            PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
            [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
            [query includeKey:@"expert"];
            [query whereKey:@"isReplyed" equalTo:[NSNumber numberWithBool:YES]];
            [query orderByDescending:@"createdAt"];
            query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            query.maxCacheAge = 60;
        
            return query;
        }else{
            //expert
            PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
            [query whereKey:@"expert" equalTo:[PFUser currentUser]];
            [query includeKey:@"fromUser"];
            [query includeKey:@"expert"];
            [query orderByAscending:@"isReplyed"];
            [query addDescendingOrder:@"createdAt"];
            query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            query.maxCacheAge = 60;
            
            return query;
        }
    }else return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
    PFUser *user = [PFUser currentUser];
    BOOL isExpert = [[user objectForKey:@"isExpert"] boolValue];
    //如果当前用户为普通用户
    if (!isExpert) {
        static NSString *cellIdentifier = @"UserMessageCell";
        MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        }
        
        // Configure the cell to show todo item with a priority at the bottom
        PFFile *thumbFile;
        NSString *expert = [[object objectForKey:@"expert"] objectForKey:@"displayName"];
        cell.nameLabel.text = expert;
        thumbFile = [[object objectForKey:@"expert"] objectForKey:@"thumbnail"];
        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[thumbFile url]] placeholderImage:nil];
        cell.createAtLabel.text = [MOHelper stringFromDate:[object createdAt]];
        NSString *content = [object objectForKey:@"reply"];
        cell.contentLabel.text = [NSString stringWithFormat:@"回复了你:%@",content];
        
        return cell;
    //如果当前用户为专家用户
    } else {
        static NSString *cellIdentifier = @"ExpertMessageCell";
        ExpertMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[ExpertMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        }
        NSString *fromUserName = [[object objectForKey:@"fromUser"] objectForKey:@"username"];
        if ([[object objectForKey:@"isReplyed"] isEqualToNumber:@1]) {
            cell.nameLabel.text = [NSString stringWithFormat:@"已回复:%@",fromUserName];
        }else{
            cell.nameLabel.text = [NSString stringWithFormat:@"未回复:%@",fromUserName];
        }
        cell.contentLabel.text = [object objectForKey:@"problem"];
        if ([cell.contentLabel.text isEqualToString:@""] || (!cell.contentLabel.text) ) {
            cell.contentLabel.text = @"[图片]";
        }
        cell.createdAtLabel.text = [MOHelper stringFromDate:[object createdAt]];
        
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if ( [self.objects count]>indexPath.row || (![self.objects count]==indexPath.row )) {
        
         self.selectedMessage = self.objects[indexPath.row];
        if (![[PFUser currentUser] objectForKey:@"isExpert"]) {
            
            [self.selectedMessage setObject:[NSNumber numberWithBool:YES] forKey:@"isRead"];
            [self.selectedMessage saveInBackground];
            [self performSegueWithIdentifier:@"UserMessageEventDetailView" sender:self];

        }else{
            [self performSegueWithIdentifier:@"ExpertMessageEventDetailView" sender:self];
        }
    }
}

#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    id dvc = [segue destinationViewController];

    [dvc setValue:self.selectedMessage forKey:@"message"];

}




@end
