//
//  ViewController.h
//  HeresWaldo
//
//  Created by Gregory Lee on 2/5/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIImagePickerControllerDelegate>

- (IBAction)takePicture:(id)sender;
- (IBAction)browsePhotos:(id)sender;
- (IBAction)openWaldoAlbum:(id)sender;
@end
