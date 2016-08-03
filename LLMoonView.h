//
//  LLMoonView.h
//  Mindly
//
//  Created by longlong on 16/5/26.
//  Copyright © 2016年 LongLong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    MoonHiden = 0,
    MoonOut= 1,
    MoonOutFirst= 2,
    MoonReturn =3,
    MoonRemove = 4,
}MoonState;

typedef enum {
    MoonNormal=0,
    MoonLarge=1,
}MoonType;


@class LLGalaxyView;
@class LLStarView;

@interface LLMoonView : UIView
@property (nonatomic,assign) MoonType moonType;

-(LLMoonView *)initWithFrame:(CGRect)frame andAry:(NSMutableArray*) starsArray atGalaxy:(LLGalaxyView *) atGalaxy;
-(void)setMoonStage:(MoonState) stage andWithStar:(LLStarView *)starView;
@end
