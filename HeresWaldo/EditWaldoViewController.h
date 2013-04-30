//
//  EditWaldoViewController.h
//  HeresWaldo
//
//  Created by Gregory Lee on 2/5/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WipeAwayView.h"
#import "FilterScrollView.h"
@interface EditWaldoViewController : UIViewController<UIScrollViewDelegate>{
    CGRect figureFrame;
    CGRect zoomRect;
    BOOL isZoomLeaving;
    CIContext *context;
    NSMutableArray *filters;
    FilterScrollView *filtersScrollView;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)done:(id)sender;
- (IBAction)undo:(id)sender;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet FilterScrollView *filtersScrollView;
@property (nonatomic, strong) UIImage *bgImage;
@property (nonatomic, strong) UIImage *figureImage;
@property (nonatomic, strong) UIImage *originalFigureImage;
@property (nonatomic,strong) WipeAwayView *wipeAwayView;
@property (nonatomic,assign)CGRect figureFrame;

-(void)setUpBackGroundWith:(UIImage*)bgImage zoomRect:(CGRect)leZoomRect;
-(void)setUpFigureWith:(UIImage*)figureImage frame:(CGRect)figureFrame OriginalFigure:(UIImage*)originalFigureImage;
@end
