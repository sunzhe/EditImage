//
//  CropImageViewController.m
//  ImageTailor
//
//  Created by yinyu on 15/10/10.
//  Copyright © 2015年 yinyu. All rights reserved.
//

#import "CropImageViewController.h"
#import "TKImageView.h"
#import "ShowImageView.h"
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define CROP_PROPORTION_IMAGE_WIDTH 30.0f
#define CROP_PROPORTION_IMAGE_SPACE 48.0f
#define CROP_PROPORTION_IMAGE_PADDING 20.0f

@interface CropImageViewController () {
    
    NSArray *proportionImageNameArr;
    NSArray *proportionImageNameHLArr;
    NSArray *proportionArr;
    NSMutableArray *proportionBtnArr;
    CGFloat currentProportion;

}
@property (weak, nonatomic) IBOutlet UIScrollView *cropProportionScrollView;
@property (weak, nonatomic) IBOutlet TKImageView *tkImageView;

@end

@implementation CropImageViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setUpTKImageView];
    currentProportion = 0;
    [self setUpCropProportionView];
    [self clickProportionBtn: proportionBtnArr[0]];
    
}
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}
- (void)setUpTKImageView {
    
    //_tkImageView
    _tkImageView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.width);
    _tkImageView.clipsToBounds = YES;
    _tkImageView.showMidLines = YES;
    _tkImageView.needScaleCrop = YES;
    //_tkImageView.showCrossLines = YES;
    _tkImageView.cropAreaCornerWidth = 20;
    _tkImageView.cropAreaCornerHeight = 20;
    _tkImageView.minSpace = 30;
//    _tkImageView.cropAreaCornerLineColor = [UIColor colorWithRed:204.0/255.0 green:51.0/255.0 blue:153.0/255.0 alpha:1.0];
//    _tkImageView.cropAreaBorderLineColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:153.0/255.0 alpha:1.0];
    _tkImageView.cropAreaCornerLineColor = [UIColor whiteColor];
    _tkImageView.cropAreaBorderLineColor = [UIColor whiteColor];
    
    _tkImageView.cropAreaCornerLineWidth = 2;
    _tkImageView.cropAreaBorderLineWidth = 1;
    
    _tkImageView.cropAreaMidLineWidth = 100;
    _tkImageView.cropAreaMidLineHeight = 1;
    
    _tkImageView.cropAreaMidLineColor = [UIColor colorWithRed:153.0/255.0 green:204.0/255.0 blue:0/255.0 alpha:1.0];
    _tkImageView.cropAreaMidLineColor = [UIColor whiteColor];
    _tkImageView.cropAreaCrossLineColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:153.0/255.0 alpha:1.0];
    
    _tkImageView.cropAreaCrossLineWidth = 1;
    _tkImageView.toCropImage = [UIImage imageNamed: @"test.jpg"];
    
}
- (void)setUpCropProportionView {
    
    proportionBtnArr = [NSMutableArray array];
    proportionImageNameArr = @[@"crop_free", @"crop_1_1", @"crop_4_3", @"crop_3_4", @"crop_16_9", @"crop_9_16"];
    proportionImageNameHLArr = @[@"cropHL_free", @"cropHL_1_1", @"cropHL_4_3", @"cropHL_3_4", @"cropHL_16_9", @"cropHL_9_16"];
    proportionArr = @[@0, @1, @(4.0/3.0), @(3.0/4.0), @(16.0/9.0), @(9.0/16.0)];
    self.cropProportionScrollView.contentSize = CGSizeMake( CROP_PROPORTION_IMAGE_PADDING * 2 + CROP_PROPORTION_IMAGE_WIDTH * proportionArr.count + CROP_PROPORTION_IMAGE_SPACE * (proportionArr.count - 1), CROP_PROPORTION_IMAGE_WIDTH);
    for(int i = 0; i < proportionArr.count; i++) {
        UIButton *proportionBtn = [[UIButton alloc]initWithFrame: CGRectMake(CROP_PROPORTION_IMAGE_PADDING + (CROP_PROPORTION_IMAGE_SPACE + CROP_PROPORTION_IMAGE_WIDTH) * i, 0, CROP_PROPORTION_IMAGE_WIDTH, CROP_PROPORTION_IMAGE_WIDTH)];
        [proportionBtn setBackgroundImage:
         [UIImage imageNamed: proportionImageNameArr[i]]
                                 forState: UIControlStateNormal];
        [proportionBtn setBackgroundImage:
         [UIImage imageNamed: proportionImageNameHLArr[i]]
                                 forState: UIControlStateSelected];
        [proportionBtn addTarget:self action:@selector(clickProportionBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.cropProportionScrollView addSubview:proportionBtn];
        [proportionBtnArr addObject:proportionBtn];
    }
    
}
- (void)clickProportionBtn: (UIButton *)proportionBtn {
    
    for(UIButton *btn in proportionBtnArr) {
        btn.selected = NO;
    }
    proportionBtn.selected = YES;
    NSInteger index = [proportionBtnArr indexOfObject:proportionBtn];
    currentProportion = [proportionArr[index] floatValue];
    _tkImageView.cropAspectRatio = currentProportion;
    
}
#pragma mark - IBActions
- (IBAction)clickCancelBtn:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}
- (IBAction)clickOkBtn:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CropOK" object: [_tkImageView currentCroppedImage]];
    }];
    
}
@end
