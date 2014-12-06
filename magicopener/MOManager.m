//
//  MOManager.m
//  MagicOpener
//
//  Created by wenlin on 14-7-30.
//  Copyright (c) 2014年 isaced. All rights reserved.
//

#import "MOManager.h"

@implementation MOManager

+ (instancetype)sharedManager {
    
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
	self = [super init];
    if (self) {
        
        _dpApi = [[DPAPI alloc] init];
        
    }
    return self;
}

-(void)refreshCurrentCofig{
    
    const NSTimeInterval configRefreshInterval = 12.0 * 60.0 * 60.0;
    static NSDate *lastFetchedDate;
    if (lastFetchedDate == nil ||
        [lastFetchedDate timeIntervalSinceNow] * -1.0 > configRefreshInterval) {
        [PFConfig getConfigInBackgroundWithBlock:nil];
        lastFetchedDate = [NSDate date];
    }
}

@end
