//
//  LCWebViewController.m
//  LCWebViewControllerDemo
//
//  Created by 刘超 on 15/7/29.
//  Copyright (c) 2015年 Leo. All rights reserved.
//

#import "LCWebViewController.h"

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
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setup];
    
    [self loadURLString:self.URLString];
}

- (void)setup {
    
    if (self.webTitle && ![self.webTitle isEqualToString:@""]) self.title = self.webTitle;
    
    
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    self.webView.frame    = self.view.bounds;
    [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.webView setMultipleTouchEnabled:YES];
    [self.webView setAutoresizesSubviews:YES];
    [self.webView setScalesPageToFit:YES];
    [self.webView.scrollView setAlwaysBounceVertical:YES];
    [self.view addSubview:self.webView];
    
    
    if (self.shouldHideProgressView) return;
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.progressTintColor = self.progressTintColor ?: [UIColor greenColor];
    self.progressView.trackTintColor = [UIColor clearColor];
    self.progressView.frame = CGRectMake(0, self.py, self.view.frame.size.width, self.progressView.frame.size.height);
    [self.progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [self.view addSubview:self.progressView];
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
        
        
    }
    
    return self;
}

#pragma mark - UIWebView 代理

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"1--%@", request.URL.absoluteString);
    
    if (![self isAppURL:request.URL]) {
        
        if (!self.shouldHideProgressView) {
            
            [self fakeProgressViewStartLoading];
        }
        
        return YES;
        
    } else {
        
        self.thirdAppURL = request.URL;
        
        
        [[[UIAlertView alloc] initWithTitle:@"跳转提示"
                                   message:@"这个网页试图跳转到另一个App，你确定要跳转吗？"
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
        
        [self fakeProgressBarStopLoading];
    }
    
    NSLog(@"2--%@", webView.request.URL.absoluteString);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if (!self.shouldHideProgressView) {
        
        [self fakeProgressBarStopLoading];
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

#pragma mark - Fake Progress Bar Control (UIWebView)

- (void)fakeProgressViewStartLoading {
    
//    [self.progressView setProgress:0.0f animated:NO];
    [self.progressView setAlpha:1.0f];
    
    if(!self.progressTimer) {
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(fakeProgressTimerDidFire:) userInfo:nil repeats:YES];
    }
}

- (void)fakeProgressBarStopLoading {
    
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

- (void)fakeProgressTimerDidFire:(id)sender {
    
    CGFloat increment = 0.005/(self.progressView.progress + 0.2);
    if([self.webView isLoading]) {
        CGFloat progress = (self.progressView.progress < 0.75f) ? self.progressView.progress + increment : self.progressView.progress + 0.0005;
        if(self.progressView.progress < 0.9) {
            [self.progressView setProgress:progress animated:YES];
        }
    }
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAllButUpsideDown;
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
