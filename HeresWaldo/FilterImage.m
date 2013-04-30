//
//  FilterImage.m
//  HeresWaldo
//
//  Created by Gregory Lee on 2/7/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import "FilterImage.h"

@implementation FilterImage
@synthesize image,name;
-(id)initWithName:(NSString *)theName CIImage:(CIImage *)theImage{
    self=[super init];
    if (self) {
        name=theName;
        image=theImage;
    }
    return self;
}

@end
