//
//  ClusterManager.h
//  ObjectiveCDemo
//


#import <Foundation/Foundation.h>
#import "ClusterQuadtree.h"

@interface ClusterManager : NSObject
@property (nonatomic, strong) NSMutableArray *clusterCaches;
- (void)clearClusterItems;
- (NSArray*)getClusters:(CGFloat)zoomLevel;
- (void)addAnnotation:(NSArray <CLLocation *>*)annotataions;
@end
