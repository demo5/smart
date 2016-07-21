//
//  DeviceViewController.h
//  gokit
//
//  Created by YoKing on 16/3/17.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <XPGWifiSDK/XPGWifiDevice.h>
#import "IoTDeviceLabelCell.h"
#import "IoTDeviceSliderCell.h"
#import "IoTDeviceBoolCell.h"
#import "IoTDeviceEnumCell.h"


@interface DeviceViewController : UIViewController<XPGWifiSDKDelegate, XPGWifiDeviceDelegate,UIAlertViewDelegate,UIActionSheetDelegate>

- (id)initWithDevice:(XPGWifiDevice *)device;
@end
