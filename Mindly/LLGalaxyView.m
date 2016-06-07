//
//  LLGalaxyView.m
//  Mindly
//
//  Created by longlong on 16/5/26.
//  Copyright © 2016年 LongLong. All rights reserved.
//

#import "LLGalaxyView.h"
#define StarWidth 100
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
        UIView *showView = [LLShowViewObject sharedInstance].onView;
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 1);
        CGContextSetRGBStrokeColor(context, 220.0/255,220.0/255,220.0/255, 1.0);
        CGContextMoveToPoint(context,self.frame.size.width/2, self.frame.size.height/2);
        CGContextAddLineToPoint(context,self.frame.size.width/2+ showView.frame.size.width/2,self.frame.size.height/2+showView.frame.size.height/2);
        CGContextStrokePath(context);
    }
    

}

-(void)setGalaxyStage:(GalaxyState) stage;
{
    switch (stage) {
        case GalaxySuper:{
            _starView.stage = StarSuperCenter;
            [_moonView setMoonStage:MoonHiden];
            
            isHidenLine = NO;
            [self setNeedsDisplay];
            break;
            
        }case GalaxyActive:{
            _starView.stage = StarCenter;
            [_moonView setMoonStage:MoonOut];
            
            isHidenLine = YES;
            [self setNeedsDisplay];
            break;
        }case GalaxyHiden:{
            self.alpha = 0;
            break;
        }default:
            break;
    }
}
@end
