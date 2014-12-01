//
//  MOHelper.m
//  magicopener
//
//  Created by wenlin on 14/11/27.
//  Copyright (c) 2014年 BRYQ. All rights reserved.
//

#import "MOHelper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MOHelper

+ (NSString *)stringFromDate:(NSDate *)date{
    
    //NSTimeZone *zone = [NSTimeZone systemTimeZone];
    //NSInteger interval = [zone secondsFromGMTForDate: date];
    //NSDate *localeDate = [date dateByAddingTimeInterval: interval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    
    return destDateString;
    
}

+ (BOOL)stringIsEmpty: (NSString *)string {
    if (string == nil || [string length] == 0) {
        return TRUE;
    }
    return FALSE;
}


+ (NSString *)trimString:(NSString *)imputText{
    
    NSString *trimmedComment = [imputText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return trimmedComment;
    
}

+ (NSString *)getImageNameByRate:(NSNumber *)rate {
    
    NSString *string = @"";
    if (rate) {
        switch ([rate intValue]) {
            case 1:
                string = @"1star";
                break;
            case 2:
                string = @"2star";
                break;
            case 3:
                string = @"3star";
                break;
            case 4:
                string = @"4star";
                break;
            case 5:
                string = @"5star";
                break;
                
            default:
                break;
        }
    }else{
        string = @"0star";
    }
    
    return string;
}


+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (BFTask *)findAsync:(PFQuery *)query{
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [task setResult:objects];
            
        } else {
            NSLog(@"inside error is %@",error);
            [task setError:error];
            
        }
    }];
    
    return task.task;
}

+ (NSString *)replaceUnicode:(NSString *)unicodeStr {
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    
    NSString *finalString = [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
    
    return finalString;
}


+(BFTask*) fetchJsonWithURL:(NSURL*)url{
    NSLog(@"Fetching: %@",url.absoluteString);
    
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
    
    NSURLSessionDataTask * dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            //TODO:Handle retrieved data
            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
            
            NSLog(@"json is %@",[json description]);
            
            if (!jsonError) {
                
                if (![[json allKeys] containsObject:@"error"]) {
                    [task setResult:json];
                }else{
                    NSError *error = [NSError errorWithDomain:nil code:[[json objectForKey:@"code"] intValue] userInfo:json];
                    [task setError:error];
                }
                
                
            }else{
                [task setError:jsonError];
            }
            
        }else{
            
            [task setError:error];
        }
    }];
    
    //执行NSURLSession
    [dataTask resume];
    
    return task.task;
}

+ (BFTask *)findAsyncUser:(NSString *)userId{
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
    __block NSError *error = nil;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PFUser *user = [PFQuery getUserObjectWithId:userId error:&error];
        
        if (!error) {
            [task setResult:user];
        }else{
            [task setError:error];
        }
    });
    
    return task.task;
}

+(void)setInstalledId{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (![userDefault objectForKey:@"isInstalled"]) {
        [userDefault setObject:@1 forKey:@"isInstalled"];
        [userDefault synchronize];
    }
}

+(BOOL)getInstalledId{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:@"isInstalled"]) {
        return YES;
    }else{
        return NO;
    }
}
/*
//md5 32位 加密 （小写）
+ (NSString *)md5:(NSString *)str {
    
    const char *cStr = [str UTF8String];
    
    unsigned char result[32];
    
    CC_MD5( cStr, strlen(cStr), result );
    
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            
            result[0],result[1],result[2],result[3],
            
            result[4],result[5],result[6],result[7],
            
            result[8],result[9],result[10],result[11],
            
            result[12],result[13],result[14],result[15],
            
            result[16], result[17],result[18], result[19],
            
            result[20], result[21],result[22], result[23],
            
            result[24], result[25],result[26], result[27],
            
            result[28], result[29],result[30], result[31]];
    
}
*/

+ (NSMutableArray*)shuffleNSMutableArray:(NSMutableArray*)array{
    if (!array.count) {
        return nil;
    }
    NSMutableArray *mArray = array;
    NSUInteger count = [mArray count];
    for (int i = 0; i < count; ++i) {
        int n = (arc4random() % (count - i)) + i;
        [mArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    return mArray;
}

+(NSString*)isFileNameExists:(NSString*)fileName{
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    filePath = [filePath stringByAppendingFormat:@"/%@",fileName];
    
    
    if ([manager fileExistsAtPath:filePath]) {
        
        return filePath;
        
    } else return nil;
    
}
/*
 + (UIImage*)screenshot
 {
 // Create a graphics context with the target size
 // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
 // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
 CGSize imageSize = [[UIScreen mainScreen] bounds].size;
 if (NULL != UIGraphicsBeginImageContextWithOptions)
 UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
 else
 UIGraphicsBeginImageContext(imageSize);
 
 CGContextRef context = UIGraphicsGetCurrentContext();
 
 // Iterate over every window from back to front
 for (UIWindow *window in [[UIApplication sharedApplication] windows])
 {
 if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
 {
 // -renderInContext: renders in the coordinate space of the layer,
 // so we must first apply the layer's geometry to the graphics context
 CGContextSaveGState(context);
 // Center the context around the window's anchor point
 CGContextTranslateCTM(context, [window center].x, [window center].y);
 // Apply the window's transform about the anchor point
 CGContextConcatCTM(context, [window transform]);
 // Offset by the portion of the bounds left of and above the anchor point
 CGContextTranslateCTM(context,
 -[window bounds].size.width * [[window layer] anchorPoint].x,
 -[window bounds].size.height * [[window layer] anchorPoint].y);
 
 // Render the layer hierarchy to the current context
 [[window layer] renderInContext:context];
 
 // Restore the context
 CGContextRestoreGState(context);
 }
 }
 // Retrieve the screenshot image
 UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
 
 UIGraphicsEndImageContext();
 
 return image;
 }
 */



+(NSDate*)dateFromTimestamp:(NSNumber*)timestamp{
    NSTimeInterval date=[timestamp doubleValue];
    
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:date];
    
    //NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    
    //formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];//注意时区设置
    
    //[formatter setDateFormat:@"yyyyMMddHHmmss"];
    
    //NSString *starLiveTime=[formatter stringFromDate:detaildate];
    
    
    return detaildate;
}

//判断该date是否为今天
+(BOOL)isDateEqualToToday:(NSDate*)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd"];
    
    NSString *dateCompare = [dateFormatter stringFromDate:date];
    NSDate *now = [NSDate date];
    NSString *dateNow = [dateFormatter stringFromDate:now];
    if ([dateCompare isEqualToString:dateNow]) {
        return YES;
    }
    else {
        return NO;
    }
    
}

//判断该date是否为今天
+(BOOL)isDateEqualToYesterday:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd"];
    
    NSString *dateCompare = [dateFormatter stringFromDate:date];
    NSDate * yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400];
    NSString *dateYesterDay = [dateFormatter stringFromDate:yesterday];
    if ([dateCompare isEqualToString:dateYesterDay]) {
        return YES;
    }
    else {
        return NO;
    }
}


+(NSString*)hintForErrorCode:(int)code{
    
    NSString *errString = @"";
    switch (code) {
        case 500:
            errString = @"亲，任务已经完成了哦";
            break;
        case 403:
            errString = @"缺少必须得参数,请检查网络并重启应用";
            break;
        case 404:
            errString = @"你的网络好像不太好(404)，请检查一下网络，再试试看吧";
            break;
            
            
        default:
            errString = @"哥们网络又崩坏了，啥人品啊,试试重来吧";
            break;
    }
    
    return errString;
}

+(void)showAlertWithMessage:(NSString*)message{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

+ (int)getAgeByBirthday: (NSDate *)birthday {
    int age = 0;
    
    NSTimeInterval dateDiff = [birthday timeIntervalSinceNow];
    age = -1 * trunc(dateDiff / (60 * 60 * 24)) / 365;
    return age;
}


/****************************************
 摩羯座 12月22日------1月19日
 水瓶座 1月20日-------2月18日
 双鱼座 2月19日-------3月20日
 白羊座 3月21日-------4月19日
 金牛座 4月20日-------5月20日
 双子座 5月21日-------6月21日
 巨蟹座 6月22日-------7月22日
 狮子座 7月23日-------8月22日
 处女座 8月23日-------9月22日
 天秤座 9月23日------10月23日
 天蝎座 10月24日-----11月21日
 射手座 11月22日-----12月21日
 ****************************************/
+ (NSString *)getAstroByBirthday: (NSDate *) birthday {
    NSString *astrologic = @"";
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat: @"MM"];              //firstly, get the month
    int i_month = 0;
    NSString *theMonth = [dateFormat stringFromDate: birthday];
    // Jan ~ Sep
    if ([[theMonth substringToIndex: 0] isEqualToString: @"0"]) {
        i_month = [[theMonth substringFromIndex: 1] intValue];
    }
    // Oct ~ Dec
    else {
        i_month = [theMonth intValue];
    }
    
    [dateFormat setDateFormat: @"dd"];              // then get the day
    int i_day = 0;
    NSString *theDay = [dateFormat stringFromDate: birthday];
    // 01 ~ 09
    if ([[theDay substringToIndex: 0] isEqualToString: @"0"]) {
        i_day = [[theDay substringFromIndex: 1] intValue];
    }
    // 10 ~ 31
    else {
        i_day = [theDay intValue];
    }
    
    switch (i_month) {
        case 1:                                     // Jan
            astrologic = (i_day <= 19) ? @"摩羯座" : @"水瓶座";
            break;
        case 2:                                     // Feb
            astrologic = (i_day <= 18) ? @"水瓶座" : @"双鱼座";
            break;
        case 3:                                     // Mar
            astrologic = (i_day <= 20) ? @"双鱼座" : @"白羊座";
            break;
        case 4:                                     // Apr
            astrologic = (i_day <= 19) ? @"白羊座" : @"金牛座";
            break;
        case 5:                                     // May
            astrologic = (i_day <= 20) ? @"金牛座" : @"双子座";
            break;
        case 6:                                     // June
            astrologic = (i_day <= 21) ? @"双子座" : @"巨蟹座";
            break;
        case 7:                                     // July
            astrologic = (i_day <= 22) ? @"巨蟹座" : @"狮子座";
            break;
        case 8:                                     // Aug
            astrologic = (i_day <= 22) ? @"狮子座" : @"处女座";
            break;
        case 9:                                     // Sep
            astrologic = (i_day <= 22) ? @"处女座" : @"天秤座";
            break;
        case 10:                                    // Oct
            astrologic = (i_day <= 23) ? @"天秤座" : @"天蝎座";
            break;
        case 11:                                    // Nov
            astrologic = (i_day <= 21) ? @"天蝎座" : @"射手座";
            break;
        case 12:                                    // Dec
            astrologic = (i_day <= 21) ? @"射手座" : @"摩羯座";
            break;
    }
    return astrologic;
}

+ (UIImage *)makeSnapshot
{
    CGSize imageSize = CGSizeZero;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (void)showErrorMessage:(NSString*)message inViewController:(UIViewController*)vc{
    [TSMessage showNotificationInViewController:vc title:message subtitle:nil type:TSMessageNotificationTypeError];
}

@end
