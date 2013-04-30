//
//  FFCaptureManager.h
//  FoodFlow
//
//  Created by Kishikawa Katsumi on 11/08/18.
//  Copyright 2011 Kishikawa Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol CaptureManagerDelegate;

@interface CaptureManager : NSObject {
@private
    AVCaptureSession *session;
    AVCaptureDeviceInput *videoInput;
    id<CaptureManagerDelegate> __unsafe_unretained delegate;
    
    AVCaptureStillImageOutput *stillImageOutput; 
}

@property (nonatomic, readonly, strong) AVCaptureSession *session;
@property (nonatomic, readonly, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, unsafe_unretained) id<CaptureManagerDelegate> delegate;
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
@property (nonatomic, assign) AVCaptureTorchMode torchMode;
@property (nonatomic, assign) AVCaptureFocusMode focusMode;
@property (nonatomic, assign) AVCaptureExposureMode exposureMode;
@property (nonatomic, assign) AVCaptureWhiteBalanceMode whiteBalanceMode;

- (BOOL)setupSessionWithPreset:(NSString *)sessionPreset error:(NSError **)error;
- (void)startRunning;
- (void)stopRunning;
- (NSUInteger)cameraCount;
- (void)captureStillImage;
- (BOOL)cameraToggle;
- (BOOL)hasMultipleCameras;
- (BOOL)hasFlash;
- (BOOL)hasTorch;
- (BOOL)hasFocus;
- (BOOL)hasExposure;
- (BOOL)hasWhiteBalance;
- (void)focusAtPoint:(CGPoint)point;
- (void)exposureAtPoint:(CGPoint)point;
+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;

@end

@protocol CaptureManagerDelegate<NSObject>
@optional
- (void)captureSessionDidStartRunning;
- (void)captureStillImageFinished:(UIImage *)image;
- (void)captureStillImageFailedWithError:(NSError *)error;
- (void)acquiringDeviceLockFailedWithError:(NSError *)error;
- (void)cannotWriteToAssetLibrary;
- (void)assetLibraryError:(NSError *)error forURL:(NSURL *)assetURL;
- (void)someOtherError:(NSError *)error;
@end
