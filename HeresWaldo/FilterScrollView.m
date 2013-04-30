//
//  FilterScrollView.m
//  HeresWaldo
//
//  Created by Gregory Lee on 2/7/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import "FilterScrollView.h"
#import "FilterImage.h"
#import <QuartzCore/QuartzCore.h>
#define Plain 0
#define SepiaTone 1
#define Monochrome 2

@implementation FilterScrollView
@synthesize figureImage,selectedFilterView;

- (id)initWithFrame:(CGRect)frame bgView:(UIImageView *)leBGView FigureView:(UIImageView *)leFigureView filterButton:(UIButton *)leButton
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setScrollEnabled:YES];
        [self setShowsVerticalScrollIndicator:NO];
        self.showsHorizontalScrollIndicator = NO;
        context = [CIContext contextWithOptions:nil];
        filterButton=leButton;
        figureView=leFigureView;
        figureImage=figureView.image;  //[[UIImage alloc]initWithCGImage:figureView.image.CGImage];
        bgView=leBGView;
        [self loadFiltersForBGImage:leBGView.image];
        //[self applyFilterWithIndex:0];
    }
    return self;
}

-(void)loadFiltersForBGImage:(UIImage *)leBGImage
{
    
    UIImage *image=leBGImage;
    
    filterImages = [[NSMutableArray alloc] init];
    CIImage *plain=[self filterImageWithIndex:Plain image:image];
    CIImage *sepia=[self filterImageWithIndex:SepiaTone image:image];
    CIImage *mono=[self filterImageWithIndex:Monochrome image:image];
    [filterImages addObjectsFromArray:[NSArray arrayWithObjects:
                                  [[FilterImage alloc]initWithName:@"Plain" CIImage:plain],
                                  [[FilterImage alloc] initWithName:@"Sepia" CIImage:sepia],
                                  [[FilterImage alloc] initWithName:@"Mono" CIImage:mono]
                                  
                                  , nil]];
    
    
    [self createPreviewViewsForFilters];
}

-(CIImage*) filterImageWithIndex:(NSInteger)index image:(UIImage*)image{
    CIImage *filterPreviewImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter;
    switch (index) {
        case SepiaTone:{
            filter = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:kCIInputImageKey,filterPreviewImage,
                                     @"inputIntensity",[NSNumber numberWithFloat:0.8],nil];
            filterPreviewImage=[filter outputImage];
            break;
        }
        case Monochrome:{
            filter = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:kCIInputImageKey,filterPreviewImage,
                                         @"inputColor",[CIColor colorWithString:@"Red"],
                                         @"inputIntensity",[NSNumber numberWithFloat:0.8], nil];
            filterPreviewImage=[filter outputImage];
            break;
        }
            
        default:
            break;
    }
    return filterPreviewImage;
}
-(void) createPreviewViewsForFilters
{
    int offsetX = 10;
    
    for(int index = 0; index < [filterImages count]; index++)
    {
        UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(offsetX, 0, 60, 60)];
        
        
        filterView.tag = index;
        
        // create a label to display the name
        UILabel *filterNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, filterView.bounds.size.width, 8)];
        
        filterNameLabel.center = CGPointMake(filterView.bounds.size.width/2, filterView.bounds.size.height + filterNameLabel.bounds.size.height);
        
        FilterImage *filterImage = [filterImages objectAtIndex:index];
        NSLog(@"object type %@",[filterImage class]);
        filterNameLabel.text =  filterImage.name;
        filterNameLabel.backgroundColor = [UIColor clearColor];
        filterNameLabel.textColor = [UIColor whiteColor];
        filterNameLabel.font = [UIFont fontWithName:@"AppleColorEmoji" size:10];
        filterNameLabel.textAlignment = UITextAlignmentCenter;
        
        CIImage *outputImage = filterImage.image;
        
        CGImageRef cgimg =
        [context createCGImage:outputImage fromRect:[outputImage extent]];
        
        UIImage *smallImage =  [UIImage imageWithCGImage:cgimg];
        
        if(smallImage.imageOrientation == UIImageOrientationUp)
        {
            //smallImage = [smallImage imageRotatedByDegrees:90];
        }
        
        // create filter preview image views
        UIImageView *filterPreviewImageView = [[UIImageView alloc] initWithImage:smallImage];
        
        [filterView setUserInteractionEnabled:YES];
        
        filterPreviewImageView.layer.cornerRadius = 15;
        filterPreviewImageView.opaque = NO;
        filterPreviewImageView.backgroundColor = [UIColor clearColor];
        filterPreviewImageView.layer.masksToBounds = YES;
        filterPreviewImageView.frame = CGRectMake(0, 0, 60, 60);
        
        filterView.tag = index;
        
        [self applyGesturesToFilterPreviewImageView:filterView];
        
        [filterView addSubview:filterPreviewImageView];
        [filterView addSubview:filterNameLabel];
        
        [self addSubview:filterView];
        
        offsetX += filterView.bounds.size.width + 10;
        }
    
    [self setContentSize:CGSizeMake(400, 90)];
}
-(void) applyGesturesToFilterPreviewImageView:(UIView *) view
{
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(applyFilter:)];
    
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    
    [view addGestureRecognizer:singleTapGestureRecognizer];
}


-(void) applyFilter:(id) sender
{
    UIView *view = [(UITapGestureRecognizer *) sender view];
    [self applyFilterWithIndex:view.tag];
}

-(void)applyFilterWithIndex:(NSInteger)index{
    selectedFilterView.layer.shadowRadius = 0.0f;
    selectedFilterView.layer.shadowOpacity = 0.0f;
    selectedFilterView=[self.subviews objectAtIndex:index];
    selectedFilterView.layer.shadowColor = [UIColor yellowColor].CGColor;
    selectedFilterView.layer.shadowRadius = 3.0f;
    selectedFilterView.layer.shadowOpacity = 0.9f;
    selectedFilterView.layer.shadowOffset = CGSizeZero;
    selectedFilterView.layer.masksToBounds = NO;
    
    int filterIndex = selectedFilterView.tag;
    FilterImage *filterImage = [filterImages objectAtIndex:filterIndex];
    
    CIImage *outputImage = filterImage.image;
    CGImageRef cgimg =
    [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *finalImage = [UIImage imageWithCGImage:cgimg];
    //finalImage = [finalImage imageRotatedByDegrees:90];
    [bgView setImage:finalImage];
    CGImageRelease(cgimg);
    
    outputImage=[self filterImageWithIndex:filterIndex image:figureImage];
    cgimg=[context createCGImage:outputImage fromRect:[outputImage extent]];
    finalImage = [UIImage imageWithCGImage:cgimg];
    //finalImage = [finalImage imageRotatedByDegrees:90];
    [figureView setImage:finalImage];
    CGImageRelease(cgimg);
    NSString *buttonTitle=[NSString stringWithFormat:@"Filter : %@",filterImage.name];
    if (filterIndex==0) {
        buttonTitle=@"Add Filter";
    }
    [filterButton setTitle:buttonTitle forState:UIControlStateNormal];
}


@end
