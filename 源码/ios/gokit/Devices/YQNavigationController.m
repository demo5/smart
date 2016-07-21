//
//  YQNavigationController.m
//  gokit
//
//  Created by YoKing on 16/4/8.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "YQNavigationController.h"

@implementation YQNavigationController

//+(void)initialize{
//        UINavigationBar *navigationBar = [UINavigationBar appearance];
//        [navigationBar setTintColor:[UIColor blueColor]];
//    
////        UIBarButtonItem *barButtonItem = [UIBarButtonItem appearance];
////        [barButtonItem setBackButtonBackgroundImage:[[UIImage imageNamed:@"bar_back_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal barMetrics:UIBarMetricsCompact];
//}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [super pushViewController:viewController animated:animated];
    if (viewController.navigationItem.leftBarButtonItem ==nil && self.viewControllers.count >1) {
        viewController.navigationItem.leftBarButtonItem = [self creatBackButton];
    }

}
-(UIBarButtonItem *)creatBackButton
{
    return [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"bar_back_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(popSelf)];
    
//    return [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(popSelf)];
}
-(void)popSelf
{
    [self popViewControllerAnimated:YES];
}
@end
