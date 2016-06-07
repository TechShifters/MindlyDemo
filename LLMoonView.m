//
//  LLMoonView.m
//  Mindly
//
//  Created by longlong on 16/5/26.
//  Copyright © 2016年 LongLong. All rights reserved.
//

#import "LLMoonView.h"
#import "LLStarView.h"
#import "LLGalaxyView.h"
#import "LLShowViewObject.h"
#define StarWidth 80
@implementation LLMoonView{
    NSMutableArray *starsViewArray;
    float fistStarAngle;
    CGPoint firstStartPoint;

    CGPoint startPoint;
    float laseTime;
    
    float lastDAngle;
    float lastDTime;
    BOOL lastIsClockwise;
}

-(LLMoonView *)initWithFrame:(CGRect)frame andAry:(NSMutableArray*) starsArray atGalaxy:(LLGalaxyView *)atGalaxy
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        starsViewArray  = [[NSMutableArray alloc]init];
        fistStarAngle = -M_PI/2;
        if ([starsArray count]!=0) {
            float r = CGRectGetMidX(self.bounds)-StarWidth/2;
            float angle = 2*M_PI/[starsArray count];
            for (int i=0; i<[starsArray count]; i++) {
                LLStarObject *moonStar  = starsArray[i];
                LLStarView *starView = [[LLStarView alloc]initWithFrame:
                                        CGRectMake(
                                                   CGRectGetMidX(self.bounds)+r*sin(i*angle)-StarWidth/2,
                                                   CGRectGetMidY(self.bounds)-r*cos(i*angle)-StarWidth/2,
                                                   StarWidth,
                                                   StarWidth)];
                [starView setStarObject:moonStar];
                starView.galaxyAtSide = atGalaxy;
                [self addSubview:starView];
                [starsViewArray addObject:starView];
            }
        }
    }
    return self;
}
-(void)setMoonStage:(MoonState) stage;
{
    switch (stage) {
        case MoonHiden:{
            for (int i=0; i<[starsViewArray count]; i++) {
                LLStarView *starView = starsViewArray[i];
                starView.stage = StarHiden;
            }
            break;
        }case MoonOut:{
            for (int i=0; i<[starsViewArray count]; i++) {
                LLStarView *starView = starsViewArray[i];
                starView.stage = StarOut;
            }
            self.alpha = 1;
            [self setHidden:NO];
            break;
        }default:
            break;
    }
}
//-(void)layoutSubviews
//{
//    float r = CGRectGetMidX(self.bounds)-StarWidth/2;
//    float angle = 2*M_PI/[starsViewArray count];
//    [UIView animateWithDuration:0.3 animations:^{
//        for (int i=0; i<[starsViewArray count]; i++) {
//            LLStarView *starView = starsViewArray[i];
//            [starView setFrame:CGRectMake(
//                                          CGRectGetMidX(self.bounds)+r*sin(i*angle+fistStarAngle+M_PI/2)-StarWidth/2,
//                                          CGRectGetMidY(self.bounds)-r*cos(i*angle+fistStarAngle+M_PI/2)-StarWidth/2,
//                                          StarWidth,
//                                          StarWidth)];
//        }
//    }];
//    [self setNeedsDisplay];
//
//}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1].CGColor);
    CGContextAddArc(ctx, CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), CGRectGetMidX(self.bounds)-StarWidth/2, 0, 2*M_PI, 0);
    CGContextStrokePath(ctx);
}

#pragma mark ----------------截取手势-----------------------

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //开始计算速度
    UITouch *lastTouch =  touches.allObjects.firstObject;
    startPoint = [lastTouch locationInView:self];
    firstStartPoint = startPoint;
    laseTime = lastTouch.timestamp;

}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //跟随手指转动
    UITouch *myTouch = touches.allObjects.firstObject;
    [self animationWithTouch:myTouch andTouching:YES];
    startPoint = [myTouch locationInView:self];
    laseTime = myTouch.timestamp;
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //结束计算速度  根据速度开始旋转
    UITouch *myTouch = touches.allObjects.firstObject;
    [self animationWithTouch:myTouch andTouching:NO];

}


#pragma mark ----------------转动动画-----------------------

-(void)animationWithTouch:(UITouch *)myTouch  andTouching:(BOOL)isTouching
{
    CGPoint endPoint = [myTouch locationInView:self];
    //根据向量计算是顺时针还是逆时针
    if (!isTouching) {
        startPoint = firstStartPoint;
    }
    if (sqrt(pow((endPoint.x-startPoint.x), 2)+pow((endPoint.y-startPoint.y), 2)>5)){
        float endAngle = [self calculateAngleWithPoint:endPoint];
        float startAngle = [self calculateAngleWithPoint:startPoint];
        BOOL isClockwise = ((endPoint.x-startPoint.x)*(CGRectGetMidY(self.bounds)- startPoint.y)+(endPoint.y-startPoint.y)*(startPoint.x-CGRectGetMidX(self.bounds)))>0;

        if (isTouching) {
            lastDAngle = endAngle-startAngle;
            lastDTime = myTouch.timestamp-laseTime;

            lastIsClockwise = isClockwise;
            [self animationAngle:(endAngle-startAngle) duration:0.1 clockwise:isClockwise];
        }else{
            if ((myTouch.timestamp-laseTime)>0.1) {
                [self animationAngle:lastDAngle*10 duration:1 clockwise:lastIsClockwise];
            }else{
                float angle = lastDAngle/lastDTime;
                [self animationAngle:angle/1.7 duration:1.5 clockwise:lastIsClockwise];
            }
        }
    }
}

/**
 * @brief 根据角度  时间  顺时针还是逆时针  转动
 */
-(void)animationAngle:(float)animationDangle  duration:(float) animationDtime clockwise:(BOOL) isClockwise
{
    UIBezierPath *bezierPath = [[UIBezierPath alloc]init];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.duration = animationDtime;
    
//    animation.removedOnCompletion  = NO;
//    animation.fillMode = kCAFillModeForwards;
    
    float r = CGRectGetMidX(self.bounds)-StarWidth/2;
    float dangle = 2*M_PI/[starsViewArray count];
    
    for (int i=0; i<[starsViewArray count]; i++) {
        LLStarView *starView = starsViewArray[i];
        float angle = fistStarAngle + dangle*i;
        [bezierPath removeAllPoints];
        [bezierPath  addArcWithCenter:self.center radius:r startAngle:angle endAngle:angle+animationDangle clockwise:isClockwise];
        animation.path = bezierPath.CGPath;
        [starView.layer addAnimation:animation forKey:nil];
        
        [starView setCenter:[self calculatePointWithAngle:angle+animationDangle]];
    }
    fistStarAngle = fistStarAngle+animationDangle;
}

/**
 * @brief 放大同时    转动卫星
 */
-(void)animationStar:(LLStarView *) starView {
    UIView *showView = [LLShowViewObject sharedInstance].onView;
    
    float angle = [self calculateAngleWithPoint:starView.center];
    float endAngel = [self calculateAngleWithPoint:CGPointMake(self.frame.size.width/2+showView.frame.size.width/2, self.frame.size.height/2+showView.frame.size.height/2)];
    
//    [self animationAngle:endAngel-angle  duration:0.3 clockwise:(angle <endAngel&&angle>-M_PI+endAngel)];
    [self animationWithAngle:endAngel-angle ];
}


/**
 * @brief 根据角度  时间  顺时针还是逆时针  转动
 */
-(void)animationWithAngle:(float)animationDangle {
    float dangle = 2*M_PI/[starsViewArray count];
    
    for (int i=0; i<[starsViewArray count]; i++) {
        LLStarView *starView = starsViewArray[i];
        float angle = fistStarAngle + dangle*i;
        [starView setCenter:[self calculatePointWithAngle:angle+animationDangle]];
    }
    fistStarAngle = fistStarAngle+animationDangle;
}


/**
 * @brief 根据角度算坐标
 */
-(CGPoint)calculatePointWithAngle:(float)angle
{
    float r = CGRectGetMidX(self.bounds)-StarWidth/2;
    return  CGPointMake(CGRectGetMidX(self.bounds)+cos(angle)*r, CGRectGetMidY(self.bounds)+sin(angle)*r);
}

/**
 * @brief 根据坐标算角度
 */
-(float)calculateAngleWithPoint:(CGPoint)point
{
    return  (point.y>self.center.y?1:-1)*acos((point.x-self.center.x)/sqrt(pow((point.x-self.center.x), 2)+pow((point.y-self.center.y), 2))) ;
}
@end