//
//  DeviceViewController.m
//  gokit
//
//  Created by YoKing on 16/3/17.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DeviceViewController.h"

typedef enum
{
    // writable
    IoTDeviceWriteUpdateData = 0,   //更新数据
    IoTDeviceWriteLED_R_onOff,      //LED R开关
    IoTDeviceWriteLED_Color,        //LED 组合颜色
    IoTDeviceWriteLED_R,            //LED R值
    IoTDeviceWriteLED_G,            //LED G值
    IoTDeviceWriteLED_B,            //LED B值
    IoTDeviceWriteMotorSpeed,       //电机转速
    
    // readonly
    IoTDeviceReadIR,                //红外
    IoTDeviceReadTemperature,       //温度
    IoTDeviceReadHumidity,          //湿度
    
    // alarm
    IoTDeviceAlarm1,                //报警1
    IoTDeviceAlarm2,                //报警2
    
    // fault
    IoTDeviceFaultLED,              //LED故障
    IoTDeviceFaultMotor,            //电机故障
    IoTDeviceFaultSensor,           //温湿度传感器故障
    IoTDeviceFaultIR,               //红外故障
}IoTDeviceDataPoint;

@interface DeviceViewController (){

    // 这些变量用于数据更新
    BOOL bLedCtrl;
    NSInteger iLedR;
    NSInteger iledColor;
    CGFloat fLedR;
    CGFloat fLedG;
    CGFloat fLedB;
    CGFloat fMonitorSpeed;
    NSInteger irr;
    CGFloat fTemperature;
    CGFloat fHumidity;
    
    UIAlertView *_alertView;
    // 暂停数据更新
    NSTimer *remainTimer;
    NSMutableArray *updateCtrl;


}
@property (readonly, nonatomic) XPGWifiDevice *device;
@property (strong,nonatomic) NSArray *arr;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *button_LED;
@property (weak, nonatomic) IBOutlet UIView *view_tem;
@property (weak, nonatomic) IBOutlet UIView *view_hum;
@property (weak, nonatomic) IBOutlet UIButton *button_open;
@property (weak, nonatomic) IBOutlet UIButton *button_close;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *lable_doorStatus;
@property (weak, nonatomic) IBOutlet UILabel *label_tem;
@property (weak, nonatomic) IBOutlet UILabel *label_hum;

@end

@implementation DeviceViewController

static DeviceViewController* _instance = nil;

+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return _instance ;
}

+(id) allocWithZone:(struct _NSZone *)zone
{
    return [DeviceViewController shareInstance] ;
}

-(id) copyWithZone:(struct _NSZone *)zone
{
    return [DeviceViewController shareInstance] ;
}

- (id)initWithDevice:(XPGWifiDevice *)device
{
    self = [super init];
    if(self)
    {
        if(nil == device || !device.isConnected)
            return nil;
        
        _device = device;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _device.delegate = self;
    
    self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    //设置右侧按钮
    UIImage *image = [[UIImage imageNamed:@"align"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(rightMenu)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //设置bar属性
//    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, 20)];
//    barView.backgroundColor = [UIColor blackColor];
//    [self.navigationController.navigationBar addSubview:barView];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBar"] forBarMetrics:UIBarMetricsDefault];
    
    //lable属性
    self.lable_doorStatus.layer.cornerRadius = 10.0;
    self.lable_doorStatus.layer.borderWidth = 2.0;
    self.lable_doorStatus.layer.borderColor = [UIColor whiteColor].CGColor;
    self.lable_doorStatus.layer.masksToBounds = YES;
    
    //button属性设置
    [self.button_LED setImage:[[UIImage imageNamed:@"button_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];

    [self.button_open setImage:[[UIImage imageNamed:@"button_open"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];

    [self.button_close setImage:[[UIImage imageNamed:@"button_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    
    //温湿度view属性设置
    self.view_tem.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"temperature"]];
    self.view_hum.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"humidity"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_device write:@{@"cmd":@2}];
    //大循环判断设备是否在线
    if(!self.device.isOnline && !self.device.isLAN)
    {
        [_alertView dismissWithClickedButtonIndex:0 animated:YES];
        _alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"设备不在线，你不可以控制设备，但你可以解除绑定信息。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [_alertView show];
        self.view.userInteractionEnabled = NO;
    }
    
    //初始化信息
    self.navigationItem.title = _device.productName;
    
    [XPGWifiSDK sharedInstance].delegate = self;
    _device.delegate = self;
    
    iLedR = 0;
    iledColor = -1;
    fLedG = 0;
    fLedB = 0;
    irr = 0;
    fMonitorSpeed = 0;
    fTemperature = -1;
    fHumidity = -1;
    
    //暂停更新页面的计时器
    if(!remainTimer)
        remainTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onRemainTimer) userInfo:nil repeats:YES];
    updateCtrl = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self writeDataPoint:IoTDeviceWriteUpdateData value:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _device.delegate = nil;
    [XPGWifiSDK sharedInstance].delegate = nil;
    [remainTimer invalidate];
    remainTimer = nil;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)writeDataPoint:(IoTDeviceDataPoint)dataPoint value:(id)value{

}
- (void)XPGWifiDevice:(XPGWifiDevice *)device didReceiveData: (NSDictionary *)data result:(int)result{
    
    
    
    NSDictionary *_data = [data valueForKey:@"data"];
    NSDictionary *entity0 = [_data valueForKey:@"entity0"];
    
    self.label_tem.text = [entity0 objectForKey:@"Temperature"];
    self.label_hum.text = [NSString stringWithFormat:@"%@%%",[entity0 objectForKey:@"Humidity"]];
    
    irr = [[entity0 objectForKey:@"Infrared"] integerValue];
    if (irr) {
//        [_button_open setEnabled:NO];
//        [_button_close setEnabled:YES];
        _lable_doorStatus.text = @"车库门已开启";
    }else{
        _lable_doorStatus.text = @"车库门已关闭";
//        [_button_close setEnabled:NO];
//        [_button_open setEnabled:YES];
    }
}

//开关灯
- (IBAction)RGBLight:(UIButton *)sender {
    
    NSDictionary *data = [NSDictionary dictionary];
    sender.selected = ![sender isSelected];
    if ([sender isSelected]) {
        [sender setImage:[[UIImage imageNamed:@"button_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
        
        data = @{@"entity0":@{@"LED_R":@244,@"LED_G":@244,@"LED_B":@244},
                 @"cmd":@1};
        
    }else{
        
        [sender setImage:[[UIImage imageNamed:@"button_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        data = @{@"entity0":@{@"LED_R":@0,@"LED_G":@0,@"LED_B":@0},
                 @"cmd":@1};

    }
    [_device write:data];
}
//返回0---->关门状态
//返回1---->开门状态  ，未知状态
//开关门
- (IBAction)openDoor:(UIButton *)sender {
    NSDictionary *data = [NSDictionary dictionary];
    data = @{@"entity0":@{@"Motor_Speed":@1},
                              @"cmd":@1};
//    sender.selected = ![sender isSelected];
//    if ([sender isSelected]) {
//        [self.button_close setEnabled:NO];
//        data = @{@"entity0":@{@"Motor_Speed":@1},
//                 @"cmd":@1};
//        [sender setImage:[[UIImage imageNamed:@"openbutton_suspend"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
//    }else{
//        
//        [self.button_close setEnabled:YES];
//        data = @{@"entity0":@{@"Motor_Speed":@0},n
//                 @"cmd":@1};
//        [sender setImage:[[UIImage imageNamed:@"button_open"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
//    }
    [_device write:data];
    
}
- (IBAction)offDoor:(UIButton *)sender {
    NSDictionary *data = [NSDictionary dictionary];
    data = @{@"entity0":@{@"Motor_Speed":@-1},
                              @"cmd":@1};
//    sender.selected = ![sender isSelected];
//    
//    if ([sender isSelected]) {
//        [self.button_open setEnabled:NO];
//        
//        data = @{@"entity0":@{@"Motor_Speed":@-1},
//                 @"cmd":@1};
//        [sender setImage:[[UIImage imageNamed:@"closebutton_suspend"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
//        
//    }else{
//        [self.button_open setEnabled:YES];
//        data = @{@"entity0":@{@"Motor_Speed":@0},
//                 @"cmd":@1};
//        [sender setImage:[[UIImage imageNamed:@"button_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
//    }
    
    [_device write:data];
}

- (void)onRemainTimer
{
    //根据系统的 Timer 去更新控件可以变更的剩余时间
    NSMutableArray *removeCtrl = [NSMutableArray array];
    for(NSMutableDictionary *dict in updateCtrl)
    {
        int remainTime = [[dict valueForKey:@"remaining"] intValue] - 1;
        if(remainTime != 0)
            [dict setValue:@(remainTime) forKey:@"remaining"];
        else
            [removeCtrl addObject:dict];
    }
    [updateCtrl removeObjectsInArray:removeCtrl];
}

- (void)rightMenu
{
    UIActionSheet *actionSheet = nil;
    if (self.device.isLAN) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"断开连接",@"解除绑定",@"更新数据",@"获取设备硬件信息", nil];
    }
    else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"断开连接",@"解除绑定",@"更新数据", nil];
    }
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag) {
        case 1://控制页面
        {
            switch (buttonIndex) {
                case 0:
                    //断开链接
                    [self.navigationController popViewControllerAnimated:YES];
                    
                    break;
                case 1:
                {
                    //解绑
                    MBProgressHUD *hud = AppDelegate.hud;
                    hud.labelText = @"与服务器解除绑定...";
                    [hud show:YES];
                    [[XPGWifiSDK sharedInstance] unbindDeviceWithUid:AppDelegate.uid token:AppDelegate.token did:self.device.did passCode:nil];
                    break;
                }
                case 2:
                {
                    //更新数据
                    [self writeDataPoint:IoTDeviceWriteUpdateData value:nil];
                    break;
                }
                case 3:
                {
                    //获取设备硬件信息
                    [self onGetHardwareInfo];
                    
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}
- (void)onGetHardwareInfo
{
    if (self.device.isLAN) {
        [self.device getHardwareInfo];
    }
}

- (void)XPGWifiDevice:(XPGWifiDevice *)device didQueryHardwareInfo:(NSDictionary *)hwInfo
{
    NSString *hardWareInfo = [NSString stringWithFormat:@"WiFi Hardware Version: %@,\n\
                              WiFi Software Version: %@,\n\
                              MCU Hardware Version: %@,\n\
                              MCU Software Version: %@,\n\
                              Firmware Id: %@,\n\
                              Firmware Version: %@,\n\
                              Product Key: %@,\n\
                              Device ID: %@,\n\
                              Device IP: %@,\n\
                              Device MAC: %@", [hwInfo valueForKey:XPGWifiDeviceHardwareWifiHardVerKey]
                              , [hwInfo valueForKey:XPGWifiDeviceHardwareWifiSoftVerKey]
                              , [hwInfo valueForKey:XPGWifiDeviceHardwareMCUHardVerKey]
                              , [hwInfo valueForKey:XPGWifiDeviceHardwareMCUSoftVerKey]
                              , [hwInfo valueForKey:XPGWifiDeviceHardwareFirmwareIdKey]
                              , [hwInfo valueForKey:XPGWifiDeviceHardwareFirmwareVerKey]
                              , [hwInfo valueForKey:XPGWifiDeviceHardwareProductKey]
                              , self.device.did, self.device.ipAddress, self.device.macAddress];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _alertView = [[UIAlertView alloc] initWithTitle:NSLS(@"device_hardwareinformation") message:hardWareInfo delegate:self cancelButtonTitle:NSLS(@"device_confirm") otherButtonTitles:nil];
        [_alertView show];
    });
}

@end
