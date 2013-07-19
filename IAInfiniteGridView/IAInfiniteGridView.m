//
//  IAInfiniteGridView.m
//  Infinite
//
//  Created by Ikhsan Assaat on 10/1/12.
//  Copyright (c) 2012 3kunci. All rights reserved.
//

#import "IAInfiniteGridView.h"

@interface IAInfiniteGridView()

@property (nonatomic) NSInteger currentIndex;
@property (strong, nonatomic) NSMutableArray *visibleGrids;
@property (strong, nonatomic) NSMutableArray *gridReusableQueue;
@property (strong, nonatomic) UIView *containerView;
@property (nonatomic, assign) NSInteger currentPageIndex;

@end

@implementation IAInfiniteGridView

- (void)initialization {
    self.visibleGrids = [[NSMutableArray alloc] init];
    self.gridReusableQueue = [[NSMutableArray alloc] init];
    self.containerView = [[UIView alloc] init];
    self.circular = NO;
    self.currentIndex = 0;
    self.delegate = self;
    
    [self addSubview:self.containerView];
    
    [self setShowsHorizontalScrollIndicator:NO];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initialization];        
    }
    return self;
}

- (void)awakeFromNib {
	[self calculateContentSize];
}

- (void)calculateContentSize {
	if (!self.dataSource) return;
	
	NSUInteger totalGrids = [self.dataSource numberOfGridsInInfiniteGridView:self];
	CGSize totalGridSize = CGSizeMake(0.0, self.bounds.size.height);
	for (int i = 0; i < totalGrids; i++) {
		totalGridSize.width += [self.dataSource infiniteGridView:self widthForIndex:i];
	}
	
	self.contentSize = CGSizeMake(totalGridSize.width * 2, totalGridSize.height);
	self.containerView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // If not dragging, send event to next responder
    if (!self.dragging) {
        UITouch *touch = [touches anyObject];
        CGPoint newPoint = [touch locationInView:self];
        UIView *result = [self gridViewAtPoint:newPoint];
        if (self.gridDelegate && [self.gridDelegate respondsToSelector:@selector(infiniteGridView:didSelectGridAtIndex:)]) {
            [self.gridDelegate infiniteGridView:self didSelectGridAtIndex:result.tag];
        }
        [self.nextResponder touchesEnded: touches withEvent:event]; 
    } else {
        [super touchesEnded: touches withEvent: event];
    }
}

- (void)jumpToIndex:(NSInteger)gridIndex {
    if ((self.isCircular && gridIndex < 0) &&
		(self.isCircular && gridIndex >= [self.dataSource numberOfGridsInInfiniteGridView:self]))
		return;
	
	[self setContentOffset:CGPointMake(0, self.contentOffset.y) animated:NO];
	
	CGRect visibleBounds = [self convertRect:self.bounds toView:self.containerView];
	CGFloat minimumVisibleX = CGRectGetMinX(visibleBounds);
	CGFloat maximumVisibleX = CGRectGetMaxX(visibleBounds);
	
	[self.visibleGrids removeAllObjects];
	self.currentIndex = gridIndex;
	
	[self tileGridsFromMinX:minimumVisibleX toMaxX:maximumVisibleX];
}

- (UIView *)getViewFromVisibleCellsWithIndex:(NSInteger)gridIndex {
	__block UIView *gridView = nil;
	[self.visibleGrids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UIView *visibleGridView = (UIView *)obj;
		
		if (visibleGridView.tag == gridIndex) {
			gridView = visibleGridView;
			*stop = YES;
		}
	}];
	
	return gridView;
}

- (id)dequeueReusableGrid {
    id grid = [self.gridReusableQueue lastObject];
    [self.gridReusableQueue removeObject:grid];
    return grid;
}

- (void)setDataSource:(id<IAInfiniteGridDataSource>)dataSource {
	_dataSource = dataSource;
	[self calculateContentSize];
}

- (void)reloadData {
	if (!self.dataSource) return;
	
	[self calculateContentSize];
	[self jumpToIndex:0];
}

#pragma mark - Layout

// recenter content periodically
- (void)recenterIfNecessary {
    CGPoint currentOffset = self.contentOffset;
    CGFloat contentWidth = self.contentSize.width;
    CGFloat centerOffsetX = (contentWidth - self.bounds.size.width) / 2.0;
    CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
    
    if (distanceFromCenter > (contentWidth / 4.0)) {
        self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        
        for (UIView *grid in self.visibleGrids) {
            CGPoint center = [self.containerView convertPoint:grid.center toView:self];
            center.x += (centerOffsetX - currentOffset.x);
            grid.center = [self convertPoint:center toView:self.containerView];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self recenterIfNecessary];
    
    // tile content in visible bounds
    CGRect visibleBounds = [self convertRect:self.bounds toView:self.containerView];
    CGFloat minimumVisibleX = CGRectGetMinX(visibleBounds);
    CGFloat maximumVisibleX = CGRectGetMaxX(visibleBounds);
    
    [self tileGridsFromMinX:minimumVisibleX toMaxX:maximumVisibleX];
}

#pragma mark - Grid Tiling

- (UIView *)insertGridWithIndex:(NSInteger)index {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(infiniteGridView:forIndex:)]) {
        UIView *viewFromDelegate = [self.dataSource infiniteGridView:self forIndex:index];
        viewFromDelegate.tag = index;
        [self.containerView addSubview:viewFromDelegate];
        
        return viewFromDelegate;
    }
    
    return nil;
}

- (CGFloat)placeNewGridOnRight:(CGFloat)rightEdge {
    if ([self.visibleGrids count] > 0) {
        UIView *lastGrid = [self.visibleGrids lastObject];
        NSInteger nextIndex = lastGrid.tag + 1;
        if ([self isCircular])
            nextIndex = (nextIndex >= [self.dataSource numberOfGridsInInfiniteGridView:self]) ? 0 : nextIndex;
        self.currentIndex = nextIndex;
    }
    
    UIView *grid = [self insertGridWithIndex:self.currentIndex];
    [self.visibleGrids addObject:grid];
    
    CGRect frame = grid.frame;
    frame.origin.x = rightEdge;
    frame.origin.y = 0; //self.containerView.bounds.size.height - frame.size.height;
    grid.frame = frame;
    
    return CGRectGetMaxX(frame);
}

- (CGFloat)placeNewGridOnLeft:(CGFloat)leftEdge {
    UIView *firstGrid = [self.visibleGrids objectAtIndex:0];
    NSInteger previousIndex = firstGrid.tag - 1;
    if ([self isCircular])
        previousIndex = (previousIndex < 0) ? [self.dataSource numberOfGridsInInfiniteGridView:self]-1 : previousIndex;
    self.currentIndex = previousIndex;
    
    UIView *grid = [self insertGridWithIndex:self.currentIndex];
    [self.visibleGrids insertObject:grid atIndex:0];
    
    CGRect frame = grid.frame;
    frame.origin.x = leftEdge - frame.size.width;
    frame.origin.y = 0; //self.containerView.bounds.size.height - frame.size.height;
    grid.frame = frame;
    
    return CGRectGetMinX(frame);
}

- (void)tileGridsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX {
    if ([self.visibleGrids count] == 0) {
        [self placeNewGridOnRight:minimumVisibleX];
    }
    
    UIView *lastGrid = [self.visibleGrids lastObject];
    CGFloat rightEdge = CGRectGetMaxX(lastGrid.frame);
    while (rightEdge < maximumVisibleX) {
        rightEdge = [self placeNewGridOnRight:rightEdge];
    }
    
    UIView *firstGrid = [self.visibleGrids objectAtIndex:0];
    CGFloat leftEdge = CGRectGetMinX(firstGrid.frame);
    while (leftEdge > minimumVisibleX) {
        leftEdge = [self placeNewGridOnLeft:leftEdge];
    }
    
    lastGrid = [self.visibleGrids lastObject];
    while (lastGrid.frame.origin.x > maximumVisibleX) {
        [lastGrid removeFromSuperview];
        [self.visibleGrids removeLastObject];
        [self.gridReusableQueue addObject:lastGrid];
        
        lastGrid = [self.visibleGrids lastObject];
    }
    
    firstGrid = [self.visibleGrids objectAtIndex:0];
    while (CGRectGetMaxX(firstGrid.frame) < minimumVisibleX) {
        [firstGrid removeFromSuperview];
        [self.visibleGrids removeObjectAtIndex:0];
        [self.gridReusableQueue addObject:firstGrid];
        
        firstGrid = [self.visibleGrids objectAtIndex:0];
    }
}

- (UIView *)gridViewAtPoint:(CGPoint)point {
    __block UIView *gridView = nil;
    [self.visibleGrids enumerateObjectsUsingBlock:^(UIView *visibleGridView, NSUInteger idx, BOOL *stop) {        
        if (CGRectContainsPoint(visibleGridView.frame, point)) {
            gridView = visibleGridView;
            *stop = YES;
        }
    }];
    
    return gridView;
}

#pragma mark - Scroll View Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.gridDelegate respondsToSelector:@selector(infiniteGridView:didScrollToPage:)]) {
        UIView *grid = [self gridViewAtPoint:scrollView.contentOffset];
        if (grid && grid.tag != self.currentPageIndex) {
            self.currentPageIndex = grid.tag;
            [self.gridDelegate infiniteGridView:self didScrollToPage:grid.tag];
        }
    }
}

// custom paging
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (self.isPaging) {
        CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:[self superview]];
        
        UIView *grid = [self gridViewAtPoint:scrollView.contentOffset];
        
        CGPoint destinationPoint;
        if (velocity.x > 0) {
            destinationPoint = [grid convertPoint:CGPointMake(0.0, 0.0) toView:scrollView];
        } else {
            destinationPoint = [grid convertPoint:CGPointMake(grid.bounds.size.width, 0.0) toView:scrollView];
        }
        
        [scrollView setContentOffset:destinationPoint animated:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.isPaging) {
        if (!decelerate) {
            UIView *grid = [self gridViewAtPoint:scrollView.contentOffset];
            CGPoint localPoint = [scrollView convertPoint:scrollView.contentOffset toView:grid];
            
            CGPoint destinationPoint;
            if (localPoint.x > (grid.bounds.size.width / 2)) {
                destinationPoint = [grid convertPoint:CGPointMake(grid.bounds.size.width, 0.0) toView:scrollView];
            } else {
                destinationPoint = [grid convertPoint:CGPointMake(0.0, 0.0) toView:scrollView];
            }
            [UIView animateWithDuration:.15 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{scrollView.contentOffset = destinationPoint;} completion:nil];
        }
    }
}

@end
