//
//  ClusterQuadtree.h
//  ObjectiveCDemo
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Cluster.h"

@interface QuadItem : NSObject
@property (nonatomic, readonly) CGPoint pt;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

@interface ClusterQuadtree : NSObject

//四叉树区域
@property (nonatomic, assign) CGRect rect;
//所包含QuadItem
@property(nonatomic, readonly) NSMutableArray *quadItems;
- (id)initWithRect:(CGRect) rect;
//添加item
- (void)addItem:(QuadItem*) quadItem;
//清除items
- (void)clearItems;
//获取rect范围内的QuadItem
- (NSArray*)searchInRect:(CGRect) searchRect;

@end

