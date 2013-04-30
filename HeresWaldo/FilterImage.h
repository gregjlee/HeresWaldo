//
//  FilterImage.h
//  HeresWaldo
//
//  Created by Gregory Lee on 2/7/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface FilterImage : NSObject{
    NSString *name;
    CIImage *image;
}
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)CIImage *image;
-(id)initWithName:(NSString *)theName CIImage:(CIImage*)theImage;
@end
