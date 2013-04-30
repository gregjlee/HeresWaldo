//
//  ImageViewController.h
//  CropImageSample
//
//  Created by Kishikawa Katsumi on 11/11/14.
//  Copyright (c) 2011 Kishikawa Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResizableView.h"
#import "WipeAwayView.h"
#import "LASharekit.h"
#import "FilterScrollView.h"
@interface ImageViewController : UIViewController <UIScrollViewDelegate,UIGestureRecognizerDelegate,ResizableViewDelegate,UIActionSheetDelegate,UIDocumentInteractionControllerDelegate>{
    UIImageView *imageView;
    UIImage *image;
    
    ResizableView *resizableView;
    WipeAwayView *imageMask;
    UIImageView *figureView;
    UIImageView *finalView;
    UIActionSheet *sheet;
    LASharekit *laSharekit;
    BOOL isZoomingEdit;
    BOOL isZoomArriving;
    CIContext *context;
    NSMutableArray *filters;
    FilterScrollView *filtersScrollView;
    NSInteger selectedFilterIndex;
    CGRect zoomRect;
    BOOL isFigureInside;
    
}
@property(nonatomic, strong)     UIDocumentInteractionController* docController;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *plainFigureImage;
@property (nonatomic, strong) UIImage *originalFigureImage;
@property (nonatomic,weak) IBOutlet FilterScrollView *filtersScrollView;
@property (strong, nonatomic) IBOutlet UIView *filterContainerView;
@property (strong, nonatomic) IBOutlet UIButton *filterButton;

- (IBAction)selectWaldo:(id)sender;
- (IBAction)editWaldo:(id)sender;
- (IBAction)openFilters:(id)sender;
- (IBAction)closeFilters:(id)sender;
- (IBAction)flipWaldo:(id)sender;

- (IBAction)wipeWaldo:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)restart:(id)sender;
- (IBAction)share:(id)sender;
- (IBAction)cancel:(id)sender;

-(void)setUpdatedFigureImage:(UIImage *)plainImage;
    @end
