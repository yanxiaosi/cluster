//
//  ViewController.m
//  cluster
//
//  Created by yanxiaosi on 2021/7/9.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import "DpPositionCourierModel.h"
#import "ClusterManager.h"
#import "ClusterAnnotation.h"
#import "ClusterAnnotationView.h"
#import <MJExtension/MJExtension.h>
@interface ViewController ()<MAMapViewDelegate>
@property(nonatomic, strong) MAMapView *mapView;
@property(nonatomic, strong) NSArray<DpPositionCourierModel *> *annotations;
@property(nonatomic, strong) ClusterManager *clusterManager;
@property(nonatomic, assign) NSUInteger clusterZoom;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    self.clusterManager = [[ClusterManager alloc] init];
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"response" ofType:@"json"]];
    NSDictionary *dic = nil;
    @try {
        dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
        
    }
    self.annotations = [DpPositionCourierModel mj_objectArrayWithKeyValuesArray:dic[@"data"]];
    
    NSMutableArray *locations = [NSMutableArray array];
    
    for (DpPositionCourierModel *model in self.annotations) {
        if (model.latitude == 0 || model.longitude == 0) continue;
            
        CLLocation *location = [[CLLocation alloc] initWithLatitude:model.latitude longitude:model.longitude];
        [locations addObject:location];
    }
    DpPositionCourierModel *m = (DpPositionCourierModel *)self.annotations.firstObject;
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(m.latitude, m.longitude)];
    self.mapView.zoomLevel = 5;
    
    [self.clusterManager addAnnotation:locations];
   
}

- (void)updateClusters {
    _clusterZoom = (NSInteger)_mapView.zoomLevel;
    @synchronized(_clusterManager.clusterCaches) {
         NSMutableArray *clusters = [_clusterManager.clusterCaches objectAtIndex:(_clusterZoom - 3)];
        if (clusters.count > 0) {
            [_mapView removeAnnotations:_mapView.annotations];
            [_mapView addAnnotations:clusters];
        } else {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                ///获取聚合后的标注
                __block NSArray *array = [self.clusterManager getClusters:self.clusterZoom];
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (Cluster *item in array) {
                        ClusterAnnotation *annotation = [[ClusterAnnotation alloc] init];
                        annotation.coordinate = item.coordinate;
                        annotation.count = item.size;
                        [clusters addObject:annotation];
                    }

                    
                        [self.mapView removeAnnotations:self.mapView.annotations];
                        //将一组标注添加到当前地图View中
                        [self.mapView addAnnotations:clusters];
                    
                });
            });
        }
    }
}

- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction{
    [self updateClusters];

}
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSLog(@"%f",mapView.zoomLevel);

}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[ClusterAnnotation class]]) {
        static NSString *const AnnotationViewReuseID = @"AnnotationViewReuseID";
        ClusterAnnotationView *annotationView = (ClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewReuseID];
        if (!annotationView) {
            annotationView = [[ClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewReuseID];
        }
        annotationView.annotation = annotation;
        annotationView.count = [(ClusterAnnotationView *)annotation count];
        annotationView.canShowCallout = NO;
        return annotationView;
    }
    
    return nil;
}

@end
