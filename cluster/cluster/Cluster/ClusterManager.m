//
//  ClusterManager.m
//  ObjectiveCDemo
//
//  Created by Baidu RD on 2018/3/6.
//  Copyright © 2015年 Baidu. All rights reserved.
//

#import "ClusterManager.h"

#define MAX_DISTANCE_IN_DP    200

@interface ClusterManager ()
@property (nonatomic, readonly) NSMutableArray *quadItems;
@property (nonatomic, readonly) ClusterQuadtree *quadtree;
@end

@implementation ClusterManager

#pragma mark - Initialization method
//- (id)init {
//    self = [super init];
//    if (self) {
//        
//        _clusterCaches = [[NSMutableArray alloc] init];
//        for (NSInteger i = 2; i < 21; i++) {
//            [_clusterCaches addObject:[NSMutableArray array]];
//        }
//        
//        _quadtree = [[ClusterQuadtree alloc] initWithRect:CGRectMake(0, 0, 1, 1)];
//        _quadItems = [[NSMutableArray alloc] init];
//        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(39.915, 116.404);
//        for (NSInteger i = 0; i < 20; i++) {
//            double lat =  (arc4random() % 100) * 0.001f;
//            double lon =  (arc4random() % 100) * 0.001f;
//            
//            CLLocationCoordinate2D coordinate;
//            coordinate = CLLocationCoordinate2DMake(coor.latitude + lat, coor.longitude + lon);
//            QuadItem *quadItem = [[QuadItem alloc] init];
//            quadItem.coordinate = coordinate;
//            @synchronized(_quadtree) {
//                [_quadItems addObject:quadItem];
//                [_quadtree addItem:quadItem];
//            }
//        }
//    }
//    return self;
//}

- (void)addAnnotation:(NSArray<CLLocation *> *)annotataions{
    
    _clusterCaches = [[NSMutableArray alloc] init];
    for (NSInteger i = 2; i < 21; i++) {
        [_clusterCaches addObject:[NSMutableArray array]];
    }
    
    _quadtree = [[ClusterQuadtree alloc] initWithRect:CGRectMake(0, 0, 1, 1)];
    _quadItems = [[NSMutableArray alloc] init];
    
    
    for (CLLocation *location in annotataions) {
        QuadItem *quadItem = [[QuadItem alloc] init];
        quadItem.coordinate = location.coordinate;
        @synchronized(_quadtree) {
            [_quadItems addObject:quadItem];
            [_quadtree addItem:quadItem];
        }
    }
    
   
    
}

#pragma mark - Clusters
- (void)clearClusterItems {
    @synchronized(_quadtree) {
        [_quadItems removeAllObjects];
        [_quadtree clearItems];
    }
}

- (NSArray *)getClusters:(CGFloat) zoomLevel {
    if (zoomLevel < 3 || zoomLevel > 20) {
        return nil;
    }
    NSMutableArray *results = [NSMutableArray array];
    
    CGFloat zoomSpecificSpan = MAX_DISTANCE_IN_DP / pow(2, zoomLevel) / 256;
    NSMutableSet *visitedCandidates = [NSMutableSet set];
    NSMutableDictionary *distanceToCluster = [NSMutableDictionary dictionary];
    NSMutableDictionary *itemToCluster = [NSMutableDictionary dictionary];
    
    @synchronized(_quadtree) {
        for (QuadItem *candidate in _quadItems) {
            //candidate已经添加到另一cluster中
            if ([visitedCandidates containsObject:candidate]) {
                continue;
            }
            Cluster *cluster = [[Cluster alloc] init];
            cluster.coordinate = candidate.coordinate;
            
            CGRect searchRect = [self getRectWithPt:candidate.pt span:zoomSpecificSpan];
            NSMutableArray *items = (NSMutableArray *)[_quadtree searchInRect:searchRect];
            if (items.count == 1) {
                CLLocationCoordinate2D coor = candidate.coordinate;
                NSValue *value = [NSValue value:&coor withObjCType:@encode(CLLocationCoordinate2D)];
                [cluster.clusterAnnotations addObject:value];
                
                [results addObject:cluster];
                [visitedCandidates addObject:candidate];
                [distanceToCluster setObject:[NSNumber numberWithDouble:0] forKey:[NSNumber numberWithLongLong:candidate.hash]];
                continue;
            }
            
            for (QuadItem *quadItem in items) {
                NSNumber *existDistache = [distanceToCluster objectForKey:[NSNumber numberWithLongLong:quadItem.hash]];
                CGFloat distance = [self getDistanceSquared:candidate.pt otherPoint:quadItem.pt];
                if (existDistache != nil) {
                    if (existDistache.doubleValue < distance) {
                        continue;
                    }
                    Cluster *existCluster = [itemToCluster objectForKey:[NSNumber numberWithLongLong:quadItem.hash]];
                    CLLocationCoordinate2D coor = quadItem.coordinate;
                    NSValue *value = [NSValue value:&coor withObjCType:@encode(CLLocationCoordinate2D)];
                    [existCluster.clusterAnnotations removeObject:value];
                }
                
                [distanceToCluster setObject:[NSNumber numberWithDouble:distance] forKey:[NSNumber numberWithLongLong:quadItem.hash]];
                CLLocationCoordinate2D coor = quadItem.coordinate;
                NSValue *value = [NSValue value:&coor withObjCType:@encode(CLLocationCoordinate2D)];
                [cluster.clusterAnnotations addObject:value];
                [itemToCluster setObject:cluster forKey:[NSNumber numberWithLongLong:quadItem.hash]];
            }
            [visitedCandidates addObjectsFromArray:items];
            [results addObject:cluster];
        }
    }
    return results;
}

- (CGRect)getRectWithPt:(CGPoint) pt  span:(CGFloat) span {
    CGFloat half = span / 2.f;
    return CGRectMake(pt.x - half, pt.y - half, span, span);
}

- (CGFloat)getDistanceSquared:(CGPoint) pt otherPoint:(CGPoint)otherPoint {
    return pow(pt.x - otherPoint.x, 2) + pow(pt.y - otherPoint.y, 2);
}


@end
