//
//  ViewController.m
//  HeresWaldo
//
//  Created by Gregory Lee on 2/5/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import "ViewController.h"
#import "CameraViewController.h"
#import "ImageViewController.h"
#import "EditWaldoViewController.h"
#import "UIImage+Utilities.h"
#define IMAGE_WIDTH 612.0f
#define IMAGE_HEIGHT 612.0f

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePicture:(id)sender {
    CameraViewController *cameraViewController=[[CameraViewController alloc]init];
    [self.navigationController pushViewController:cameraViewController animated:YES];
}

- (IBAction)browsePhotos:(id)sender {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.allowsEditing = YES;
    [self presentModalViewController:pickerController animated:YES];
}

#pragma mark -

- (void)showImagePicker {
    
}

- (void)hideImagePickerAnimated:(BOOL)animated {
    [self dismissModalViewControllerAnimated:animated];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    CGRect cropRect = [[info valueForKey:UIImagePickerControllerCropRect] CGRectValue];
    UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    cropRect = [originalImage convertCropRect:cropRect];
    
    UIImage *croppedImage = [originalImage croppedImage:cropRect];
    UIImage *resizedImage = [croppedImage resizedImage:CGSizeMake(IMAGE_WIDTH, IMAGE_HEIGHT) imageOrientation:originalImage.imageOrientation];
    
    ImageViewController *controller = [[ImageViewController alloc] init];
    controller.image = resizedImage;
//    EditWaldoViewController *controller=[[EditWaldoViewController alloc]init];
//    [controller setUpBackGroundWith:resizedImage];
    [self.navigationController pushViewController:controller animated:YES];
    
    [self hideImagePickerAnimated:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self hideImagePickerAnimated:YES];
}

- (IBAction)openWaldoAlbum:(id)sender {
}
@end
