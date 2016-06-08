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
    galaxyView = [[LLGalaxyView alloc]initWithFrame:self.view.frame
                  andStar:[self getData]];
    [galaxyView setGalaxyStage:GalaxyActive andWithStar:nil];
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
