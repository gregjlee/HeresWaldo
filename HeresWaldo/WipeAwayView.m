//
//  WipeAwayView.m
//  WipeAway
//
//  Created by Craig on 12/6/10.
//
//  See http://craigcoded.com/2010/12/08/erase-top-uiview-to-reveal-content-underneath/ for full explanation
//

#import "WipeAwayView.h"
#import <QuartzCore/QuartzCore.h>
@implementation WipeAwayView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		wipingInProgress = NO;
		eraser = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"eraser" ofType:@"png"]];
        eraserSize=eraser.size;
		[self setBackgroundColor:[UIColor clearColor]];
        self.layer.borderWidth=1;
        self.layer.borderColor=[UIColor whiteColor].CGColor;
        [self setAlpha:0.6];
    }
    return self;
}

- (void)newMaskWithColor:(UIColor *)color eraseSpeed:(CGFloat)speed {
	
	wipingInProgress = NO;
	
	eraseSpeed = speed;
	
	maskColor = color;
	
	[self setNeedsDisplay];
	
}

-(void)newMaskWithImage:(UIImage *)newImage eraseSpeed:(CGFloat)speed{
    image=newImage;
    wipingInProgress = NO;
	
	eraseSpeed = speed;
	
	maskColor = nil;
	[self setNeedsDisplay];
}

-(void)setScrollViewEnabled:(BOOL)enabled{
    UIScrollView *scrollView=(UIScrollView*)self.superview.superview;
    [scrollView setScrollEnabled:enabled];
}


-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *view=[super hitTest:point withEvent:event];
    if (view==self) {
        [self setScrollViewEnabled:NO];

        NSLog(@"hit WipeView");
    }
    
    return view;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"wipe begin");
    //[self setScrollViewEnabled:NO];

	wipingInProgress = YES;
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if ([touches count] == 1) {
		UITouch *touch = [touches anyObject];
		location = [touch locationInView:self];
		location.x -= [eraser size].width/2;
		location.y -= [eraser size].width/2;
		[self setNeedsDisplay];
	}
    NSLog(@"move eraser width %f height %f",eraser.size.width,eraser.size.height);
    
	
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self setScrollViewEnabled:YES];

}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self setScrollViewEnabled:YES];
}

- (void)drawRect:(CGRect)rect {
    
	CGContextRef context = UIGraphicsGetCurrentContext();
    
	if (wipingInProgress) {
		if (imageRef) {
            CGSize size= [UIImage imageWithCGImage:imageRef].size;
            
			// Restore the screen that was previously saved
			CGContextTranslateCTM(context, 0, rect.size.height);
			CGContextScaleCTM(context, 1.0, -1.0);
			
			CGContextDrawImage(context, rect, imageRef);
			CGImageRelease(imageRef);
            
			CGContextTranslateCTM(context, 0, rect.size.height);  //flip context back to nrom
			CGContextScaleCTM(context, 1.0, -1.0);
		}
        
		// Erase the background -- raise the alpha to clear more away with eash swipe
		[eraser drawAtPoint:location blendMode:kCGBlendModeDestinationOut alpha:eraseSpeed];
	} else {
        //rect=CGRectInset(rect, 20, 20);
        [image drawInRect:rect];
		// First time in, we start with a solid color
        
        //        CGContextDrawImage(context, rect, [image CGImage]);
        //		CGContextFillRect( context, rect );
	}
    
	// Save the screen to restore next time around
	imageRef = CGBitmapContextCreateImage(context);
	
}

-(void)resizeEraserAfterZoomWithScale:(float)zoomScale{
    NSLog(@"eraser size %f",eraser.size.width);
    CGFloat scale=1.0/zoomScale;
    CGSize scaleSize=eraserSize;
    scaleSize.width*=scale;
    scaleSize.height*=scale;
    eraser=[self imageWithImage:eraser scaledToSize:scaleSize];
    NSLog(@"resize eraser size %f",eraser.size.width);
    
}
- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage*)currentImage{
    //NSLog(@"wipe size %f",ima)
    return [UIImage imageWithCGImage:imageRef scale:1 orientation:UIImageOrientationUp];
}

-(void)setCurrentImage:(UIImage*)currentImage{
    CGImageRelease(imageRef);
    imageRef=[currentImage CGImage];
}

-(void)changeImageRefFrame:(CGRect)targetFrame{

    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    UIImage* sourceImage=image;
    CGFloat targetWidth = targetFrame.size.width;
	CGFloat targetHeight = targetFrame.size.height;
	if (bitmapInfo == kCGImageAlphaNone) {
		bitmapInfo = kCGImageAlphaNoneSkipLast;
	}
    
	CGContextRef bitmap;
    
	if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
		bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
	} else {
		bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
	}
    
//	if (sourceImage.imageOrientation == UIImageOrientationLeft) {
//		CGContextRotateCTM (bitmap, radians(90));
//		CGContextTranslateCTM (bitmap, 0, -targetHeight);
//        
//	} else if (sourceImage.imageOrientation == UIImageOrientationRight) {
//		CGContextRotateCTM (bitmap, radians(-90));
//		CGContextTranslateCTM (bitmap, -targetWidth, 0);
//        
//	} else if (sourceImage.imageOrientation == UIImageOrientationUp) {
//		// NOTHING
//	} else if (sourceImage.imageOrientation == UIImageOrientationDown) {
//		CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
//		CGContextRotateCTM (bitmap, radians(-180.));
//	}
    
	CGContextDrawImage(bitmap, CGRectMake(targetFrame.origin.x, targetFrame.origin.y, targetWidth, targetHeight), imageRef);
	imageRef = CGBitmapContextCreateImage(bitmap);
    
	CGContextRelease(bitmap);
}


@end
