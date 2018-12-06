//
//  ViewController.h
//  JTWiFiDemo
//
//  Created by hoyifo on 2018/12/6.
//  Copyright © 2018 hoyifo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITextFieldDelegate>


@property  UITextField *txtSSID;
@property  UITextField *txtPwd;
@property  UIButton *cancelBtn;
@property  UIButton *logBtn;
@property  UIProgressView *progress;

@property  NSString *host;
@property  NSString *gmac;


@end

