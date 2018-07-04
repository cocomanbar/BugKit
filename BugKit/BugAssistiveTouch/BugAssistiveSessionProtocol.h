//
//  BugAssistiveSessionProtocol.h
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/24.
//  Copyright © 2018年 cocomanber. All rights reserved.
//  扩展其他功能
//  统计APP内的网络请求失败率
//  APP某个API进行一些访问的统计
//  https://github.com/yangqian111/PPSNetworkMonitor

#import <Foundation/Foundation.h>

@interface BugAssistiveSessionProtocol : NSURLProtocol

@end
/*
 NSURLProtocol也是苹果众多黑魔法中的一种，使用它可以轻松地重定义整个URL Loading System。当你注册自定义NSURLProtocol后，就有机会对所有的请求进行统一的处理，基于这一点它可以让你
 
 ·自定义请求和响应
 
 ·提供自定义的全局缓存支持
 
 ·重定向网络请求
 
 ·提供HTTP Mocking (方便前期测试)
 
 ·其他一些全局的网络请求修改需求
 */

/*
 NSURLProtocol是iOS网络加载系统中很强的一部分，它其实是一个抽象类，我们可以通过继承子类化来拦截APP中的网络请求。
 
 举几个例子：
 
 我们的APP内的所有请求都需要增加公共的头，像这种我们就可以直接通过NSURLProtocol来实现，当然实现的方式有很多种
 再比如我们需要将APP某个API进行一些访问的统计
 再比如我们需要统计APP内的网络请求失败率
 等等，都可以用到
 
 NSURLProtocol是一个抽象类，我们需要子类化才能实现网络请求拦截。
 */

