//
//  DateIdeaViewController.m
//  MagicOpener
//
//  Created by wenlin on 14-7-29.
//  Copyright (c) 2014年 isaced. All rights reserved.
//
@import CoreLocation;
#import "DateIdeaViewController.h"
#import <TOWebViewController/TOWebViewController.h>
#import <pop/POP.h>
#import "DPAPI.h"
#import "MOBusiness.h"
#import "DateIdeaCell.h"
#import "DateIdeaItem.h"
#import "AutoCoding.h"
#import "MOManager.h"


@interface DateIdeaViewController ()<DPRequestDelegate,UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *relationshipTypeSegment;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (readonly,nonatomic) DPAPI *dpApi;
@property (strong,nonatomic) MOBusiness *currentBusiness;
@property (strong,nonatomic) NSArray *datasource;
@property (strong,nonatomic) PFGeoPoint *currentGeoPoint;
@property (strong,nonatomic) CLLocationManager* locationManager;


- (IBAction)refreshDatePlan:(id)sender;


@end

@implementation DateIdeaViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        //Custom initialization
        DateIdeaItem *place = [[DateIdeaItem alloc] initWithTitle:@"约会地点" imageName:@"date-icon-place" content:@"适合当前情感关系的约会地点"];
        DateIdeaItem *opener = [[DateIdeaItem alloc] initWithTitle:@"开场白" imageName:@"date-icon-opener" content:@"见面的第一句话"];
        DateIdeaItem *topic = [[DateIdeaItem alloc] initWithTitle:@"聊天话题" imageName:@"date-icon-topic" content:@"了解对方,不只是问题"];
        DateIdeaItem *interact = [[DateIdeaItem alloc] initWithTitle:@"互动点子" imageName:@"date-icon-interact" content:@"约会过程中的互动建议"];
        
        self.datasource = @[place,opener,topic,interact];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeOther;

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[MobClick beginLogPageView:@"DatePlan"];
    [self.refreshButton addTarget:self action:@selector(scaleToSmall)
                 forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [self.refreshButton addTarget:self action:@selector(scaleAnimation)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.refreshButton addTarget:self action:@selector(scaleToDefault)
                 forControlEvents:UIControlEventTouchDragExit];
    
    if (![PFConfig currentConfig]) {
        [MOHelper showErrorMessage:@"网络连接出现问题,万能约会机暂停工作,需重启应用再试试" inViewController:self];
        self.refreshButton.enabled = NO;
    }

}

-(void)viewDidAppear:(BOOL)animated{
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self startTrackingLocation];
    }else {
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                // do something with the new geoPoint
                self.currentGeoPoint = geoPoint;
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法获取地理位置信息" message:@"请前往设置打开该选项" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    //[MobClick endLogPageView:@"DatePlan"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startTrackingLocation {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }else if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        //[self.locationManager startUpdatingLocation];
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                // do something with the new geoPoint
                self.currentGeoPoint = geoPoint;
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法获取地理位置信息" message:@"请前往设置打开该选项" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
}

- (void)scaleToSmall
{
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.95f, 0.95f)];
    [self.refreshButton.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleSmallAnimation"];
}

- (void)scaleAnimation
{
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.velocity = [NSValue valueWithCGSize:CGSizeMake(3.f, 3.f)];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
    scaleAnimation.springBounciness = 18.0f;
    [self.refreshButton.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleSpringAnimation"];
}

- (void)scaleToDefault
{
    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.f, 1.f)];
    [self.refreshButton.layer pop_addAnimation:scaleAnimation forKey:@"layerScaleDefaultAnimation"];
}

- (IBAction)refreshDatePlan:(id)sender {
    
    if (!self.currentGeoPoint) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法获取地理位置信息" message:@"请前往设置打开该选项" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        return [alert show];
    }
    
    //友盟统计
    NSString *type = @"";
    switch (self.relationshipTypeSegment.selectedSegmentIndex) {
        case 0:
            type = @"初次见";
            break;
        case 1:
            type = @"有点熟";
            break;
        case 2:
            type = @"暧昧";
            break;
            
        default:
            type = @"初次见";
            break;
    }
    NSDictionary *dict = @{@"type":type};
    //[MobClick event:@"GetDatePlan" attributes:dict];
    
    //动画
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.tableView.alpha = 0.0;

    } completion:^(BOOL finished) {
        
    }];
    
    //请求date plan
    NSString *latitude = [NSString stringWithFormat:@"%f",self.currentGeoPoint.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",self.currentGeoPoint.longitude];
    
    NSString *basicString = [self paramsStringWithOptionIndex:self.relationshipTypeSegment.selectedSegmentIndex];
    NSString *paramsString = [basicString stringByAppendingString:[NSString stringWithFormat:@"&latitude=%@&longitude=%@",latitude,longitude]];
    
    [[[MOManager sharedManager] dpApi] requestWithURL:@"v1/business/find_businesses" paramsString:paramsString delegate:self];
}

//约会地点根据情感关系配置
-(NSString*)paramsStringWithOptionIndex:(NSInteger)index{
    
    NSString *params = nil;
    switch (index) {
        case 0:
            params = @"category=面包甜点,咖啡,公园&limit=40&sort=9&radius=5000";
            break;
        case 1:
            params = @"category=美食,电影院,运动健身&limit=40&sort=2&radius=5000";
            break;
        case 2:
            params = @"category=酒店,KTV,足疗按摩,酒吧&limit=40&sort=2&radius=5000";
            break;
            
        default:
            break;
    }
    return params;
}

//约会话题根据情感关系配置
-(PFQuery*)queryTopicWithOptionIndex:(NSInteger)index{
    
    int count = 0;
    PFQuery *queryTopic = [PFQuery queryWithClassName:@"ChatTopic"];
    switch (index) {
        case 0:
            [queryTopic whereKey:@"type" equalTo:@"first"];
            count = [[PFConfig currentConfig][@"dateIdeaFirstRelationTopicCount"] intValue];
            break;
        case 1:
            [queryTopic whereKey:@"type" equalTo:@"friend"];
            count = [[PFConfig currentConfig][@"dateIdeaFriendRelationTopicCount"] intValue];
            break;
        case 2:
            [queryTopic whereKey:@"type" equalTo:@"hot"];
            [[PFConfig currentConfig][@"dateIdeaHotRelationTopicCount"] intValue];
            break;
            
        default:
            [queryTopic whereKey:@"type" equalTo:@"first"];
            [[PFConfig currentConfig][@"dateIdeaFirstRelationTopicCount"] intValue];
            break;
    }
    int random = arc4random() % count;
    queryTopic.skip = random;
    queryTopic.limit = 1;
    
    return queryTopic;
    
}


#pragma mark - dpRequest delegate
- (void)request:(DPRequest *)request didFailWithError:(NSError *)error {
    //NSLog(@"Error从大众点评返回：%@",[error description]);
}

- (void)request:(DPRequest *)request didFinishLoadingWithResult:(NSDictionary*)result {
    
	//NSLog(@"成功从大众点评返回：%@,地址是：%@",result[@"businesses"][0][@"name"],result[@"businesses"][0][@"address"]);
    NSArray *businesses = result[@"businesses"];
    
    if (businesses.count>0) {
        int random1 = arc4random() % businesses.count;
        NSDictionary *business = businesses[random1];
        self.currentBusiness = [MTLJSONAdapter modelOfClass:[MOBusiness class] fromJSONDictionary:business error:nil];
        [(DateIdeaItem*)self.datasource[0] setContent:self.currentBusiness.name];
        [(DateIdeaItem*)self.datasource[0] setRemark:self.currentBusiness.address];
        
        //开场白
        int openersCount = [[PFConfig currentConfig][@"dateIdeaOpenerCount"] intValue];
        int random3 = arc4random() % openersCount;
        PFQuery *queryOpener = [PFQuery queryWithClassName:@"Opener"];
        [queryOpener whereKey:@"scene" equalTo:@"date"];
        queryOpener.skip = random3;
        queryOpener.limit = 1;
        
        //互动点子
        int interactionCount = [[PFConfig currentConfig][@"dateIdeaInteractionCount"] intValue];
        int random4 = arc4random() % interactionCount;
        PFQuery *queryInteract = [PFQuery queryWithClassName:@"DateIdea"];
        [queryInteract whereKey:@"available" equalTo:[NSNumber numberWithBool:YES]];
        queryInteract.skip = random4;
        queryInteract.limit = 1;
        
        [[[[MOHelper findAsync:[self queryTopicWithOptionIndex:self.relationshipTypeSegment.selectedSegmentIndex]] continueWithSuccessBlock:^id(BFTask *task) {
            
            NSArray *result = task.result;
            PFObject *topic = result[0];
            [(DateIdeaItem*)self.datasource[2] setContent:[topic objectForKey:@"topic"]];
            [(DateIdeaItem*)self.datasource[2] setRemark:[topic objectForKey:@"description"]];
            
            
            
            return [MOHelper findAsync:queryOpener];
        }] continueWithSuccessBlock:^id(BFTask *task) {
            
            NSArray *result = task.result;
            PFObject *opener = result[0];
            [(DateIdeaItem*)self.datasource[1] setContent:[opener objectForKey:@"opener"]];
            [(DateIdeaItem*)self.datasource[1] setRemark:[opener objectForKey:@"description"]];
            
            return [MOHelper findAsync:queryInteract];
        }] continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
            NSArray *result = task.result;
            PFObject *interact = result[0];
            [(DateIdeaItem*)self.datasource[3] setContent:[interact objectForKey:@"idea"]];
            [(DateIdeaItem*)self.datasource[3] setRemark:[interact objectForKey:@"description"]];
            
            [self.tableView reloadData];
            
            
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                self.tableView.alpha = 1.0;
            } completion:^(BOOL finished) {
                
            }];
            
            return nil;
        }];
    }
}


#pragma mark - tableview datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.datasource count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"DateIdeaCell";
    
    DateIdeaCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[DateIdeaCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:cellIdentifier];
    }
    // Configure the cell to show todo item with a priority at the bottom
    cell.titleLabel.text = [self.datasource[indexPath.row] title];
    cell.contentLable.text = [self.datasource[indexPath.row] content];
    cell.descriptionLabel.text = [self.datasource[indexPath.row] remark];
    cell.iconImageView.image = [UIImage imageNamed:[self.datasource[indexPath.row] imageName]];
    if (indexPath.row == 0 && [self.datasource[0] description]) {
        cell.moreButton.hidden = NO;
        cell.contentLable.textColor = [UIColor redColor];
    }
    
    return cell;
}

#pragma mark - tableview delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSURL *url = [NSURL URLWithString:self.currentBusiness.url];
    
    if (indexPath.row == 0 &&[self.datasource[0] description]) {
        NSDictionary *dict = @{@"business":self.currentBusiness.name};
        //[MobClick event:@"GetMoreBusinessInfo" attributes:dict];
        
        TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:url];
        webViewController.showUrlWhileLoading = NO;
        webViewController.showPageTitles = NO;
        webViewController.hideWebViewBoundaries = YES;
        [self.navigationController pushViewController:webViewController animated:YES];
        
    }
    
}

#pragma mark - cllocation manager
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"Got authorization, start tracking location");
            [self startTrackingLocation];
            break;
        case kCLAuthorizationStatusNotDetermined:
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self startTrackingLocation];
            }
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // Pass location updates to the map view.
    [locations enumerateObjectsUsingBlock:^(CLLocation *location, NSUInteger idx, BOOL *stop) {
        NSLog(@"Location (Floor %@): %@", location.floor, location.description);
    }];
}


@end
