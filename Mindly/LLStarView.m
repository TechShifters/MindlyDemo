//
//  LLStarView.m
//  Mindly
//
//  Created by longlong on 16/5/26.
//  Copyright © 2016年 LongLong. All rights reserved.
//


#import "LLStarObject.h"

#import "LLStarView.h"
#import "LLGalaxyView.h"
#import "LLMoonView.h"

#import "LLShowViewObject.h"
@implementation LLStarView{
    LLStarObject *theStarObject;
}
-(LLStarView *)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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

-(void)clickTap
{
    switch (_stage) {
        case StarSuperCenter:{
            [self showHigherLevel];
            break;
        }case StarOut:{
            [self showNextLevel];
            break;
        }case StarHiden:{
            break;
        }default:
            break;
    }
}

//-(void)layoutSubviews
//{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [_titleLable setFont:[UIFont systemFontOfSize:CGRectGetHeight(self.frame)/8]];
//        [_titleLable setFrame:CGRectMake(CGRectGetWidth(self.frame)*1/10, CGRectGetHeight(self.frame)/4,CGRectGetWidth(self.frame)*8/10,CGRectGetHeight(self.frame)/2)];
//
//    });
//}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 40.0/255, 155.0/255, 127.0/255, 1.0);
    CGContextAddArc(ctx, CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), CGRectGetMidX(self.bounds), 0, 2*M_PI, 0);
    CGContextDrawPath(ctx, kCGPathFill);
    CGContextStrokePath(ctx);
}

-(void)setStarObject:(LLStarObject *)starObject;
{
    theStarObject = starObject;
    if (starObject.image.length>2) {
        self.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:starObject.image].CGImage);
    }else if (starObject.title){
        [_titleLable setText:starObject.title];
        [self setBackgroundColor:[UIColor clearColor]];
    }
}



-(void)showNextLevel
{
    UIView *showView = [LLShowViewObject sharedInstance].onView;
    LLGalaxyView *galaxyView = [[LLGalaxyView alloc]initWithFrame:CGRectMake(0,0, CGRectGetWidth(showView.bounds)-20, CGRectGetWidth(showView.bounds)-20) andStar:theStarObject];
    [galaxyView setCenter:showView.center];
    galaxyView.moonView.alpha = 0;
    [showView addSubview:galaxyView];
    _galaxyAtSide.starView.galaxyNext = galaxyView;
    
    [(LLMoonView *)self.superview animationStar:self];
    
    float  r =   sqrt(pow(CGRectGetWidth(showView.frame)/2, 2)+pow(CGRectGetHeight(showView.frame)/2, 2)) +40;
    [UIView animateWithDuration:0.3 animations:^{
        [_galaxyAtSide setFrame:CGRectMake(-r, -r,2*r,2*r)];
        [galaxyView setGalaxyStage:GalaxyActive];
        galaxyView.moonView.alpha = 1;
        _galaxyAtSide.moonView.alpha = 0;
        
    } completion:^(BOOL finished) {
        [_galaxyAtSide setGalaxyStage:GalaxySuper];
        
    }];
    
}

-(void)showHigherLevel
{
    UIView *showView = [LLShowViewObject sharedInstance].onView;
    [UIView animateWithDuration:0.3 animations:^{
        [_galaxyAtCenter setGalaxyStage:GalaxyActive];
        float r = CGRectGetWidth(showView.frame)-20;
        [_galaxyAtCenter setFrame:CGRectMake(showView.frame.size.width/2-r/2,showView.frame.size.height/2-r/2, r, r)];
        [_galaxyNext setGalaxyStage:GalaxyHiden];
    } completion:^(BOOL finished) {
        [_galaxyNext removeFromSuperview];
    }];
}

@end

