//
//  DpPositionCourierModel.m
//  Deppon
//
//  Created by MrChen on 2017/12/13.
//  Copyright © 2017年 MrChen. All rights reserved.
//

#import "DpPositionCourierModel.h"
#import <CoreLocation/CoreLocation.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

@implementation DpPositionCourierModel
- (instancetype)initWithDic:(NSDictionary *)dic
{
    if (self = [super init]) {
        if ([dic isKindOfClass:[NSNull class]]) {
            return self;
        }
        
        // 是否上班
        self.work = [dic[@"work"] boolValue];
        
        // 名字
        self.empName = dic[@"empName"];
        
        // 是否是低效
        self.low30 = [dic[@"low30"] boolValue];
        
        
        // 经度
        self.longitude = [dic[@"longitude"] floatValue];
        
        // 维度
        self.latitude = [dic[@"latitude"] floatValue];
        
        // 百度经纬度转高德经纬度
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude);
        CLLocationCoordinate2D transCoordinate = AMapCoordinateConvert(coordinate, AMapCoordinateTypeBaidu);
        self.latitude = transCoordinate.latitude;
        self.longitude = transCoordinate.longitude;
        
        // gps是否开启
        self.gpsOn = [dic[@"gpsOn"] boolValue];
        
        // 工号
        self.empCode = dic[@"empCode"];
        
        // 是否pda在线
        self.pdaOnline = [dic[@"pdaOnline"] boolValue];
    }
    
    return self;
}

+ (instancetype)courierWithDic:(NSDictionary *)dic
{
    return [[self alloc]initWithDic:dic];
}
@end
