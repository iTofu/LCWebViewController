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
static NSString * TestURLString = @"http://www.sina.com";

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
        webVC.URLString = TestURLString;
        webVC.hideProgressView = NO;
        [self.navigationController pushViewController:webVC animated:YES];
        
    } else if (indexPath.section == 1) {
        
        // Modal a LCWebViewController
        LCWebViewController *webVC = [[LCWebViewController alloc] init];
        webVC.URLString = TestURLString;
        [self presentViewController:webVC
                           animated:YES
                         completion:nil];
    }
}

@end
