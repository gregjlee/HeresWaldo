//
//  FilterScrollView.h
//  HeresWaldo
//
//  Created by Gregory Lee on 2/7/13.
//  Copyright (c) 2013 Gregory Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FilterScrollViewDelegate<NSObject>

@end
@interface FilterScrollView : UIScrollView{
    CIContext *context;
    NSMutableArray *filterImages;
    UIView *selectedFilterView;
    UIImageView *bgView;
    UIImageView *figureView;
    UIButton *filterButton;
}
- (id)initWithFrame:(CGRect)frame bgView:(UIImageView *)leBGView FigureView:(UIImageView *)leFigureView filterButton:(UIButton *)leButton;
-(void) loadFiltersForBGImage:(UIImage*)leBGImage;
-(void) applyFilter:(id) sender;
-(void)applyFilterWithIndex:(NSInteger)index;
@property(nonatomic,strong)UIImage* figureImage;
@property(nonatomic,strong)UIView *selectedFilterView;

@end
