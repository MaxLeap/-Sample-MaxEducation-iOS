//
//  AppDelegate.m
//  MaxEducation
//
//  Created by luomeng on 16/6/6.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "AppDelegate.h"
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <MLHelpCenter/MLHelpCenter.h>

@import MLWeiboUtils;
@import MLWeChatUtils;
@import MLQQUtils;

#define MAXLEAP_APPID           @"5754d895169e7d0001c91852"
#define MAXLEAP_CLIENTKEY       @"UTdFLWg1UjV5WDFMbjhxNGhmRS10QQ"

// 注意要在info.plist中的URL Types中设置
#define WECHAT_APPID            @"wx41b6f4bde79513c8"
#define WECHAT_SECRET           @"d4624c36b6795d1d99dcf0547af5443d"
#define WEIBO_APPKEY            @"2328234403"
#define WEIBO_REDIRECTURL       @"https://api.weibo.com/oauth2/default.html"
#define QQ_APPID                @"222222"

@interface AppDelegate () <WXApiDelegate,
TencentSessionDelegate,
WeiboSDKDelegate
>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //配置 MaxLeap app信息
    [MaxLeap setApplicationId:MAXLEAP_APPID clientKey:MAXLEAP_CLIENTKEY site:MLSiteCN];
    [MLHelpCenter install];
    
    // 集成Wechat & Weibo & QQ
    [MLWeChatUtils initializeWeChatWithAppId:WECHAT_APPID appSecret:WECHAT_SECRET wxDelegate:self];
    [MLWeiboUtils initializeWeiboWithAppKey:WEIBO_APPKEY redirectURI:WEIBO_REDIRECTURL];
    [MLQQUtils initializeQQWithAppId:QQ_APPID qqDelegate:self];
    
    [self setAppearance];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - UI
- (void)setAppearance {
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    [navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(51, 178, 151, 1)] forBarMetrics:UIBarMetricsDefault];
    UIImage *backImg = [ImageNamed(@"icn_back_gerenzhongxin") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [navigationBar setBackIndicatorImage:backImg];
    [navigationBar setBackIndicatorTransitionMaskImage:backImg];
    [navigationBar setShadowImage:[UIImage imageWithColor:[UIColor clearColor]]];
    [navigationBar setTitleTextAttributes:@{
             NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    UIBarButtonItem *naviItem = [UIBarButtonItem appearance];
    [naviItem setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -64) forBarMetrics:UIBarMetricsDefault];
    [naviItem setTintColor:[UIColor whiteColor]];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

#pragma mark WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        [MLWeChatUtils handleAuthorizeResponse:(SendAuthResp *)resp];
    } else {
        // 处理其他请求的响应
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    if ([url.absoluteString hasPrefix:@"tencent"]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    if ([url.absoluteString hasPrefix:@"wb"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    if ([url.absoluteString hasPrefix:@"wx"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([url.absoluteString hasPrefix:@"tencent"]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    if ([url.absoluteString hasPrefix:@"wb"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    if ([url.absoluteString hasPrefix:@"wx"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    if ([url.absoluteString hasPrefix:@"tencent"]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    if ([url.absoluteString hasPrefix:@"wb"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    if ([url.absoluteString hasPrefix:@"wx"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    return YES;
}

#pragma mark TencentLoginDelegate TencentSessionDelegate

// 以下三个方法保持空实现就可以，MLQQUtils 会置换这三个方法，但是会调用这里的实现

- (void)tencentDidLogin {
    
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    
}

- (void)tencentDidNotNetWork {
    
}

#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    NSLog(@"didReceiveWeiboRequest %@", request);
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        [MLWeiboUtils handleAuthorizeResponse:(WBAuthorizeResponse *)response];
    }
}


@end
