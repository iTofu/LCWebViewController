//
//  LCWebViewController.h
//  LCWebViewControllerDemo
//
//  Created by 刘超 on 15/7/29.
//  Copyright (c) 2015年 Leo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCWebViewController : UIViewController

#pragma mark - 属性

/**
 *  默认标题
 */
@property (nonatomic, copy) NSString *webTitle;

/**
 *  是否取消自动更换标题(换成网站标题)
 */
@property (nonatomic, assign, getter=shouldNoAutoTitle) BOOL noAutoTitle;

/**
 *  网址(字符串)
 */
@property (nonatomic, copy) NSString *URLString;

/**
 *  网址(URL)
 */
@property (nonatomic, strong) NSURL *URL;

/**
 *  超时时间
 */
@property (nonatomic, assign) int timeout;

/**
 *  是否隐藏进度条
 */
@property (nonatomic, assign, getter=shouldHideProgressView) BOOL hideProgressView;

/**
 *  进度条主题色
 */
@property (nonatomic, strong) UIColor *progressTintColor;

/**
 *  是否隐藏工具条
 */
@property (nonatomic, assign, getter=shouldHideToolBar) BOOL hideToolBar;

/**
 *  工具条主题色
 */
@property (nonatomic, strong) UIColor *toolBarTintColor;

/**
 *  工具条高度
 */
@property (nonatomic, assign) CGFloat toolBarHeight;

/**
 *  自定义工具条(若设置该属性, showToolBar属性将失效)
 */
@property (nonatomic, weak) UIView *customToolBar;

#pragma mark - 方法

/**
 *  实例化一个LCWebViewController的对象(类方法)
 *
 *  @param title     默认标题
 *  @param URLString 链接
 *
 *  @return 实例化的LCWebViewController的对象
 */
+ (instancetype)webViewControllerWithTitle:(NSString *)title
                                 URLString:(NSString *)URLString;

/**
 *  实例化一个LCWebViewController的对象(实例方法)
 *
 *  @param title     默认标题
 *  @param URLString 链接
 *
 *  @return 实例化的LCWebViewController的对象
 */
- (instancetype)initWithTitle:(NSString *)title
                    URLString:(NSString *)URLString;

@end
