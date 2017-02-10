//
//  CropCornerView.h
//  TKImageViewDemo
//
//  Created by admin on 2016/12/21.
//  Copyright © 2016年 yinyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CropCornerView : UIImageView
@property(nonatomic, weak)CropCornerView *cornerViewX; //
@property(nonatomic, weak)CropCornerView *cornerViewY; //
@property(nonatomic, assign)int position; //1左上 2右上 3左下 4右下
@property(nonatomic, assign)CGRect cropRect; //整个剪切frame
@property(nonatomic, assign)float aspectRatios;//任意比例

@end
