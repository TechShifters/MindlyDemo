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
@implementation LLGalaxyView{
    BOOL isHidenLine;
}

-(LLGalaxyView *)initWithFrame:(CGRect)frame andStar:(LLStarObject *)starObject
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        if (starObject.nextStars.count<7) {
            //加圆圈
            float r = CGRectGetMidX(self.bounds)-StarWidth/2;
            _circleView  = [[LLCircleView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.bounds)-r, CGRectGetMidY(self.bounds)-r, r*2,r*2)];
            [self addSubview:_circleView];
            
            //加恒星
            _starView = [[LLStarView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.bounds)-CGRectGetWidth(self.bounds)/6,CGRectGetMidY(self.bounds)-CGRectGetWidth(self.bounds)/6, CGRectGetWidth(self.bounds)/3,CGRectGetWidth(self.bounds)/3)];
            [_starView setStarObject:starObject];
            [self addSubview:_starView];
            
            //加卫星
            _moonView = [[LLMoonView alloc]initWithFrame:self.bounds andAry:starObject.nextStars atGalaxy:self];
            [self addSubview:_moonView];
        }else{
            //加圆圈
            float r = CGRectGetWidth(self.bounds);
            _circleView  = [[LLCircleView alloc] initWithFrame:CGRectMake(StarWidth/2, CGRectGetHeight(self.bounds)*2/5, r*2,r*2)];
            [self addSubview:_circleView];
            
            //加恒星
            _starView = [[LLStarView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)-StarWidth*4.8/3,CGRectGetHeight(self.bounds)-StarWidth*7/3, StarWidth*4/3,StarWidth*4/3)];
            [_starView setStarObject:starObject];
            [self addSubview:_starView];

            
            //加卫星
            _moonView = [[LLMoonView alloc]initWithFrame:self.bounds andAry:starObject.nextStars atGalaxy:self];
            [self addSubview:_moonView];
        }
        //上一星系的恒星响应事件
        UIButton *superStarBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        [superStarBtn setBackgroundColor:[UIColor clearColor]];
        [superStarBtn addTarget:self action:@selector(showSubGalaxy) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:superStarBtn];
    }
    return self;
}
#pragma  mark  --------------------星系转换--------------------

-(void)showNextGalaxyWith:(LLStarView *)starView andStartObject:(LLStarObject*)theStarObject
{
    //本星系 转超星
    [self setGalaxyStage:GalaxySuper andWithStar:starView];

    //新星系 诞生
    LLGalaxyView *galaxyView = [[LLGalaxyView alloc]initWithFrame:self.frame andStar:theStarObject];
    [self addSubview:galaxyView];
    [galaxyView setGalaxyStage:GalaxyBorn andWithStar:starView];
    
    //星系关系设置
    galaxyView.galaxySuper = self;
    self.galaxyNext = galaxyView;
}

-(void)showSubGalaxy
{
    if (_superStarView) {
        //本星系  消散
        [self setGalaxyStage:GalaxyDeath andWithStar:nil];

        //超星 回归
        [_galaxySuper setGalaxyStage:GalaxyReturn andWithStar:_superStarView];    }
}


-(void)setGalaxyStage:(GalaxyState) stage  andWithStar:(LLStarView *) starView;
{
    switch (stage) {
        case GalaxySuper:{
            [_galaxySuper hidenLine:YES];//隐藏上个星系的线
            
            [_starView setStarStage:StarSuperCenter];
            [_moonView setMoonStage:MoonHiden andWithStar:starView];
            break;
            
        }case GalaxyBorn:{
            [self hidenLine:YES];//本星系的线 隐藏
            
            [_starView setStarStage:StarCenter];
            _superStarView = starView;
            if (starView) {
                [_starView setHidden:YES];
                [_moonView setMoonStage:MoonOut andWithStar:starView];
            }else{
                //第一个诞生的星系
                [_moonView setMoonStage:MoonOutFirst andWithStar:starView];
            }
            break;
        }case GalaxyReturn:{
            [self hidenLine:YES];//本星系的线 隐藏
            
            [_starView setStarStage:StarCenterReturn];
            [_moonView setMoonStage:MoonReturn andWithStar:starView];
            break;
            
        }case GalaxyDeath:{
            
            [_starView setStarStage:StarDeath];
            [_moonView setMoonStage:MoonRemove andWithStar:nil];
            break;
        }default:
            break;
    }
}

#pragma mark   -------------星际链接线控制-------------

-(void)hidenLine:(BOOL)isHiden;
{
    isHidenLine = isHiden;
    [self setNeedsDisplay];
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

@end
