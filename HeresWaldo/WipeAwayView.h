//
//  WipeAwayView.h
//  WipeAway
//
//  Created by Craig on 12/6/10.
//

#import <UIKit/UIKit.h>

@interface WipeAwayView : UIView {
    
	CGPoint		location;
	CGImageRef	imageRef;
	UIImage		*eraser;
	BOOL		wipingInProgress;
	UIColor		*maskColor;
	CGFloat		eraseSpeed;
    UIImage *image;
    CGSize eraserSize;
	
}
-(void)resizeEraserAfterZoomWithScale:(float)zoomScale;
@property(nonatomic,assign) CGImageRef imageRef;
- (void)newMaskWithColor:(UIColor *)color eraseSpeed:(CGFloat)speed;
-(void)newMaskWithImage:(UIImage *)newImage eraseSpeed:(CGFloat)speed;
-(UIImage*)currentImage;
-(void)setCurrentImage:(UIImage*)currentImage;
-(void)changeImageRefFrame:(CGRect)targetFrame;
@end
