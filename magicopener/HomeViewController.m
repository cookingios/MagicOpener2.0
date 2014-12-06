//
//  HomeViewController.m
//  MagicOpener
//
//  Created by wenlin on 14-2-22.
//  Copyright (c) 2014年 isaced. All rights reserved.
//

#import "HomeViewController.h"
#import <MBProgressHUD.h>
#import <UIImageView+UIImageView_FaceAwareFill.h>
#import "FaceppAPI.h"
#import "OpenerPageViewController.h"
#import "OpenerCarouselViewController.h"

@interface HomeViewController ()<UIPageViewControllerDelegate>{
    MBProgressHUD *hud;
}

@property (strong,nonatomic) NSArray *dataSource;
@property (strong,nonatomic) NSNumber *life;

@property (weak, nonatomic) IBOutlet UIButton *duplicateButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *starImageView;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UILabel *starDecorateLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;

- (IBAction)duplicateOpener:(id)sender;


@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectImage)];
    [self.avatarImageView addGestureRecognizer:tap];
    //[self getOpeners];
    
    self.duplicateButton.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    //[MobClick beginLogPageView:@"Opener"];
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSLog(@"life remain %@",[[PFUser currentUser] objectForKey:@"freeChance"]);
    }];
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.size.width/2.0;
    self.avatarImageView.layer.masksToBounds = YES;
    self.duplicateButton.layer.masksToBounds = YES;
    self.duplicateButton.layer.borderWidth = 1.0f;
    self.duplicateButton.layer.borderColor = [[UIColor grayColor] CGColor];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    //[MobClick endLogPageView:@"Opener"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 复制
- (IBAction)duplicateOpener:(id)sender {
        /*
    //复制到黏贴板
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [self.dataSource[self.swipeView.currentItemIndex] objectForKey:@"opener"];
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    hud.mode = MBProgressHUDModeCustomView;
	hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	hud.delegate = self;
    
    hud.labelText = @"已复制到剪切板";
    
    [self.navigationController.view addSubview:hud];
	
	[hud show:YES];
	[hud hide:YES afterDelay:2];
    
    NSDictionary *dict = @{@"opener":pasteboard.string,@"type":@"picture"};
    //[MobClick event:@"DuplicateOpener" attributes:dict];
        */
}


- (void)selectImage{
    NSString *title = [NSString stringWithFormat:@"剩余次数:%@",[[PFUser currentUser] objectForKey:@"freeChance"]];
    if ([[[PFUser currentUser] objectForKey:@"freeChance"] isEqualToNumber:@0]) {
        //alertview 提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"本日次数已用完" message:@"每日6次机会,凌晨12时前后更新." delegate:nil cancelButtonTitle:@"好的,我知道了" otherButtonTitles: nil];
        return [alert show];
    }else if(![[PFUser currentUser] objectForKey:@"freeChance"]){
        title = @"剩余次数:获取中";
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍一张", @"从相册选择", nil];
    [actionSheet setTag:240];
    [actionSheet showInView:self.view];
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet tag] == 240) {
        switch (buttonIndex) {
            case 0:
                [self takePhotoFromCamera];
                break;
            case 1:
                [self takePictureFromPhotoLibrary];
                break;
                
            default:
                break;
        }
    }
}

- (void)takePhotoFromCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        [picker setDelegate:self];
        [picker setAllowsEditing:NO];
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        [MOHelper showErrorMessage:@"无法使用摄像头,请检查隐私设置" inViewController:self];
    }
}

- (void)takePictureFromPhotoLibrary {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        [picker setDelegate:self];
        [picker setAllowsEditing:NO];
        [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        [MOHelper showErrorMessage:@"无法打开相册,请检查隐私设置" inViewController:self];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *sourceImage = info[UIImagePickerControllerOriginalImage];
    UIImage *imageToDisplay = [MOHelper fixOrientation:sourceImage];
    NSData *imgData = UIImageJPEGRepresentation(imageToDisplay, 0.2f);
    [self.avatarImageView setImage:sourceImage];
    [self.avatarImageView faceAwareFill];
    //检测人脸
    [self performSelectorInBackground:@selector(detectWithImageData:) withObject:imgData];
    [picker dismissViewControllerAnimated:YES completion:nil];
    //初始化页面
    self.hintLabel.text = @"分析照片中...";
    //self.swipeView.hidden = YES;
    self.starDecorateLabel.hidden = YES;
    self.starImageView.hidden = YES;
    self.duplicateButton.hidden = YES;

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)detectWithImageData:(NSData *)imageData{
    
    FaceppResult *result = [[FaceppAPI detection] detectWithURL:nil orImageData:imageData mode:FaceppDetectionModeNormal attribute:FaceppDetectionAttributeGender];
    
    NSString *hintContent = @"";
    if (result.success) {
        
        hintContent = [self getHintFromResult:[result content]];
        
        if ([hintContent isEqualToString:@"正在下载开场白"]) {
            
            NSDictionary *eyeleft = [result content][@"face"][0][@"position"][@"eye_left"];
            NSDictionary *mouthright = [result content][@"face"][0][@"position"][@"mouth_right"];
            int random = ([eyeleft[@"x"] intValue]*
                                [eyeleft[@"y"] intValue]*
                                [mouthright[@"x"] intValue]*
                                [mouthright[@"y"] intValue]);
            NSLog(@"random is %ld",(long)random);
            [self getOpenersWithRandomNumber:random];
        }
        
    }else{
        hintContent = @"网络连接错误";
    }
    
    [self performSelectorOnMainThread:@selector(setHint:) withObject:hintContent waitUntilDone:YES];
}

- (void)getOpenersWithRandomNumber:(int)random {
    
    //统计
    NSDictionary *dict = @{@"type":@"picture"};
    //[MobClick event:@"GetOpener" attributes:dict];
    
    [[PFUser currentUser] incrementKey:@"freeChance" byAmount:@-1];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            NSLog(@"life remain %@",[[PFUser currentUser] objectForKey:@"freeChance"]);
        }];
    }];
    
    PFQuery *queryLow = [PFQuery queryWithClassName:@"Opener"];
    [queryLow whereKey:@"rate" lessThan:@3];
    [queryLow whereKey:@"available" equalTo:[NSNumber numberWithBool:YES]];
    [queryLow whereKey:@"scene" equalTo:@"sns"];
    queryLow.skip = random % 25;
    queryLow.limit = 1;
    
    PFQuery *queryMedium = [PFQuery queryWithClassName:@"Opener"];
    [queryMedium whereKey:@"rate" lessThan:@5];
    [queryMedium whereKey:@"rate" greaterThan:@2];
    [queryMedium whereKey:@"available" equalTo:[NSNumber numberWithBool:YES]];
    [queryMedium whereKey:@"scene" equalTo:@"sns"];
    queryMedium.skip = random % 44;
    queryMedium.limit = 1;
    
    PFQuery *queryHigh = [PFQuery queryWithClassName:@"Opener"];
    [queryHigh whereKey:@"rate" equalTo:@5];
    [queryHigh whereKey:@"available" equalTo:[NSNumber numberWithBool:YES]];
    [queryHigh whereKey:@"scene" equalTo:@"sns"];
    queryHigh.skip = random % 26;
    queryHigh.limit = 1;
    
    NSMutableArray *ds = [NSMutableArray array];
    
    [[[[[MOHelper findAsync:queryLow] continueWithSuccessBlock:^id(BFTask *task) {
        NSArray *array = task.result;
        PFObject *opener = [array objectAtIndex:0];
        [ds addObject:opener];
       // NSLog(@"ds is %@",[self.dataSource description]);
        NSLog(@"lowlevel opener is %@",[opener objectForKey:@"opener"]);
        
        return [MOHelper findAsync:queryMedium];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        
        NSArray *array = task.result;
        PFObject *opener = [array objectAtIndex:0];
        [ds addObject:opener];
        //NSLog(@"ds is %@",[self.dataSource description]);
        NSLog(@"Mediumlevel opener is %@",[opener objectForKey:@"opener"]);
        
        return [MOHelper findAsync:queryHigh];
    }] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"error is %@",task.error);
            return nil;
        }else {
            NSArray *array = task.result;
            PFObject *opener = [array objectAtIndex:0];
            [ds addObject:opener];
            self.dataSource = [NSArray arrayWithArray:ds];
            //NSLog(@"ds is %ld",(long)[self.dataSource count]);
            NSLog(@"Highlevel opener is %@",[opener objectForKey:@"opener"]);
            //[self.swipeView reloadData];
            return nil;
        }
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
        //self.swipeView.hidden = NO;
        self.hintLabel.text = @"马上选一条开始搭讪吧";
        //[self.swipeView scrollToItemAtIndex:0 duration:0];
        PFObject *currentObject = self.dataSource[0];
        NSString *starImageName = [MOHelper getImageNameByRate:[currentObject objectForKey:@"rate"]];
        _starImageView.image = [UIImage imageNamed:starImageName];
        self.starDecorateLabel.hidden = NO;
        self.starImageView.hidden = NO;
        self.duplicateButton.hidden = NO;
        [self performSegueWithIdentifier:@"OpenerPageViewControllerSegue" sender:self];
        return nil;
    }];
    
}

- (void)setHint:(NSString *)content{
    
    self.hintLabel.text = content;
    
}

-(NSString *)getHintFromResult:(NSDictionary *)result{
    
    NSString *hint = @"正在下载开场白";
    NSArray *faces = result[@"face"];
    if ([faces count]==0) {
        return @"没有发现人类";
    }
    
    if ([faces count]>1) {
        return @"太淫荡了,这么多人";
    }
    NSDictionary *gender = [[faces[0] objectForKey:@"attribute"] objectForKey:@"gender"];
    if ([gender[@"value"] isEqualToString:@"Male"]) {
        return @"我们不帮你搭讪男人";
    }
    
    return hint;
}

#pragma mark - uipageview delegate
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    OpenerCarouselViewController *vc = (OpenerCarouselViewController *)pageViewController.viewControllers[0];
    NSInteger index = [self.dataSource indexOfObject:vc.opener];
    return index;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    NSInteger index = [self presentationIndexForPageViewController:pageViewController];
    self.pageControl.currentPage = index;
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
    if ([identifier isEqualToString:@"OpenerPageViewControllerSegue"]) {
        if (self.dataSource.count>0) {
            return YES;
        }else return NO;
    }else return NO;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id dvc = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"OpenerPageViewControllerSegue"]){
        [dvc setValue:self.dataSource forKey:@"openers"];
        OpenerPageViewController* vc = (OpenerPageViewController*)dvc;
        vc.delegate = self;
        self.pageControl.hidden = NO;
        self.aboutLabel.hidden = YES;
    }
    
}


@end
