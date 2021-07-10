//
//  ClusterItem.h
//  ObjectiveCDemo
//


#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Cluster : NSObject
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSMutableArray *clusterAnnotations;
@property (nonatomic, readonly) NSUInteger size;
@end



