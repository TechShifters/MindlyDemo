//
//  LLGalaxyView.m
//  Mindly
//
//  Created by longlong on 16/5/26.
//  Copyright © 2016年 LongLong. All rights reserved.
//

#import "LLGalaxyView.h"
#import "LLCircleView.h"
#define StarWidth 80
#import "LLStarView.h"
#import "LLMoonView.h"
#import "LLStarObject.h"
#import "LLShowViewObject.h"
@implementation LLGalaxyView{
    LLStarObject *starOb;
    BOOL isHidenLine;
}

-(LLGalaxyView *)initWithFrame:(CGRect)frame andStar:(LLStarObject *)starObject
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        starOb = starObject;
        //加圆圈
        float r = CGRectGetMidX(self.bounds)-StarWidth/2;
        _circleView  = [[LLCircleView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds)-r, CGRectGetMidY(self.bounds)-r, r*2,r*2)];
        [self addSubview:_circleView];

        //加恒星
        _starView = [[LLStarView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.bounds)-CGRectGetWidth(self.bounds)/6,CGRectGetMidY(self.bounds)-CGRectGetWidth(self.bounds)/6, CGRectGetWidth(self.bounds)/3,CGRectGetWidth(self.bounds)/3)];
        [_starView setStarObject:starObject];
        _starView.galaxyAtCenter = self;
        [self addSubview:_starView];

        //加卫星
        _moonView = [[LLMoonView alloc]initWithFrame:self.bounds andAry:starObject.nextStars atGalaxy:self];
        [self addSubview:_moonView];
        
    }
    return self;

}

/**
 *   @brief  修改其大小
 */
-(void)layoutSubviews
{
    [UIView animateWithDuration:0.3 animations:^{
        float smallWidth = 3;
        if (self.bounds.size.width>[UIScreen mainScreen].bounds.size.width) {
            smallWidth = 4;
        }
        [_moonView setFrame:self.bounds];
        [_starView setFrame:CGRectMake(CGRectGetMidX(self.bounds)-CGRectGetWidth(self.bounds)/(smallWidth*2),CGRectGetMidY(self.bounds)-CGRectGetWidth(self.bounds)/(smallWidth*2), CGRectGetWidth(self.bounds)/smallWidth,CGRectGetWidth(self.bounds)/smallWidth)];
    }];
}

-(void)drawRect:(CGRect)rect
{
    //画一个斜线  链接下一个星系
    if (!isHidenLine) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 1);
        CGContextSetRGBStrokeColor(context, 220.0/255,220.0/255,220.0/255, 1.0);
        CGContextMoveToPoint(context,0, 0);
        CGContextAddLineToPoint(context,self.frame.size.width/2,self.frame.size.height/2);
        CGContextStrokePath(context);
    }
    

}
-(void)hideLine
{
    isHidenLine = YES;
    [self setNeedsDisplay];
}
-(void)setGalaxyStage:(GalaxyState) stage  andWithStar:(LLStarView *) starView;
{
    switch (stage) {
        case GalaxySuper:{
            isHidenLine = NO;
            [self changeToSuperGalaxy];
            [_starView.galaxyAtSide hideLine];//隐藏上个星系的线
            _starView.stage = StarSuperCenter;
            [_moonView setMoonStage:MoonHiden andWithStar:starView andIsMove:NO];
            break;
            
        }case GalaxyActive:{
            isHidenLine = YES;
            [self setNeedsDisplay];
            
            _starView.stage = StarCenter;
            
            if (self.superview.subviews.count>1) {
                [_starView setHidden:YES];
                [_moonView setMoonStage:MoonOut andWithStar:starView  andIsMove:YES];
            }else{
                [_moonView setMoonStage:MoonOut andWithStar:starView  andIsMove:NO];
            }
            break;
        }case GalaxyHiden:{
            self.alpha = 0;
            break;
        }default:
            break;
    }
}

-(void)changeToSuperGalaxy
{
    [_starView setHidden:NO];
    //恒星放大
    CABasicAnimation *animationOne = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animationOne.fromValue = [NSNumber numberWithFloat:1.0];
    animationOne.toValue = [NSNumber numberWithFloat:1.5];
    // 移动
    CABasicAnimation *animationTwo = [CABasicAnimation animationWithKeyPath:@"position"];
    animationTwo.fromValue = [NSValue valueWithCGPoint:_starView.layer.position];
    animationTwo.toValue = [NSValue valueWithCGPoint:CGPointMake(0,0)];
    //组合
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.repeatCount = 1;
    group.duration = 0.5;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.animations=@[animationOne,animationTwo];
    group.delegate = self;
    [self.starView.layer addAnimation:group forKey:@"group"];
    
    [self.starView setCenter:CGPointMake(0, 0)];
    
}
#pragma mark   ---------CAAnimationDelegate---------
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self setNeedsDisplay];
    
}
@end
