//
//  LLGalaxyView.h
//  Mindly
//
//  Created by longlong on 16/5/26.
//  Copyright © 2016年 LongLong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    GalaxySuper = 0,
    GalaxyBorn = 1,
    GalaxyReturn = 2,
    GalaxyDeath = 3
    
}GalaxyState;

@class LLMoonView;
@class LLStarView;
@class LLCircleView;
@class LLStarObject;

@interface LLGalaxyView : UIView

@property (nonatomic,weak) LLGalaxyView *galaxySuper;
@property (nonatomic,weak) LLGalaxyView *galaxyNext;

@property (nonatomic,weak) LLStarView *superStarView;
@property (nonatomic,strong) LLStarView *starView;
@property (nonatomic,strong) LLMoonView *moonView;
@property (nonatomic,strong) LLCircleView *circleView;

-(LLGalaxyView *)initWithFrame:(CGRect)frame andStar:(LLStarObject *)starObject;
-(void)setGalaxyStage:(GalaxyState) stage  andWithStar:(LLStarView *) starView;
-(void)showNextGalaxyWith:(LLStarView *)starView andStartObject:(LLStarObject*)theStarObject;//展示下一星系
-(void)hidenLine:(BOOL)isHiden;//是否显示星际链接线
@end
