//
//  ViewController.m
//  SmartCity
//
//  Created by  on 16/5/16.
//  Copyright © 2016年 ohayou. All rights reserved.
//

#import "ViewController.h"
#import "WebViewJavascriptBridge.h"
#import "YYCache.h"
#import "URLCache.h"
#import "HCScanQRViewController.h"
#import <objc/runtime.h>
#import "UIColor+Hex.h"

#define Camerapermissions @"Camerapermissions"

@interface ViewController ()<UIWebViewDelegate>
{
    WebViewJavascriptBridge *_bridge;
    
    URLCache *sharedCache ;
}
@property (nonatomic,assign)BOOL hasInit;
@property (weak, nonatomic) IBOutlet UIButton *test;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor colorWithHex:@"22AB38"];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(postCode:) name:@"Code" object:nil];
    [self loadWebView];
    
    [self locationSet];
}
-(void)loadView
{
    [super loadView];

    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    _search.delegate = self;
}
- (void)loadWebView
{
    _webView.delegate = self;
    _webView.clipsToBounds = NO;
    NSURL *url = [[NSBundle mainBundle]URLForResource:@"index" withExtension:@"html" subdirectory:@"trace"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
   NSCachedURLResponse *respose = [sharedCache cachedResponseForRequest:request];
  
    [_webView loadRequest:request];
//
    [WebViewJavascriptBridge enableLogging];
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        
    }];
    [_bridge registerHandler:@"getLocation" handler:^(id data, WVJBResponseCallback responseCallback) {
        

    }];
    [_bridge registerHandler:@"getQRCode" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSLog(@"%@",[data objectForKey:@"type"]);
        
//        NSString *type = @"";
        if (data) {
            NSData *tempData = [data dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:tempData options:0 error:nil];
            NSLog(@"%@",dic);
            //        NSArray*temp =  [data componentsSeparatedByString:@"\""];
            //        for (NSString *str in temp){
            //            if ([str integerValue]==1||[str integerValue]==2){
            //                type = str;
            //                break ;
            //            }
            //        }
            [self getQRCodeWithKey:dic[@"type"]];
        }
    }];
    
}
#pragma mark 定位
- (void)locationSet
{
 
    
}

- (void)postCode:(NSNotification*)noti
{
    if (noti.userInfo!=nil) {
        [_bridge callHandler:@"onOtherAppCode" data:[noti.userInfo objectForKey:@"code"] responseCallback:^(id responseData) {
            
        }];

        if (_hasInit) {

            [_bridge callHandler:@"refreshData"];

        }
    }
}
#pragma mark 二维码/条形码
- (void)getQRCodeWithKey:(NSString*)key
{
    
    HCScanQRViewController *scan = [[HCScanQRViewController alloc]init];
    scan.showQRCodeInfo = YES;
    scan.type = [key intValue];
    //调用此方法来获取二维码信息
    [scan successfulGetQRCodeInfo:^(NSString *QRCodeInfo) {
        NSString *reslut = QRCodeInfo.length>0?@"true":@"false";
        NSDictionary *dataDic = @{@"code":QRCodeInfo,@"result":reslut};
        [_bridge callHandler:@"onQRCode" data:dataDic responseCallback:^(id responseData) {
            
        }];
    }];
    [self presentViewController:scan animated:YES completion:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _webView = nil;
    NSLog(@"失败");
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    URLCache *sharedCache = (URLCache *)[NSURLCache sharedURLCache];
//    [sharedCache saveInfo];
    _hasInit = YES;
    NSLog(@"结束");
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"开始");
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    NSLog(@"%@",url.absoluteString);
//    NSString *urlStr = url.absoluteString;
//    if ([urlStr hasPrefix:@"http"]) {
//        return NO;
//    }
    return YES;
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}
@end
