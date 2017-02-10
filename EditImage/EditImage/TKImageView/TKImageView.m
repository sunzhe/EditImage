//
//  TKImageView.m
//  TKImageDemo
//
//  Created by yinyu on 16/7/10.
//  Copyright © 2016年 yinyu. All rights reserved.
//

#import "TKImageView.h"
#import "ShowImageView.h"
#define WIDTH(_view) CGRectGetWidth(_view.bounds)
#define HEIGHT(_view) CGRectGetHeight(_view.bounds)
#define MAXX(_view) CGRectGetMaxX(_view.frame)
#define MAXY(_view) CGRectGetMaxY(_view.frame)
#define MINX(_view) CGRectGetMinX(_view.frame)
#define MINY(_view) CGRectGetMinY(_view.frame)
#define MID_LINE_INTERACT_WIDTH 44
#define MID_LINE_INTERACT_HEIGHT 44
typedef NS_ENUM(NSInteger, TKCropAreaCornerPosition) {
    TKCropAreaCornerPositionTopLeft,
    TKCropAreaCornerPositionTopRight,
    TKCropAreaCornerPositionBottomLeft,
    TKCropAreaCornerPositionBottomRight
};
typedef NS_ENUM(NSInteger, TKMidLineType) {
    
    TKMidLineTypeTop,
    TKMidLineTypeBottom,
    TKMidLineTypeLeft,
    TKMidLineTypeRight
    
};
@interface UIImage(Handler)
@end
@implementation UIImage(Handler)
- (UIImage *)imageAtRect:(CGRect)rect
{
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage* subImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    
    return subImage;
    
}
@end
@interface CornerView: UIView

@property (assign, nonatomic) CGFloat lineWidth;
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) TKCropAreaCornerPosition cornerPosition;
@property (assign, nonatomic) CornerView *relativeViewX;
@property (assign, nonatomic) CornerView *relativeViewY;
@property (strong, nonatomic) CAShapeLayer *cornerShapeLayer;

- (void)updateSizeWithWidth: (CGFloat)width height: (CGFloat)height;
@end
@implementation CornerView
- (instancetype)initWithFrame:(CGRect)frame lineColor: (UIColor *)lineColor lineWidth: (CGFloat)lineWidth {
    
    self = [super initWithFrame: frame];
    if(self) {
        self.lineColor = lineColor;
        self.lineWidth = lineWidth;
    }
    return self;
}
- (void)setCornerPosition:(TKCropAreaCornerPosition)cornerPosition {
    
    _cornerPosition = cornerPosition;
    [self drawCornerLines];
    
}
- (void)setLineWidth:(CGFloat)lineWidth {
    
    _lineWidth = lineWidth;
    [self drawCornerLines];
    
}
- (void)drawCornerLines {
    
    if(_cornerShapeLayer && _cornerShapeLayer.superlayer) {
        [_cornerShapeLayer removeFromSuperlayer];
    }
    _cornerShapeLayer = [CAShapeLayer layer];
    _cornerShapeLayer.lineWidth = _lineWidth;
    _cornerShapeLayer.strokeColor = _lineColor.CGColor;
    _cornerShapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    UIBezierPath *cornerPath = [UIBezierPath bezierPath];
    CGFloat paddingX = _lineWidth / 2.0f;
    CGFloat paddingY = _lineWidth / 2.0f;
    switch (_cornerPosition) {
        case TKCropAreaCornerPositionTopLeft: {
            [cornerPath moveToPoint:CGPointMake(WIDTH(self), paddingY)];
            [cornerPath addLineToPoint:CGPointMake(paddingX, paddingY)];
            [cornerPath addLineToPoint:CGPointMake(paddingX, HEIGHT(self))];
            break;
        }
        case TKCropAreaCornerPositionTopRight: {
            [cornerPath moveToPoint:CGPointMake(0, paddingY)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self) - paddingX, paddingY)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self) - paddingX, HEIGHT(self))];
            break;
        }
        case TKCropAreaCornerPositionBottomLeft: {
            [cornerPath moveToPoint:CGPointMake(paddingX, 0)];
            [cornerPath addLineToPoint:CGPointMake(paddingX, HEIGHT(self) - paddingY)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self), HEIGHT(self) - paddingY)];
            break;
        }
        case TKCropAreaCornerPositionBottomRight: {
            [cornerPath moveToPoint:CGPointMake(WIDTH(self) - paddingX, 0)];
            [cornerPath addLineToPoint:CGPointMake(WIDTH(self) - paddingX, HEIGHT(self) - paddingY)];
            [cornerPath addLineToPoint:CGPointMake(0, HEIGHT(self) - paddingY)];
            break;
        }
        default:
            break;
    }
    _cornerShapeLayer.path = cornerPath.CGPath;
    [self.layer addSublayer: _cornerShapeLayer];
    
}
- (void)updateSizeWithWidth: (CGFloat)width height: (CGFloat)height {
    
    switch (_cornerPosition) {
        case TKCropAreaCornerPositionTopLeft: {
            self.frame = CGRectMake(MINX(self), MINY(self), width, height);
            break;
        }
        case TKCropAreaCornerPositionTopRight: {
            self.frame = CGRectMake(MAXX(self) - width, MINY(self), width, height);
            break;
        }
        case TKCropAreaCornerPositionBottomLeft: {
            self.frame = CGRectMake(MINX(self), MAXY(self) - height, width, height);
            break;
        }
        case TKCropAreaCornerPositionBottomRight: {
            self.frame = CGRectMake(MAXX(self) - width, MAXY(self) - height, width, height);
            break;
        }
        default:
            break;
    }
    [self drawCornerLines];
    
}
- (void)setLineColor:(UIColor *)lineColor {
    
    _lineColor = lineColor;
    _cornerShapeLayer.strokeColor = lineColor.CGColor;
    
}
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
}
@end

@interface MidLineView : UIView
@property (strong, nonatomic) CAShapeLayer *lineLayer;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) CGFloat lineHeight;
@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) TKMidLineType type;
@property (strong, nonatomic) UIView *colorLine;
@end
@implementation MidLineView
- (instancetype)initWithLineWidth: (CGFloat)lineWidth lineHeight: (CGFloat)lineHeight lineColor: (UIColor *)lineColor {
    
    self = [super initWithFrame: CGRectMake(0, 0, MID_LINE_INTERACT_WIDTH, MID_LINE_INTERACT_HEIGHT)];
    if(self) {
        self.lineWidth = lineWidth;
        self.lineHeight = lineHeight;
        self.lineColor = lineColor;
        self.colorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, lineWidth, lineHeight)];
        [self addSubview:_colorLine];
    }
    return self;
    
}
- (void)setType:(TKMidLineType)type {
    
    _type = type;
    [self updateMidLine];
    
}
- (void)setLineWidth:(CGFloat)lineWidth {
    
    _lineWidth = lineWidth;
    [self updateMidLine];
    
}
- (void)setLineColor:(UIColor *)lineColor {
    _colorLine.backgroundColor = lineColor;
    _lineColor = lineColor;
    _lineLayer.strokeColor = lineColor.CGColor;
    
}
- (void)setLineHeight:(CGFloat)lineHeight {
    
    _lineHeight = lineHeight;
    _lineLayer.lineWidth = lineHeight;
    
}
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self updateMidLine];
}

- (void)updateMidLine{
    switch (_type) {
        case TKMidLineTypeTop:{
        case TKMidLineTypeBottom: {
            _colorLine.frame = CGRectMake(-_lineHeight, (HEIGHT(self)-_lineHeight) / 2.0, WIDTH(self)+_lineHeight*2, _lineHeight);
            break;
        }
        case TKMidLineTypeRight:
        case TKMidLineTypeLeft: {
            _colorLine.frame = CGRectMake((WIDTH(self)-_lineHeight) / 2.0, -_lineHeight, _lineHeight, HEIGHT(self)+_lineHeight*2);
            break;
        }
        default:
            break;
        }
    }
}

- (void)drawMidLine {
    
    if(_lineLayer && _lineLayer.superlayer) {
        [_lineLayer removeFromSuperlayer];
    }
    _lineLayer = [CAShapeLayer layer];
    _lineLayer.strokeColor = _lineColor.CGColor;
    _lineLayer.lineWidth = _lineHeight;
    _lineLayer.fillColor = [UIColor clearColor].CGColor;
    
    UIBezierPath *midLinePath = [UIBezierPath bezierPath];
    switch (_type) {
        case TKMidLineTypeTop:
        case TKMidLineTypeBottom: {
            [midLinePath moveToPoint:CGPointMake((WIDTH(self) - _lineWidth) / 2.0, HEIGHT(self) / 2.0)];
            [midLinePath addLineToPoint:CGPointMake((WIDTH(self) + _lineWidth) / 2.0, HEIGHT(self) / 2.0)];
            break;
        }
        case TKMidLineTypeRight:
        case TKMidLineTypeLeft: {
            [midLinePath moveToPoint:CGPointMake(WIDTH(self) / 2.0, (HEIGHT(self) - _lineWidth) / 2.0)];
            [midLinePath addLineToPoint:CGPointMake(WIDTH(self) / 2.0, (HEIGHT(self) + _lineWidth) / 2.0)];
            break;
        }
        default:
            break;
    }
    _lineLayer.path = midLinePath.CGPath;
    [self.layer addSublayer: _lineLayer];
    
}
@end

@interface CropAreaView : UIView
@property (strong, nonatomic) CAShapeLayer *crossLineLayer;
@property (assign, nonatomic) CGFloat crossLineWidth;
@property (strong, nonatomic) UIColor *crossLineColor;
@property (strong, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) CGFloat borderWidth;
@property (strong, nonatomic) CAShapeLayer *borderLayer;
@property (assign, nonatomic) BOOL showCrossLines;
@property (assign, nonatomic) UIView *imageView;
@end
@implementation CropAreaView

- (instancetype)init {
    
    self = [super init];
    if(self) {
        [self createBorderLayer];
    }
    return self;
}
- (void)setFrame:(CGRect)frame {
    
    [super setFrame: frame];
    if(_showCrossLines) {
        [self showCrossLineLayer];
    }
    [self resetBorderLayerPath];
    
}
- (void)setBounds:(CGRect)bounds {
    
    [super setBounds:bounds];
    if(_showCrossLines) {
        [self showCrossLineLayer];
    }
    [self resetBorderLayerPath];
    
}
- (void)showCrossLineLayer {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(WIDTH(self) / 3.0, 0)];
    [path addLineToPoint: CGPointMake(WIDTH(self) / 3.0, HEIGHT(self))];
    [path moveToPoint:CGPointMake(WIDTH(self) / 3.0 * 2.0, 0)];
    [path addLineToPoint: CGPointMake(WIDTH(self) / 3.0 * 2.0, HEIGHT(self))];
    [path moveToPoint:CGPointMake(0, HEIGHT(self) / 3.0)];
    [path addLineToPoint: CGPointMake(WIDTH(self), HEIGHT(self) / 3.0)];
    [path moveToPoint:CGPointMake(0, HEIGHT(self) / 3.0 * 2.0)];
    [path addLineToPoint: CGPointMake(WIDTH(self), HEIGHT(self) / 3.0 * 2.0)];
    if(!_crossLineLayer) {
        _crossLineLayer = [CAShapeLayer layer];
        [self.layer addSublayer: _crossLineLayer];
    }
    _crossLineLayer.lineWidth = _crossLineWidth;
    _crossLineLayer.strokeColor = _crossLineColor.CGColor;
    _crossLineLayer.path = path.CGPath;
    
}
- (void)setCrossLineWidth:(CGFloat)crossLineWidth {
    
    _crossLineWidth = crossLineWidth;
    _crossLineLayer.lineWidth = crossLineWidth;
    
}
- (void)setCrossLineColor:(UIColor *)crossLineColor {
    
    _crossLineColor = crossLineColor;
    _crossLineLayer.strokeColor = crossLineColor.CGColor;
    
}
- (void)setShowCrossLines:(BOOL)showCrossLines {
    
    if(_showCrossLines && !showCrossLines) {
        [_crossLineLayer removeFromSuperlayer];
        _crossLineLayer = nil;
    }
    else if(!_showCrossLines && showCrossLines) {
        [self showCrossLineLayer];
    }
    _showCrossLines = showCrossLines;
    
}
- (void)createBorderLayer {
    
    if(_borderLayer && _borderLayer.superlayer) {
        [_borderLayer removeFromSuperlayer];
    }
    _borderLayer = [CAShapeLayer layer];
    [self.layer addSublayer: _borderLayer];
    
}
- (void)resetBorderLayerPath {
    return;
    UIBezierPath *layerPath = [UIBezierPath bezierPathWithRect: CGRectMake(_borderWidth / 2.0f, _borderWidth / 2.0f, WIDTH(self) - _borderWidth, HEIGHT(self) - _borderWidth)];
    _borderLayer.lineWidth = _borderWidth;
    _borderLayer.fillColor = nil;
    _borderLayer.path = layerPath.CGPath;
    
}
- (void)setBorderWidth:(CGFloat)borderWidth {
    
    _borderWidth = borderWidth;
    [self resetBorderLayerPath];
    
}
- (void)setBorderColor:(UIColor *)borderColor {
    
    _borderColor = borderColor;
    _borderLayer.strokeColor = borderColor.CGColor;
    
}
@end
@interface TKImageView(){
    
    NSInteger _lastCornnerFinger;
    CGPoint _lastCornnerPoint;
}

@property (strong, nonatomic) UIView *cropMaskView;
@property (strong, nonatomic) ShowImageView *imageView;
@property (strong, nonatomic) CornerView *topLeftCorner;
@property (strong, nonatomic) CornerView *topRightCorner;
@property (strong, nonatomic) CornerView *bottomLeftCorner;
@property (strong, nonatomic) CornerView *bottomRightCorner;
@property (strong, nonatomic) CropAreaView *cropAreaView;
@property (strong, nonatomic) UIPanGestureRecognizer *topLeftPan;
@property (strong, nonatomic) UIPanGestureRecognizer *topRightPan;
@property (strong, nonatomic) UIPanGestureRecognizer *bottomLeftPan;
@property (strong, nonatomic) UIPanGestureRecognizer *bottomRightPan;
@property (strong, nonatomic) UIPanGestureRecognizer *cropAreaPan;
@property (strong, nonatomic) UIPanGestureRecognizer *imagePan;
@property (strong, nonatomic) UIPinchGestureRecognizer *cropAreaPinch;
@property (strong, nonatomic) UIPinchGestureRecognizer *imagePinch;
@property (assign, nonatomic) CGSize pinchOriSize;
@property (assign, nonatomic) CGPoint cropAreaOriCenter;
@property (assign, nonatomic) CGRect cropAreaOriFrame;
@property (strong, nonatomic) MidLineView *topMidLine;
@property (strong, nonatomic) MidLineView *leftMidLine;
@property (strong, nonatomic) MidLineView *bottomMidLine;
@property (strong, nonatomic) MidLineView *rightMidLine;
@property (strong, nonatomic) UIPanGestureRecognizer *topMidPan;
@property (strong, nonatomic) UIPanGestureRecognizer *bottomMidPan;
@property (strong, nonatomic) UIPanGestureRecognizer *leftMidPan;
@property (strong, nonatomic) UIPanGestureRecognizer *rightMidPan;
@property (assign, nonatomic) CGFloat paddingLeftRight;
@property (assign, nonatomic) CGFloat paddingTopBottom;
@property (assign, nonatomic) CGFloat imageAspectRatio;
@property (assign, nonatomic, readonly) CGFloat cornerMargin;
@end
@implementation TKImageView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame: frame];
    if(self) {
        [self commonInit];
    }
    return self;
    
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder: aDecoder];
    if(self) {
        [self commonInit];
    }
    return self;
    
}
- (void)commonInit {
    
    [self setUp];
    [self createCorners];
    [self resetCropAreaOnCornersFrameChanged];
    [self bindPanGestures];
    
}
- (void)dealloc {
    
    [_cropAreaView removeObserver: self forKeyPath: @"frame"];
    [_cropAreaView removeObserver: self forKeyPath: @"center"];
    
}
- (void)setUp {
    
    _imageView = [[ShowImageView alloc]initWithFrame: self.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = NO;
    _imageView.userInteractionEnabled = YES;
    _imageView.cropChangeEnable = YES;
    _imageAspectRatio = 0;
    [self addSubview: _imageView];
    
    _cropMaskView = [[UIView alloc]initWithFrame: _imageView.frame];
    _cropMaskView.userInteractionEnabled = NO;
    _cropMaskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _cropMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview: _cropMaskView];
    
    UIColor *defaultColor = [UIColor colorWithWhite: 1 alpha: 0.8];
    _cropAreaBorderLineColor = defaultColor;
    _cropAreaCornerLineColor = [UIColor whiteColor];
    _cropAreaBorderLineWidth = 4;
    _cropAreaCornerLineWidth = 6;
    _cropAreaCornerWidth = 30;
    _cropAreaCornerHeight = 30;
    _cropAspectRatio = 0;
    _minSpace = 30;
    _cropAreaCrossLineWidth = 4;
    _cropAreaCrossLineColor = defaultColor;
    _cropAreaMidLineWidth = 40;
    _cropAreaMidLineHeight = 6;
    _cropAreaMidLineColor = defaultColor;
    
    _cropAreaView = [[CropAreaView alloc] init];
    _cropAreaView.userInteractionEnabled = NO;
    _cropAreaView.borderWidth = _cropAreaBorderLineWidth;
    _cropAreaView.borderColor = _cropAreaBorderLineColor;
    _cropAreaView.crossLineColor = _cropAreaCrossLineColor;
    _cropAreaView.crossLineWidth = _cropAreaCrossLineWidth;
    _cropAreaView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview: _cropAreaView];
    _cropAreaView.imageView = _imageView;
    
    [_cropAreaView addObserver: self
                    forKeyPath: @"frame"
                       options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                       context: NULL];
    [_cropAreaView addObserver: self
                    forKeyPath: @"center"
                       options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                       context: NULL];
    
}

- (void)autoAdjustViews{
    CGRect cropRect = _cropAreaView.frame;
    CGRect willRect = self.cropAreaViewWillFrame;
    CGFloat scale = willRect.size.width/cropRect.size.width;
    
    CGRect imageRect = _imageView.frame;
    CGRect imageWillRect = CGRectMake(imageRect.origin.x*scale, imageRect.origin.y*scale, imageRect.size.width*scale, imageRect.size.height*scale);
    //先 放大 移动
    CGRect cropWillRect = CGRectMake(cropRect.origin.x*scale, cropRect.origin.y*scale, cropRect.size.width*scale, cropRect.size.height*scale);
    imageWillRect.origin.x += willRect.origin.x-cropWillRect.origin.x;
    imageWillRect.origin.y += willRect.origin.y-cropWillRect.origin.y;
    
    [self animationCropTransparentAreaFromRect:cropRect toRect:willRect];
    
    CGFloat zoomScale = _imageView.zoomScrollView.zoomScale*scale;
    
    CGPoint offset = _imageView.zoomScrollView.contentOffset;
    CGPoint point = _imageView.zoomScrollView.frame.origin;//image当前位置
    offset.x += (cropRect.origin.x - point.x);
    offset.y += (cropRect.origin.y - point.y);
    
    offset.x *= scale;
    offset.y *= scale;
    
    [UIView animateWithDuration:0.3 animations:^{
        _cropAreaView.frame = willRect;
        [self resetCornersOnCropAreaFrameChanged];
        
        //改变图片frame  放大居中
        [_imageView updateCropRect:willRect reset:NO];
        [_imageView.zoomScrollView setZoomScale:zoomScale animated:NO];
        [_imageView.zoomScrollView setContentOffset:offset animated:NO];
        //_imageView.frame = imageWillRect;
        
        //[self resetCropTransparentArea];
    } completion:^(BOOL finished) {
        //self.showMidLines = YES;
    }];
}
- (void)autoAdjustImageView:(BOOL)animation{
    _currCropAspectRatio = _cropAreaView.frame.size.width/_cropAreaView.frame.size.height;
    //return;
    CGRect imageRect = _imageView.zoomImageView.frame;
    CGRect cropRect = _cropAreaView.frame;
    
    if (CGRectContainsRect(_imageView.zoomScrollView.frame, cropRect)) {
        //没有超出边界 不用处理
        return;
    }
    
    CGFloat scaleWidth = cropRect.size.width/imageRect.size.width;
    CGFloat scaleHeight = cropRect.size.height/imageRect.size.height;
    CGFloat maxScale = MAX(scaleWidth, scaleHeight);
    if (maxScale > 1) {
        //maxScale = _imageView.zoomScrollView.zoomScale*maxScale;
    }
    
    if (animation) {
        [UIView animateWithDuration:.3 animations:^{
            _imageView.zoomScrollView.frame = cropRect;
            //[_imageView updateCropRect:imageRect reset:NO];
            //_imageView.frame = imageRect;
        }];
    }else {
        _imageView.zoomScrollView.frame = cropRect;
        if (maxScale>1) {
            [_imageView.zoomScrollView setZoomScale:_imageView.zoomScrollView.zoomScale*maxScale animated:NO];
        }
        //[_imageView updateCropRect:imageRect reset:NO];
        //_imageView.frame = imageRect;
    }
}
#pragma mark - PanGesture Bind
- (void)bindPanGestures {
    
    _topLeftPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCornerPan:)];
    _topRightPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCornerPan:)];
    _bottomLeftPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCornerPan:)];
    _bottomRightPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCornerPan:)];
    //_cropAreaPan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleCropAreaPan:)];
    //_imagePan = [[UIPanGestureRecognizer alloc]initWithTarget: self action: @selector(handleImagePan:)];
    
    [_topLeftCorner addGestureRecognizer: _topLeftPan];
    [_topRightCorner addGestureRecognizer: _topRightPan];
    [_bottomLeftCorner addGestureRecognizer: _bottomLeftPan];
    [_bottomRightCorner addGestureRecognizer: _bottomRightPan];
    //[_cropAreaView addGestureRecognizer: _cropAreaPan];
    //[self addGestureRecognizer:_imagePan];
    
}
#pragma mark - PinchGesture CallBack
- (void)handleImagePinch: (UIPinchGestureRecognizer *)sender {
    
    static CGFloat lastScale;
    static CGFloat lastWidth;
    static CGFloat lastHeight;
    CGFloat curScale = sender.scale;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            lastScale = curScale;
            lastWidth = _imageView.bounds.size.width;
            lastHeight = _imageView.bounds.size.height;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            
            CGFloat offsetScale = curScale - lastScale + 1;
            
            CGFloat toWidth = offsetScale * lastWidth;
            CGFloat toHeight =offsetScale * lastHeight;
            
            _imageView.bounds = CGRectMake(0, 0, toWidth, toHeight);
            
        }
            break;
        case UIGestureRecognizerStateEnded:{
            [self autoAdjustImageView:YES];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)handleCropAreaPinch: (UIPinchGestureRecognizer *)pinchGesture {
    
    switch (pinchGesture.state) {
        case UIGestureRecognizerStateBegan: {
            _pinchOriSize = _cropAreaView.frame.size;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self resetCropAreaByScaleFactor: pinchGesture.scale];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self autoAdjustImageView:YES];
            [self autoAdjustViews];
            break;
        }
        default:
            break;
    }
    
}
#pragma mark - PanGesture CallBack

- (void)handleImagePan: (UIPanGestureRecognizer *)sender {
    static NSInteger lastFinger;
    static CGPoint lastPoint;
    static CGPoint lastCenter;
    CGPoint curPoint = [sender locationInView:self.superview];
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:{
            lastPoint = curPoint;
            lastCenter = _imageView.center;
            lastFinger = sender.numberOfTouches;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            if (lastFinger != sender.numberOfTouches) {
                lastPoint = curPoint;
                lastCenter = _imageView.center;
                lastFinger = sender.numberOfTouches;
                //break;
            }
            CGPoint toPoint = _imageView.center;
            toPoint.x = lastCenter.x + curPoint.x - lastPoint.x;
            toPoint.y = lastCenter.y + curPoint.y - lastPoint.y;
            _imageView.center = toPoint;
        }
            break;
        case UIGestureRecognizerStateEnded:{
            [self autoAdjustImageView:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)handleCropAreaPan: (UIPanGestureRecognizer *)panGesture {
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            _cropAreaOriCenter = _cropAreaView.center;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [panGesture translationInView: _imageView];
            CGPoint willCenter = CGPointMake(_cropAreaOriCenter.x + translation.x, _cropAreaOriCenter.y + translation.y);
            CGFloat centerMinX = WIDTH(_cropAreaView) / 2.0f + self.cornerMargin * _cornerBorderInImage ;
            CGFloat centerMaxX = WIDTH(_imageView) - WIDTH(_cropAreaView) / 2.0f - self.cornerMargin * _cornerBorderInImage;
            CGFloat centerMinY = HEIGHT(_cropAreaView) / 2.0f + self.cornerMargin * _cornerBorderInImage;
            CGFloat centerMaxY = HEIGHT(_imageView) - HEIGHT(_cropAreaView) / 2.0f - self.cornerMargin * _cornerBorderInImage;
            _cropAreaView.center = CGPointMake(MIN(MAX(centerMinX, willCenter.x), centerMaxX), MIN(MAX(centerMinY, willCenter.y), centerMaxY));
            [self resetCornersOnCropAreaFrameChanged];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self autoAdjustViews];
            break;
        }
        default:
            break;
    }
    
}
- (void)handleMidPan: (UIPanGestureRecognizer *)panGesture {
    
    MidLineView *midLineView = (MidLineView *)panGesture.view;
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            _cropAreaOriFrame = _cropAreaView.frame;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [panGesture translationInView: _cropAreaView];
            switch (midLineView.type) {
                case TKMidLineTypeTop: {
                    CGFloat minHeight = _minSpace + (_cropAreaCornerHeight - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth) * 2;
                    CGFloat maxHeight = CGRectGetMaxY(_cropAreaOriFrame) - (_cropAreaCornerLineWidth - _cropAreaBorderLineWidth);
                    CGFloat willHeight = MIN(MAX(minHeight, CGRectGetHeight(_cropAreaOriFrame) - translation.y), maxHeight);
                    CGFloat deltaY = willHeight - CGRectGetHeight(_cropAreaOriFrame);
                    if (_cropAspectRatio == 0) {
                        _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame), CGRectGetMinY(_cropAreaOriFrame) - deltaY, CGRectGetWidth(_cropAreaOriFrame), willHeight);
                    }else {
                        CGFloat width = _cropAspectRatio*willHeight;
                        if (width < minHeight) {
                            width = minHeight;
                            willHeight = width/_cropAspectRatio;
                        }
                        _cropAreaView.frame = CGRectMake((WIDTH(self)-width)/2, CGRectGetMinY(_cropAreaOriFrame) - deltaY, width, willHeight);
                    }
                    
                    break;
                }
                case TKMidLineTypeBottom: {
                    CGFloat minHeight = _minSpace + (_cropAreaCornerHeight - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth) * 2;
                    CGFloat maxHeight = HEIGHT(self) - CGRectGetMinY(_cropAreaOriFrame) - (_cropAreaCornerLineWidth - _cropAreaBorderLineWidth);
                    CGFloat willHeight = MIN(MAX(minHeight, CGRectGetHeight(_cropAreaOriFrame) + translation.y), maxHeight);
                    if (_cropAspectRatio == 0) {
                        _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame), CGRectGetMinY(_cropAreaOriFrame), CGRectGetWidth(_cropAreaOriFrame), willHeight);
                    }else {
                        CGFloat width = _cropAspectRatio*willHeight;
                        if (width < minHeight) {
                            width = minHeight;
                            willHeight = width/_cropAspectRatio;
                        }
                        _cropAreaView.frame = CGRectMake((WIDTH(self)-width)/2, CGRectGetMinY(_cropAreaOriFrame), width, willHeight);
                    }
                    break;
                }
                case TKMidLineTypeLeft: {
                    CGFloat minWidth = _minSpace + (_cropAreaCornerWidth - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth) * 2;
                    CGFloat maxWidth = CGRectGetMaxX(_cropAreaOriFrame) - (_cropAreaCornerLineWidth - _cropAreaBorderLineWidth);
                    CGFloat willWidth = MIN(MAX(minWidth, CGRectGetWidth(_cropAreaOriFrame) - translation.x), maxWidth);
                    CGFloat deltaX = willWidth - CGRectGetWidth(_cropAreaOriFrame);
                    if (_cropAspectRatio == 0) {
                        _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame) - deltaX, CGRectGetMinY(_cropAreaOriFrame), willWidth, CGRectGetHeight(_cropAreaOriFrame));
                    }else {
                        CGFloat height = willWidth/_cropAspectRatio;
                        if (height < minWidth) {
                            height = minWidth;
                            willWidth = height*_cropAspectRatio;
                        }
                        _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame) - deltaX, (HEIGHT(self)-height)/2, willWidth, height);
                    }
                    break;
                }
                case TKMidLineTypeRight: {
                    CGFloat minWidth = _minSpace + (_cropAreaCornerWidth - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth) * 2;
                    CGFloat maxWidth = WIDTH(self) - CGRectGetMinX(_cropAreaOriFrame) - (_cropAreaCornerLineWidth - _cropAreaBorderLineWidth);
                    CGFloat willWidth = MIN(MAX(minWidth, CGRectGetWidth(_cropAreaOriFrame) + translation.x), maxWidth);
                    if (_cropAspectRatio == 0) {
                        _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame), CGRectGetMinY(_cropAreaOriFrame), willWidth, CGRectGetHeight(_cropAreaOriFrame));
                    }else {
                        CGFloat height = willWidth/_cropAspectRatio;
                        if (height < minWidth) {
                            height = minWidth;
                            willWidth = height*_cropAspectRatio;
                        }
                        _cropAreaView.frame = CGRectMake(CGRectGetMinX(_cropAreaOriFrame), (HEIGHT(self)-height)/2, willWidth, height);
                    }
                    break;
                }
                default:
                    break;
            }
            [self resetCornersOnCropAreaFrameChanged];
            [self autoAdjustImageView:NO];
            [self resetCropTransparentArea];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self autoAdjustViews];
            break;
        }
        default:
            break;
    }
    
}
- (void)handleCornerPan: (UIPanGestureRecognizer *)panGesture {
    
    CornerView *panView = (CornerView *)panGesture.view;
    CornerView *relativeViewX = panView.relativeViewX;
    CornerView *relativeViewY = panView.relativeViewY;
    CGPoint curPoint = [panGesture locationInView:self];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            self.showCrossLines = YES;
            _lastCornnerPoint = CGPointMake(relativeViewY.center.x, relativeViewX.center.y);
            _lastCornnerFinger = panGesture.numberOfTouches;
        }
            break;
        case UIGestureRecognizerStateChanged:{
            if (_lastCornnerFinger != panGesture.numberOfTouches) {
                _lastCornnerPoint = CGPointMake(relativeViewY.center.x, relativeViewX.center.y);
                _lastCornnerFinger = panGesture.numberOfTouches;
                //break;
            }
            
            CGFloat minSpace = _minSpace;
            NSInteger xFactor = MINX(relativeViewY) > MINX(panView) ? -1 : 1;
            NSInteger yFactor = MINY(relativeViewX) > MINY(panView) ? -1 : 1;
            
            CGFloat offsetX = (curPoint.x - _lastCornnerPoint.x)*xFactor + _cropAreaCornerWidth;
            offsetX = MAX(_cropAreaCornerWidth*2 + minSpace, offsetX);
            
            CGFloat offsetY = (curPoint.y - _lastCornnerPoint.y)*yFactor + _cropAreaCornerHeight;
            offsetY = MAX(_cropAreaCornerHeight*2 + minSpace, offsetY);
            
            if(_cropAspectRatio > 0) {
                //基于x轴计算
                CGFloat tmpY = MAX(offsetX / _cropAspectRatio, minSpace + _cropAreaCornerHeight * 2);
                CGFloat tmpYX = tmpY * _cropAspectRatio;
                
                //基于y轴计算
                CGFloat tmpX = MAX(offsetY * _cropAspectRatio, _minSpace + _cropAreaCornerWidth * 2);
                CGFloat tmpXY = tmpX / _cropAspectRatio;
                
                //取变化较大的
                if((tmpYX > tmpX)) {
                    offsetX = tmpX;
                    offsetY = tmpXY;
                }else {
                    offsetY = tmpY;
                    offsetX = tmpYX;
                }
            }
            
            CGPoint toPoint = panView.center;
            toPoint.x = (offsetX - _cropAreaCornerWidth) * xFactor + _lastCornnerPoint.x;
            toPoint.y = (offsetY - _cropAreaCornerHeight) * yFactor + _lastCornnerPoint.y;
            
            panView.center = toPoint;
            
            relativeViewX.frame = CGRectMake(MINX(panView), MINY(relativeViewX), WIDTH(relativeViewX), HEIGHT(relativeViewX));
            relativeViewY.frame = CGRectMake(MINX(relativeViewY), MINY(panView), WIDTH(relativeViewY), HEIGHT(relativeViewY));
            
            [self resetCropAreaOnCornersFrameChanged];
            [self resetCropTransparentArea];
            [self autoAdjustImageView:NO];
        }
            break;
        case UIGestureRecognizerStateEnded:{
            self.showCrossLines = NO;
            [self autoAdjustViews];
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - Position/Resize Corners&CropArea
- (void)resetCornersOnCropAreaFrameChanged {
    
    _topLeftCorner.frame = CGRectMake(MINX(_cropAreaView) - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth, MINY(_cropAreaView) - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth, _cropAreaCornerWidth, _cropAreaCornerHeight);
    _topRightCorner.frame = CGRectMake(MAXX(_cropAreaView) - _cropAreaCornerWidth + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth, MINY(_cropAreaView) - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth, _cropAreaCornerWidth, _cropAreaCornerHeight);
    _bottomLeftCorner.frame = CGRectMake(MINX(_cropAreaView) - _cropAreaCornerLineWidth + _cropAreaBorderLineWidth, MAXY(_cropAreaView) - _cropAreaCornerHeight + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth, _cropAreaCornerWidth, _cropAreaCornerHeight);
    _bottomRightCorner.frame = CGRectMake(MAXX(_cropAreaView) - _cropAreaCornerWidth + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth, MAXY(_cropAreaView) - _cropAreaCornerHeight + _cropAreaCornerLineWidth - _cropAreaBorderLineWidth, _cropAreaCornerWidth, _cropAreaCornerHeight);
    
}

- (void)resetCropAreaOnCornersFrameChanged {
    
    _cropAreaView.frame = CGRectMake(MINX(_topLeftCorner) + self.cornerMargin, MINY(_topLeftCorner) + self.cornerMargin, MAXX(_topRightCorner) - MINX(_topLeftCorner) - self.cornerMargin * 2, MAXY(_bottomLeftCorner) - MINY(_topLeftCorner) - self.cornerMargin * 2);
}
- (void)resetCropTransparentArea {
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect: self.bounds];
    UIBezierPath *clearPath = [[UIBezierPath bezierPathWithRect: _cropAreaView.frame] bezierPathByReversingPath];
    [path appendPath: clearPath];
    CAShapeLayer *shapeLayer = (CAShapeLayer *)_cropMaskView.layer.mask;
    if(!shapeLayer) {
        shapeLayer = [CAShapeLayer layer];
        [_cropMaskView.layer setMask: shapeLayer];
    }
    shapeLayer.path = path.CGPath;
    
}

- (void)animationCropTransparentAreaFromRect:(CGRect)fromRect toRect:(CGRect)toRect{
    if (CGRectEqualToRect(fromRect, toRect)) {
        return;
    }
    CAShapeLayer *shapeLayer = (CAShapeLayer *)_cropMaskView.layer.mask;
    if(!shapeLayer) {
        shapeLayer = [CAShapeLayer layer];
        [_cropMaskView.layer setMask: shapeLayer];
    }
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.duration = 0.3;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect: self.bounds];
    UIBezierPath *clearPath = [[UIBezierPath bezierPathWithRect: fromRect] bezierPathByReversingPath];
    [path appendPath: clearPath];
    anim.fromValue = (__bridge id _Nullable)(path.CGPath);
    
    path = [UIBezierPath bezierPathWithRect: self.bounds];
    clearPath = [[UIBezierPath bezierPathWithRect: toRect] bezierPathByReversingPath];
    [path appendPath: clearPath];
    anim.toValue = (__bridge id _Nullable)(path.CGPath);
    shapeLayer.path = path.CGPath;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [shapeLayer addAnimation:anim forKey:nil];
}

- (void)resetCornersOnSizeChanged {
    
    [_topLeftCorner updateSizeWithWidth: _cropAreaCornerWidth height: _cropAreaCornerHeight];
    [_topRightCorner updateSizeWithWidth: _cropAreaCornerWidth height: _cropAreaCornerHeight];
    [_bottomLeftCorner updateSizeWithWidth: _cropAreaCornerWidth height: _cropAreaCornerHeight];
    [_bottomRightCorner updateSizeWithWidth: _cropAreaCornerWidth height: _cropAreaCornerHeight];
    
}
- (void)createCorners {
    _topLeftCorner = [[CornerView alloc]initWithFrame: CGRectMake(0, 0, _cropAreaCornerWidth, _cropAreaCornerHeight) lineColor:_cropAreaCornerLineColor lineWidth: _cropAreaCornerLineWidth];
    _topLeftCorner.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    _topLeftCorner.cornerPosition = TKCropAreaCornerPositionTopLeft;
    
    _topRightCorner = [[CornerView alloc]initWithFrame: CGRectMake(WIDTH(_imageView) -  _cropAreaCornerWidth, 0, _cropAreaCornerWidth, _cropAreaCornerHeight) lineColor: _cropAreaCornerLineColor lineWidth: _cropAreaCornerLineWidth];
    _topRightCorner.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    _topRightCorner.cornerPosition = TKCropAreaCornerPositionTopRight;
    
    _bottomLeftCorner = [[CornerView alloc]initWithFrame: CGRectMake(0, HEIGHT(_imageView) -  _cropAreaCornerHeight, _cropAreaCornerWidth, _cropAreaCornerHeight) lineColor: _cropAreaCornerLineColor lineWidth: _cropAreaCornerLineWidth];
    _bottomLeftCorner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    _bottomLeftCorner.cornerPosition = TKCropAreaCornerPositionBottomLeft;
    
    _bottomRightCorner = [[CornerView alloc]initWithFrame: CGRectMake(WIDTH(_imageView) - _cropAreaCornerWidth, HEIGHT(_imageView) -  _cropAreaCornerHeight, _cropAreaCornerWidth, _cropAreaCornerHeight) lineColor: _cropAreaCornerLineColor lineWidth: _cropAreaCornerLineWidth];
    _bottomRightCorner.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    _bottomRightCorner.cornerPosition = TKCropAreaCornerPositionBottomRight;
    
    _topLeftCorner.relativeViewX = _bottomLeftCorner;
    _topLeftCorner.relativeViewY = _topRightCorner;
    
    _topRightCorner.relativeViewX = _bottomRightCorner;
    _topRightCorner.relativeViewY = _topLeftCorner;
    
    _bottomLeftCorner.relativeViewX = _topLeftCorner;
    _bottomLeftCorner.relativeViewY = _bottomRightCorner;
    
    _bottomRightCorner.relativeViewX = _topRightCorner;
    _bottomRightCorner.relativeViewY = _bottomLeftCorner;
    
    [self addSubview: _topLeftCorner];
    [self addSubview: _topRightCorner];
    [self addSubview: _bottomLeftCorner];
    [self addSubview: _bottomRightCorner];
    
}
- (void)createMidLines {
    
    if(_topMidLine && _bottomMidLine && _leftMidLine && _rightMidLine) return;
    _topMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _topMidLine.type = TKMidLineTypeTop;
    
    _bottomMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _bottomMidLine.type = TKMidLineTypeBottom;
    
    _leftMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _leftMidLine.type = TKMidLineTypeLeft;
    
    _rightMidLine = [[MidLineView alloc]initWithLineWidth: _cropAreaMidLineWidth lineHeight: _cropAreaMidLineHeight lineColor: _cropAreaMidLineColor];
    _rightMidLine.type = TKMidLineTypeRight;
    
    _topMidPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(handleMidPan:)];
    [_topMidLine addGestureRecognizer: _topMidPan];
    
    _bottomMidPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(handleMidPan:)];
    [_bottomMidLine addGestureRecognizer: _bottomMidPan];
    
    _leftMidPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(handleMidPan:)];
    [_leftMidLine addGestureRecognizer: _leftMidPan];
    
    _rightMidPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action: @selector(handleMidPan:)];
    [_rightMidLine addGestureRecognizer: _rightMidPan];
    
    [self addSubview: _topMidLine];
    [self addSubview: _bottomMidLine];
    [self addSubview: _leftMidLine];
    [self addSubview: _rightMidLine];
    
}
- (void)removeMidLines {
    
    [_topMidLine removeFromSuperview];
    [_bottomMidLine removeFromSuperview];
    [_leftMidLine removeFromSuperview];
    [_rightMidLine removeFromSuperview];
    
    _topMidLine = nil;
    _bottomMidLine = nil;
    _leftMidLine = nil;
    _rightMidLine = nil;
    
}
- (void)resetMidLines {
    //撑满边界
    
    CGFloat offset = _cropAreaCornerWidth;
    CGFloat midWidth = WIDTH(_cropAreaView) - offset*2;
    CGFloat midHeight = HEIGHT(_cropAreaView) - offset*2;
    
    CGFloat lineMargin = _cropAreaMidLineHeight / 2.0 - _cropAreaBorderLineWidth;
    
    CGFloat offsetX = MINX(_cropAreaView);
    CGFloat offsetY = MINY(_cropAreaView);
    _topMidLine.frame = CGRectMake(offset + offsetX, - MID_LINE_INTERACT_HEIGHT / 2.0 - lineMargin + offsetY, midWidth, MID_LINE_INTERACT_HEIGHT);
    _bottomMidLine.frame = CGRectMake(offset + offsetX, HEIGHT(_cropAreaView) - MID_LINE_INTERACT_HEIGHT / 2.0 + lineMargin + offsetY, midWidth, MID_LINE_INTERACT_HEIGHT);
    
    _leftMidLine.frame = CGRectMake(- MID_LINE_INTERACT_WIDTH / 2.0 - lineMargin + offsetX, offset + offsetY, MID_LINE_INTERACT_HEIGHT, midHeight);
    _rightMidLine.frame = CGRectMake(WIDTH(_cropAreaView) - MID_LINE_INTERACT_WIDTH / 2.0 + lineMargin + offsetX, offset + offsetY, MID_LINE_INTERACT_HEIGHT, midHeight);
    
}
- (void)resetImageView {
    //
    CGFloat selfAspectRatio = WIDTH(_cropAreaView) / HEIGHT(_cropAreaView);
    if(_imageAspectRatio > selfAspectRatio) {
        _paddingLeftRight = 0;
        _paddingTopBottom = floor((HEIGHT(_cropAreaView) - WIDTH(_cropAreaView) / _imageAspectRatio) / 2.0);
        _imageView.frame = CGRectMake(0, _paddingTopBottom, WIDTH(_cropAreaView), floor(WIDTH(_cropAreaView) / _imageAspectRatio));
    }
    else {
        _paddingTopBottom = 0;
        _paddingLeftRight = floor((WIDTH(_cropAreaView) - HEIGHT(_cropAreaView) * _imageAspectRatio) / 2.0);
        _imageView.frame = CGRectMake(_paddingLeftRight, 0, floor(HEIGHT(_cropAreaView) * _imageAspectRatio), HEIGHT(_cropAreaView));
    }
    _cropMaskView.frame = self.bounds;
}
- (void)resetCropAreaByAspectRatio {
    
    if(_imageAspectRatio == 0) return;
    CGRect toRect = self.cropAreaViewWillFrame;
    [self animationCropTransparentAreaFromRect:_cropAreaView.frame toRect:toRect];
    
    [UIView animateWithDuration:.3 animations:^{
        _cropAreaView.frame = toRect;
        //_imageView.frame = toRect;
        [self resetCornersOnCropAreaFrameChanged];
        [_imageView updateCropRect:toRect reset:YES];
    }];
}

- (CGRect)cropAreaViewWillFrame{
    if(_imageAspectRatio == 0) return CGRectZero;
    CGFloat tmpCornerMargin = self.cornerMargin * _cornerBorderInImage + 20;
    CGFloat width, height;
    CGFloat maxWidth = WIDTH(self) - 2 * tmpCornerMargin;
    CGFloat maxHeight = HEIGHT(self) - 2 * tmpCornerMargin;
    if(_cropAspectRatio == 0) {
        
        if(_imageAspectRatio > _currCropAspectRatio) {
            height = maxHeight;
            width = height * _currCropAspectRatio;
            if (width>maxWidth) {
                CGFloat tmpScale = maxWidth/width;
                width = maxWidth;
                height *= tmpScale;
            }
        }else {
            width = WIDTH(self) - 2 * tmpCornerMargin;
            height = width / _currCropAspectRatio;
            if (height>maxHeight) {
                CGFloat tmpScale = maxHeight/height;
                height = maxHeight;
                width *= tmpScale;
            }
        }
        
        if(_showMidLines) {
            [self createMidLines];
            [self resetMidLines];
        }
    }else {
        //[self removeMidLines];
        if(_imageAspectRatio > _cropAspectRatio) {
            height = HEIGHT(self) - 2 * tmpCornerMargin;
            width = height * _cropAspectRatio;
        }else {
            width = WIDTH(self) - 2 * tmpCornerMargin;
            height = width / _cropAspectRatio;
        }
    }
    CGRect rect = CGRectMake((WIDTH(self) - width) / 2.0, (HEIGHT(self) - height) / 2.0, width, height);
    return rect;
}

- (void)resetCropAreaByScaleFactor: (CGFloat)scaleFactor {
    
    CGPoint center = _cropAreaView.center;
    CGFloat tmpCornerMargin = self.cornerMargin * _cornerBorderInImage;
    CGFloat width = _pinchOriSize.width * scaleFactor;
    CGFloat height = _pinchOriSize.height * scaleFactor;
    CGFloat widthMax = MIN(WIDTH(_imageView) - center.x - tmpCornerMargin, center.x - tmpCornerMargin) * 2;
    CGFloat widthMin = _minSpace + _cropAreaCornerWidth * 2.0 - tmpCornerMargin * 2.0;
    CGFloat heightMax = MIN(HEIGHT(_imageView) - center.y - tmpCornerMargin, center.y - tmpCornerMargin) * 2;
    CGFloat heightMin = _minSpace + _cropAreaCornerWidth * 2.0 - tmpCornerMargin * 2;
    
    BOOL isMinimum = NO;
    if(_cropAspectRatio > 1) {
        if(height <= heightMin) {
            height = heightMin;
            width = height * _cropAspectRatio;
            isMinimum = YES;
        }
    }
    else {
        if(width <= widthMin) {
            width = widthMin;
            height = width / (_cropAspectRatio == 0 ? 1 : _cropAspectRatio);
            isMinimum = YES;
        }
    }
    if(!isMinimum) {
        if(_cropAspectRatio == 0) {
            if(width >= widthMax) {
                width = MIN(width, WIDTH(_imageView) - 2 * tmpCornerMargin);
                center.x = center.x > WIDTH(_imageView) / 2.0 ? WIDTH(_imageView) - width / 2.0 - tmpCornerMargin : width / 2.0 + tmpCornerMargin;
            }
            if(height > heightMax) {
                height = MIN(height, HEIGHT(_imageView) - 2 * tmpCornerMargin);
                center.y = center.y > HEIGHT(_imageView) / 2.0 ? HEIGHT(_imageView) - height / 2.0 - tmpCornerMargin : height / 2.0 + tmpCornerMargin;
            }
            
        }
        else if(_imageAspectRatio > _cropAspectRatio) {
            if(height >= heightMax) {
                height = MIN(height, HEIGHT(_imageView) - 2 * tmpCornerMargin);
                center.y = center.y > HEIGHT(_imageView) / 2.0 ? HEIGHT(_imageView) - height / 2.0 - tmpCornerMargin : height / 2.0 + tmpCornerMargin;
            }
            width = height * _cropAspectRatio;
            if(width > widthMax) {
                center.x = center.x > WIDTH(_imageView) / 2.0 ? WIDTH(_imageView) - width / 2.0 - tmpCornerMargin : width / 2.0 + tmpCornerMargin;
            }
        }
        else {
            if(width >= widthMax) {
                width = MIN(width, WIDTH(_imageView) - 2 * tmpCornerMargin);
                center.x = center.x > WIDTH(_imageView) / 2.0 ? WIDTH(_imageView) - width / 2.0 - tmpCornerMargin : width / 2.0 + tmpCornerMargin;
            }
            height = width / _cropAspectRatio;
            if(height > heightMax) {
                center.y = center.y > HEIGHT(_imageView) / 2.0 ? HEIGHT(_imageView) - height / 2.0 - tmpCornerMargin : height / 2.0 + tmpCornerMargin;
            }
        }
    }
    _cropAreaView.bounds = CGRectMake(0, 0, width, height);
    _cropAreaView.center = center;
    [self resetCornersOnCropAreaFrameChanged];
    
}
#pragma mark - Setter & Getters
- (void)setScaleFactor:(CGFloat)scaleFactor {
    
    _pinchOriSize = _cropAreaView.frame.size;
    [self resetCropAreaByScaleFactor: scaleFactor];
    
}
- (CGFloat)cornerMargin {
    
    return _cropAreaCornerLineWidth - _cropAreaBorderLineWidth;
    
}
- (void)setMaskColor:(UIColor *)maskColor {
    
    _maskColor = maskColor;
    _cropMaskView.backgroundColor = maskColor;
    
}
- (void)setToCropImage:(UIImage *)toCropImage {
    
    _toCropImage = toCropImage;
    _imageAspectRatio = toCropImage.size.width / toCropImage.size.height;
    _imageView.image = toCropImage;
    _currCropAspectRatio = _imageAspectRatio;
    [self resetCropAreaByAspectRatio];
    //[self resetImageView];
    
}
- (void)setNeedScaleCrop:(BOOL)needScaleCrop {
    
    if(!_needScaleCrop && needScaleCrop) {
        _cropAreaPinch = [[UIPinchGestureRecognizer alloc]initWithTarget: self action:@selector(handleImagePinch:)];
        [_cropAreaView addGestureRecognizer: _cropAreaPinch];
    }
    else if(_needScaleCrop && !needScaleCrop){
        [_cropAreaView removeGestureRecognizer: _cropAreaPinch];
        _cropAreaPinch = nil;
    }
    _needScaleCrop = needScaleCrop;
    
}
- (void)setCropAreaCrossLineWidth:(CGFloat)cropAreaCrossLineWidth {
    
    _cropAreaCrossLineWidth = cropAreaCrossLineWidth;
    _cropAreaView.crossLineWidth = cropAreaCrossLineWidth;
    
}
- (void)setCropAreaCrossLineColor:(UIColor *)cropAreaCrossLineColor {
    
    _cropAreaCrossLineColor = cropAreaCrossLineColor;
    _cropAreaView.crossLineColor = cropAreaCrossLineColor;
    
}
- (void)setCropAreaMidLineWidth:(CGFloat)cropAreaMidLineWidth {
    
    _cropAreaMidLineWidth = cropAreaMidLineWidth;
    _topMidLine.lineWidth = cropAreaMidLineWidth;
    _bottomMidLine.lineWidth = cropAreaMidLineWidth;
    _leftMidLine.lineWidth = cropAreaMidLineWidth;
    _rightMidLine.lineWidth = cropAreaMidLineWidth;
    if(_showMidLines) {
        [self resetMidLines];
    }
    
}
- (void)setCropAreaMidLineHeight:(CGFloat)cropAreaMidLineHeight {
    
    _cropAreaMidLineHeight = cropAreaMidLineHeight;
    _topMidLine.lineHeight = cropAreaMidLineHeight;
    _bottomMidLine.lineHeight = cropAreaMidLineHeight;
    _leftMidLine.lineHeight = cropAreaMidLineHeight;
    _rightMidLine.lineHeight = cropAreaMidLineHeight;
    if(_showMidLines) {
        [self resetMidLines];
    }
    
}
- (void)setCropAreaMidLineColor:(UIColor *)cropAreaMidLineColor {
    
    _cropAreaMidLineColor = cropAreaMidLineColor;
    _topMidLine.lineColor = cropAreaMidLineColor;
    _bottomMidLine.lineColor = cropAreaMidLineColor;
    _leftMidLine.lineColor = cropAreaMidLineColor;
    _rightMidLine.lineColor = cropAreaMidLineColor;
    
}
- (void)setCropAreaBorderLineWidth:(CGFloat)cropAreaBorderLineWidth {
    
    _cropAreaBorderLineWidth = cropAreaBorderLineWidth;
    _cropAreaView.borderWidth = cropAreaBorderLineWidth;
    [self resetCropAreaOnCornersFrameChanged];
    
}
- (void)setCropAreaBorderLineColor:(UIColor *)cropAreaBorderLineColor {
    
    _cropAreaBorderLineColor = cropAreaBorderLineColor;
    _cropAreaView.borderColor = cropAreaBorderLineColor;
    
}
- (void)setCropAreaCornerLineColor:(UIColor *)cropAreaCornerLineColor {
    
    _cropAreaCrossLineColor = cropAreaCornerLineColor;
    _topLeftCorner.lineColor = cropAreaCornerLineColor;
    _topRightCorner.lineColor = cropAreaCornerLineColor;
    _bottomLeftCorner.lineColor = cropAreaCornerLineColor;
    _bottomRightCorner.lineColor = cropAreaCornerLineColor;
    
}
- (void)setCropAreaCornerLineWidth:(CGFloat)cropAreaCornerLineWidth {
    
    _cropAreaCornerLineWidth = cropAreaCornerLineWidth;
    _topLeftCorner.lineWidth = cropAreaCornerLineWidth;
    _topRightCorner.lineWidth = cropAreaCornerLineWidth;
    _bottomLeftCorner.lineWidth = cropAreaCornerLineWidth;
    _bottomRightCorner.lineWidth = cropAreaCornerLineWidth;
    [self resetCropAreaByAspectRatio];
    
}
- (void)setCropAreaCornerWidth:(CGFloat)cropAreaCornerWidth {
    
    _cropAreaCornerWidth = cropAreaCornerWidth;
    [self resetCornersOnSizeChanged];
    
}
- (void)setCropAreaCornerHeight:(CGFloat)cropAreaCornerHeight {
    
    _cropAreaCornerHeight = cropAreaCornerHeight;
    [self resetCornersOnSizeChanged];
    
}
- (void)setCropAspectRatio:(CGFloat)cropAspectRatio {
    
    _cropAspectRatio = MAX(cropAspectRatio, 0);
    if (_cropAspectRatio == 0) {
        _currCropAspectRatio = _imageAspectRatio;
    }
    [self resetCropAreaByAspectRatio];
    
}
- (void)setShowMidLines:(BOOL)showMidLines {
    
    if(_cropAspectRatio == 0) {
        if(!_showMidLines && showMidLines) {
            [self createMidLines];
            [self resetMidLines];
        }
        else if(_showMidLines && !showMidLines) {
            [self removeMidLines];
        }
    }
    _showMidLines = showMidLines;
    
}
- (void)setShowCrossLines:(BOOL)showCrossLines {
    
    _showCrossLines = showCrossLines;
    _cropAreaView.showCrossLines = _showCrossLines;
    
}
- (void)setCornerBorderInImage:(BOOL)cornerBorderInImage {
    
    _cornerBorderInImage = cornerBorderInImage;
    [self resetCropAreaByAspectRatio];
    
}
- (void)setFrame:(CGRect)frame {
    
    [super setFrame: frame];
    _cropMaskView.frame = self.bounds;
    
}
#pragma mark - KVO CallBack
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if([object isEqual: _cropAreaView]) {
        if(_showMidLines){
            [self resetMidLines];
        }
        //[self resetCropTransparentArea];
    }
    
}
#pragma Instance Methods
- (UIImage *)currentCroppedImage {
    
    if ([_imageView isKindOfClass:[ShowImageView class]]) {
        return [_imageView outputImage];
    }
    CGFloat scaleFactor = WIDTH(_imageView) / _toCropImage.size.width;
    CGRect cropRect = CGRectMake((MINX(_cropAreaView) + _cropAreaBorderLineWidth), (MINY(_cropAreaView) + _cropAreaBorderLineWidth), (WIDTH(_cropAreaView) - 2 * _cropAreaBorderLineWidth), (HEIGHT(_cropAreaView) - 2 * _cropAreaBorderLineWidth));
    
    CGRect cropImageRect = [_imageView convertRect:cropRect fromView:self];
    cropImageRect.origin.x /= scaleFactor;
    cropImageRect.origin.y /= scaleFactor;
    cropImageRect.size.width /= scaleFactor;
    cropImageRect.size.height /= scaleFactor;
    return [_toCropImage imageAtRect: cropImageRect];
    
}
- (void)touchesBegan1:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;
    CGPoint cPoint = [touch locationInView:_cropAreaView];
    for(UIView *subView in _cropAreaView.subviews) {
        if(CGRectContainsPoint(subView.frame, cPoint)) {
            _cropAreaView.userInteractionEnabled = YES;
            return;
        }
    }
    _cropAreaView.userInteractionEnabled = NO;
}

- (UIView *)hitTest1:(CGPoint) point withEvent:(UIEvent *)event {
    UITouch *touch = [event touchesForView:_cropAreaView].anyObject;
    if (touch) {
        CGPoint cPoint = [touch locationInView:_cropAreaView];
        for(UIView *subView in _cropAreaView.subviews) {
            if(CGRectContainsPoint(subView.frame, cPoint)) {
                return subView;
            }
        }
    }
    return _imageView;
}

@end


