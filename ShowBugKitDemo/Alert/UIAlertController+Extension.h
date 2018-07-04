//
//  UIAlertController+Extension.h
//  TMNetwork
//
//  Created by cocomanber on 2018/6/1.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TM_ALERT_NOTICE @"提示"
#define TM_ALERT_CANCEL @"取消"
#define TM_ALERT_SURE   @"确定"

#if TARGET_OS_IOS
typedef void (^UIAlertControllerPopoverPresentationControllerBlock) (UIPopoverPresentationController * __nonnull popover);
#endif

/**
 按钮点击事件 block
 
 @param alertController alertController
 @param action UIAlertAction
 @param buttonIndex buttonIndex
 */
typedef void (^AlertControllerButtonActionBlock) (UIAlertController * __nonnull alertController, UIAlertAction * __nonnull action, NSInteger buttonIndex);

/**
 textField 配置信息 block
 
 @param textField textField
 @param index index
 */
typedef void (^AlertControllerTextFieldConfigurationActionBlock)(UITextField * _Nullable textField, NSInteger index);

@interface UIAlertController (Extension)

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
                                               block:(nullable AlertControllerButtonActionBlock)block;

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
                                                block:(nullable AlertControllerButtonActionBlock)block;

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
                                                         block:(nullable AlertControllerButtonActionBlock)block;


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
                                                     block:(nullable AlertControllerButtonActionBlock)block;

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
                                                               block:(nullable AlertControllerButtonActionBlock)block;

@end
