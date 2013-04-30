//
//  ResizableView.h
//  CropImageTest
//
//  Created by Gregory Lee on 1/25/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef struct ResizableViewAnchorPoint {
    CGFloat adjustsX;
    CGFloat adjustsY;
    CGFloat adjustsH;
    CGFloat adjustsW;
} ResizableViewAnchorPoint;

@protocol ResizableViewDelegate;
@class GripViewBorderView;

@interface ResizableView : UIView{
    GripViewBorderView *borderView;
    UIView *contentView;
    CGPoint touchStart;
    CGFloat minWidth;
    CGFloat minHeight;
    CGRect boundaryRect;
    
    // Used to determine which components of the bounds we'll be modifying, based upon where the user's touch started.
    ResizableViewAnchorPoint anchorPoint;
    
    id <ResizableViewDelegate> delegate;
}

@property (nonatomic, strong) id <ResizableViewDelegate> delegate;

// Will be retained as a subview.
@property (nonatomic, strong) UIView *contentView;

// Default is 48.0 for each.
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;

// Defaults to YES. Disables the user from dragging the view outside the parent view's bounds.
@property (nonatomic) BOOL preventsPositionOutsideSuperview;

- (void)hideEditingHandles;
- (void)showEditingHandles;

@end

@protocol ResizableViewDelegate<NSObject>
@optional

// Called when the resizable view receives touchesBegan: and activates the editing handles.
- (void)resizableViewDidBeginEditing:(ResizableView *)resizableView;

// Called when the resizable view receives touchesEnded: or touchesCancelled:
- (void)resizableViewDidEndEditing:(ResizableView *)resizableView;

@end
