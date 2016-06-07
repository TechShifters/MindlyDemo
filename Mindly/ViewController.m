//
//  ViewController.m
//  Mindly
//
//  Created by longlong on 16/5/26.
//  Copyright © 2016年 LongLong. All rights reserved.
//

#import "ViewController.h"

#import "LLStarObject.h"
#import "LLGalaxyView.h"
#import "LLShowViewObject.h"

@interface ViewController (){
    LLGalaxyView *galaxyView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addStar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addStar
{
    
    float r = self.view.frame.size.width-20;
    galaxyView = [[LLGalaxyView alloc]initWithFrame:
                  CGRectMake(self.view.frame.size.width/2-r/2,
                             self.view.frame.size.height/2-r/2,
                             r,
                             r)
                  andStar:[self getData]];
    
    [galaxyView setGalaxyStage:GalaxyActive];
    [self.view addSubview:galaxyView];
    
}
-(LLStarObject *)getData
{
    [LLShowViewObject sharedInstance].onView = self.view;
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"DataList" ofType:@"plist"];
    NSDictionary *dataDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    return  [LLStarObject changeToStarFromDic:dataDic];
}
@end
