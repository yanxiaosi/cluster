//
//  ClusterItem.m
//  ObjectiveCDemo
//

#import "Cluster.h"

@implementation Cluster

#pragma mark - Initialization method
- (id)init {
    self = [super init];
    if (self) {
        _clusterAnnotations = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - View life cycle
- (NSUInteger)size {
    return _clusterAnnotations.count;
}

@end
