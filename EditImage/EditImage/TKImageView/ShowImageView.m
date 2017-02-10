//
//  ShowImageView.m
//  OCamera
//
//  Created by admin on 2016/12/22.
//  Copyright © 2016年 appdevgu. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import "ShowImageView.h"
//#import "HandleOptionView.h"
#pragma mark - MaskShadowLyer
@interface MaskShadowLyer ()
@property (nonatomic, strong) UIBezierPath *bezierPath;
@property (nonatomic, assign) CGFloat clipRadius;
@property (nonatomic, assign) ClipType clipType;
@property (nonatomic, assign) CGSize clipSize;
@property (nonatomic, assign) CGSize viewSize;
@property (nonatomic, assign) CGPathRef layerPath;
@end

static inline CGFloat CGAffineTransformGetRotation(CGAffineTransform transform) {
    return atan2(transform.b, transform.a);
}

@implementation MaskShadowLyer

- (instancetype)initWithRaidus:(CGFloat)radius type:(ClipType)type shapeSize:(CGSize)shapSize viewSize:(CGSize)viewSize {
    self = [super init];
    if (self) {
        self.viewSize = viewSize;
        self.clipType = type;
        self.clipSize = shapSize;
        self.clipRadius = radius;
        self.path = self.bezierPath.CGPath;
        //默认颜色
        self.fillColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
        
    }
    return self;
}
- (CGPathRef)layerPath{
    if (_layerPath == nil) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGRect rect = CGRectMake(0, 0, _viewSize.width, _viewSize.width);
        CGPathAddRect(path, NULL, rect);
        CGFloat rectX = (rect.size.width-_clipSize.width)/2;
        CGFloat rectY = (rect.size.height-_clipSize.height)/2;
        CGFloat rectW = _clipSize.width;
        CGFloat rectH = _clipSize.height;
        if (self.clipType == ClipTypeCycle) {
            CGPathAddArc(path, NULL, rectX, rectY, rectW, 0, M_PI*2, NO);
        } else if (self.clipType == ClipTypeRect) {
            if (_clipRadius==0) {
                CGPathAddRect(path, NULL, CGRectMake(rectX, rectY, rectW, rectH));
            }else {
                UIBezierPath *maskPath =
                [UIBezierPath bezierPathWithRoundedRect:CGRectMake(rectX, rectY, rectW, rectH)
                                      byRoundingCorners:UIRectCornerAllCorners
                                            cornerRadii:CGSizeMake(_clipRadius, _clipRadius)];
                //_layerPath = maskPath.CGPath;
                CGPathAddPath(path, NULL, maskPath.CGPath);
            }
        } else  if (self.clipType == ClipTypeEllipse){
            CGPathAddEllipseInRect(path, NULL, CGRectMake(rectX, rectY, rectW, rectH));
        }
        _layerPath = path;
    }
    return _layerPath;
}

- (UIBezierPath *)bezierPath {
    if (_bezierPath == nil) {
        CGRect rect = CGRectMake(0, 0, _viewSize.width, _viewSize.width);
        _bezierPath = [UIBezierPath bezierPathWithRect:rect];
        
        CGFloat rectX = (rect.size.width-_clipSize.width)/2;
        CGFloat rectY = (rect.size.height-_clipSize.height)/2;
        CGFloat rectW = _clipSize.width;
        CGFloat rectH = _clipSize.height;
        if (self.clipType == ClipTypeEllipse){
            CGPathRef path = CGPathCreateWithEllipseInRect(CGRectMake(rectX, rectY, rectW, rectH), NULL);
            [_bezierPath appendPath:[[UIBezierPath bezierPathWithCGPath:path] bezierPathByReversingPath]];
            CGPathRelease(path);
            
        }else {
            CGFloat radius = self.clipType == ClipTypeRect? self.clipRadius : rectW/2;
            [_bezierPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(rectX, rectY, rectW, rectH) cornerRadius:radius] bezierPathByReversingPath]];
        }
    }
    return _bezierPath;
}

@end


@interface ShowImageView() <UIScrollViewDelegate>{
    CGFloat _lastRotation;
    
    CGPoint _lastPoint;
    CGFloat _lastScale;
    
    BOOL _isDoubleTap;
    
    CGPoint _doubleTapPoint;
    
    CGFloat _halfAppendWidth;
}
@property (nonatomic, strong) UIRotationGestureRecognizer *rotateGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;

@end
@implementation ShowImageView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}
- (void)dealloc{
    //[self removeObserverBlocks];
}
- (void)initView{
    _unLimitBackgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    self.clipRect = self.bounds;
    [self addSubview:self.zoomScrollView];
    [self.zoomScrollView addSubview:self.zoomImageView];
    
    [self addDoubleTapGesture];
}

- (void)setFrame:(CGRect)frame{
    CGSize old = self.frame.size;
    [super setFrame:frame];
    CGSize new = self.frame.size;
    if (!CGSizeEqualToSize(new, old)) {
        [self updateZoomViews];
    }
}
#pragma mark - updateZoomView
- (void)updateZoomViews{
    if (_image == nil) {
        return;
    }
    //更新frame/切换图片后 重需要重置
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeScale(1, 1);
    //transform = CGAffineTransformRotate(transform, 0);//旋转要不要重置?
    _zoomImageView.transform = transform;
    
    //CGSize lSize = self.bounds.size;
    //self.clipRect = CGRectMake((self.frame.size.width-lSize.width)/2, (self.frame.size.height-lSize.height)/2, lSize.width, lSize.height);
    
    CGRect rect = self.bounds;
    if (_limitCycle) {
        self.clipRect = CGRectMake(DefaultCycleOffset, DefaultCycleOffset, rect.size.width-DefaultCycleOffset*2, rect.size.width-DefaultCycleOffset*2);
    }else {
        self.clipRect = rect;
    }
    _zoomScrollView.bounds = CGRectMake(0, 0, _clipRect.size.width, _clipRect.size.height);
    
    CGFloat widthScale = self.clipRect.size.width / self.zoomImageView.frame.size.width;
    CGFloat heightScale = self.clipRect.size.height / self.zoomImageView.frame.size.height;
    
    
    _maxCurrScale = MAX(widthScale, heightScale);
    _minCurrScale = MIN(widthScale, heightScale);
    
    CGFloat minScale = _minScale ?: _minCurrScale;
    
    _lastScale  = _maxCurrScale;
    
    //_lastScale 首次展示倍数
    if (_unLimit) {// 无限制
        _zoomScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        //_lastScale = _minCurrScale*.75;//首次显示 1/2;
        _lastScale = _maxCurrScale;
        minScale = _minCurrScale/20.0;//无限制
        self.backgroundColor = self.unLimitBackgroundColor;
    }else {
        _zoomScrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        //self.backgroundColor = _showFullImage ? [UIColor whiteColor] : [UIColor blackColor];
        self.backgroundColor = _cropChangeEnable ? [UIColor blackColor] : [UIColor whiteColor];
        
        //首次显示撑满  最后执行.
        if (_showFullImage) {//显示全部图片 选择小的倍数
            _lastScale = _minScale;
        }else if(_limitCycle){//限制圆要放大倍数
            minScale = _maxCurrScale;
            _lastScale = minScale*self.bounds.size.width/_clipRect.size.width;
        }else {//撑满视图 max
            minScale = _maxCurrScale;
            _lastScale = minScale;
        }
    }
    [_zoomScrollView setMaximumZoomScale:_maxCurrScale*3.0];
    [_zoomScrollView setMinimumZoomScale:minScale];
    
    _zoomScrollView.zoomScale = _lastScale;
    
    [self scrollViewDidZoom:_zoomScrollView];
    
    
    if (_cropChangeEnable) {
        [_zoomScrollView setMaximumZoomScale:CGFLOAT_MAX];
    }
    if (!_showFullImage) {
        //移动到中央
        [self moveImageToCenterWithAnimation:NO];
    }
}

- (void)updateItemLimit{
    if (!_newUnLimit) {
        return;
    }
    //[self edgeLimitSubview:_zoomImageView offset:10];
    
    //*/
}
- (void)setCropChangeEnable:(BOOL)cropChangeEnable{
    if (_cropChangeEnable == cropChangeEnable) {
        return;
    }
    _cropChangeEnable = cropChangeEnable;
    [self updateZoomViews];
}

- (void)updateCropRect:(CGRect)rect reset:(BOOL)reset{
    self.clipRect = rect;
    if (reset) {
        /*
         //更新frame/切换图片后 重需要重置 重置会有跳跃
         CGAffineTransform transform = CGAffineTransformIdentity;
         transform = CGAffineTransformMakeScale(1, 1);
         transform = CGAffineTransformRotate(transform, 0);//旋转要不要重置?
         _zoomImageView.transform = transform;
         //*/
        _zoomScrollView.frame = rect;
        //_zoomScrollView.bounds = CGRectMake(0, 0, _clipRect.size.width, _clipRect.size.height);
        
        CGFloat widthScale = self.clipRect.size.width / self.zoomImageView.frame.size.width;
        CGFloat heightScale = self.clipRect.size.height / self.zoomImageView.frame.size.height;
        
        
        CGFloat tmpScale = MAX(widthScale, heightScale);
        //缩放居中
        [_zoomScrollView setZoomScale:tmpScale animated:NO];
        
        //* 缩放图片
        CGRect imageRect = _zoomScrollView.bounds;
        CGFloat wScale = imageRect.size.width/_image.size.width;
        CGFloat hScale = imageRect.size.height/_image.size.height;
        CGFloat theScale = MAX(wScale, hScale);
        imageRect.size.width = theScale*_image.size.width;
        imageRect.size.height = theScale*_image.size.height;
        imageRect.origin = CGPointZero;
        _zoomImageView.frame = imageRect;
        _zoomScrollView.contentSize = imageRect.size;
        //*/
        [self moveImageToCenterWithAnimation:NO];
        [_zoomScrollView setMinimumZoomScale:_zoomScrollView.zoomScale];
    }else {
        _zoomScrollView.frame = rect;
    }
}
- (void)updateImage:(UIImage *)image{
    //CGPoint lastPoint = _zoomScrollView.contentOffset;
    CGFloat lastScale = _zoomScrollView.zoomScale;
    self.image = image;
    
    [_zoomScrollView setZoomScale:lastScale animated:NO];
    //[_zoomScrollView setContentOffset:lastPoint animated:NO];
    //默认居中
    [self moveImageToCenterWithAnimation:NO];
}
#pragma mark - open method
- (void)moveImageToCenterWithAnimation:(BOOL)animation{
    CGFloat offsetX = (_zoomScrollView.contentSize.width-_zoomScrollView.frame.size.width)/2;
    CGFloat offsetY = (_zoomScrollView.contentSize.height-_zoomScrollView.frame.size.height)/2;
    [self.zoomScrollView setContentOffset:CGPointMake(offsetX, offsetY) animated:animation];
}

- (void)addCycleWithMaskSize:(CGSize)maskSize{
    CGFloat width = 0;
    if (maskSize.width > 0) {
        width = maskSize.width;
    }else {
        width = CGRectGetWidth(self.bounds)-DefaultCycleOffset*2;
    }
    MaskShadowLyer *_layer = [[MaskShadowLyer alloc] initWithRaidus:0 type:ClipTypeCycle shapeSize:CGSizeMake(width, width) viewSize:self.bounds.size];
    [self.superview.layer addSublayer:_layer];
    if (_shadowLayer) {//如果有先移除
        [_shadowLayer removeFromSuperlayer];
    }
    self.shadowLayer = _layer;
}

- (UIImage *)outputImage{
    UIImage *cropImage = nil;
    
    CGFloat scale = 1;
    
    //*
    if (_unLimit) {
        /*
         scale = self.image.size.width/(_zoomScrollView.contentSize.width-_halfAppendWidth*2);
         
         CGFloat x = MAX(0, (_zoomScrollView.contentOffset.x-_halfAppendWidth)*scale);
         CGFloat y = MAX(0, (_zoomScrollView.contentOffset.y-_halfAppendWidth)*scale);
         
         CGFloat w = CGRectGetWidth(_zoomImageView.frame)-x;
         CGFloat h = CGRectGetHeight(_zoomImageView.frame)-y;
         
         CGFloat spaceW = (CGRectGetMaxX(_zoomImageView.frame) - (_zoomScrollView.contentOffset.x + self.width));
         if (spaceW>0) {
         w -= spaceW;
         }
         
         CGFloat spaceH = (CGRectGetMaxY(_zoomImageView.frame) - (_zoomScrollView.contentOffset.y + self.height));
         if (spaceH>0) {
         h -= spaceH;
         }
         CGRect cropRect = CGRectMake(x, y, w*scale, h*scale);
         cropImage = [self.image cropImageInRect:cropRect];
         //*/
        
        //创建画布size 高保真的话增加放大倍数 最大倍数为 self.image.size.width/self.zoomImageView.size.width
        /*
        //限制最大倍数? 需要?
        scale = self.image.size.width/self.zoomImageView.frame.size.width;
        if (scale < [UIScreen mainScreen].scale) {
            scale = [UIScreen mainScreen].scale;
        }
        
        CGFloat imageWidth = lroundf(CGRectGetWidth(self.frame)*scale);
        if (imageWidth > DefaultMaxWidth) {
            //防止生成图片过大
            imageWidth = DefaultMaxWidth;
            scale = imageWidth/CGRectGetWidth(self.frame);
        }
        //取的坐标系是基于self.view的 所以放大要基于self的frame放大
        
        CGRect drawRect = CGRectMake((_zoomImageView.frame.origin.x - _zoomScrollView.contentOffset.x), (_zoomImageView.frame.origin.y - _zoomScrollView.contentOffset.y), self.zoomImageView.frame.size.width, self.zoomImageView.frame.size.height);
        
        drawRect.origin.x = lroundf(drawRect.origin.x*scale);
        drawRect.origin.y = lroundf(drawRect.origin.y*scale);
        drawRect.size.width = lroundf(drawRect.size.width*scale);
        drawRect.size.height = lroundf(drawRect.size.height*scale);
        
        
        UIGraphicsBeginImageContext(CGSizeMake(imageWidth, imageWidth));
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //绘制背景颜色
        UIImage *backgroundImg = nil;
        switch (_secondOptionType) {
            case CycleOptionTypeAlpha: case CycleOptionTypeBlack:{
                //CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
                //CGContextFillRect(context, CGRectMake(0, 0, imageWidth, imageWidth));
                BOOL black = self.shadowColor == COLOR_BLACK;
                if (_secondOptionType == CycleOptionTypeBlack){
                    [MobClick event:@"square_save" label:black?@"黑":@"白"];
                }else {
                    [MobClick event:@"square_save" label:black?@"透明黑":@"透明白"];
                }
            }
                break;
            case CycleOptionTypeXuan1:{
                backgroundImg = [UIImage imageNamed:@"xuanpaper_larger" cached:NO];
                [MobClick event:@"square_save" label:@"牙色"];
            }
                break;
            case CycleOptionTypeXuan2:{
                backgroundImg = [UIImage imageNamed:@"xuanpaper2_larger" cached:NO];
                [MobClick event:@"square_save" label:@"鸦青"];
            }
                break;
            case CycleOptionTypeXuan3:{
                backgroundImg = [UIImage imageNamed:@"xuanpaper3_larger" cached:NO];
                [MobClick event:@"square_save" label:@"茶白"];
            }
                break;
                
            default:
                break;
        }
        if (backgroundImg) {//宣纸背景
            if (imageWidth <= 1500) {
                [backgroundImg drawAtPoint:CGPointZero];
            }else {
                [backgroundImg drawInRect:CGRectMake(0, 0, imageWidth, imageWidth)];
            }
        }else {
            CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
            CGContextFillRect(context, CGRectMake(0, 0, imageWidth, imageWidth));
        }
        
        [self.image drawInRect:drawRect];
        cropImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
         return cropImage;
         //*/
    }
    /*
     if (_newUnLimit) {
     //图片缩放倍数
     scale = self.image.size.width/_zoomImageView.bounds.size.width;
     if (scale > 10) {
     scale = 10;
     }else if( scale<2 ){
     scale = 2;
     }
     
     //图片frame
     CGRect cropRect = _zoomImageView.bounds;
     
     cropRect.origin.x = _zoomImageView.center.x - cropRect.size.width/2;
     cropRect.origin.y = _zoomImageView.center.y - cropRect.size.height/2;
     
     //图片缩放
     cropRect.origin.x *= scale;
     cropRect.origin.y *= scale;
     cropRect.size.width *= scale;
     cropRect.size.height *= scale;
     
     UIImage *handleImage = self.image;
     
     CGFloat rotate = CGAffineTransformGetRotation(_zoomImageView.transform);
     
     //画布大小
     CGSize contentSize = CGSizeMake(self.bounds.size.width*scale, self.bounds.size.height*scale);
     UIGraphicsBeginImageContext(contentSize);
     
     CGContextRef context = UIGraphicsGetCurrentContext();
     
     //绘制背景颜色
     CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
     CGContextFillRect(context, CGRectMake(0, 0, contentSize.width, contentSize.height));
     
     if (rotate != 0) {
     CGPoint center = CGPointMake(CGRectGetMidX(cropRect), CGRectGetMidY(cropRect));
     //以中心点旋转 然后回到原点
     CGContextConcatCTM(context, CGAffineTransformMakeTranslation(center.x, center.y));
     CGContextConcatCTM(context, CGAffineTransformMakeRotation(rotate));
     CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-center.x, -center.y));
     }
     [handleImage drawInRect:cropRect];
     cropImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     return cropImage;
     }//*/
    
    scale = self.image.size.width/_zoomScrollView.contentSize.width;
    CGFloat offsetScale = 1;
    //    if (scale > 10) {
    //        offsetScale = 10/scale;
    //        scale = 10;
    //    }else if( scale<2 ){
    //        offsetScale = 2/scale;
    //        scale = 2;
    //    }
    
    CGFloat offset = _limitCycle ? DefaultCycleOffset : 0;
    
    CGRect cropRect = CGRectMake(_zoomScrollView.contentOffset.x-offset, _zoomScrollView.contentOffset.y-offset, self.clipRect.size.width+offset*2, self.clipRect.size.height+offset*2);
    cropRect.origin.x = lroundf(cropRect.origin.x*scale);
    cropRect.origin.y = lroundf(cropRect.origin.y*scale);
    cropRect.size.width = lroundf(cropRect.size.width*scale);
    cropRect.size.height = lroundf(cropRect.size.height*scale);
    
    UIImage *handleImage = self.image;
    
    CGFloat rotate = CGAffineTransformGetRotation(_zoomScrollView.transform);
    
    CGSize contentSize = CGSizeMake(cropRect.size.width*offsetScale, cropRect.size.height*offsetScale);
    UIGraphicsBeginImageContext(contentSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //透明会影响模糊效果.
    //绘制背景颜色
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, contentSize.width, contentSize.height));
    
    if (rotate != 0) {
        CGPoint center = CGPointMake(cropRect.size.width/2, cropRect.size.height/2);
        //以中心点旋转 然后回到原点
        CGContextConcatCTM(context, CGAffineTransformMakeTranslation(center.x, center.y));
        CGContextConcatCTM(context, CGAffineTransformMakeRotation(rotate));
        CGContextConcatCTM(context, CGAffineTransformMakeTranslation(-center.x, -center.y));
    }
    [handleImage drawAtPoint:CGPointMake(-cropRect.origin.x, -cropRect.origin.y)];
    
    cropImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cropImage;
    /*
     NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/1.jpg"];
     NSData *data = UIImageJPEGRepresentation(cropImage, 1);
     [data writeToFile:path atomically:YES];
     //*/
    
}

- (void)updateBlurShadow{
    if (!_blurShadow) {
        self.blurImage = nil;
        return;
    }
    [self.superview.layer addSublayer:_shadowLayer];
    //UIImage *originalImage = [self snapshotImage];
    /*
     CGFloat scale = originalImage.size.width/_zoomScrollView.contentSize.width;
     CGRect cropRect = CGRectMake(_zoomScrollView.contentOffset.x*scale, _zoomScrollView.contentOffset.y*scale, self.bounds.size.width*scale, self.bounds.size.height*scale);
     CGImageRef imageRef = CGImageCreateWithImageInRect([originalImage CGImage], cropRect);
     //*/
    //originalImage = self.outputImage;
    UIImage *result = [self snapshotImage];
    //originalImage = [self.outputImage imageByResizeToSize:self.size];
    /*
     CGImageRef imageRef = originalImage.CGImage;
     //layer fillcolour 有镜面效果
     //UIImageOrientationDownMirrored 与效果一致
     UIImage *result = [UIImage imageWithCGImage:imageRef scale:originalImage.scale orientation:UIImageOrientationDownMirrored];
     //CGImageRelease(imageRef);
     CGFloat scale = 1.0;
     CGFloat _imageWidth = self.bounds.size.width*scale;
     CGFloat _imageHeight = self.bounds.size.height*scale;
     CGContextRef ctx = CGBitmapContextCreate(NULL, _imageWidth, _imageHeight,
     CGImageGetBitsPerComponent(result.CGImage), 0,
     CGImageGetColorSpace(result.CGImage),
     CGImageGetBitmapInfo(result.CGImage));
     
     CGAffineTransform transform = CGAffineTransformIdentity;
     transform = CGAffineTransformTranslate(transform, _imageWidth, _imageHeight);
     transform = CGAffineTransformRotate(transform, M_PI);
     
     transform = CGAffineTransformTranslate(transform, _imageWidth, 0);
     transform = CGAffineTransformScale(transform, -1, 1);//镜面翻转
     
     CGContextConcatCTM(ctx, transform);
     
     CGContextDrawImage(ctx, CGRectMake(0,0,_imageWidth,_imageHeight), result.CGImage);
     
     CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
     result = [UIImage imageWithCGImage:cgimg scale:scale orientation:0];
     CGContextRelease(ctx);
     CGImageRelease(cgimg);
     //*/
    //模糊效果
    //result = [result imageByBlurExtraLight];
    //result = [result imageByBlurRadius:28 tintColor:[UIColor colorWithWhite:0 alpha:.28] tintMode:kCGBlendModeNormal saturation:2 maskImage:nil];
    //result = result.imageByFlipVertical;
    [self fillShadowWithColor:nil image:result];
    self.blurImage = result;
    
    /*
     NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/2.jpg"];
     NSData *data = UIImageJPEGRepresentation(result, 1);
     [data writeToFile:path atomically:YES];
     //*/
    
}

- (void)fillShadowWithColor:(UIColor *)color image:(UIImage *)image{
    //直接改变fillcolur 会有白屏闪烁 所以直接添加新的 再移除老的.
    
    CGFloat width = CGRectGetWidth(self.bounds)-30;
    MaskShadowLyer *_layer = [[MaskShadowLyer alloc] initWithRaidus:0 type:ClipTypeCycle shapeSize:CGSizeMake(width, width) viewSize:self.bounds.size];
    
    if (image){//图片优先
        _layer.fillColor = [UIColor colorWithPatternImage:image].CGColor;
    }else if (color) {
        _layer.fillColor = color.CGColor;
    }else {
        _layer.fillColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
    }
    //背景颜色调整
    if (color == [UIColor blackColor]) {
        self.backgroundColor = color;
    }else {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    [self.layer addSublayer:_layer];
    if (_shadowLayer) {//如果有先移除
        [_shadowLayer removeFromSuperlayer];
        _shadowLayer = nil;
    }
    self.shadowLayer = _layer;
}
- (void)copyToOtherView:(ShowImageView *)view{
    //view.zoomImageView.transform = _zoomImageView.transform;
    view.zoomScrollView.zoomScale = _zoomScrollView.zoomScale;
    view.zoomScrollView.contentOffset = _zoomScrollView.contentOffset;
}
#pragma mark - setter getter
- (void)setLimitCycle:(BOOL)limitCycle{
    if (_limitCycle == limitCycle) {
        return;
    }
    _limitCycle = limitCycle;
    //if (_limitCycle) {
    //_showFullView = YES;
    //}
    [self updateZoomViews];
}
- (void)setBlurShadow:(BOOL)blurShadow{
    if (_blurShadow == blurShadow) {
        return;
    }
    _blurShadow = blurShadow;
    
    
    [self updateBlurShadow];
    
}

- (void)setShowFullView:(BOOL)showFullView{
    if (_showFullView != showFullView) {
        _showFullView = showFullView;
        [self updateZoomViews];
    }
}

- (void)setMaxScale:(CGFloat)maxScale{
    if (_maxScale != maxScale) {
        _zoomScrollView.maximumZoomScale = maxScale;
    }
}
- (void)setMinScale:(CGFloat)minScale{
    if (_minScale != minScale) {
        _zoomScrollView.minimumZoomScale = minScale;
    }
}

- (void)setImage:(UIImage *)image{
    if (_image != image) {
        _image = image;
        
        CGSize imageSize = self.image.size;
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat width = imageSize.width / scale;
        CGFloat height = imageSize.height / scale;
        
        self.zoomImageView.image = image;
        _zoomImageView.bounds = CGRectMake(0, 0, width, height);
        
        [self updateZoomViews];
    }
}
- (void)setShowFullImage:(BOOL)showFullImage{
    if (_showFullImage == showFullImage) {
        return;
    }
    _showFullImage = showFullImage;
    self.userInteractionEnabled = !showFullImage;
    [self updateZoomViews];
}
- (void)setUnLimit:(BOOL)unLimit{
    if (_unLimit != unLimit) {
        _unLimit = unLimit;
        [self updateZoomViews];
    }
    
}
- (void)setNewUnLimit:(BOOL)newUnLimit{
    if (_newUnLimit == newUnLimit) {
        return;
    }
    _newUnLimit = newUnLimit;
    _zoomScrollView.hidden = _newUnLimit;
    
    if (_newUnLimit) {
        [self addSubview:_zoomImageView];
        self.panGesture.enabled = YES;
        self.pinchGesture.enabled = YES;
        
        
        
    }else {
        _panGesture.enabled = NO;
        _pinchGesture.enabled = NO;
    }
    [self updateZoomViews];
}
- (void)setUnLimitBackgroundColor:(UIColor *)unLimitBackgroundColor{
    if (_unLimitBackgroundColor == unLimitBackgroundColor) {
        return;
    }
    _unLimitBackgroundColor = unLimitBackgroundColor;
    self.backgroundColor = unLimitBackgroundColor;
}

- (void)setShouldRotate:(BOOL)shouldRotate{
    if (_shouldRotate == shouldRotate) {
        return;
    }
    _shouldRotate = shouldRotate;
    if (_shouldRotate) {
        if (_rotateGesture==nil) {
            UIRotationGestureRecognizer *rota = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(onRotationGesture:)];
            [self addGestureRecognizer:rota];
            self.rotateGesture = rota;
        }
    }
    _rotateGesture.enabled = _shouldRotate;
}


- (UIPanGestureRecognizer *)panGesture{
    if (_panGesture) {
        return _panGesture;
    }
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)];
    [self addGestureRecognizer:_panGesture];
    return _panGesture;
}
- (UIPinchGestureRecognizer *)pinchGesture{
    if (_pinchGesture) {
        return _pinchGesture;
    }
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinchGesture:)];
    [self addGestureRecognizer:_pinchGesture];
    return _pinchGesture;
}
/*
- (void)setSecondOptionType:(NSInteger)secondOptionType{
    if (secondOptionType == CycleOptionTypeCrop) {
        //排除crop
    }else {
        _secondOptionType = secondOptionType;
    }
}//*/
#pragma mark - privite
- (UIImage *)snapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}
-(UIImage *)boxblurImage:(UIImage *)image withBlurNumber:(CGFloat)blur
{
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    CGImageRef img = image.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    //从CGImage中获取数据
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    //设置从CGImage获取对象的属性
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate( outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    //clean up CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    return returnImage;
}

#pragma mark - ZoomScale
- (CGFloat)getMinimumZoomScale {
    CGFloat miniScale = 0;
    //CGSize imageSize = self.image.size;
    miniScale = self.clipRect.size.width / self.zoomImageView.frame.size.width;
    miniScale = MAX(miniScale, self.clipRect.size.height / self.zoomImageView.frame.size.height);
    return miniScale;
}

- (CGFloat)getScreenScale {
    CGFloat scale = self.frame.size.width / self.zoomImageView.frame.size.width;
    if (_showFullView) {
        scale = MAX(scale, self.clipRect.size.height / self.zoomImageView.frame.size.height);
    }else {
        scale = MIN(scale, self.clipRect.size.height / self.zoomImageView.frame.size.height);
    }
    return scale;
}

#pragma mark - zoomScrollView
- (UIScrollView *)zoomScrollView {
    if (_zoomScrollView == nil) {
        _zoomScrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _zoomScrollView.delegate = self;
        _zoomScrollView.bouncesZoom = YES;
        _zoomScrollView.showsHorizontalScrollIndicator = NO;
        _zoomScrollView.showsVerticalScrollIndicator = NO;
        _zoomScrollView.backgroundColor = [UIColor clearColor];
        _zoomScrollView.clipsToBounds = NO;
    }
    return _zoomScrollView;
}
- (UIImageView *)zoomImageView {
    if (_zoomImageView == nil) {
        _zoomImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _zoomImageView.contentMode = UIViewContentModeScaleAspectFit;
        //_zoomImageView.clipsToBounds = YES;
        _zoomImageView.userInteractionEnabled = YES;
        _zoomImageView.backgroundColor = [UIColor clearColor];
    }
    return _zoomImageView;
}

#pragma mark - UIGestureRecognizer
- (void)addDoubleTapGesture{
    /*
    @weakify(self);
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *sender) {
        @strongify(self);
        CGFloat newZoomScale = 1;
        //双击回到缩放大小.
        CGFloat shouldBackScale = _maxCurrScale;
        if (self.zoomScrollView.zoomScale != shouldBackScale) {
            newZoomScale = shouldBackScale;
        }else{
            newZoomScale = self.zoomScrollView.maximumZoomScale;
        }
        if (_unLimit) {
            CGPoint touchPoint = [sender locationInView:_zoomScrollView];
            _doubleTapPoint = touchPoint;
            [self.zoomScrollView setZoomScale:newZoomScale animated:YES];
        }else {
            //移动点击位置到中心.
            CGPoint touchPoint = [sender locationInView:_zoomImageView];
            CGFloat xsize = self.width / newZoomScale;
            CGFloat ysize = self.height / newZoomScale;
            CGRect toRect = CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize);
            _isDoubleTap = YES;
            [self.zoomScrollView zoomToRect:toRect animated:YES];
        }
        
    }];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
     //*/
}
- (void)onPanGesture:(UIPanGestureRecognizer *)sender{
    static NSInteger lastFinger;
    static CGPoint lastPoint;
    static CGPoint lastCenter;
    CGPoint curPoint = [sender locationInView:self];
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            lastPoint = curPoint;
            lastCenter = _zoomImageView.center;
            lastFinger = sender.numberOfTouches;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            if (lastFinger != sender.numberOfTouches) {
                lastPoint = curPoint;
                lastCenter = _zoomImageView.center;
                lastFinger = sender.numberOfTouches;
                //break;
            }
            CGPoint toPoint = self.center;
            toPoint.x = lastCenter.x + curPoint.x - lastPoint.x;
            toPoint.y = lastCenter.y + curPoint.y - lastPoint.y;
            _zoomImageView.center = toPoint;
        }
            break;
        case UIGestureRecognizerStateEnded:{
            [self updateItemLimit];
        }
            break;
            
        default:
            break;
    }
}

- (void)onPinchGesture:(UIPinchGestureRecognizer *)sender{
    static CGFloat lastScale;
    static CGFloat lastWidth;
    CGFloat curScale = sender.scale;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            lastScale = curScale;
            lastWidth = _zoomImageView.bounds.size.width;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            
            CGFloat offsetScale = curScale - lastScale + 1;
            
            CGFloat toWidth = offsetScale * lastWidth;
            //GKLOG(@"toWidth======= %f", toWidth);
            _zoomImageView.bounds = CGRectMake(0, 0, toWidth, toWidth);
        }
            break;
        case UIGestureRecognizerStateEnded:{
            [self updateItemLimit];
        }
            break;
            
        default:
            break;
    }
}

- (void)onRotationGesture:(UIRotationGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _lastRotation = gesture.rotation;
        if (_blurShadow) {
            [self fillShadowWithColor:[UIColor colorWithWhite:0 alpha:.5] image:nil];
        }
    }else if (gesture.state == UIGestureRecognizerStateChanged){
        if (_newUnLimit) {
            _zoomImageView.transform = CGAffineTransformRotate(_zoomImageView.transform, gesture.rotation-_lastRotation);
        }else {
            _zoomScrollView.transform = CGAffineTransformRotate(_zoomScrollView.transform, gesture.rotation-_lastRotation);
        }
        _lastRotation = gesture.rotation;
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        [self updateBlurShadow];
        [self updateItemLimit];
    }
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_blurShadow) {
        [self fillShadowWithColor:[UIColor colorWithWhite:0 alpha:.5] image:nil];
    }
}
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if (_unLimit) {
        //[scrollView setContentOffset:scrollView.contentOffset animated:YES];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //self.custormShadowLayer.fillColor = [UIColor colorWithPatternImage:[self getCurrImage]].CGColor;
    [self updateBlurShadow];
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if (CGPointEqualToPoint(velocity, CGPointZero)) {
        [self updateBlurShadow];
    }
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.zoomImageView;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    _lastScale = _zoomScrollView.zoomScale;
    _lastPoint = _zoomScrollView.contentOffset;
    if (_blurShadow) {
        [self fillShadowWithColor:[UIColor colorWithWhite:0 alpha:.5] image:nil];
    }
    //UIPinchGestureRecognizer *pinch = scrollView.pinchGestureRecognizer;
    //_lastPoint = [pinch locationInView:_zoomImageView];
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGSize contentSize = scrollView.contentSize;
    CGFloat zoomSacle = _zoomScrollView.zoomScale/_lastScale;
    
    CGPoint contentOffset = CGPointZero;
    
    self.zoomImageView.transform = CGAffineTransformMakeScale(scrollView.zoomScale, scrollView.zoomScale);
    
    CGFloat pointX = 0, pointY = 0;
    CGFloat halfWidth = self.frame.size.width/2;
    
    CGPoint centerPoint = _zoomImageView.center;
    
    if (_unLimit) {
        CGFloat _appendWidth = self.frame.size.width*2 - 20;
        contentSize.height = _appendWidth + _zoomImageView.frame.size.height;
        contentSize.width = _appendWidth + _zoomImageView.frame.size.width;
        
        centerPoint = CGPointMake(contentSize.width/2, contentSize.height/2);
        
        CGFloat halfAppendWidth = _appendWidth/2;
        _halfAppendWidth = halfAppendWidth;
        if (CGPointEqualToPoint(CGPointZero, _doubleTapPoint)) {
            //边框appendWidth固定  缩放前要去除边框  缩放后再追加边框或者其他
            //*//居中放大
            pointX = (_lastPoint.x-halfAppendWidth + halfWidth)*zoomSacle + halfAppendWidth - halfWidth;
            pointY = (_lastPoint.y-halfAppendWidth + halfWidth)*zoomSacle + halfAppendWidth - halfWidth;
            //*/
        }else {
            _lastPoint = _doubleTapPoint;
            _doubleTapPoint = CGPointZero;
            
            //contentOffset 是左上角 要追加宽度
            pointX = (_lastPoint.x-halfAppendWidth)*zoomSacle + halfAppendWidth - halfWidth;
            pointY = (_lastPoint.y-halfAppendWidth)*zoomSacle + halfAppendWidth - halfWidth;
            
            //*//防止超出边界
            pointX = MAX(0, pointX);
            pointY = MAX(0, pointY);
            pointX = MIN(contentSize.width-self.frame.size.width, pointX);
            pointY = MIN(contentSize.height-self.frame.size.height, pointY);
            //*/
        }
        
        
        contentOffset = CGPointMake(pointX, pointY);
        
        self.zoomImageView.center = centerPoint;
        
        scrollView.contentSize = contentSize;
        if (!_isDoubleTap) {
            [scrollView setContentOffset:contentOffset animated:NO];//有动画会跳闪
        }else {
            _isDoubleTap = NO;
        }
        
    }else {
        
        /*//居中放大.
         //contentOffset 是左上角 要追加宽度
         pointX = (_lastPoint.x+halfWidth)*zoomSacle - halfWidth;
         pointY = (_lastPoint.y+halfWidth)*zoomSacle - halfWidth;
         
         contentOffset = CGPointMake(pointX, pointY);
         
         self.zoomImageView.center = centerPoint;
         
         scrollView.contentSize = contentSize;
         if (!_isDoubleTap) {
         [scrollView setContentOffset:contentOffset animated:NO];//有动画会跳闪
         }else {
         _isDoubleTap = NO;
         }//*/
        
        //*/
        centerPoint = CGPointMake(contentSize.width/2, contentSize.height/2);
        CGRect imgFrame = self.zoomImageView.frame;
        
        CGSize boundsSize = scrollView.bounds.size;
        if (imgFrame.size.width <= boundsSize.width){
            centerPoint.x = boundsSize.width/2;
        }
        // center vertically
        if (imgFrame.size.height <= boundsSize.height){
            centerPoint.y = boundsSize.height/2;
        }//*/
        
        self.zoomImageView.center = centerPoint;
    }
    
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [self updateBlurShadow];
}
#pragma mark - System Method

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint scrollViewPoint = [self.zoomScrollView convertPoint:point fromView:self];
    if ([self.zoomScrollView pointInside:scrollViewPoint withEvent:event]) {
        return self.zoomScrollView;
    }
    return self.zoomScrollView;
}
@end
