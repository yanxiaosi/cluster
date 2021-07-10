//
//  ClusterQuadtree.m
//  ObjectiveCDemo
//


#import "ClusterQuadtree.h"


#define MAX_POINTS_PER_NODE 40

@implementation QuadItem : NSObject

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
    _coordinate = coordinate;
    _pt = [self convertCoordinateToPoint:coordinate];
}

- (CGPoint)convertCoordinateToPoint:(CLLocationCoordinate2D) coor {
    CGFloat x = coor.longitude / 360.f + 0.5;
    CGFloat siny = sin(coor.latitude * M_PI / 180.f);
    CGFloat y = 0.5 * log((1 + siny) / (1 - siny)) / - (2 * M_PI) + 0.5;
    return CGPointMake(x, y);
}

@end

#pragma mark - ClusterQuadtree
@interface ClusterQuadtree () 
@property (nonatomic, strong) NSMutableArray *childrens;
@end

@implementation ClusterQuadtree

#pragma mark - Initialization method

- (id)initWithRect:(CGRect) rect {
    self = [super init];
    if (self) {
        _quadItems = [[NSMutableArray alloc] initWithCapacity:MAX_POINTS_PER_NODE];
        _rect = rect;
    }
    return self;
}

//四叉树拆分
- (void)subdivide {
    _childrens = [[NSMutableArray alloc] initWithCapacity:4];
    CGFloat x = _rect.origin.x;
    CGFloat y = _rect.origin.y;
    CGFloat w = _rect.size.width / 2.f;
    CGFloat h = _rect.size.height / 2.f;
    [_childrens addObject:[[ClusterQuadtree alloc] initWithRect:CGRectMake(x, y, w, h)]];
    [_childrens addObject:[[ClusterQuadtree alloc] initWithRect:CGRectMake(x + w, y, w, h)]];
    [_childrens addObject:[[ClusterQuadtree alloc] initWithRect:CGRectMake(x, y + h, w, h)]];
    [_childrens addObject:[[ClusterQuadtree alloc] initWithRect:CGRectMake(x + w, y + h, w, h)]];
}

//插入数据
- (void)addItem:(QuadItem *)quadItem {
    if (quadItem == nil) {
        return ;
    }
    
    if (CGRectContainsPoint(_rect, quadItem.pt) == NO) {
        return;
    }
    
    if(_quadItems.count < MAX_POINTS_PER_NODE) {
        [_quadItems addObject:quadItem];
        return ;
    }
    
    if(_childrens == nil || _childrens.count == 0) {
        [self subdivide];
    }
    for (ClusterQuadtree *children in _childrens) {
        [children addItem:quadItem];
    }
}

- (void)clearItems {
    _childrens = nil;
    if (_quadItems) {
        [_quadItems removeAllObjects];
    }
}

//获取rect范围内的QuadItem
- (NSArray *)searchInRect:(CGRect)searchRect {
    //searchrect和四叉树区域rect无交集
    if (CGRectIntersectsRect(searchRect, _rect) == NO) {
        return [NSArray array];
    }
    NSMutableArray *array = [NSMutableArray array];
    //searchrect包含四叉树区域
    if (CGRectContainsRect(searchRect, _rect)) {
        [array addObjectsFromArray:_quadItems];
    } else {
        for (QuadItem *item in _quadItems) {
            if (CGRectContainsPoint(searchRect, item.pt)) {
                [array addObject:item];
            }
        }
    }
    if(_childrens != nil && _childrens.count == 4) {
        for (ClusterQuadtree *children in _childrens) {
            [array addObjectsFromArray:[children searchInRect:searchRect]];
        }
    }
    return array;
}

@end
