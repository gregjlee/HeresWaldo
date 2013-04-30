//
//  EditWaldoViewController.m
//  HeresWaldo
//
//  Created by Gregory Lee on 2/5/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import "EditWaldoViewController.h"
#import "ImageViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface EditWaldoViewController ()

@end

@implementation EditWaldoViewController
@synthesize imageView,wipeAwayView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [_scrollView zoomToRect:zoomRect animated:NO];
    [wipeAwayView resizeEraserAfterZoomWithScale:_scrollView.zoomScale];
    [_scrollView setMinimumZoomScale:_scrollView.zoomScale];
    [_scrollView setMaximumZoomScale:_scrollView.zoomScale*2];

    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    

    imageView.image=_bgImage;
    
    [self.scrollView setContentSize:imageView.frame.size];
   [self.scrollView setMaximumZoomScale:2.0];
    
    [imageView setUserInteractionEnabled:YES];
    
    wipeAwayView=[[WipeAwayView alloc]initWithFrame:_figureFrame];
    [wipeAwayView newMaskWithImage:_figureImage eraseSpeed:.25];
    [wipeAwayView setUserInteractionEnabled:YES];
    [imageView addSubview:wipeAwayView];
    
    isZoomLeaving=NO;
    
    filtersScrollView = [[FilterScrollView alloc] initWithFrame:CGRectMake(0, 400, self.view.bounds.size.width, 90)];
    //[filtersScrollView loadFiltersForImage:_figureImage];
    //[self.view addSubview:filtersScrollView];
    
    
    
    // Do any additional setup after loading the view from its nib.
}



-(void)setUpBackGroundWith:(UIImage *)bgImage zoomRect:(CGRect)leZoomRect{
    zoomRect=leZoomRect;
    _bgImage=bgImage;
}
-(void)setUpFigureWith:(UIImage *)figureImage frame:(CGRect)figureFrame OriginalFigure:(UIImage *)originalFigureImage{
    _figureImage=figureImage;
    _figureFrame=figureFrame;
    _originalFigureImage=originalFigureImage;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender {
    NSLog(@"edit doneButton");
    [_scrollView setMinimumZoomScale:1.0];
    isZoomLeaving=YES;
    [_scrollView zoomToRect:_scrollView.bounds animated:YES];
    
}

- (IBAction)undo:(id)sender {
    _figureImage=_originalFigureImage;
    [wipeAwayView removeFromSuperview];
    wipeAwayView=[[WipeAwayView alloc]initWithFrame:_figureFrame];
    [wipeAwayView newMaskWithImage:_figureImage eraseSpeed:.25];
    [wipeAwayView setUserInteractionEnabled:YES];
    [imageView addSubview:wipeAwayView];
}

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return [scrollView.subviews objectAtIndex:0];
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    UIView *subView=[scrollView.subviews objectAtIndex:0];
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
    
}
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
    
    if (isZoomLeaving) {
        NSLog(@"zoom is leaving");
        isZoomLeaving=NO;
        NSArray *viewControllers=self.navigationController.viewControllers;
        ImageViewController *controller= (ImageViewController*)[viewControllers objectAtIndex:viewControllers.count-2];
        [controller setUpdatedFigureImage:[wipeAwayView currentImage] ];
        [self.navigationController popViewControllerAnimated:NO];
    }
    else{
        
        [wipeAwayView resizeEraserAfterZoomWithScale:scale];
    }
    
}

@end
