//
//  LLMoonView.m
//  Mindly
//
//  Created by longlong on 16/5/26.
//  Copyright © 2016年 LongLong. All rights reserved.
//

#import "LLMoonView.h"
#import "LLStarView.h"
#import "LLCircleView.h"
#import "LLGalaxyView.h"
#import "LLShowViewObject.h"

#define StarWidth 80
#define DTime  0.5
#define DD 10
@implementation LLMoonView{
    NSMutableArray *starsViewArray;
    float fistStarAngle;
    CGPoint firstStartPoint;
    MoonState moonStage;

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
-(void)setMoonStage:(MoonState) stage andWithStar:(LLStarView *)starView andIsMove:(BOOL) isMove;
{
    moonStage = stage;
    switch (stage) {
        case MoonHiden:{
            [self animationStar:starView];//旋转动画
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
            
            if (isMove) {
                [self showMoonView];
            }
            break;
        }case MoonReturn:{
            for (int i=0; i<[starsViewArray count]; i++) {
                LLStarView *starView = starsViewArray[i];
                starView.stage = StarOut;
            }
            self.alpha = 1;
            [self setHidden:NO];

            [self returnCircleView];//圆环回位
            [self returnAnimationStar:starView];
            break;
        }default:
            break;
    }
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


#pragma mark ----------------星系转换-----------------------

#pragma mark 卫星旋转放大

/**
 * @brief 放大同时    转动所有卫星
 */
-(void)animationStar:(LLStarView *) starView {
    [self moveCircleView];
    float angle = [self calculateAngleWithPoint:starView.center];
    float endAngel = [self calculateAngleWithPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
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
        [self animationEveryStar:starView startAngle:angle endAngle:angle+animationDangle];
    }
    fistStarAngle = fistStarAngle+animationDangle;
}

-(void)animationEveryStar:(LLStarView *) starView  startAngle:(float)startAngle endAngle:(float) endAngle
{
    //卫星放大
    CABasicAnimation *animationOne = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animationOne.fromValue = [NSNumber numberWithFloat:1.0];
    animationOne.toValue = [NSNumber numberWithFloat:1.5];
    //移动
    CAKeyframeAnimation *animationTwo = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animationTwo.values = [self getPathArrayWithStartAngle:startAngle endAngle:endAngle];
    //组合
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.repeatCount = 1;
    group.duration = DTime;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.animations=@[animationOne,animationTwo];
//    group.delegate = self;
    [starView.layer addAnimation:group forKey:@"group"];
}

-(NSMutableArray *)getPathArrayWithStartAngle:(float)startAngle endAngle:(float) endAngle
{
    //计算移动经过的坐标
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (int i=0; i<=DTime*DD;i++) {
        CGPoint center = CGPointMake(self.frame.size.width/2 - i*self.frame.size.width/(2*DTime*DD), self.frame.size.height/2- i*self.frame.size.height/(2*DTime*DD));
        float dRadius = sqrt(pow((self.center.x), 2)+pow((self.center.y), 2)) -(CGRectGetMidX(self.bounds)-StarWidth/2);
        float radius = CGRectGetMidX(self.bounds)-StarWidth/2+i*dRadius/(DTime*DD);
        CGPoint pathPoint = [self calculatePointWithAngle:startAngle+i*(endAngle-startAngle)/(DTime*DD) andRadius:radius andCenter:center];
        [array addObject:[NSValue valueWithCGPoint:pathPoint]];
    }
    return array;
}

/**
 * @brief 根据角度 圆心  半径  算坐标
 */
-(CGPoint)calculatePointWithAngle:(float)angle andRadius:(float) r andCenter:(CGPoint)center
{
    return  CGPointMake(center.x+cos(angle)*r, center.y+sin(angle)*r);
}


-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (moonStage == MoonHiden) {
        //自己变为超星系   隐藏圆   隐藏卫星   显示下个星系的恒星
        LLCircleView *circleView = ((LLGalaxyView *)self.superview).circleView;
        [circleView setHidden:YES];
        [self setHidden:YES];
        
        [((LLGalaxyView *)self.superview).starView.galaxyNext.starView setHidden:NO];
    }else if (moonStage == MoonReturn){
        [self returnMoon];
        [((LLGalaxyView *)self.superview).starView.galaxyAtSide showLine];//显示上一星系的线
    }else if (moonStage == MoonRemove){
        [self.superview removeFromSuperview];
    }

}
#pragma mark 超星系回退

/**
 * @brief 放小同时    转动所有卫星
 */
-(void)returnAnimationStar:(LLStarView *) starView {
    int i;
    for (i = 0; i<[starsViewArray count]; i++) {
        LLStarView *moonStar  = starsViewArray[i];
        if ([starView isEqual:moonStar]) {
            break;
        }
    }
    float angle = [self calculateAngleWithPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    float endAngel= -M_PI/2+i*(2*M_PI/[starsViewArray count]);
    [self returnAnimationWithAngle:endAngel-angle ];
}


/**
 * @brief 根据角度  时间  顺时针还是逆时针  转动
 */
-(void)returnAnimationWithAngle:(float)animationDangle {
    float dangle = 2*M_PI/[starsViewArray count];
    for (int i=0; i<[starsViewArray count]; i++) {
        LLStarView *starView = starsViewArray[i];
        float angle = fistStarAngle + dangle*i;
        [self returnAnimationEveryStar:starView startAngle:angle endAngle:angle+animationDangle];
    }
    fistStarAngle = fistStarAngle+animationDangle;
}

-(void)returnAnimationEveryStar:(LLStarView *) starView  startAngle:(float)startAngle endAngle:(float) endAngle
{
    //卫星放大
    CABasicAnimation *animationOne = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animationOne.fromValue = [NSNumber numberWithFloat:1.5];
    animationOne.toValue = [NSNumber numberWithFloat:1];
    //移动
    CAKeyframeAnimation *animationTwo = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animationTwo.values = [self returnGetPathArrayWithStartAngle:startAngle endAngle:endAngle];
    //组合
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.repeatCount = 1;
    group.duration = DTime;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.animations=@[animationOne,animationTwo];
    [starView.layer addAnimation:group forKey:@"group"];
}

-(NSMutableArray *)returnGetPathArrayWithStartAngle:(float)startAngle endAngle:(float) endAngle
{
    //计算移动经过的坐标
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (int i=0; i<=DTime*DD;i++) {
        CGPoint center = CGPointMake( i*self.frame.size.width/(2*DTime*DD),i*self.frame.size.height/(2*DTime*DD));
        float dRadius = sqrt(pow((self.center.x), 2)+pow((self.center.y), 2)) -(CGRectGetMidX(self.bounds)-StarWidth/2);
        float radius = sqrt(pow((self.center.x), 2)+pow((self.center.y), 2))-i*dRadius/(DTime*DD);
        CGPoint pathPoint = [self calculatePointWithAngle:startAngle+i*(endAngle-startAngle)/(DTime*DD) andRadius:radius andCenter:center];
        [array addObject:[NSValue valueWithCGPoint:pathPoint]];
    }
    return array;
}



-(void)returnMoon
{
    fistStarAngle = -M_PI/2;
    if ([starsViewArray count]!=0) {
        float r = CGRectGetMidX(self.bounds)-StarWidth/2;
        float angle = 2*M_PI/[starsViewArray count];
        for (int i=0; i<[starsViewArray count]; i++) {
            LLStarView *moonStar  = starsViewArray[i];
            [moonStar setFrame:CGRectMake(
                                         CGRectGetMidX(self.bounds)+r*sin(i*angle)-StarWidth/2,
                                         CGRectGetMidY(self.bounds)-r*cos(i*angle)-StarWidth/2,
                                         StarWidth,
                                          StarWidth)];
        }
    }
}


#pragma mark 圆环

-(void)moveCircleView
{
    LLCircleView *circleView = ((LLGalaxyView *)self.superview).circleView;
    
    //恒星放大
    CABasicAnimation *animationOne = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animationOne.fromValue = [NSNumber numberWithFloat:1.0];
    animationOne.toValue = [NSNumber numberWithFloat:2.8];
    // 移动
    CABasicAnimation *animationTwo = [CABasicAnimation animationWithKeyPath:@"position"];
    
    animationTwo.fromValue = [NSValue valueWithCGPoint:circleView.layer.position];
    animationTwo.toValue = [NSValue valueWithCGPoint:CGPointMake(0,0)];
    //组合
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.repeatCount = 1;
    group.duration = 0.5;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.animations=@[animationOne,animationTwo];
    group.delegate = self;
    [circleView.layer addAnimation:group forKey:@"group"];
}

-(void)returnCircleView
{
    LLCircleView *circleView = ((LLGalaxyView *)self.superview).circleView;
    [circleView setHidden:NO];
    //恒星放大
    CABasicAnimation *animationOne = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animationOne.fromValue = [NSNumber numberWithFloat:2.8];
    animationOne.toValue = [NSNumber numberWithFloat:1.0];
    // 移动
    CABasicAnimation *animationTwo = [CABasicAnimation animationWithKeyPath:@"position"];
    
    animationTwo.fromValue = [NSValue valueWithCGPoint:CGPointMake(0,0)];
    animationTwo.toValue = [NSValue valueWithCGPoint:circleView.layer.position];
    //组合
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.repeatCount = 1;
    group.duration = 0.5;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.animations=@[animationOne,animationTwo];
    group.delegate = self;
    [circleView.layer addAnimation:group forKey:@"group"];
}

#pragma mark 新星系显示动画

-(void)showMoonView
{
    //恒星放大
    CABasicAnimation *animationOne = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animationOne.fromValue = [NSNumber numberWithFloat:0.5];
    animationOne.toValue = [NSNumber numberWithFloat:1];
    // 移动
    CABasicAnimation *animationTwo = [CABasicAnimation animationWithKeyPath:@"opacity"];
    
    animationTwo.fromValue = @0.2;
    animationTwo.toValue = @1.0;
    //组合
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.repeatCount = 1;
    group.duration = 0.5;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.animations=@[animationOne,animationTwo];
    [self.layer addAnimation:group forKey:@"group"];
    
    LLCircleView *circleView = ((LLGalaxyView *)self.superview).circleView;
    [circleView.layer addAnimation:group forKey:@"group"];

}

#pragma mark 现星系消失动画

-(void)removeMoonView
{
    //恒星放大
    CABasicAnimation *animationOne = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animationOne.fromValue = [NSNumber numberWithFloat:1];
    animationOne.toValue = [NSNumber numberWithFloat:0.5];
    // 移动
    CABasicAnimation *animationTwo = [CABasicAnimation animationWithKeyPath:@"opacity"];
    
    animationTwo.fromValue = @1.0;
    animationTwo.toValue = @0.2;
    //组合
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.repeatCount = 1;
    group.duration = 0.5;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.animations=@[animationOne,animationTwo];
    group.delegate = self;
    [self.layer addAnimation:group forKey:@"group"];
    
    LLCircleView *circleView = ((LLGalaxyView *)self.superview).circleView;
    [circleView.layer addAnimation:group forKey:@"group"];
}
@end




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
//- (void)drawRect:(CGRect)rect {
////    if (!isShow) {
////        return;
////    }
//    if (moonStage==MoonHiden) {
//        CGContextRef ctx=UIGraphicsGetCurrentContext();
//        CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1].CGColor);
//        CGContextAddArc(ctx, circleForLine.x, circleForLine.y,radiusForLine, 0, 2*M_PI, 0);
//        CGContextStrokePath(ctx);
//    }else{
//        CGContextRef ctx=UIGraphicsGetCurrentContext();
//        CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1].CGColor);
//        CGContextAddArc(ctx, CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), CGRectGetMidX(self.bounds)-StarWidth/2, 0, 2*M_PI, 0);
//        CGContextStrokePath(ctx);
//    }
//}

