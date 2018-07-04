//
//  UIAlertController+Extension.m
//  TMNetwork
//
//  Created by cocomanber on 2018/6/1.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "UIAlertController+Extension.h"
#import <Foundation/Foundation.h>
#import "NSObject+Runtime.h"

@interface UIViewController (Extension)

- (UIViewController *)currentViewController;

@end

@implementation UIAlertController (Extension)

/**
 快速创建一个系统 普通 UIAlertController-Alert
 
 @param viewController 显示的VC
 @param title title
 @param message message
 @param buttonTitleArray 按钮数组
 @param buttonTitleColorArray 按钮颜色数组，默认：系统蓝色，如果颜色数组个数小于title数组个数，则全部为默认蓝色
 @param block block
 @return UIAlertController-Alert
 */
+ (nonnull instancetype)alertShowInViewController:(nonnull UIViewController *)viewController
                                               title:(nullable NSString *)title
                                             message:(nullable NSString *)message
                                    buttonTitleArray:(nullable NSArray *)buttonTitleArray
                               buttonTitleColorArray:(nullable NSArray <UIColor *>*)buttonTitleColorArray
                                               block:(nullable AlertControllerButtonActionBlock)block
{
    return [self alertControllerShowInViewController:viewController
                                                  title:title
                                        attributedTitle:nil
                                                message:message
                                      attributedMessage:nil
                                         preferredStyle:UIAlertControllerStyleAlert
                                       buttonTitleArray:buttonTitleArray
                                  buttonTitleColorArray:buttonTitleColorArray
                          buttonEnabledNoWithTitleArray:nil
                              textFieldPlaceholderArray:nil
                      textFieldConfigurationActionBlock:nil
#if TARGET_OS_IOS
                     popoverPresentationControllerBlock:nil
#endif
                                                  block:block];
}

/**
 快速创建一个系统 普通 带 textField 的 UIAlertController-Alert
 
 @param viewController 显示的VC
 @param title title
 @param message message
 @param buttonTitleArray 按钮数组
 @param buttonTitleColorArray 按钮颜色数组，默认：系统蓝色，如果颜色数组个数小于title数组个数，则全部为默认蓝色
 @param buttonEnabledNoWithTitleArray 初始化的时候按钮为 EnabledNo 状态 的 title 数组
 @param textFieldPlaceholderArray textFieldPlaceholderArray 需要添加的 textField placeholder 数组
 @param textFieldConfigurationActionBlock textField 配置信息 block
 @param block block
 @return 普通 带 textField 的 UIAlertController-Alert
 */
+ (nonnull instancetype)alert2ShowInViewController:(nonnull UIViewController *)viewController
                                                title:(nullable NSString *)title
                                              message:(nullable NSString *)message
                                     buttonTitleArray:(nullable NSArray *)buttonTitleArray
                                buttonTitleColorArray:(nullable NSArray <UIColor *> *)buttonTitleColorArray
                        buttonEnabledNoWithTitleArray:(NSArray <NSString *> *_Nullable)buttonEnabledNoWithTitleArray
                            textFieldPlaceholderArray:(NSArray <NSString *> *_Nullable)textFieldPlaceholderArray
                    textFieldConfigurationActionBlock:(nullable AlertControllerTextFieldConfigurationActionBlock)textFieldConfigurationActionBlock
                                                block:(nullable AlertControllerButtonActionBlock)block
{
    return [self alertControllerShowInViewController:viewController
                                                  title:title
                                        attributedTitle:nil
                                                message:message
                                      attributedMessage:nil
                                         preferredStyle:UIAlertControllerStyleAlert
                                       buttonTitleArray:buttonTitleArray
                                  buttonTitleColorArray:buttonTitleColorArray
                          buttonEnabledNoWithTitleArray:buttonEnabledNoWithTitleArray
                              textFieldPlaceholderArray:textFieldPlaceholderArray
                      textFieldConfigurationActionBlock:textFieldConfigurationActionBlock
#if TARGET_OS_IOS
                     popoverPresentationControllerBlock:nil
#endif
                                                  block:block];
}

/**
 快速创建一个系统 attributedTitle UIAlertController-Alert
 
 @param viewController 显示的VC
 @param attributedTitle attributedTitle
 @param attributedMessage attributedMessage
 @param buttonTitleArray 按钮数组
 @param buttonTitleColorArray 按钮颜色数组，默认：系统蓝色，如果颜色数组个数小于title数组个数，则全部为默认蓝色
 @param block block
 @return UIAlertController-Alert
 */
+ (nonnull instancetype)alertAttributedShowInViewController:(nonnull UIViewController *)viewController
                                               attributedTitle:(nullable NSMutableAttributedString *)attributedTitle
                                             attributedMessage:(nullable NSMutableAttributedString *)attributedMessage
                                              buttonTitleArray:(nullable NSArray *)buttonTitleArray
                                         buttonTitleColorArray:(nullable NSArray <UIColor *>*)buttonTitleColorArray
                                                         block:(nullable AlertControllerButtonActionBlock)block
{
    return [self alertControllerShowInViewController:viewController
                                                  title:nil
                                        attributedTitle:attributedTitle
                                                message:nil
                                      attributedMessage:attributedMessage
                                         preferredStyle:UIAlertControllerStyleAlert
                                       buttonTitleArray:buttonTitleArray
                                  buttonTitleColorArray:buttonTitleColorArray
                          buttonEnabledNoWithTitleArray:nil
                              textFieldPlaceholderArray:nil
                      textFieldConfigurationActionBlock:nil
#if TARGET_OS_IOS
                     popoverPresentationControllerBlock:nil
#endif
                                                  block:block];
}


/**
 快速创建一个系统 普通 UIAlertController-ActionSheet
 
 @param viewController 显示的VC
 @param title title
 @param message message
 @param buttonTitleArray 按钮数组
 @param buttonTitleColorArray 按钮颜色数组，默认：系统蓝色，如果颜色数组个数小于title数组个数，则全部为默认蓝色
 @param popoverPresentationControllerBlock popoverPresentationControllerBlock description
 @param block block
 @return UIAlertController-ActionSheet
 */
+ (nonnull instancetype)actionSheetShowInViewController:(nonnull UIViewController *)viewController
                                                     title:(nullable NSString *)title
                                                   message:(nullable NSString *)message
                                          buttonTitleArray:(nullable NSArray *)buttonTitleArray
                                     buttonTitleColorArray:(nullable NSArray <UIColor *>*)buttonTitleColorArray
#if TARGET_OS_IOS
                        popoverPresentationControllerBlock:(nullable UIAlertControllerPopoverPresentationControllerBlock)popoverPresentationControllerBlock
#endif
                                                     block:(nullable AlertControllerButtonActionBlock)block
{
    return [self alertControllerShowInViewController:viewController
                                                  title:title
                                        attributedTitle:nil
                                                message:message
                                      attributedMessage:nil
                                         preferredStyle:UIAlertControllerStyleActionSheet
                                       buttonTitleArray:buttonTitleArray
                                  buttonTitleColorArray:buttonTitleColorArray
                          buttonEnabledNoWithTitleArray:nil
                              textFieldPlaceholderArray:nil
                      textFieldConfigurationActionBlock:nil
#if TARGET_OS_IOS
                     popoverPresentationControllerBlock:popoverPresentationControllerBlock
#endif
                                                  block:block];
}

/**
 快速创建一个系统 attributedTitle UIAlertController-ActionSheet
 
 @param viewController 显示的VC
 @param attributedTitle attributedTitle
 @param attributedMessage attributedMessage
 @param buttonTitleArray 按钮数组
 @param buttonTitleColorArray 按钮颜色数组，默认：系统蓝色，如果颜色数组个数小于title数组个数，则全部为默认蓝色
 @param popoverPresentationControllerBlock popoverPresentationControllerBlock description
 @param block block
 @return UIAlertController-ActionSheet
 */
+ (nonnull instancetype)actionSheetAttributedShowInViewController:(nonnull UIViewController *)viewController
                                                     attributedTitle:(nullable NSMutableAttributedString *)attributedTitle
                                                   attributedMessage:(nullable NSMutableAttributedString *)attributedMessage
                                                    buttonTitleArray:(nullable NSArray *)buttonTitleArray
                                               buttonTitleColorArray:(nullable NSArray <UIColor *>*)buttonTitleColorArray
#if TARGET_OS_IOS
                                  popoverPresentationControllerBlock:(nullable UIAlertControllerPopoverPresentationControllerBlock)popoverPresentationControllerBlock
#endif
                                                               block:(nullable AlertControllerButtonActionBlock)block
{
    return [self alertControllerShowInViewController:viewController
                                                  title:nil
                                        attributedTitle:attributedTitle
                                                message:nil
                                      attributedMessage:attributedMessage
                                         preferredStyle:UIAlertControllerStyleActionSheet
                                       buttonTitleArray:buttonTitleArray
                                  buttonTitleColorArray:buttonTitleColorArray
                          buttonEnabledNoWithTitleArray:nil
                              textFieldPlaceholderArray:nil
                      textFieldConfigurationActionBlock:nil
#if TARGET_OS_IOS
                     popoverPresentationControllerBlock:popoverPresentationControllerBlock
#endif
                                                  block:block];
}


+ (instancetype)alertControllerShowInViewController:(UIViewController *)viewController
                                                 title:(NSString *)title
                                       attributedTitle:(nullable NSMutableAttributedString *)attributedTitle
                                               message:(NSString *)message
                                     attributedMessage:(nullable NSMutableAttributedString *)attributedMessage
                                        preferredStyle:(UIAlertControllerStyle)preferredStyle
                                      buttonTitleArray:(nullable NSArray *)buttonTitleArray
                                 buttonTitleColorArray:(nullable NSArray <UIColor *>*)buttonTitleColorArray
                         buttonEnabledNoWithTitleArray:(NSArray <NSString *> *_Nullable)buttonEnabledNoWithTitleArray
                             textFieldPlaceholderArray:(NSArray <NSString *> *_Nullable)textFieldPlaceholderArray
                     textFieldConfigurationActionBlock:(nullable AlertControllerTextFieldConfigurationActionBlock)textFieldConfigurationActionBlock
#if TARGET_OS_IOS
                    popoverPresentationControllerBlock:(void(^)(UIPopoverPresentationController *popover))popoverPresentationControllerBlock
#endif
                                                 block:(AlertControllerButtonActionBlock)block
{
    UIAlertController *strongController = [self alertControllerWithTitle:title
                                                                 message:message
                                                          preferredStyle:preferredStyle];
    
    __weak UIAlertController *alertController = strongController;
    
    if (buttonTitleArray)
    {
        for (NSUInteger i = 0; i < buttonTitleArray.count; i++)
        {
            NSString *buttonTitle = buttonTitleArray[i];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:buttonTitle
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action){
                                                               if (block)
                                                               {
                                                                   block(alertController, action, i);
                                                               }
                                                           }];
            [alertController addAction:action];
            
            for (NSInteger j = 0; j < buttonEnabledNoWithTitleArray.count; j ++)
            {
                if ([buttonEnabledNoWithTitleArray[j] isEqualToString:buttonTitle])
                {
                    action.enabled = NO;
                }
            }
            
            if (!buttonTitleColorArray || buttonTitleColorArray.count == 0 ||
                buttonTitleColorArray.count < buttonTitleArray.count)
            {
                NSMutableArray *mutArr = [NSMutableArray array];
                for (NSInteger i = 0; i < buttonTitleArray.count; i ++)
                {
                    [mutArr addObject:[UIColor blueColor]];
                }
                buttonTitleColorArray = [mutArr mutableCopy];
            }
            if (buttonTitleColorArray)
            {
                [strongController setAlertWithAlert:strongController
                             mutableAttributedTitle:attributedTitle
                           mutableAttributedMessage:attributedMessage
                                             Action:action
                                   buttonTitleColor:buttonTitleColorArray[i]];
            }
        }
    }
    if (textFieldPlaceholderArray)
    {
        for (NSInteger i = 0; i < textFieldPlaceholderArray.count; i++)
        {
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                
                textField.placeholder = textFieldPlaceholderArray[i];
                if (textFieldConfigurationActionBlock)
                {
                    textFieldConfigurationActionBlock(textField, i);
                }
            }];
        }
    }
    
    if (preferredStyle == UIAlertControllerStyleActionSheet)
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取 消"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
        [alertController addAction:action];
    }
    
#if TARGET_OS_IOS
    if (popoverPresentationControllerBlock)
    {
        popoverPresentationControllerBlock(alertController.popoverPresentationController);
    }
#endif
    
    [viewController.currentViewController presentViewController:alertController animated:YES completion:nil];
    
    return alertController;
}

#pragma mark - setter / getter

- (void)setAlertWithAlert:(UIAlertController * __nonnull )alert
   mutableAttributedTitle:(NSMutableAttributedString *)mutableAttributedTitle
 mutableAttributedMessage:(nullable NSMutableAttributedString *)mutableAttributedMessage
                   Action:(UIAlertAction * __nonnull )action
         buttonTitleColor:(UIColor *)buttonTitleColor
{
    /*! 1、首先获得对应的属性 */
    //    NSArray *propertysListArray = [[UIAlertController class] propertysList];
    //    NSLog(@"1、获取【UIAlertController】所有的属性名：%@", propertysListArray);
    
    /*! 2、获得成员变量 */
    NSArray *ivarListArray = [[UIAlertAction class] ivarList];
    //    NSLog(@"2、获取【UIAlertController】所有的成员变量：%@", ivarListArray);
    
    for (NSInteger i = 0; i < ivarListArray.count; i++)
    {
        NSString *ivarName = ivarListArray[i];
        if ([ivarName isEqualToString:@"_titleTextColor"])
        {
            [action setValue:buttonTitleColor forKey:@"titleTextColor"];
        }
    }
    
    /*! 3、改变显示提示字体颜色 */
    NSArray *propertysListArray2 = [[UIAlertController class] ivarList];
    //    NSLog(@"3、获取【UIAlertController】所有的成员变量：%@", propertysListArray2);
    for (NSInteger i = 0; i < propertysListArray2.count; i++)
    {
        NSString *ivarName = propertysListArray2[i];
        if ([ivarName isEqualToString:@"_attributedTitle"])
        {
            [alert setValue:mutableAttributedTitle forKey:@"attributedTitle"];
        }
        if ([ivarName isEqualToString:@"_attributedMessage"])
        {
            [alert setValue:mutableAttributedMessage forKey:@"attributedMessage"];
        }
    }
}

@end

@implementation UIViewController (Extension)

- (UIViewController *)currentViewController
{
    UIViewController *topVC = self;
    UIViewController *above;
    while ((above = topVC.presentedViewController)) {
        topVC = above;
    }
    return topVC;
}

@end
