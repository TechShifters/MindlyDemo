//
//  LLStarObject.h
//  Mindly
//
//  Created by longlong on 16/5/26.
//  Copyright © 2016年 LongLong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LLStarObject : NSObject
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *image;
@property (nonatomic,strong) UIColor *color;
@property (nonatomic,strong) NSMutableArray *nextStars;

+(LLStarObject *)changeToStarFromDic:(NSDictionary*) dic;
@end
