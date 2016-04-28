//
//  ViewController.m
//  AdLooper
//
//  Created by wang xinkai on 16/4/27.
//  Copyright © 2016年 wxk. All rights reserved.
//

#import "ViewController.h"
#import "AdLooper.h"
@interface ViewController ()

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image0 = [UIImage imageNamed:@"home_0"];
    UIImage *image1 = [UIImage imageNamed:@"home_1.jpg"];
    UIImage *image2 = [UIImage imageNamed:@"home_2.jpg"];
    AdLooper *Adview = [[AdLooper alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300) data:@[image0,image1,image2]];

    
    [self.view addSubview:Adview];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
