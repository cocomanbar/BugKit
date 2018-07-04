//
//  NSObject+Runtime.h
//  TMNetwork
//
//  Created by cocomanber on 2018/6/1.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  - 添加运行时分类方法
 *  - 用于运行时动态获取当前类的属性列表、方法列表、成员变量列表、协议列表
 *  - 性能优化
 */
@interface NSObject (Runtime)

/**
 *  将 ‘字典数组‘ 转换成当前模型的对象数组
 *
 *  @param array 字典数组
 *
 *  @return 返回模型对象的数组
 */
+ (NSArray *)objectsWithArray:(NSArray *)array;

/**
 *  返回当前类的所有属性列表
 *
 *  @return 属性名称
 */
+ (NSArray *)propertysList;

/**
 *  返回当前类的所有成员变量数组
 *
 *  @return 当前类的所有成员变量！
 *
 *  Tips：用于调试, 可以尝试查看所有不开源的类的ivar
 */
+ (NSArray *)ivarList;

/**
 *  返回当前类的所有方法
 *
 *  @return 当前类的所有成员变量！
 */
+ (NSArray *)methodList;

/**
 *  返回当前类的所有协议
 *
 *  @return 当前类的所有协议！
 */
+ (NSArray *)protocolList;

@end
