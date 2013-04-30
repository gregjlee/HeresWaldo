//
//  ImageViewController.m
//  CropImageSample
//
//  Created by Kishikawa Katsumi on 11/11/14.
//  Copyright (c) 2011 Kishikawa Katsumi. All rights reserved.
//

#import "ImageViewController.h"
#import "EditWaldoViewController.h"

#define SaveToLibrary 0
#define Instagram 1
#define Facebook 2
#define Twitter 3
#define Email 4
@implementation ImageViewController

@synthesize imageView;
@synthesize image;


#pragma mark - View lifecycle

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    isZoomArriving=YES;
    [filtersScrollView applyFilterWithIndex:selectedFilterIndex];
    [_scrollView zoomToRect:_scrollView.bounds animated:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Add Waldo", nil);
    isZoomingEdit=NO;
    [self initialFigure];
    laSharekit=[[LASharekit alloc]init:self];
    selectedFilterIndex=0;
    
    CGRect filterFrame=_filterContainerView.frame;
    filterFrame.origin.y=[[UIScreen mainScreen] bounds].size.height;
    NSLog(@"view screen height %f",filterFrame.origin.y);
    _filterContainerView.frame=filterFrame;
    [self.view addSubview:_filterContainerView];
    CGPoint filterCenterPoint=[[_filterContainerView.subviews objectAtIndex:1]center];
    filtersScrollView =[[FilterScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 90) bgView:imageView FigureView:figureView filterButton:_filterButton];
    filtersScrollView.center=filterCenterPoint;
    [_filterContainerView addSubview:filtersScrollView];
    
    
}
-(void)initialFigure{
    if (figureView) [figureView removeFromSuperview];
    if(resizableView) [resizableView removeFromSuperview];
    if (imageMask) [imageMask removeFromSuperview];
    if (finalView) [finalView removeFromSuperview];
    UIImage *imageFigure=[UIImage imageNamed:@"lawlence.png"] ;
    _plainFigureImage=imageFigure;
    _originalFigureImage=imageFigure;
    CGFloat ratio=imageFigure.size.height/imageFigure.size.width;
    CGFloat width=100;
    CGFloat height=width*ratio;
    height=roundf(height);
    
    figureView=[[UIImageView alloc]initWithImage:imageFigure];
    figureView.frame=CGRectMake(50, 50, width, height);
    resizableView=[[ResizableView alloc]initWithFrame:figureView.frame];
    [resizableView setDelegate:self];
    [resizableView setContentView:figureView];
    [imageView setUserInteractionEnabled:YES];
    [imageView setBackgroundColor:[UIColor lightGrayColor]];
    imageView.image=image;
    [imageView setClipsToBounds:YES];
    [self.imageView addSubview:resizableView];
    [self.scrollView setMaximumZoomScale:2.0];
    [self.scrollView setContentSize:imageView.frame.size];
    [self.scrollView setUserInteractionEnabled:YES];
    
    imageMask=[[WipeAwayView alloc]initWithFrame:CGRectMake(50, 200, 200, 200)];
    [imageMask newMaskWithImage:imageFigure eraseSpeed:.25];
    [imageMask setUserInteractionEnabled:YES];
    [imageView addSubview:imageMask];
    [imageMask setAlpha:0.6];
    [imageMask setHidden:YES];

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([resizableView hitTest:[touch locationInView:resizableView] withEvent:nil]) {
        
        NSLog(@"resize gesture touch");
        return NO;
    }
    NSLog(@"touch bg");
    return YES;
}

-(void)resizableViewDidBeginEditing:(ResizableView *)resizableView{
    NSLog(@"resize begin edit");
}

-(void)resizableViewDidEndEditing:(ResizableView *)resizableView{
    NSLog(@"resize end edit");
}


- (void)hideEditingHandles {
    // We only want the gesture recognizer to end the editing session on the last
    // edited view. We wouldn't want to dismiss an editing session in progress.
    [resizableView hideEditingHandles];
}

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return imageView;
}

-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    NSLog(@"scrollview will zoom");
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"scrollview will drag");

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
    if (isZoomingEdit) {
        isZoomingEdit=NO;
        selectedFilterIndex=[filtersScrollView.subviews indexOfObject:filtersScrollView.selectedFilterView];
        EditWaldoViewController *editWaldoController=[[EditWaldoViewController alloc]initWithNibName:@"EditWaldoViewController" bundle:nil];
        
        
        if (isFigureInside) {
            CGRect figureFrame=zoomRect;
            CGSize roundSize=figureFrame.size;
            roundSize.width=roundf(roundSize.width);
            roundSize.height=roundf(roundSize.height);
            figureFrame.size=roundSize;
            figureFrame.origin.x=resizableView.frame.origin.x+figureView.frame.origin.x;
            figureFrame.origin.y=resizableView.frame.origin.y+figureView.frame.origin.y;
        }
        else{ // do zoom and figure seperately
            CGSize roundSize=zoomRect.size;
            roundSize.width=roundf(roundSize.width);
            roundSize.height=roundf(roundSize.height);
            zoomRect.size=roundSize;
            zoomRect.origin.x=resizableView.frame.origin.x+figureView.frame.origin.x;
            zoomRect.origin.y=resizableView.frame.origin.y+figureView.frame.origin.y;
            
            
            CGRect figureFrame=figureView.frame;
            roundSize=figureFrame.size;
            roundSize.width=roundf(roundSize.width);
            roundSize.height=roundf(roundSize.height);
            figureFrame.size=roundSize;
            figureFrame.origin.x=resizableView.frame.origin.x+figureView.frame.origin.x;
            figureFrame.origin.y=resizableView.frame.origin.y+figureView.frame.origin.y;
            
        }
        
        [editWaldoController setUpBackGroundWith:imageView.image zoomRect:zoomRect];
        [editWaldoController setUpFigureWith:_plainFigureImage frame:figureFrame OriginalFigure:_originalFigureImage];
        [self.navigationController pushViewController:editWaldoController animated:NO];
    }
    if (isZoomArriving) {
        NSLog(@"endarrive zoom scal %f",_scrollView.zoomScale);
        isZoomArriving=NO;
    }
}
							
- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (IBAction)wipeWaldo:(id)sender {
    NSLog(@"wipewaldo");
//    if (imageMask) {
//        [imageMask removeFromSuperview];
//    }
//    imageMask=[[WipeAwayView alloc]initWithFrame:figureView.frame];  
//    [imageMask newMaskWithImage:figureView.image eraseSpeed:.25];
//    [imageMask setUserInteractionEnabled:YES];
//    [imageView addSubview:imageMask];
//    [imageMask setAlpha:0.6];
    CGRect figureFrame=figureView.frame;
    CGSize roundSize=figureFrame.size;
    roundSize.width=roundf(roundSize.width);
    roundSize.height=roundf(roundSize.height);
    figureFrame.size=roundSize;
    imageMask.frame=figureFrame;
    imageMask.center=resizableView.center;
    [resizableView setHidden:YES];

    [imageMask setHidden:NO];
}

-(UIImage *)finalizeImage{
    if (finalView) {
        [finalView removeFromSuperview];
    }
    self.scrollView.zoomScale=1.0;
    
    
    CGSize finalSize=CGSizeMake(612, 612);  //imageView.image.size;
    CGRect largeRect=CGRectMake(0, 0, finalSize.width, finalSize.height);
    
    UIImage *figureImage=figureView.image;
    CGPoint figurePoint=figureView.frame.origin;
    figurePoint=[imageView convertPoint:figurePoint fromView:figureView];
    CGSize figureSize=figureView.image.size;
    CGRect finalFrame=[self frameForRect:largeRect inCenterOfRect:imageView.frame];
    CGRect finalFigureRect=[self scaleFinalFigureWithFinalSize:finalSize OffsetPoint:finalFrame.origin];

    
    UIGraphicsBeginImageContext(finalSize);
    [imageView.image drawInRect:largeRect];
    [figureImage drawInRect:finalFigureRect];
    
    UIImage *finalImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    finalView=[[UIImageView alloc]initWithImage:finalImage];
    [finalView setUserInteractionEnabled:YES];
    finalView.frame=finalFrame;
    [imageView addSubview:finalView];
    
    return finalImage;
}

-(CGRect)scaleFinalFigureWithFinalSize:(CGSize)finalSize OffsetPoint:(CGPoint)offsetPoint{
    UIImage *figureImage=figureView.image;    //figureimage
    
    CGPoint figurePoint=CGPointMake(0, 0);
    figurePoint=[imageView convertPoint:figurePoint fromView:figureView];
    CGPoint finalFigurePoint=figurePoint;
    CGSize figureSize=figureView.frame.size;
    CGSize finalFigureSize=figureSize;
    
    CGFloat imageScale,figureRatio,pointRatio;
    if (finalSize.height>finalSize.width) {
        imageScale=finalSize.height/imageView.frame.size.height;
        figureRatio=figureSize.width/figureSize.height;
        finalFigureSize.height=figureSize.height*imageScale;
        finalFigureSize.width=finalFigureSize.height*figureRatio;
        
        pointRatio=figurePoint.x/figurePoint.y;
        finalFigurePoint.y=figurePoint.y*imageScale;
        finalFigurePoint.x=finalFigurePoint.y*pointRatio;
        
        
        //finalFigurePoint.x-=offsetPoint.x;
        
    }
    else{
        imageScale=finalSize.width/imageView.frame.size.width;
        figureRatio=figureSize.height/figureSize.width;
        finalFigureSize.width=figureSize.width*imageScale;
        finalFigureSize.height=finalFigureSize.width*figureRatio;
        
        pointRatio=figurePoint.y/figurePoint.x;
        finalFigurePoint.x=figurePoint.x*imageScale;
        finalFigurePoint.y=finalFigurePoint.x*pointRatio;
        //finalFigurePoint.y-=offsetPoint.y;
        
    }
    
    return CGRectMake(finalFigurePoint.x, finalFigurePoint.y, finalFigureSize.width, finalFigureSize.height);
    
}
-(CGRect)frameForRect:(CGRect)innerFrame inCenterOfRect:(CGRect)outerRect {
    CGSize innerSize=innerFrame.size;
    CGFloat height,width,ratio;
    CGSize outerSize=outerRect.size;
    if (innerSize.height>innerSize.width) {
        ratio =innerSize.width/innerSize.height;
        height=outerSize.height;
        width=height*ratio;

    }
    else{
        ratio =innerSize.height/innerSize.width;
        width=outerSize.width;
        height=width*ratio;
    }
    CGPoint innerPoint=CGPointMake((outerSize.width-width)/2, (outerSize.height-height)/2);
    
    return CGRectMake(innerPoint.x, innerPoint.y, width, height);
    
}

- (IBAction)restart:(id)sender {
    [self initialFigure];
}

- (IBAction)share:(id)sender {
    [self finalizeImage];
    laSharekit.image=finalView.image;
    
    
    

    
    sheet = [[UIActionSheet alloc] initWithTitle:@"Save/Share"
                                        delegate:self
                               cancelButtonTitle:@"Cancel"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"Save to Library", @"Instagram", @"Facebook", @"Twitter", @"Email", nil];
    
    // Show the sheet
    [sheet showInView:self.view];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case SaveToLibrary:{  //library
            ;
            UIImageWriteToSavedPhotosAlbum(finalView.image, nil, nil, nil);
            break;
        }
        
        case Instagram :{
            
             UIImage* instaImage = finalView.image;
             NSString* imagePath = [NSString stringWithFormat:@"%@/image.ig", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
             [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
             [UIImagePNGRepresentation(instaImage) writeToFile:imagePath atomically:YES];
             NSLog(@"image size: %@", NSStringFromCGSize(instaImage.size));
             _docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
             _docController.delegate=self;
             _docController.UTI = @"com.instagram.photo";
             [_docController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
             
            break;
        }
        case Facebook:{
            [laSharekit facebookPost];
            break;
        }
        case Twitter:{
            [laSharekit tweet];
            break;
        }
        case Email:{
            [laSharekit emailIt];
            break;
        }
        
            
        default:
            break;
    }
    NSLog(@"Button %d", buttonIndex);
}

-(void)setUpdatedFigureImage:(UIImage *)plainImage{
    _plainFigureImage=plainImage;
    filtersScrollView.figureImage=plainImage;
    [filtersScrollView applyFilter:self];
}



- (IBAction)selectWaldo:(id)sender {
    if (imageMask) {
        figureView.image=[imageMask currentImage];
        
        //[resizableView setFrame:imageMask.frame];
    }
    
    NSLog(@"selectwaldo");
    [resizableView setHidden:NO];
    [imageMask setHidden:YES];
}

- (IBAction)editWaldo:(id)sender {
    isZoomingEdit=YES;
    CGRect rect=[imageView convertRect:figureView.frame fromView:figureView];
    isFigureInside=CGRectContainsRect(imageView.bounds, rect);
    if(isFigureInside){
        zoomRect=figureView.frame;
        zoomRect.origin.x+=resizableView.frame.origin.x;
        zoomRect.origin.y+=resizableView.frame.origin.y;
    }
    
    else
        zoomRect= CGRectIntersection(imageView.bounds, rect);
    
    [_scrollView zoomToRect:zoomRect animated:YES];
    
}

- (IBAction)openFilters:(id)sender {
    CGRect filterFrame=_filterContainerView.frame;
    filterFrame.origin.y=self.view.bounds.size.height-filterFrame.size.height;
    [UIView animateWithDuration:0.2
                          delay:0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _filterContainerView.frame=filterFrame;
                     }
                     completion:nil];
    
}

- (IBAction)closeFilters:(id)sender {
    CGRect filterFrame=_filterContainerView.frame;
    filterFrame.origin.y=self.view.bounds.size.height;
    [UIView animateWithDuration:0.2
                          delay:0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _filterContainerView.frame=filterFrame;
                     }
                     completion:nil];
    
}

- (IBAction)flipWaldo:(id)sender {
}
@end
