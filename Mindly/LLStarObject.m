//
//  LLStarObject.m
//  Mindly
//
//  Created by longlong on 16/5/26.
//  Copyright © 2016年 LongLong. All rights reserved.
//

#import "LLStarObject.h"

@implementation LLStarObject
+(LLStarObject *)changeToStarFromDic:(NSDictionary*) dic;
{
    LLStarObject *star = [[LLStarObject alloc]init];
    star.title = [dic objectForKey:@"title"];
    star.image = [dic objectForKey:@"image"];
    star.color = [UIColor colorWithRed:40.0/255 green:155.0/255 blue:127.0/255 alpha:1];
    
    star.nextStars = [[NSMutableArray alloc]init];
    NSArray *array = [dic objectForKey:@"nextLevel"];
    for (NSDictionary *nextDic in array) {
        [star.nextStars addObject: [LLStarObject changeToStarFromDic:nextDic]];
    }
    return star;

}
@end
