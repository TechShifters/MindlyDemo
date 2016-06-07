//
//  LLShowViewObject.m
//  Mindly
//
//  Created by longlong on 16/6/2.
//  Copyright © 2016年 LongLong. All rights reserved.
//

#import "LLShowViewObject.h"

@implementation LLShowViewObject
static LLShowViewObject *showViewObject=nil;
+(LLShowViewObject *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        showViewObject = [[LLShowViewObject alloc] init];
    });
    return showViewObject;
}
@end
