//
//  OpenerViewController.m
//  magicopener
//
//  Created by wenlin on 14/12/8.
//  Copyright (c) 2014年 BRYQ. All rights reserved.
//

#import "OpenerViewController.h"

@interface OpenerViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *roundImageView;
@property (weak, nonatomic) IBOutlet UITextView *openerTextView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *starImageView;
@property (strong,nonatomic) PFObject *currentOpener;

- (IBAction)duplicateOpener:(id)sender;

@end

@implementation OpenerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.openerTextView.selectable = NO;
    self.openerTextView.editable = NO;
    self.descriptionTextView.selectable = NO;
    self.descriptionTextView.editable = NO;
    self.roundImageView.layer.masksToBounds = YES;
    self.roundImageView.layer.cornerRadius = self.roundImageView.layer.bounds.size.width/2.0;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rotateOpenerImageView:)];
    [self.roundImageView addGestureRecognizer:tap];
    
    //self.navigationItem.leftBarButtonItem.tintColor = [UIColor lightGrayColor];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Opener"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    query.maxCacheAge = 60 * 60 * 24;
    //[query whereKey:@"available" equalTo:[NSNumber numberWithBool:YES]];
    [query whereKey:@"scene" equalTo:@"sns"];
    [query whereKey:@"rate" lessThan:@5];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %ld openers.", (long)objects.count);
        } else {
            NSLog(@"failed because %@ ", error);
        }
    }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)rotateOpenerImageView:(id)sender{
    
    POPSpringAnimation *basicAnimation = [POPSpringAnimation animation];
    basicAnimation.property = [POPAnimatableProperty propertyWithName: kPOPLayerRotation];
    basicAnimation.velocity=@(300);       // change of value units per second
    basicAnimation.springBounciness= 1;    // value between 0-20 default at 4
    basicAnimation.springSpeed= 0.2;     // value between 0-20 default at 4
    
    basicAnimation.toValue= @(4*M_PI); //2 M_PI is an entire rotation
    
    basicAnimation.name=@"RotateOpener";
    basicAnimation.delegate= self;
    
    [self.roundImageView.layer pop_addAnimation:basicAnimation forKey:@"Rotate"];
}

- (IBAction)duplicateOpener:(id)sender {
    //复制到黏贴板
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.openerTextView.text;
    
    [MOHelper showSuccessMessage:@"复制好了,赶紧去微信/陌陌试试吧" inViewController:self];
    
    NSDictionary *dict = @{@"opener":pasteboard.string,@"type":@"classic"};
    //[MobClick event:@"DuplicateOpener" attributes:dict];
}
- (IBAction)backToolsHomePage:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - pop delegate
- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished;{
    NSLog(@"stop");
    //统计
    NSDictionary *dict = @{@"type":@"classic"};
    //[MobClick event:@"GetOpener" attributes:dict];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Opener"];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 60 * 60 * 48 ;
    [query whereKey:@"available" equalTo:[NSNumber numberWithBool:YES]];
    [query whereKey:@"scene" equalTo:@"sns"];
    [query whereKey:@"rate" lessThan:@5];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count>0) {
                int x = arc4random() % (objects.count-1);
                _currentOpener = [objects objectAtIndex:x];
                NSString *opener=[_currentOpener objectForKey:@"opener"];
                self.openerTextView.text=[NSString stringWithFormat:@"%@",opener] ;
                self.descriptionTextView.text=[_currentOpener objectForKey:@"description"];
                [self showStar:[_currentOpener objectForKey:@"rate"]];
            }
        } else {
            [MOHelper showErrorMessage:@"获取数据失败,请检查网络设置" inViewController:self];
        }
    }];

}

-(void)showStar:(NSNumber *)starCounts{
    if (starCounts) {
        switch ([starCounts intValue]) {
            case 1:
                _starImageView.image =[UIImage imageNamed:@"1star"];
                break;
            case 2:
                _starImageView.image =[UIImage imageNamed:@"2star"];
                break;
            case 3:
                _starImageView.image =[UIImage imageNamed:@"3star"];
                break;
            case 4:
                _starImageView.image =[UIImage imageNamed:@"4star"];
                break;
            case 5:
                _starImageView.image =[UIImage imageNamed:@"5star"];
                break;
                
            default:
                break;
        }
    }else{
        _starImageView.image =[UIImage imageNamed:@"0star"];
    }
}


@end
