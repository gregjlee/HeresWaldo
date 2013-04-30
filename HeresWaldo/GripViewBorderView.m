//
//  GripViewBorderView.m
//  CropImageTest
//
//  Created by Gregory Lee on 1/25/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import "GripViewBorderView.h"
#define kResizableViewGlobalInset 5.0

#define kResizableViewDefaultMinWidth 48.0
#define kResizableViewDefaultMinHeight 48.0
#define kBorderSize 20.0
#define kDotSize 10.0
#define kBorderDotSize 15.0


@implementation GripViewBorderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        borderRect=CGRectInset(self.bounds,  kBorderSize, kBorderSize);
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    borderRect=CGRectInset(self.bounds,  kBorderSize, kBorderSize);
    CGSize gridSize=CGSizeMake(borderRect.size.width/3, borderRect.size.height/3);
    CGFloat lineWidth=1;
    //all lines will be drawin 10 pts wide
    CGContextSetLineWidth(context, lineWidth);
    
    //set stroke color to light gray
    [[UIColor whiteColor] setStroke];
    
    
    //    draw horizontal lines
    for(int i=1;i<3;i++){
        CGContextMoveToPoint(context, kBorderSize, i*gridSize.height+kBorderSize);
        CGContextAddLineToPoint(context, rect.size.width-kBorderSize, i*gridSize.height+kBorderSize);
        CGContextStrokePath(context);
    }
    //    draw vertical lines
    for(int i=1;i<3;i++){
        CGContextMoveToPoint(context, i*gridSize.width+kBorderSize, kBorderSize);
        CGContextAddLineToPoint(context, i*gridSize.width+kBorderSize, rect.size.height-kBorderSize);
        CGContextStrokePath(context);
    }
    
    CGContextSaveGState(context);
    
    // (1) Draw the bounding box.
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextAddRect(context, borderRect);
    CGContextStrokePath(context);
    
    // (2) Calculate the bounding boxes for each of the anchor points.
    CGRect upperLeft = CGRectMake(kBorderDotSize, kBorderDotSize, kDotSize, kDotSize);
    CGRect upperRight = CGRectMake(self.bounds.size.width - (kBorderDotSize+kDotSize), kBorderDotSize, kDotSize, kDotSize);
    CGRect lowerRight = CGRectMake(self.bounds.size.width - (kBorderDotSize+kDotSize), self.bounds.size.height - (kBorderDotSize+kDotSize), kDotSize, kDotSize);
    CGRect lowerLeft = CGRectMake(kBorderDotSize, self.bounds.size.height - (kBorderDotSize+kDotSize), kDotSize, kDotSize);
    CGRect upperMiddle = CGRectMake((self.bounds.size.width - kBorderDotSize)/2, kBorderDotSize, kDotSize, kDotSize);
    CGRect lowerMiddle = CGRectMake((self.bounds.size.width - kBorderDotSize)/2, self.bounds.size.height - (kBorderDotSize+kDotSize), kDotSize, kDotSize);
    CGRect middleLeft = CGRectMake(kBorderDotSize, (self.bounds.size.height - kBorderDotSize)/2, kDotSize, kDotSize);
    CGRect middleRight = CGRectMake(self.bounds.size.width - (kBorderDotSize+kDotSize), (self.bounds.size.height - kBorderDotSize)/2, kDotSize, kDotSize);
    
    // (3) Create the gradient to paint the anchor points.
    CGFloat colors [] = {
        0.4, 0.8, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    // (4) Set up the stroke for drawing the border of each of the anchor points.
    CGContextSetLineWidth(context, 1);
    CGContextSetShadow(context, CGSizeMake(0.5, 0.5), 1);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // (5) Fill each anchor point using the gradient, then stroke the border.
    CGRect allPoints[8] = { upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight };
    for (NSInteger i = 0; i < 8; i++) {
        CGRect currPoint = allPoints[i];
        CGContextSaveGState(context);
        CGContextAddEllipseInRect(context, currPoint);
        CGContextClip(context);
        CGPoint startPoint = CGPointMake(CGRectGetMidX(currPoint), CGRectGetMinY(currPoint));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(currPoint), CGRectGetMaxY(currPoint));
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        CGContextRestoreGState(context);
        CGContextStrokeEllipseInRect(context, CGRectInset(currPoint, 1, 1));
    }
    CGGradientRelease(gradient), gradient = NULL;
    CGContextRestoreGState(context);
}

@end
