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
#import "LLStarObject.h"

typedef enum {
    NormalSuperMove=0,
    NormalReturnMove=1,
    HH=2,
}MoveType;

typedef enum {
    MoonNormal=0,
    MoonLarge=1,
}MoonType;

#define StarWidth 80
#define DTime  0.5
#define DD 10

@implementation LLMoonView{
    MoonState moonStage;
    MoonType moonType;
    
    NSMutableArray *starsViewArray;
    float fistStarAngle;
    
    CGPoint firstStartPoint;
    CGPoint startPoint;
    float startTime;
    
    float lastDAngle;
    float lastDTime;
    BOOL lastIsClockwise;
    
    CGPoint circleCenter;
    float r;
    NSMutableArray *starsStoreArray;
}

-(LLMoonView *)initWithFrame:(CGRect)frame andAry:(NSMutableArray*) starsArray atGalaxy:(LLGalaxyView *)atGalaxy
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        starsViewArray  = [[NSMutableArray alloc]init];
        starsStoreArray = starsArray;
        if ([starsArray count]>0&&[starsArray count]<7) {
            fistStarAngle = -M_PI/2;
            r = CGRectGetMidX(self.bounds)-StarWidth/2;
            float angle = 2*M_PI/[starsArray count];
            circleCenter = CGPointMake( CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
            moonType = MoonNormal;
            for (int i=0; i<[starsArray count]; i++) {
                LLStarObject *moonStar  = starsArray[i];
                LLStarView *starView = [[LLStarView alloc]initWithFrame:
                                        CGRectMake(
                                                  circleCenter.x+r*sin(i*angle)-StarWidth/2,
                                                   circleCenter.y-r*cos(i*angle)-StarWidth/2,
                                                   StarWidth,
                                                   StarWidth)];
                [starView setStarObject:moonStar];
                [self addSubview:starView];
                [starsViewArray addObject:starView];
            }
        }else if ([starsArray count]>=7){
            fistStarAngle = -M_PI;
            float angle = M_PI/9;
            r = CGRectGetWidth(self.bounds);
            circleCenter = CGPointMake(CGRectGetWidth(self.bounds)+StarWidth/2, CGRectGetHeight(self.bounds)*2/5+CGRectGetWidth(self.bounds));
            moonType = MoonLarge;

            for (int i=0; i<18; i++) {
                LLStarObject *moonStar  = starsArray[i%[starsArray count]];
                LLStarView *starView = [[LLStarView alloc]initWithFrame:
                                        CGRectMake(
                                                   circleCenter.x-r*cos(i*angle)-StarWidth/2,
                                                   circleCenter.y-r*sin(i*angle)-StarWidth/2,
                                                   StarWidth,
                                                   StarWidth)];
                [starView setStarObject:moonStar];
                [self addSubview:starView];
                [starsViewArray addObject:starView];
            }

        }
    }
    return self;
}

-(void)setMoonStage:(MoonState) stage andWithStar:(LLStarView *)starView {
    moonStage = stage;
    switch (stage) {
        case MoonHiden:{
            [self setAllStar:StarSide];

            [self moveCircleView];
            [self animationStar:starView andWithMoveType:NormalSuperMove];//旋转动画
            break;
        }case MoonOut:{
            [self showMoonView];
        }case MoonOutFirst:{
            self.alpha = 1;
            [self setHidden:NO];
            [self setAllStar:StarSide];
            
            break;
        }case MoonReturn:{
            self.alpha = 1;
            [self setHidden:NO];
            [self setAllStar:StarSide];

            [self returnCircleView];//圆环回位
            [self animationStar:starView andWithMoveType:NormalReturnMove];//卫星回归
            break;
        }case MoonRemove:{
            [self removeMoonView];
            break;
        }default:
            break;
    }
}

-(void)setAllStar:(StarState)stage
{
    for (int i=0; i<[starsViewArray count]; i++) {
        LLStarView *starView = starsViewArray[i];
        starView.stage = stage;
    }
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (moonStage == MoonHiden) {
        //转超星系   隐藏卫星  隐藏圆    显示下个星系的恒星
        [self setHidden:YES];
        [((LLGalaxyView *)self.superview).circleView setHidden:YES];
        [((LLGalaxyView *)self.superview).galaxyNext.starView setHidden:NO];
    }else if (moonStage == MoonReturn){
        //转换为活跃  卫星复位   显示上一星系的线
        [self returnMoon];
        [((LLGalaxyView *)self.superview).galaxySuper hidenLine:NO];
    }else if (moonStage == MoonRemove){
        [self.superview removeFromSuperview];
    }
}

#pragma mark ----------------截取手势-----------------------

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //开始计算速度
    UITouch *lastTouch =  touches.allObjects.firstObject;
    startPoint = [lastTouch locationInView:self];
    firstStartPoint = startPoint;
    startTime = lastTouch.timestamp;

}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //跟随手指转动
    UITouch *myTouch = touches.allObjects.firstObject;
    [self animationWithTouch:myTouch andTouching:YES];
    startPoint = [myTouch locationInView:self];
    startTime = myTouch.timestamp;
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
    if (!isTouching) {
        startPoint = firstStartPoint;
    }
    
    if (sqrt(pow((endPoint.x-startPoint.x), 2)+pow((endPoint.y-startPoint.y), 2)>5)){
        if (isTouching) {
            float endAngle = [self calculateAngleWithPoint:endPoint];
            float startAngle = [self calculateAngleWithPoint:startPoint];
            BOOL isClockwise = ((endPoint.x-startPoint.x)*(circleCenter.y- startPoint.y)+(endPoint.y-startPoint.y)*(startPoint.x-circleCenter.x))>0;//根据向量计算是顺时针还是逆时针

            lastDAngle = endAngle-startAngle;
            lastDTime = myTouch.timestamp-startTime;

            lastIsClockwise = isClockwise;
            [self animationAngle:lastDAngle duration:0.1 clockwise:isClockwise];
        }else{
            if ((myTouch.timestamp-startTime)>0.1) {
                [self animationAngle:lastDAngle*10 duration:1 clockwise:lastIsClockwise];
            }else{
                float angle = 0;
                if (lastDTime!=0) {
                    angle = lastDAngle/lastDTime;
                }
                if (moonType == MoonNormal) {
                    [self animationAngle:angle/1.7 duration:1.5 clockwise:lastIsClockwise];

                }else if (moonType == MoonLarge){
                    float largeAngel = angle/8;
                    [self animationAngle:largeAngel duration:1.5 clockwise:lastIsClockwise];
                }
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
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;

    float dangle = 2*M_PI/[starsViewArray count];
    
    //文字更新
    if (moonType == MoonLarge) {
        [self reSetStarNameWith:isClockwise];
    }
    for (int i=0; i<[starsViewArray count]; i++) {
        LLStarView *starView = starsViewArray[i];
        float angle = fistStarAngle + dangle*i;
        [bezierPath removeAllPoints];
        [bezierPath  addArcWithCenter:circleCenter radius:r startAngle:angle endAngle:angle+animationDangle clockwise:isClockwise];
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
    return  CGPointMake(circleCenter.x+cos(angle)*r, circleCenter.y+sin(angle)*r);
}

/**
 * @brief 根据坐标算角度
 */
-(float)calculateAngleWithPoint:(CGPoint)point
{
    return  (point.y>circleCenter.y?1:-1)*acos((point.x-circleCenter.x)/sqrt(pow((point.x-circleCenter.x), 2)+pow((point.y-circleCenter.y), 2))) ;
}

-(float)calculateAngleOriginalWithPoint:(CGPoint)point
{
    return  acos((point.x)/sqrt(pow((point.x), 2)+pow((point.y), 2))) ;
}
/**
 * @brief 重置星星的名称
 */
-(void)reSetStarNameWith:(BOOL)isClockwise
{
    int viewStartIndex = 0;
    int viewEndIndex = 0;
    
    int startIndex = 0;
    int endIndex = 0;
    
    float smallX = 10000;
    float smallY = 10000;
    
    //获取   view中两边显示的view   数组中位置
    for (int i=0; i<[starsViewArray count]; i++) {
        LLStarView *starView = starsViewArray[i];
        if (starView.center.x<=(StarWidth/2+CGRectGetHeight(self.bounds)/3)) {
            if (starView.center.x<smallX) {
                smallX =starView.center.x;
                viewStartIndex = i;
                startIndex = [self indexWithString:starView.titleLable.text];
            }
        }else if (starView.center.y<CGRectGetHeight(self.bounds)*2/5+CGRectGetHeight(self.bounds)/3){
            if (starView.center.y<smallY) {
                smallY =starView.center.y;
                viewEndIndex = i;
                endIndex = [self indexWithString:starView.titleLable.text];
            }
        }
    }

    //刷新view的标题
    if (!isClockwise) {//逆时针
        if (viewStartIndex<viewEndIndex) {
            for (int i = viewEndIndex; i<[starsViewArray count]; i++) {
                [self setStarViewWith:i andWith:endIndex+(i-viewEndIndex)];
            }
            for (int i = 0; i <viewStartIndex; i++) {
                [self setStarViewWith:i andWith:endIndex+i+([starsViewArray count]-viewEndIndex)];
            }
        }else{
            for (int i = viewEndIndex; i<viewStartIndex; i++) {
                [self setStarViewWith:i andWith:endIndex+(i-viewEndIndex)];
            }
        }
    }
    else{//顺时针
        if (viewStartIndex<viewEndIndex) {
            for (int i = viewStartIndex-1; i>=0; i--) {
                [self setStarViewWith:i andWith:startIndex-(viewStartIndex-i)];
            }
            
            for (long i = [starsViewArray count]-1; i>viewEndIndex; i--) {
                [self setStarViewWith:i andWith:startIndex-([starsViewArray count]-i)-viewStartIndex];
            }
        }else{
            for (int i =viewStartIndex-1; i>viewEndIndex; i--) {
                [self setStarViewWith:i andWith:startIndex-(viewStartIndex-i)];
            }
        }
    }
}
-(void)setStarViewWith:(long) viewIndex andWith:(long) dataIndex
{
    long starCount = [starsStoreArray count];
    long storeArray = dataIndex%starCount;
    if (storeArray<0) {
        storeArray = storeArray + starCount;
    }
    LLStarView *starView = starsViewArray[viewIndex];
    LLStarObject *star = starsStoreArray[storeArray];
    [starView setStarObject:star];
}
-(int)indexWithString:(NSString *)title
{
    for (int i=0; i<[starsStoreArray count]; i++) {
        LLStarObject *star = starsStoreArray[i];
        if ([star.title isEqualToString:title]) {
            return i;
        }
    }
    return 0;
}
#pragma mark ----------------星系转换-----------------------

#pragma mark 卫星旋转

/**
 * @brief  转动所有卫星
 */
-(void)animationStar:(LLStarView *)starView  andWithMoveType:(MoveType)moveType{
    //隐藏部分view
    if (moonType == MoonLarge) {
        for (int i=0; i<[starsViewArray count]; i++) {
            LLStarView *starView = starsViewArray[i];
            if (starView.center.y>(self.frame.size.height+40)||starView.center.x>self.frame.size.width+40) {
                [starView setHidden:YES];
            }
        }

    }
    float angle;
    float endAngel;
    switch (moveType) {
        case NormalSuperMove:{
             angle = [self calculateAngleWithPoint:starView.center];
             endAngel = [self calculateAngleOriginalWithPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
            //处理第三象限的特殊情况
            if (angle<-M_PI+endAngel) {
                angle = 2*M_PI+angle;
            }
            break;
        }case NormalReturnMove:{
            int whichOne;
            for (whichOne = 0; whichOne<[starsViewArray count]; whichOne++) {
                if ([starView isEqual:starsViewArray[whichOne]]) {
                    break;
                }
            }
             angle = [self calculateAngleOriginalWithPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
             endAngel= -M_PI/2+whichOne*(2*M_PI/[starsViewArray count]);
            if (moonType == MoonLarge) {
                endAngel =  endAngel -M_PI/2;
            }
            break;
            
        }default:
            break;
    }
    [self animationWithAngle:endAngel-angle andType:moveType withStarView:starView];
}

/**
 * @brief 根据角度  时间  顺时针还是逆时针  转动所有卫星
 */
-(void)animationWithAngle:(float)animationDangle andType:(MoveType) moveType withStarView:(LLStarView *)showStarView {
    float dangle = 2*M_PI/[starsViewArray count];
    for (int i=0; i<[starsViewArray count]; i++) {
        LLStarView *starView = starsViewArray[i];
        float angle = fistStarAngle + dangle*i;
        [self animationEveryStar:starView andIsHiden:![starView isEqual:showStarView] startAngle:angle endAngle:angle+animationDangle andType:moveType];
    }
    fistStarAngle = fistStarAngle+animationDangle;
}

/**
 * @brief 每个卫星做关键帧动画
 */
-(void)animationEveryStar:(LLStarView *) starView  andIsHiden:(BOOL) isHiden  startAngle:(float)startAngle endAngle:(float) endAngle  andType:(MoveType) moveType
{    
    CAKeyframeAnimation *animationOne = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    if (moveType == NormalSuperMove) {
        animationOne.values = @[@1,@1.1,@1.5];
    }else{
        animationOne.values = @[@1.5,@1.4,@1];
    }

    //移动
    CAKeyframeAnimation *animationTwo = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animationTwo.values = [self getPathArrayWithStartAngle:startAngle endAngle:endAngle andType:moveType];
    //组合
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.repeatCount = 1;
    group.duration = DTime;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.animations=@[animationOne,animationTwo];
    [starView.layer addAnimation:group forKey:@"group"];

    if (isHiden) {
        CAKeyframeAnimation *animationOne = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        if (moveType == NormalSuperMove) {
            animationOne.values = @[@1,@0.9,@0];
        }else{
            animationOne.values = @[@0,@0,@1];
        }
        animationOne.repeatCount = 1;
        animationOne.duration = 0.3;
        animationOne.removedOnCompletion = NO;
        animationOne.fillMode = kCAFillModeForwards;
        [starView.layer addAnimation:animationOne forKey:@"changeOpacity"];
    }
}

/**
 * @brief 计算卫星运动路径
 */
-(NSMutableArray *)getPathArrayWithStartAngle:(float)startAngle endAngle:(float) endAngle andType:(MoveType) moveType
{
    //计算移动经过的坐标
    NSMutableArray *array = [[NSMutableArray alloc]init];
    float dRadius =0;
    CGPoint center;
    float radius = 0.0;
    
    if (moveType<2) {
        dRadius=sqrt(pow((self.center.x), 2)+pow((self.center.y), 2)) -r;
    }
    
    for (int i=0; i<=DTime*DD;i++) {
        switch (moveType) {
            case NormalSuperMove:{
                center = CGPointMake(circleCenter.x - i*circleCenter.x/(DTime*DD), circleCenter.y- i*circleCenter.y/(DTime*DD));
                radius = r+i*dRadius/(DTime*DD);

                break;
            }case NormalReturnMove:{
                center = CGPointMake(i*circleCenter.x/(DTime*DD),i*circleCenter.y/(DTime*DD));
                radius = sqrt(pow((self.center.x), 2)+pow((self.center.y), 2))-i*dRadius/(DTime*DD);

                break;
            }default:
                break;
        }
        
        CGPoint pathPoint = [self calculatePointWithAngle:startAngle+i*(endAngle-startAngle)/(DTime*DD) andRadius:radius andCenter:center];

        [array addObject:[NSValue valueWithCGPoint:pathPoint]];
    }
    return array;
}


/**
 * @brief 根据角度 圆心 半径  得到坐标
 */
-(CGPoint)calculatePointWithAngle:(float)angle andRadius:(float)rTwo andCenter:(CGPoint)center
{
    return  CGPointMake(center.x+cos(angle)*rTwo, center.y+sin(angle)*rTwo);
}

-(void)returnMoon
{
    if (moonType == MoonNormal) {
        fistStarAngle = -M_PI/2;
        if ([starsViewArray count]!=0) {
            float angle = 2*M_PI/[starsViewArray count];
            for (int i=0; i<[starsViewArray count]; i++) {
                LLStarView *moonStar  = starsViewArray[i];
                [moonStar setFrame:CGRectMake(
                                              circleCenter.x+r*sin(i*angle)-StarWidth/2,
                                              circleCenter.y-r*cos(i*angle)-StarWidth/2,
                                              StarWidth,
                                              StarWidth)];
            }
        }
    }else if (moonType == MoonLarge){
        fistStarAngle = -M_PI;
        if ([starsViewArray count]!=0) {
            float angle = M_PI/9;
            for (int i=0; i<[starsViewArray count]; i++) {
                LLStarView *moonStar  = starsViewArray[i];
                [moonStar setHidden:NO];
//                moonStar.layer.opacity = 1;
                [moonStar setFrame:CGRectMake(
                                              circleCenter.x-r*cos(i*angle)-StarWidth/2,
                                              circleCenter.y-r*sin(i*angle)-StarWidth/2,
                                              StarWidth,
                                              StarWidth)];
            }
        }
    }
}

#pragma mark 圆环

-(void)moveCircleView
{
    LLCircleView *circleView = ((LLGalaxyView *)self.superview).circleView;
    [self circleFromSize:1.0 toSize:2.8 andFromPosition:circleView.layer.position andToPosition:CGPointMake(0,0)];
}

-(void)returnCircleView
{
    LLCircleView *circleView = ((LLGalaxyView *)self.superview).circleView;
    [self circleFromSize:2.8 toSize:1.0 andFromPosition:CGPointMake(0,0) andToPosition:circleView.layer.position];
}
-(void)circleFromSize:(float) fromSize toSize:(float) toSize andFromPosition:(CGPoint)fromPosition  andToPosition:(CGPoint)toPosition
{
    LLCircleView *circleView = ((LLGalaxyView *)self.superview).circleView;
    [circleView setHidden:NO];
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
    [circleView.layer addAnimation:group forKey:@"group"];
}



#pragma mark 卫星 大小
//现卫星 显示动画
-(void)showMoonView
{
    [self moonFromSize:0.5 toSize:1 andFromOpacity:0.2 andToOpacity:1.0];
}

//现卫星 消失动画
-(void)removeMoonView
{
    [self moonFromSize:1 toSize:0.5 andFromOpacity:1.0 andToOpacity:0.2];
}

-(void)moonFromSize:(float) fromSize toSize:(float) toSize andFromOpacity:(float)fromOpacity  andToOpacity:(float)toOpacity
{
    //恒星放大
    CABasicAnimation *animationOne = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animationOne.fromValue = [NSNumber numberWithFloat:fromSize];
    animationOne.toValue = [NSNumber numberWithFloat:toSize];
    // 不透明
    CABasicAnimation *animationTwo = [CABasicAnimation animationWithKeyPath:@"opacity"];
    
    animationTwo.fromValue = [NSNumber numberWithFloat:fromOpacity];
    animationTwo.toValue = [NSNumber numberWithFloat:toOpacity];
    
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
