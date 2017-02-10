//
//  ShowImageView.h
//  OCamera
//
//  Created by admin on 2016/12/22.
//  Copyright © 2016年 appdevgu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ClipType) {
    ClipTypeRect = 0,
    ClipTypeCycle,
    ClipTypeEllipse,
};
#define DefaultCycleOffset 15
#define DefaultMaxWidth 1500
@interface MaskShadowLyer: CAShapeLayer
- (instancetype)initWithRaidus:(CGFloat)radius type:(ClipType)type shapeSize:(CGSize)shapeSize viewSize:(CGSize)viewSize;
@end


@interface ShowImageView : UIView{
    
}

@property (nonatomic, strong) UIImageView *tmpImageView;
@property (nonatomic, strong) UIImageView *zoomImageView;
@property (nonatomic, strong) UIScrollView *zoomScrollView;

@property (nonatomic, assign) CGRect clipRect;

@property(nonatomic, strong)UIImage *image;
@property(nonatomic, assign)BOOL shouldZoom;
@property(nonatomic, assign)CGFloat minScale;
@property(nonatomic, assign)CGFloat maxScale;
@property(nonatomic, assign)BOOL showFullView;//是否撑满,默认全部展示
@property(nonatomic, assign)BOOL showFullImage;//是否显示全图片

@property(nonatomic, assign)BOOL unLimit;//自由 无限制 任意移动

@property(nonatomic, assign)BOOL newUnLimit;//新 自由 无限制 任意移动

@property(nonatomic, assign)BOOL limitCycle;//限制圆范围内 任意移动

@property(nonatomic, assign)BOOL cropChangeEnable;//裁剪框改变 默认不可变

@property(nonatomic, strong)UIColor *unLimitBackgroundColor;//自由背色

@property(nonatomic, strong)MaskShadowLyer *shadowLayer;

@property(nonatomic, assign)BOOL blurShadow;
@property(nonatomic, strong)UIImage *blurImage;

@property(nonatomic, assign)BOOL shouldRotate;

@property(nonatomic, assign)CGFloat maxCurrScale;
@property(nonatomic, assign)CGFloat minCurrScale;

@property(nonatomic, strong)UIColor *shadowColor;
@property(nonatomic, assign)CGFloat shadowAlpha;

@property(nonatomic, assign)NSInteger firstOptionType;
@property(nonatomic, assign)NSInteger secondOptionType;


- (void)addCycleWithMaskSize:(CGSize)maskSize;
- (void)moveImageToCenterWithAnimation:(BOOL)animation;

- (UIImage *)outputImage;


- (void)updateBlurShadow;
- (void)fillShadowWithColor:(UIColor *)color image:(UIImage *)image;

- (void)copyToOtherView:(ShowImageView *)view;

- (void)updateCropRect:(CGRect)rect reset:(BOOL)reset;
- (void)updateImage:(UIImage *)image;
@end
