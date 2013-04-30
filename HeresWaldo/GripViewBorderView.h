//
//  GripViewBorderView.h
//  CropImageTest
//
//  Created by Gregory Lee on 1/25/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResizableView.h"

@interface GripViewBorderView : UIView{
    CGRect borderRect;
}

@property(nonatomic,assign)CGRect borderRect;

@end
