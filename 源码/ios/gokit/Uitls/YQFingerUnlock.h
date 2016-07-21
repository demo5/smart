//
//  YQFingerUnlock.h
//  smartCarHouse
//
//  Created by YoKing on 16/4/27.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <XPGWifiSDK/XPGWifiDevice.h>
@interface YQFingerUnlock : UIViewController
@property (nonatomic,strong) XPGWifiDevice *device;
//- (id)initWithDevice:(XPGWifiDevice *)device;
@end
