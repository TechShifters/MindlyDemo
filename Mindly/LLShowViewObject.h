//
//  LLShowViewObject.h
//  Mindly
//
//  Created by longlong on 16/6/2.
//  Copyright © 2016年 LongLong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface LLShowViewObject : NSObject
@property(nonatomic ,weak)  UIView *onView;
+(LLShowViewObject *)sharedInstance;
@end
