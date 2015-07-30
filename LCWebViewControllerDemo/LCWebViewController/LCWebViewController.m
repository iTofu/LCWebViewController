//
//  LCWebViewController.m
//  LCWebViewControllerDemo
//
//  Created by 刘超 on 15/7/29.
//  Copyright (c) 2015年 Leo. All rights reserved.
//

#import "LCWebViewController.h"
//#import "IonIcons.h"

#define VIEW_WIDTH self.view.bounds.size.width

@interface LCWebViewController () <UIWebViewDelegate, UIAlertViewDelegate>

/**
 *  浏览器
 */
@property (nonatomic, strong) UIWebView *webView;

/**
 *  进度条
 */
@property (nonatomic, strong) UIProgressView *progressView;

/**
 *  工具条
 */
@property (nonatomic, strong) UIToolbar *toolBar;

/**
 *  是否正在加载
 */
@property (nonatomic, assign, getter=isLoading) BOOL *loading;

@property (nonatomic, assign) CGFloat py;

/**
 *  加载条的定时器
 */
@property (nonatomic, strong) NSTimer *progressTimer;

@property (nonatomic, strong) NSURL *thirdAppURL;

@end

@implementation LCWebViewController

- (CGFloat)py {
    
    return self.navigationController.navigationBar ? 64.0f : 0;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (self.progressTimer) {
        
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
    
    [self.progressView removeFromSuperview];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setup];
    
    [self loadURLString:self.URLString];
}

- (void)setup {
    
    // 设置标题
    if (self.webTitle && ![self.webTitle isEqualToString:@""]) self.title = self.webTitle;
    
    
    // 设置webView
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    self.webView.frame    = self.view.bounds;
    [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.webView setMultipleTouchEnabled:YES];
    [self.webView setAutoresizesSubviews:YES];
    [self.webView setScalesPageToFit:YES];
    [self.webView.scrollView setAlwaysBounceVertical:YES];
    [self.view addSubview:self.webView];
    
    
    // 设置进度条
    if (!self.shouldHideProgressView) {
        
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView.progressTintColor = self.progressTintColor ?: [UIColor greenColor];
        self.progressView.trackTintColor = [UIColor clearColor];
        self.progressView.frame = CGRectMake(0, self.py, self.view.frame.size.width, self.progressView.frame.size.height);
        [self.progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
        [self.view addSubview:self.progressView];
    }
    
    
//    if (!self.shouldHideToolBar) {
//        
//        self.toolBar = [[UIToolbar alloc] init];
//        self.toolBar.items = @[];
////        self.toolBar.frame = CGRectMake(0, self, <#CGFloat width#>, <#CGFloat height#>);
//    }
}

- (void)loadURLString:(NSString *)URLString {
    
    NSURLRequest *request = nil;
    if (self.timeout != 0) {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]
                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                               timeoutInterval:self.timeout];
    } else {
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    }
    [self.webView loadRequest:request];
}

+ (instancetype)webViewControllerWithTitle:(NSString *)title URLString:(NSString *)URLString {
    
    return [[self alloc] initWithTitle:title URLString:URLString];
}

- (instancetype)initWithTitle:(NSString *)title URLString:(NSString *)URLString {
    
    if (self = [super init]) {
        
        self.webTitle  = title;
        self.URLString = URLString;
    }
    
    return self;
}

#pragma mark - UIWebView 代理

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (![self isAppURL:request.URL]) {
        
        if (!self.shouldHideProgressView) {
            
            [self progressViewStartLoading];
        }
        
        return YES;
        
    } else {
        
        self.thirdAppURL = request.URL;
        
//        NSLog(@"1--%@", request.URL.absoluteString);
        
        [[[UIAlertView alloc] initWithTitle:@"跳转提示"
                                   message:@"检测到网页可能试图跳转到另一个App，你确定要执行跳转吗？"
                                  delegate:self
                         cancelButtonTitle:@"取消"
                         otherButtonTitles:@"跳转", nil] show];
        
        return NO;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (!self.shouldNoAutoTitle) self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if(!self.webView.isLoading && !self.shouldHideProgressView) {
        
        [self progressBarStopLoading];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if (!self.shouldHideProgressView) {
        
        [self progressBarStopLoading];
    }
}

/**
 *  是否时启动另一个App的链接
 *
 *  @param URL 链接
 *
 *  @return 是否是
 */
- (BOOL)isAppURL:(NSURL *)URL {
    
    NSSet *validSchemes = [NSSet setWithArray:@[@"http", @"https", @"about"]];
    
    return ![validSchemes containsObject:URL.scheme];
}

#pragma mark - 处理进度条

- (void)progressViewStartLoading {
    
//    [self.progressView setProgress:0.0f animated:NO];
    [self.progressView setAlpha:1.0f];
    
    if(!self.progressTimer) {
        
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1 / 60.0f
                                                              target:self
                                                            selector:@selector(progressTimerDidFire:)
                                                            userInfo:nil
                                                             repeats:YES];
    }
}

- (void)progressBarStopLoading {
    
    if(self.progressTimer) {
        
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
    
    if(self.progressView) {
        
        [self.progressView setProgress:1.0f animated:YES];
        
        [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            [self.progressView setAlpha:0.0f];
            
        } completion:^(BOOL finished) {
            
            [self.progressView setProgress:0.0f animated:NO];
        }];
    }
}

- (void)progressTimerDidFire:(id)sender {
    
    CGFloat increment = 0.005 / (self.progressView.progress + 0.2f);
    
    if([self.webView isLoading]) {
        
        CGFloat progress = (self.progressView.progress < 0.75f) ? self.progressView.progress + increment : self.progressView.progress + 0.0005;
        
        if(self.progressView.progress < 0.9) {
            
            [self.progressView setProgress:progress animated:YES];
        }
    }
}

#pragma mark - Interface Orientation

- (BOOL)shouldAutorotate {
    
    return YES;
}

#pragma mark - UIAlertView 代理方法

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != alertView.cancelButtonIndex) {
        
        [[UIApplication sharedApplication] openURL:self.thirdAppURL];
    }
}

@end
