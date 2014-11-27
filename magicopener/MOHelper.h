//
//  MOHelper.h
//  magicopener
//
//  Created by wenlin on 14/11/27.
//  Copyright (c) 2014年 BRYQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts.h>


@interface MOHelper : NSObject

//日期转换为字符串
+ (NSString *)stringFromDate:(NSDate *)date;

//字符串是否为空
+ (BOOL)stringIsEmpty: (NSString *)string;

//去除字符串空格
+ (NSString *)trimString:(NSString *)imputText;

//获取星星图片名称
+ (NSString *)getImageNameByRate:(NSNumber *)rate;

//返回图像
+ (UIImage *)fixOrientation:(UIImage *)aImage;

//Bolts task
+ (BFTask *)findAsync:(PFQuery *)query;

//Unicode 转为 UTF-8
+ (NSString *)replaceUnicode:(NSString *)unicodeStr;

//网络连接
+(BFTask*)fetchJsonWithURL:(NSURL*)url;

//异步获取用户
+ (BFTask *)findAsyncUser:(NSString *)userId;

//设置installId，判断设备是否已安装app
+(void)setInstalledId;

//获取installId，判断设备是否已安装app
+(BOOL)getInstalledId;

//MD5加密 32位 小写
+ (NSString *)md5:(NSString *)str;

//打乱NSMutableArray顺序
+ (NSMutableArray*)shuffleNSMutableArray:(NSMutableArray*)array;

//判断缓存目录是否存在该文件
+(NSString*)isFileNameExists:(NSString*)fileName;

//截图
+ (UIImage *)makeSnapshot;

//timestamp 转NSDate
+(NSDate*)dateFromTimestamp:(NSNumber*)timestamp;

//判断该date是否为今天
+(BOOL)isDateEqualToToday:(NSDate*)date;

//判断该date是否为今天
+(BOOL)isDateEqualToYesterday:(NSDate*)date;

//根据服务器返回error code,展示相关用户提示语
+(NSString*)hintForErrorCode:(int)code;

//show alert
+(void)showAlertWithMessage:(NSString*)message;

//根据生日拿岁数
+ (int)getAgeByBirthday: (NSDate *)birthday;

//根据生日拿星座
+ (NSString *)getAstroByBirthday: (NSDate *) birthday;

@end
