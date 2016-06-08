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
    GalaxyActive = 1,
    GalaxyHiden = 2
}GalaxyState;

@class LLMoonView;
@class LLStarView;
@class LLCircleView;

@class LLStarObject;

@interface LLGalaxyView : UIView

@property (nonatomic,strong) LLStarView *starView;
@property (nonatomic,strong) LLMoonView *moonView;
@property (nonatomic,strong) LLCircleView *circleView;

-(LLGalaxyView *)initWithFrame:(CGRect)frame andStar:(LLStarObject *)starObject;
-(void)setGalaxyStage:(GalaxyState) stage  andWithStar:(LLStarView *) starView;
@end
