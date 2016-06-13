//
//  LLStarView.m
//  Mindly
//
//  Created by longlong on 16/5/26.
//  Copyright © 2016年 LongLong. All rights reserved.
//


#import "LLStarObject.h"

#import "LLGalaxyView.h"
#import "LLStarView.h"

@implementation LLStarView{
    LLStarObject *theStarObject;
    BOOL isShowLine;
}
-(LLStarView *)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        _titleLable = [[UILabel alloc]init];
        [_titleLable setTextColor:[UIColor whiteColor]];
        [_titleLable setTextAlignment:NSTextAlignmentCenter];
        _titleLable.numberOfLines = 0;
        [_titleLable setFont:[UIFont systemFontOfSize:CGRectGetHeight(self.frame)/8]];
        [_titleLable setFrame:CGRectMake(CGRectGetWidth(self.frame)*1/10, CGRectGetHeight(self.frame)/4,CGRectGetWidth(self.frame)*8/10,CGRectGetHeight(self.frame)/2)];
        [self addSubview:_titleLable];

        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickTap)];
        gesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:gesture];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 40.0/255, 155.0/255, 127.0/255, 1.0);
    CGContextAddArc(ctx, CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), CGRectGetMidX(self.bounds), 0, 2*M_PI, 0);
    CGContextDrawPath(ctx, kCGPathFill);
    CGContextStrokePath(ctx);
}


-(void)clickTap
{
    switch (_stage) {
        case StarSuperCenter:{
            break;
        }case StarCenter:{
            break;
        }case StarSide:{
            LLGalaxyView *galaxy = (LLGalaxyView *)self.superview.superview;
            [galaxy showNextGalaxyWith:self andStartObject:theStarObject];//显示下个星系
            break;
        }case StarDeath:{
            break;
        }default:
            break;
    }
}

-(void)setStarObject:(LLStarObject *)starObject;
{
    theStarObject = starObject;
    if (starObject.image.length>2) {
        self.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:starObject.image].CGImage);
    }else if (starObject.title){
        [_titleLable setText:starObject.title];
    }
}

#pragma  mark  --------------------星星动画--------------------
-(void)setStarStage:(StarState) stage;
{
    _stage = stage;
    switch (stage) {
        case StarSuperCenter:{
            [self changeToSuperGalaxy];
            
            break;
        }case StarCenter:{
            
            break;
        }case StarSide:{
            
            break;
        }case StarCenterReturn:{
            [self changeToActiveGalaxy];
            
            break;
        }case StarDeath:{
            [self removeFromSuperview];
            
            break;
        }default:
            break;
    }
}


-(void)changeToSuperGalaxy
{
    [self starFromSize:1.0 toSize:1.5 andFromPosition:self.layer.position andToPosition:CGPointMake(0,0)];
    isShowLine = YES;
}

-(void)changeToActiveGalaxy
{
    [self starFromSize:1.5 toSize:1.0 andFromPosition:CGPointMake(0,0) andToPosition:self.layer.position];
    isShowLine = NO;
}

-(void)starFromSize:(float) fromSize toSize:(float) toSize andFromPosition:(CGPoint)fromPosition  andToPosition:(CGPoint)toPosition
{
    [self setHidden:NO];
    //恒星放大
    CABasicAnimation *animationOne = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animationOne.fromValue = [NSNumber numberWithFloat:fromSize];
    animationOne.toValue = [NSNumber numberWithFloat:toSize];
    // 移动
    CABasicAnimation *animationTwo = [CABasicAnimation animationWithKeyPath:@"position"];
    animationTwo.fromValue = [NSValue valueWithCGPoint:fromPosition];
    animationTwo.toValue = [NSValue valueWithCGPoint:toPosition];
    //组合
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.repeatCount = 1;
    group.duration = 0.5;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.animations=@[animationOne,animationTwo];
    group.delegate = self;
    [self.layer addAnimation:group forKey:@"group"];
}
#pragma mark  行星动画完结
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (isShowLine) {
        LLGalaxyView *galaxy = (LLGalaxyView *)self.superview;
        [galaxy hidenLine:NO];
    }
}
@end
