//
//  ResizableView.m
//  CropImageTest
//
//  Created by Gregory Lee on 1/25/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import "ResizableView.h"
#import "GripViewBorderView.h"
#define kResizableViewGlobalInset 5.0

#define kResizableViewDefaultMinWidth 96.0
#define kResizableViewDefaultMinHeight 96.0
#define kResizableViewInteractiveBorderSize 10.0
#define kBorderSize 20.0

static ResizableViewAnchorPoint ResizableViewNoResizeAnchorPoint = { 0.0, 0.0, 0.0, 0.0 };
static ResizableViewAnchorPoint ResizableViewUpperLeftAnchorPoint = { 1.0, 1.0, -1.0, 1.0 };
static ResizableViewAnchorPoint ResizableViewMiddleLeftAnchorPoint = { 1.0, 0.0, 0.0, 1.0 };
static ResizableViewAnchorPoint ResizableViewLowerLeftAnchorPoint = { 1.0, 0.0, 1.0, 1.0 };
static ResizableViewAnchorPoint ResizableViewUpperMiddleAnchorPoint = { 0.0, 1.0, -1.0, 0.0 };
static ResizableViewAnchorPoint ResizableViewUpperRightAnchorPoint = { 0.0, 1.0, -1.0, -1.0 };
static ResizableViewAnchorPoint ResizableViewMiddleRightAnchorPoint = { 0.0, 0.0, 0.0, -1.0 };
static ResizableViewAnchorPoint ResizableViewLowerRightAnchorPoint = { 0.0, 0.0, 1.0, -1.0 };
static ResizableViewAnchorPoint ResizableViewLowerMiddleAnchorPoint = { 0.0, 0.0, 1.0, 0.0 };

@implementation ResizableView
@synthesize contentView, minWidth, minHeight, preventsPositionOutsideSuperview, delegate;
- (id)initWithFrame:(CGRect)frame {
    
    frame=CGRectInset(frame, -(kResizableViewInteractiveBorderSize*2+kResizableViewGlobalInset), -( kResizableViewInteractiveBorderSize*2+kResizableViewGlobalInset));
    boundaryRect=frame;
    NSLog(@"boundary height %f width %f",frame.size.height,frame.size.width);
    if ((self = [super initWithFrame:frame])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupDefaultAttributes];
    }
    return self;
}


- (void)setupDefaultAttributes {
    borderView = [[GripViewBorderView alloc] initWithFrame:CGRectInset(self.bounds, kResizableViewGlobalInset, kResizableViewGlobalInset)];
    [borderView setHidden:YES];
    [self addSubview:borderView];
    self.minWidth = kResizableViewDefaultMinWidth;
    self.minHeight = kResizableViewDefaultMinHeight;
    self.preventsPositionOutsideSuperview = YES;
    [self setAlpha:1.0];
}

- (void)setContentView:(UIView *)newContentView {
    [contentView removeFromSuperview];
    contentView = newContentView;
    //[self setFrame:contentView.frame];
    contentView.frame =CGRectInset(self.bounds, kResizableViewInteractiveBorderSize*2+kResizableViewGlobalInset,  kResizableViewInteractiveBorderSize*2+kResizableViewGlobalInset);
    [self addSubview:contentView];
    
    // Ensure the border view is always on top by removing it and adding it to the end of the subview list.
    [borderView removeFromSuperview];
    [self addSubview:borderView];
}

- (void)setFrame:(CGRect)newFrame {
    [super setFrame:newFrame];
    contentView.frame = CGRectInset(self.bounds, kResizableViewInteractiveBorderSize*2+kResizableViewGlobalInset,  kResizableViewInteractiveBorderSize*2+kResizableViewGlobalInset);
    borderView.frame = CGRectInset(self.bounds, kResizableViewGlobalInset, kResizableViewGlobalInset);
    [borderView setNeedsDisplay];
}



static CGFloat SPDistanceBetweenTwoPoints(CGPoint point1, CGPoint point2) {
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy);
};

typedef struct CGPointResizableViewAnchorPointPair {
    CGPoint point;
    ResizableViewAnchorPoint anchorPoint;
} CGPointResizableViewAnchorPointPair;

- (ResizableViewAnchorPoint)anchorPointForTouchLocation:(CGPoint)touchPoint {
    // (1) Calculate the positions of each of the anchor points.
    CGPointResizableViewAnchorPointPair upperLeft = { CGPointMake(0.0, 0.0), ResizableViewUpperLeftAnchorPoint };
    CGPointResizableViewAnchorPointPair upperMiddle = { CGPointMake(self.bounds.size.width/2, 0.0), ResizableViewUpperMiddleAnchorPoint };
    CGPointResizableViewAnchorPointPair upperRight = { CGPointMake(self.bounds.size.width, 0.0), ResizableViewUpperRightAnchorPoint };
    CGPointResizableViewAnchorPointPair middleRight = { CGPointMake(self.bounds.size.width, self.bounds.size.height/2), ResizableViewMiddleRightAnchorPoint };
    CGPointResizableViewAnchorPointPair lowerRight = { CGPointMake(self.bounds.size.width, self.bounds.size.height), ResizableViewLowerRightAnchorPoint };
    CGPointResizableViewAnchorPointPair lowerMiddle = { CGPointMake(self.bounds.size.width/2, self.bounds.size.height), ResizableViewLowerMiddleAnchorPoint };
    CGPointResizableViewAnchorPointPair lowerLeft = { CGPointMake(0, self.bounds.size.height), ResizableViewLowerLeftAnchorPoint };
    CGPointResizableViewAnchorPointPair middleLeft = { CGPointMake(0, self.bounds.size.height/2), ResizableViewMiddleLeftAnchorPoint };
    CGPointResizableViewAnchorPointPair centerPoint = { CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2), ResizableViewNoResizeAnchorPoint };
    
    // (2) Iterate over each of the anchor points and find the one closest to the user's touch.
    CGPointResizableViewAnchorPointPair allPoints[9] = { upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight, centerPoint };
    CGFloat smallestDistance = MAXFLOAT; CGPointResizableViewAnchorPointPair closestPoint = centerPoint;
    for (NSInteger i = 0; i < 9; i++) {
        CGFloat distance = SPDistanceBetweenTwoPoints(touchPoint, allPoints[i].point);
        if (distance < smallestDistance) {
            closestPoint = allPoints[i];
            smallestDistance = distance;
        }
    }
    return closestPoint.anchorPoint;
}

- (BOOL)isResizing {
    return (anchorPoint.adjustsH || anchorPoint.adjustsW || anchorPoint.adjustsX || anchorPoint.adjustsY);
}

-(void)setScrollViewEnabled:(BOOL)enabled{
    UIScrollView *scrollView=(UIScrollView*)self.superview.superview;
    [scrollView setScrollEnabled:enabled];
}
-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *view=[super hitTest:point withEvent:event];
    if (view==self) {
        [self setScrollViewEnabled:NO];
        [self showEditingHandles];
        NSLog(@"hit borderview");
    }
    else {NSLog(@"no hitborder");
        [self hideEditingHandles];
    }
    return view;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've begun our editing session.
    if (self.delegate && [self.delegate respondsToSelector:@selector(ResizableViewDidBeginEditing:)]) {
        [self.delegate resizableViewDidBeginEditing:self];
    }
    
    [borderView setHidden:NO];
    [self setScrollViewEnabled:NO];
    UITouch *touch = [touches anyObject];
    anchorPoint = [self anchorPointForTouchLocation:[touch locationInView:self]];
    
    // When resizing, all calculations are done in the superview's coordinate space.
    touchStart = [touch locationInView:self.superview];
    if (![self isResizing]) {
        // When translating, all calculations are done in the view's coordinate space.
        touchStart = [touch locationInView:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isResizing]) {
        [self resizeUsingTouchLocation:[[touches anyObject] locationInView:self.superview]];
    } else {
        [self translateUsingTouchLocation:[[touches anyObject] locationInView:self]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.
    if (self.delegate && [self.delegate respondsToSelector:@selector(resizableViewDidEndEditing:)]) {
        [self.delegate resizableViewDidEndEditing:self];
    }
    [self setScrollViewEnabled:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.
    if (self.delegate && [self.delegate respondsToSelector:@selector(resizableViewDidEndEditing:)]) {
        [self.delegate resizableViewDidEndEditing:self];
    }
    [self setScrollViewEnabled:YES];
}

- (void)showEditingHandles {
    [borderView setHidden:NO];
    [self setAlpha:0.6];
}

- (void)hideEditingHandles {
    [borderView setHidden:YES];
    [self setAlpha:1.0];
}

- (void)resizeUsingTouchLocation:(CGPoint)touchPoint {
    // (1) Update the touch point if we're outside the superview.
    if (self.preventsPositionOutsideSuperview) {
        CGFloat border =  kResizableViewGlobalInset + kResizableViewInteractiveBorderSize/2;
        border=0;
        if (touchPoint.x < border) {
            touchPoint.x = border;
        }
        if (touchPoint.x > self.superview.bounds.size.width - border) {
            touchPoint.x = self.superview.bounds.size.width - border;
        }
        if (touchPoint.y < border) {
            touchPoint.y = border;
        }
        if (touchPoint.y > self.superview.bounds.size.height - border) {
            touchPoint.y = self.superview.bounds.size.height - border;
        }
    }
    
    // (2) Calculate the deltas using the current anchor point.
    CGFloat deltaW = anchorPoint.adjustsW * (touchStart.x - touchPoint.x);
    CGFloat deltaX = anchorPoint.adjustsX * (-1.0 * deltaW);
    CGFloat deltaH = anchorPoint.adjustsH * (touchPoint.y - touchStart.y);
    CGFloat deltaY = anchorPoint.adjustsY * (-1.0 * deltaH);
    
    // (3) Calculate the new frame.
    CGFloat newX = self.frame.origin.x + deltaX;
    CGFloat newY = self.frame.origin.y + deltaY;
    CGFloat newWidth = self.frame.size.width + deltaW;
    CGFloat newHeight = self.frame.size.height + deltaH;
    
    // (4) If the new frame is too small, cancel the changes.
    NSLog(@"new width %f height %f",newWidth,newHeight);
    if (newWidth < self.minWidth) {
        NSLog(@"min width %f",newWidth);
        newWidth = self.frame.size.width;
        newX = self.frame.origin.x;
    }
    if (newHeight < self.minHeight) {
        newHeight = self.frame.size.height;
        newY = self.frame.origin.y;
    }
    
    // (5) Ensure the resize won't cause the view to move offscreen.
    if (self.preventsPositionOutsideSuperview) {
        CGFloat rectMaxXEdge=self.superview.bounds.origin.x+self.superview.bounds.size.width;
        CGFloat rectMaxYEdge=self.superview.bounds.origin.y+self.superview.bounds.size.height;
        CGFloat rightSide=newX+newWidth;
        CGFloat leftLimit=self.superview.bounds.origin.x+self.minWidth;
        CGFloat rightLimit=self.superview.bounds.size.width-self.minWidth;
        CGFloat botSide=newY+newHeight;
        CGFloat topLimit=self.superview.bounds.origin.y+self.minHeight;
        CGFloat botLimit=self.superview.bounds.size.height-self.minHeight;
        if ((newX < self.superview.bounds.origin.x)&&(rightSide<leftLimit)) {
            newWidth=self.frame.size.width;
            // Calculate how much to grow the width by such that the new X coordintae will align with the superview.
//            deltaW = self.frame.origin.x - self.superview.bounds.origin.x;
//            newWidth = self.frame.size.width + deltaW;
//            newX = self.superview.bounds.origin.x;
        }
        if ((rightSide > rectMaxXEdge)&&(newX>rightLimit)) {
            newX=self.frame.origin.x;
            newWidth = self.frame.size.width;
        }
        if ((newY < self.superview.bounds.origin.y)&&(botSide<topLimit)) {
            newHeight=self.frame.size.height;
            // Calculate how much to grow the width by such that the new X coordintae will align with the superview.
            //            deltaW = self.frame.origin.x - self.superview.bounds.origin.x;
            //            newWidth = self.frame.size.width + deltaW;
            //            newX = self.superview.bounds.origin.x;
        }
        if ((botSide > rectMaxYEdge)&&(newY>botLimit)) {
            newY=self.frame.origin.y;
            newHeight = self.frame.size.height;
        }
    }
    
    self.frame = CGRectMake(newX, newY, newWidth, newHeight);
    touchStart = touchPoint;
}
- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - touchStart.x, self.center.y + touchPoint.y - touchStart.y);
    if (self.preventsPositionOutsideSuperview) {
        // Ensure the translation won't cause the view to move offscreen.
        CGFloat midPointX = 0;//CGRectGetMidX(self.bounds);
        if (newCenter.x > self.superview.bounds.size.width - midPointX) {
            newCenter.x = self.superview.bounds.size.width - midPointX;
        }
        if (newCenter.x < midPointX) {
            newCenter.x = midPointX;
        }
        CGFloat midPointY = 0;//CGRectGetMidY(self.bounds);
        if (newCenter.y > self.superview.bounds.size.height - midPointY) {
            newCenter.y = self.superview.bounds.size.height - midPointY;
        }
        if (newCenter.y < midPointY) {
            newCenter.y = midPointY;
        }
    }
    self.center = newCenter;
}



- (void)dealloc {
    [contentView removeFromSuperview];
}

@end
