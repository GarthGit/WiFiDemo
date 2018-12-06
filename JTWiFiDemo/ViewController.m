//
//  ViewController.m
//  JTWiFiDemo
//
//  Created by hoyifo on 2018/12/6.
//  Copyright © 2018 hoyifo. All rights reserved.
//

#import "ViewController.h"

#import "HFSmartLink.h"
#import "HFSmartLinkDeviceInfo.h"
#import "smartlinklib_7x.h"
#import <SystemConfiguration/CaptiveNetwork.h>






@interface ViewController (){
    
    HFSmartLink *smtlk;
    BOOL isconnecting;
    UIActivityIndicatorView *_indicator;
    UILabel *_lab;

    
}

@end

@implementation ViewController

//创建界面上的控件  renrouweidao duohaoch a a
-(void)createmainView{
    
    
    //创建登录网络标题
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(95, 100, 180, 45)];
    titleLab.text = @"登录网络";
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = [UIColor blackColor];
    titleLab.font = [UIFont systemFontOfSize:28];
    [self.view addSubview:titleLab];
    
    //创建返回按钮
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 100, 100, 50)];
    [backBtn setImage:[UIImage imageNamed:@"test_0"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    //创建输入网络名称框
    self.txtSSID = [[UITextField alloc]initWithFrame:CGRectMake(75, 250, 200, 50)];
    //self.txtSSID.backgroundColor = [UIColor grayColor];
    self.txtSSID.placeholder = @"请输入网络名称";
    UILabel *lab1 = [[UILabel alloc]initWithFrame:CGRectMake(75, 300, 220, 1)];
    lab1.backgroundColor = [UIColor grayColor];
    lab1.alpha = 0.3;
    [self.view addSubview:lab1];
    [self.view addSubview:self.txtSSID];
    
    //创建输入网络密码框
    self.txtPwd = [[UITextField alloc]initWithFrame:CGRectMake(75, 300, 200, 50)];
    //self.txtSSID.backgroundColor = [UIColor grayColor];
    self.txtPwd.placeholder = @"请输入网络密码";
    UILabel *lab2 = [[UILabel alloc]initWithFrame:CGRectMake(75, 350, 220, 1)];
    lab2.backgroundColor = [UIColor grayColor];
    lab2.alpha = 0.3;
    [self.view addSubview:lab2];
    [self.view addSubview:self.txtPwd];
    
    //创建登录按钮
    self.logBtn = [[UIButton alloc]initWithFrame:CGRectMake(95, 400, 75, 30)];
    [self.logBtn setTitle:@"登录" forState:UIControlStateNormal];
    self.logBtn.backgroundColor = [UIColor greenColor];
    [self.logBtn addTarget:self action:@selector(logBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.logBtn];
    
    //创建取消按钮
    self.cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(180, 400, 75, 30)];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    self.cancelBtn.backgroundColor = [UIColor greenColor];
    [self.cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelBtn];
    
    //smartlink初始化
    smtlk = [HFSmartLink shareInstence];
    smtlk.isConfigOneDevice = true;
    smtlk.waitTimers = 15;
    isconnecting=false;
    
    self.progress = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 20, 220, 1)];
    self.progress.progress = 0.0;
    //[self.view addSubview:self.progress];
    
    
    
    [self showWifiSsid];
    self.txtPwd.text = [self getspwdByssid:self.txtSSID.text];
    _txtPwd.delegate=self;
    _txtSSID.delegate=self;
    
    //创建加载时显示的等待加载lab
    _lab = [[UILabel alloc]initWithFrame:CGRectMake(75, 550, 100, 50)];
    _lab.text = @"连接中，请等待";
    _lab.adjustsFontSizeToFitWidth = YES;
    _lab.hidden = YES;
    _lab.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:_lab];
    
    //创建活动显示器
    _indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(95, 350, 50, 50)];
    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    [self.view addSubview:_indicator];
}



//返回按钮的点击事件
-(void)backBtnClick:(UIButton *)btn{
    
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (IBAction)cancelButton:(id)sender {
    
    [smtlk stopWithBlock:^(NSString *stopMsg, BOOL isOk) {
        if(isOk){
            isconnecting  = false;
            [self showAlertWithMsg:@"停止连接" title:@"OK"];
            _lab.hidden = YES;
            [_indicator stopAnimating];
        }else{
            [self showAlertWithMsg:@"停止连接" title:@"error"];
            _lab.hidden = YES;
            [_indicator stopAnimating];
        }
    }];
    
}

//取消按钮
- (void)cancelBtnClick:(UIButton *)btn{
    [smtlk stopWithBlock:^(NSString *stopMsg, BOOL isOk) {
        if(isOk){
            isconnecting  = false;
            [self showAlertWithMsg:@"停止连接" title:@"OK"];
            _lab.hidden = YES;
            [_indicator stopAnimating];
        }else{
            [self showAlertWithMsg:@"停止连接" title:@"error"];
            _lab.hidden = YES;
            [_indicator stopAnimating];
        }
    }];
    
    //[self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)loginButton:(id)sender {
    
    NSString * ssidStr= self.txtSSID.text;
    NSString * pswdStr = self.txtPwd.text;
    [self.txtPwd resignFirstResponder];
    [self.txtSSID resignFirstResponder];
    
    _lab.hidden = NO;
    [_indicator startAnimating];
    
    [self savePswd];
    self.progress.progress = 0.0;
    if(!isconnecting){
        isconnecting = true;
        [smtlk startWithSSID:ssidStr Key:pswdStr withV3x:true
                processblock: ^(NSInteger pro) {
                    self.progress.progress = (float)(pro)/100.0;
                    
                } successBlock:^(HFSmartLinkDeviceInfo *dev) {
                    self.host = dev.ip;
                    self.gmac = dev.mac;
                    [self  showAlertWithMsg:[NSString stringWithFormat:@"%@:%@",dev.mac,dev.ip] title:@"OK"];
                } failBlock:^(NSString *failmsg) {
                    failmsg = @"连接失败，请确认";
                    _lab.hidden = YES;
                    [_indicator stopAnimating];
                    [self  showAlertWithMsg:failmsg title:@"error"];
                } endBlock:^(NSDictionary *deviceDic) {
                    isconnecting  = false;
                    _lab.hidden = YES;
                    [_indicator stopAnimating];
                }];
    }else{
        [smtlk stopWithBlock:^(NSString *stopMsg, BOOL isOk) {
            
            if(isOk){
                isconnecting  = false;
                [self showAlertWithMsg:@"停止连接" title:@"OK"];
                _lab.hidden = YES;
                [_indicator stopAnimating];
            }else{
                [self showAlertWithMsg:@"停止连接" title:@"error"];
                _lab.hidden = YES;
                [_indicator stopAnimating];
            }
        }];
    }
    
    
}

- (void)logBtnClick:(UIButton *)btn
{
    NSString * ssidStr= self.txtSSID.text;
    NSString * pswdStr = self.txtPwd.text;
    [self.txtPwd resignFirstResponder];
    [self.txtSSID resignFirstResponder];
    
    _lab.hidden = NO;
    [_indicator startAnimating];
    
    [self savePswd];
    self.progress.progress = 0.0;
    if(!isconnecting){
        isconnecting = true;
        [smtlk startWithSSID:ssidStr Key:pswdStr withV3x:true
                processblock: ^(NSInteger pro) {
                    self.progress.progress = (float)(pro)/100.0;
                    
                } successBlock:^(HFSmartLinkDeviceInfo *dev) {
                    self.host = dev.ip;
                    self.gmac = dev.mac;
                    [self  showAlertWithMsg:[NSString stringWithFormat:@"%@:%@",dev.mac,dev.ip] title:@"OK"];
                } failBlock:^(NSString *failmsg) {
                    failmsg = @"连接失败，请确认";
                    _lab.hidden = YES;
                    [_indicator stopAnimating];
                    [self  showAlertWithMsg:failmsg title:@"error"];
                } endBlock:^(NSDictionary *deviceDic) {
                    isconnecting  = false;
                    _lab.hidden = YES;
                    [_indicator stopAnimating];
                }];
    }else{
        [smtlk stopWithBlock:^(NSString *stopMsg, BOOL isOk) {
            
            if(isOk){
                isconnecting  = false;
                [self showAlertWithMsg:@"停止连接" title:@"OK"];
                _lab.hidden = YES;
                [_indicator stopAnimating];
            }else{
                [self showAlertWithMsg:@"停止连接" title:@"error"];
                _lab.hidden = YES;
                [_indicator stopAnimating];
            }
        }];
    }
    
    
    
}

-(void)showAlertWithMsg:(NSString *)msg
                  title:(NSString*)title{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        //hyf_gateway *g = [[hyf_gateway alloc]init];
        //[g updateIp:stmt gip:self.host gmac:self.gmac];
        
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

-(void)savePswd{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    [def setObject:self.txtPwd.text forKey:self.txtSSID.text];
}

-(NSString *)getspwdByssid:(NSString * )mssid{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    return [def objectForKey:mssid];
}

-(void)showWifiSsid{
    BOOL wifiOk = false;
    NSDictionary *ifs;
    NSString *ssid;
    //UIAlertView *alert;
    
    if (!wifiOk) {
        ifs = [self fetchSSIDInfo];
        ssid = [ifs objectForKey:@"SSID"];
        if (ssid != nil) {
            wifiOk = true;
            self.txtSSID.text = ssid;
        }
        else{
            //            alert= [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"请连接Wi-Fi"] delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil];
            //            alert.delegate=self;
            //[alert show];
            
            
            
        }
    }
    
}

- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    return info;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.txtSSID resignFirstResponder];
    [self.txtPwd resignFirstResponder];
}


- (void)viewDidLoad {
    [super viewDidLoad];
//    [self createmainView];
    // Do any additional setup after loading the view from its nib.
    
    
        
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
