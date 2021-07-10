//
//  ClusterAnnotation.h
//  cluster
//
//  Created by yanxiaosi on 2021/7/10.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import "DpPositionCourierModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ClusterAnnotation : NSObject<MAAnnotation>
@property (assign, nonatomic) CLLocationCoordinate2D coordinate; //poi的平均位置
@property (assign, nonatomic) NSInteger count;
@property (nonatomic, strong) NSMutableArray <CLLocation *> *pois;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) DpPositionCourierModel *positionCourierModel;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSString *imagesUrl;
@property (assign, nonatomic) CLLocation* coverLocation; //封面位置


- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate count:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
