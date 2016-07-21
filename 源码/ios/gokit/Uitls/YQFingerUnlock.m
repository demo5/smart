//
//  YQFingerUnlock.m
//  smartCarHouse
//
//  Created by YoKing on 16/4/27.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "YQFingerUnlock.h"
#import "DeviceViewController.h"
#import "IoTCheckConnection.h"
@interface YQFingerUnlock ()
@property (nonatomic,strong)LAContext *context;
@property (nonatomic,assign) BOOL canBiometrics;
@end

@implementation YQFingerUnlock

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    _context = [[LAContext alloc] init];
    _canBiometrics = [_context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    
    if (_canBiometrics) {//支持生物识别
        [self authenticationWithLAPolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics];
    }else{//不支持指纹解锁
        [self authenticationWithLAPolicy:LAPolicyDeviceOwnerAuthentication];
    }
    
}
-(void)authenticationWithLAPolicy:(LAPolicy)laPolicy{
    [_context evaluatePolicy:laPolicy
             localizedReason:@"指纹验证"
                       reply:^(BOOL success, NSError * _Nullable error) {
                           if (success) {
                               IoTCheckConnection *controller = [[IoTCheckConnection alloc] init];
                               [self.navigationController pushViewController:controller animated:YES];
                               
                           } else {
                               if (error.code == kLAErrorUserFallback) {
                                   //Fallback按钮被点击执行,忘记密码
                                   NSLog(@"Fallback按钮被点击");
                               } else if (error.code == kLAErrorUserCancel) {
                                   //取消按钮被点击执行，取消
                                   NSLog(@"取消按钮被点击");
                               } else {
                                   //指纹识别失败执行
                                   NSLog(@"指纹识别失败");
                               }
                        }
       }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
