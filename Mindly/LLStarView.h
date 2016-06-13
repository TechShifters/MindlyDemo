//
//  LLStarView.h
//  Mindly
//
//  Created by longlong on 16/5/26.
//  Copyright © 2016年 LongLong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    StarSuperCenter = 0,
    StarCenter = 1,
    StarSide= 2,
    StarCenterReturn= 3,
    StarDeath = 4
}StarState;

@class LLStarObject;

@interface LLStarView : UIView
@property (nonatomic,assign) StarState stage;
@property (nonatomic,strong) UILabel *titleLable;

-(void)setStarObject:(LLStarObject *)starObject;
-(void)setStarStage:(StarState) stage;
@end

