//
//  ExpertMessageDetailTableViewController.m
//  MagicOpener
//
//  Created by wenlin on 14-6-6.
//  Copyright (c) 2014年 isaced. All rights reserved.
//

#import "ExpertMessageDetailTableViewController.h"
#import <UIImageView+WebCache.h>


@interface ExpertMessageDetailTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *questionImageView;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;


- (IBAction)submitAnswer:(id)sender;

@end

@implementation ExpertMessageDetailTableViewController

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
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    self.questionLabel.text = [NSString stringWithFormat:@"\"%@\"", [self.message objectForKey:@"problem"]];
    self.inputTextView.text = [self.message objectForKey:@"reply"];
    [self.questionImageView sd_setImageWithURL:[NSURL URLWithString:[(PFFile *)[self.message objectForKey:@"screenshot"] url]]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
    pStyle.lineSpacing = 3;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17.0f],NSParagraphStyleAttributeName:pStyle};
    //Question cell 高度
    CGRect rect2 = [self.questionLabel.text boundingRectWithSize:CGSizeMake(165, MAXFLOAT)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:attributes
                                                         context:nil];

    NSUInteger index = indexPath.row;
    switch (index) {
        case 0:
            // Get the string of text from each comment
            if (rect2.size.height<138) {
                return 152;
            }else{
                return 14 + rect2.size.height;
            }
            break;
        case 1:
            // Get the string of text from each comment
            return 152;
            break;
        case 2:
            return 64.0f;
            break;
            
            
        default:
            return 64.0f;
            break;
    }
    
    
}

- (IBAction)submitAnswer:(id)sender {
    
    NSString *trimInputString = [MOHelper trimString:self.inputTextView.text];
    
    if ([trimInputString isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"内容不能为空" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        
        return [alert show];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否确定提交以下内容做为回复?" message:self.inputTextView.text delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    [alert show];
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        
        [self.message setValue:self.inputTextView.text forKey:@"reply"];
        [self.message setValue:[NSNumber numberWithBool:YES] forKey:@"isReplyed"];
        [self.message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                //推送
                //if (![[self.toUser objectId]isEqualToString:[[PFUser currentUser] objectId]]) {
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"owner" equalTo:[self.message objectForKey:@"fromUser"]]; // Set notification toUser
                //Create Options
                NSString *expertName = [NSString stringWithFormat:@"收到%@的回复信息",[[self.message objectForKey:@"expert"] objectForKey:@"displayName"]];
                NSDictionary *data = @{
                                       @"alert":expertName,
                                       @"eventId":self.message.objectId,
                                       @"badge":@"Increment",
                                       @"sound":@"Voidcemail.caf"
                                       };
                // Send push notification to query
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery];
                [push setData:data];
                [push sendPushInBackground];
                //}
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else{
                [MOHelper showErrorMessage:@"网络连接问题,稍后再试" inViewController:self];
            }

        }];
        
    }
}
@end
