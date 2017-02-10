//
//  CropCornerView.m
//  TKImageViewDemo
//
//  Created by admin on 2016/12/21.
//  Copyright © 2016年 yinyu. All rights reserved.
//

#import "CropCornerView.h"

@implementation CropCornerView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}
- (void)initView{
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    [self addGestureRecognizer:pan];
}

- (void)setPosition:(int)position{
    if (_position != position) {
        _position = position;
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"arrow%d", position]];
    }
}

- (void)onPan:(UIPanGestureRecognizer *)pan{
    if (self.superview == nil) {
        return;
    }
    CGPoint point = [pan locationInView:self.superview];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            
        }
            break;
        case UIGestureRecognizerStateChanged:{
            //联动 x y 关联
            CGRect xRect = _cornerViewX.frame;
            xRect.origin.x = point.x;
            _cornerViewX.frame = xRect;
            CGRect yRect = _cornerViewY.frame;
            yRect.origin.y = point.y;
            _cornerViewY.frame = yRect;
        }
            break;
        case UIGestureRecognizerStateEnded:{
            
        }
            break;
            
        default:
            break;
    }
    
}

@end
