//
//  ViewController.m
//  LCWebViewControllerDemo
//
//  Created by 刘超 on 15/7/29.
//  Copyright (c) 2015年 Leo. All rights reserved.
//

#import "ViewController.h"
#import "LCWebViewController.h"

/**
 *  测试网址
 */
static NSString * TestURLString = @"http://weibo.cn/CoderLeo";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}

#pragma mark UITableView 代理

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        // Push a LCWebViewController
        LCWebViewController *webVC = [[LCWebViewController alloc] init];
        webVC.webTitle = @"这是缺省标题";
        webVC.URLString = TestURLString;
        webVC.progressTintColor = [UIColor redColor];
        [self.navigationController pushViewController:webVC animated:YES];
        
    } else if (indexPath.section == 1) {
        
        // Modal a LCWebViewController
        LCWebViewController *webVC = [LCWebViewController webViewControllerWithTitle:nil URLString:TestURLString];
        [self presentViewController:webVC
                           animated:YES
                         completion:nil];
    }
}

@end
