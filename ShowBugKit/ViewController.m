//
//  ViewController.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/16.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "ViewController.h"
#import "TMNetworkingHelper.h"
#import "TMNetworkConfig.h"
#import "TMNetworkAnalyse.h"
#import "UIAlertController+Extension.h"

/* 新建宏归类 */
#define kaaaaaaUrl @"cook/category"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"DELETE" style:UIBarButtonItemStyleDone target:self action:@selector(onButton)];
    self.navigationItem.rightBarButtonItem = item;
    
    /* 应在appdelegate初始化TMNetworkConfig */
    [TMNetworkConfig shareInstance].betaVersion = YES;
    [TMNetworkConfig shareInstance].proServerAPI = @"http://apis.juhe.cn/";
    [TMNetworkConfig shareInstance].testServerAPI = @"http://apis.juhe.cn/";
    [TMNetworkConfig shareInstance].generalHeaders = @{@"Content-Type":@"application/json"};
    [TMNetworkConfig shareInstance].enableDebug = NO;
    [TMNetworkConfig shareInstance].apiAnalyse = YES;
}

- (void)onButton{
    NSLog(@"--->%@",[TMNetworkAnalyse shareManager].failurePercent);
    NSLog(@"--->%@",[TMNetworkAnalyse shareManager].getAPINetworkAnalyseFailurejson);
    NSDictionary *dict = [NSDictionary dictionary];
    [dict setValue:@"aa" forKey:@"aa"];
//    NSArray *array = [NSArray array];
//    id ob = array[1];
}

- (IBAction)buttonType1:(UIButton *)sender {
    NSDictionary *dict = @{@"key": @"1e86b8ec4d601567841d73a942132f65",//1e86b8ec4d601567841d73a942132f65
                           @"dtype": @"",
                           @"parentid": @""
                           };
    [TMNetworkingHelper getWithUrl:kaaaaaaUrl refreshRequest:YES cache:YES params:dict successBlock:^(id response) {
        NSLog(@"-->>>%@",response);
    } failBlock:^(NSError *error) {
        NSDictionary *errorInfo = error.userInfo;
        /* 可根据单个接口不同的错误码置换与服务器不一样的个性化提示 */
        NSString *status = errorInfo[KEY_ERRORCODE];
        NSString *message = errorInfo[KEY_MESSAGE];
        
        if ([status isEqualToString:@"10001"]) {
            message = @"无效的key啊大佬";
        }
        NSString *content = [NSString stringWithFormat:@"%@，错误码是：%@",message, status];
        [UIAlertController alertShowInViewController:self title:TM_ALERT_NOTICE message:content buttonTitleArray:@[TM_ALERT_SURE] buttonTitleColorArray:@[[UIColor blackColor]] block:^(UIAlertController * _Nonnull alertController, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
            
        }];
    }];
}

- (IBAction)buttonType2:(UIButton *)sender {
    NSDictionary *dict = @{@"key": @"1e86b8ec4d601567841d73a942132f65",//1e86b8ec4d601567841d73a942132f65
                           @"dtype": @"",
                           @"parentid": @""
                           };
    [TMNetworkingHelper postWithUrl:kaaaaaaUrl refreshRequest:YES cache:YES params:dict successBlock:^(id response) {
        NSLog(@"-->>>%@",response);
    } failBlock:^(NSError *error) {
        NSDictionary *errorInfo = error.userInfo;
        /* 统一错误码风格 */
        NSString *content = errorInfo[KEY_CONTENT];
        [UIAlertController alertShowInViewController:self title:TM_ALERT_NOTICE message:content buttonTitleArray:@[TM_ALERT_SURE] buttonTitleColorArray:@[[UIColor blackColor]] block:^(UIAlertController * _Nonnull alertController, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
            
        }];
    }];
}

- (IBAction)buttonType3:(UIButton *)sender {
    
}

- (IBAction)buttonType4:(UIButton *)sender {
    
}

- (IBAction)buttonType5:(UIButton *)sender {
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.navigationController pushViewController:[ViewController new] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
