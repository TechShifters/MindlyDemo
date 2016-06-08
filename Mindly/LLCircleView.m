//
//  LLCircleView.m
//  Mindly
//
//  Created by longlong on 16/6/8.
//  Copyright © 2016年 LongLong. All rights reserved.
//

#import "LLCircleView.h"

@implementation LLCircleView

-(LLCircleView *)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
    
}


- (void)drawRect:(CGRect)rect {
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:0.5].CGColor);
    CGContextAddArc(ctx, CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), CGRectGetMidX(self.bounds), 0, 2*M_PI, 0);
    CGContextStrokePath(ctx);
}

@end
