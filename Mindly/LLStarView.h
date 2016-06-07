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
    StarOut= 2,
    StarHiden = 3
}StarState;

@class LLStarObject;
@class LLGalaxyView;

@interface LLStarView : UIView
@property (nonatomic,strong) UILabel *titleLable;
@property (nonatomic,assign) StarState stage;

@property (nonatomic,weak) LLGalaxyView *galaxyAtSide;
@property (nonatomic,weak) LLGalaxyView *galaxyAtCenter;
@property (nonatomic,weak) LLGalaxyView *galaxyNext;

-(void)setStarObject:(LLStarObject *)starObject;
@end