//
//  TMNetworkingHelper.h
//  TMNetworkingHelper
//
//  Created by cocomanber on 2017/8/29.
//  Copyright © 2017年 cocomanber. All rights reserved.
//  这样集中式的封装局限性很大,对于小型简单项目适用,中大型复杂项目建议用YTKNetwork
//  举个例子：api版本需要控制时，得传多一个版本控制参数，那这些请求接口的方法都得重新封装过加上一个verson参数
//  解决办法是：把这些版本控制参数或api公共参数随着版本跌增的部分参数放置于公共请求参数，TMNetworkConfig管理

#import <Foundation/Foundation.h>

/**
 *  成功回调
 *
 *  @param response 成功后返回的数据
 */
typedef void(^TMResponseSuccessBlock)(id response);

/**
 *  失败回调
 *
 *  @param error 失败后返回的错误信息
 */
typedef void(^TMResponseFailBlock)(NSError *error);

/**
 *  下载进度
 *
 *  @param bytesRead                 已下载的大小
 *  @param totalBytes                总下载大小
 */
typedef void (^TMDownloadProgress)(int64_t bytesRead, int64_t totalBytes);

/**
 *  下载成功回调
 *
 *  @param url                       下载存放的路径
 */
typedef void(^TMDownloadSuccessBlock)(NSURL *url);

/**
 *  上传进度
 *
 *  @param bytesWritten              已上传的大小
 *  @param totalBytes                总上传大小
 */
typedef void(^TMUploadProgressBlock)(int64_t bytesWritten, int64_t totalBytes);

/**
 *  多文件上传成功回调
 *
 *  @param responses 成功后返回的数据
 */
typedef void(^TMMultUploadSuccessBlock)(NSArray *responses);

/**
 *  多文件上传失败回调
 *
 *  @param errors 失败后返回的错误信息
 */
typedef void(^TMMultUploadFailBlock)(NSArray *errors);

/* 别名 */
typedef NSURLSessionTask TMURLSessionTask;
typedef TMDownloadProgress TMGetProgress;
typedef TMDownloadProgress TMPostProgress;
typedef TMResponseFailBlock TMDownloadFailBlock;

/* 可以针对接口单独判断错误码做提示 */
#define KEY_MESSAGE @"KEY_MESSAGE"
#define KEY_ERRORCODE @"KEY_ERRORCODE"
/* 可以运用整体app风格做错误码提示 */
#define KEY_CONTENT @"KEY_CONTENT"

@interface TMNetworkingHelper : NSObject

/**
 *  目前正在运行的网络任务
 *
 *  @return 返回Tasks
 */
+ (NSArray *)currentRunningTasks;

/**
 *  取消某一个请求
 */
+ (void)cancelRequestWithURL:(NSString *)url;

/**
 *  取消所有请求
 */
+ (void)cancleAllRequest;


#pragma mark - GET(都差一层error code识别过滤层)

/**
 *  GET请求-LV1
 *
 *  @param url              请求路径
 *  @param params           拼接参数
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (TMURLSessionTask *)getWithUrl:(NSString *)url
                          params:(NSDictionary *)params
                    successBlock:(TMResponseSuccessBlock)successBlock
                       failBlock:(TMResponseFailBlock)failBlock;

/**
 *  GET请求-LV2
 *
 *  @param url              请求路径
 *  @param cache            是否缓存，对同一个域名+baseurl做MD5后当key，不管是post或get都指向同一份缓存
 *  @param refresh          是否刷新请求(遇到重复请求，若为YES，则会取消旧的请求，用新的请求，若为NO，则忽略新请求，用旧请求)
 *  @param params           拼接参数
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (TMURLSessionTask *)getWithUrl:(NSString *)url
                  refreshRequest:(BOOL)refresh
                           cache:(BOOL)cache
                          params:(NSDictionary *)params
                    successBlock:(TMResponseSuccessBlock)successBlock
                       failBlock:(TMResponseFailBlock)failBlock;

/**
 *  GET请求-LV3
 *
 *  @param url              请求路径
 *  @param cache            是否缓存，对同一个域名+baseurl做MD5后当key，不管是post或get都指向同一份缓存
 *  @param refresh          是否刷新请求(遇到重复请求，若为YES，则会取消旧的请求，用新的请求，若为NO，则忽略新请求，用旧请求)
 *  @param params           拼接参数
 *  @param progressBlock    进度回调
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (TMURLSessionTask *)getWithUrl:(NSString *)url
                  refreshRequest:(BOOL)refresh
                           cache:(BOOL)cache
                          params:(NSDictionary *)params
                   progressBlock:(TMGetProgress)progressBlock
                    successBlock:(TMResponseSuccessBlock)successBlock
                       failBlock:(TMResponseFailBlock)failBlock;

#pragma mark - POST

/**
 *  POST请求-LV1
 *
 *  @param url              请求路径
 *  @param params           拼接参数
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (TMURLSessionTask *)postWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                     successBlock:(TMResponseSuccessBlock)successBlock
                        failBlock:(TMResponseFailBlock)failBlock;

/**
 *  POST请求-LV2
 *
 *  @param url              请求路径
 *  @param cache            是否缓存，对同一个域名+baseurl做MD5后当key，不管是post或get都指向同一份缓存
 *  @param refresh          是否刷新请求(遇到重复请求，若为YES，则会取消旧的请求，用新的请求，若为NO，则忽略新请求，用旧请求)
 *  @param params           拼接参数
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (TMURLSessionTask *)postWithUrl:(NSString *)url
                   refreshRequest:(BOOL)refresh
                            cache:(BOOL)cache
                           params:(NSDictionary *)params
                     successBlock:(TMResponseSuccessBlock)successBlock
                        failBlock:(TMResponseFailBlock)failBlock;

/**
 *  POST请求-LV3
 *
 *  @param url              请求路径
 *  @param cache            是否缓存，对同一个域名+baseurl做MD5后当key，不管是post或get都指向同一份缓存
 *  @param refresh          是否刷新请求(遇到重复请求，若为YES，则会取消旧的请求，用新的请求，若为NO，则忽略新请求，用旧请求)
 *  @param params           拼接参数
 *  @param progressBlock    进度回调
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (TMURLSessionTask *)postWithUrl:(NSString *)url
                   refreshRequest:(BOOL)refresh
                            cache:(BOOL)cache
                           params:(NSDictionary *)params
                    progressBlock:(TMPostProgress)progressBlock
                     successBlock:(TMResponseSuccessBlock)successBlock
                        failBlock:(TMResponseFailBlock)failBlock;

#pragma mark - 单文件上传

/**
 *  文件上传-单文件
 *
 *  @param url              上传文件接口地址
 *  @param data             上传文件数据
 *  @param type             上传文件类型
 *  @param name             上传文件服务器文件夹名
 *  @param mimeType         mimeType
 *  @param progressBlock    上传文件路径
 *	@param successBlock     成功回调
 *	@param failBlock		失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (TMURLSessionTask *)uploadFileWithUrl:(NSString *)url
                               fileData:(NSData *)data
                                   type:(NSString *)type
                                   name:(NSString *)name
                               mimeType:(NSString *)mimeType
                          progressBlock:(TMUploadProgressBlock)progressBlock
                           successBlock:(TMResponseSuccessBlock)successBlock
                              failBlock:(TMResponseFailBlock)failBlock;

#pragma mark - 多文件上传

/**
 *  文件上传-多文件
 *
 *  @param url           上传文件地址
 *  @param datas         数据集合
 *  @param type          类型
 *  @param name          服务器文件夹名
 *  @param mimeTypes     mimeTypes
 *  @param progressBlock 上传进度
 *  @param successBlock  成功回调
 *  @param failBlock     失败回调
 *
 *  @return 任务集合
 */
+ (NSArray *)uploadMultFileWithUrl:(NSString *)url
                         fileDatas:(NSArray *)datas
                              type:(NSString *)type
                              name:(NSString *)name
                          mimeType:(NSString *)mimeTypes
                     progressBlock:(TMUploadProgressBlock)progressBlock
                      successBlock:(TMMultUploadSuccessBlock)successBlock
                         failBlock:(TMMultUploadFailBlock)failBlock;

#pragma mark - 文件下载

/**
 *  文件下载 - 单次下载不支持断点续传
 *
 *  @param url           下载文件接口地址
 *  @param progressBlock 下载进度
 *  @param successBlock  成功回调
 *  @param failBlock     下载回调
 *
 *  @return 返回的对象可取消请求
 */
+ (TMURLSessionTask *)downloadWithUrl:(NSString *)url
                        progressBlock:(TMDownloadProgress)progressBlock
                         successBlock:(TMDownloadSuccessBlock)successBlock
                            failBlock:(TMDownloadFailBlock)failBlock;

@end

@interface TMNetworkingHelper (cache)

/**
 *  获取缓存目录路径
 *
 *  @return 缓存目录路径
 */
+ (NSString *)getCacheDiretoryPath;

/**
 *  获取下载目录路径
 *
 *  @return 下载目录路径
 */
+ (NSString *)getDownDirectoryPath;

/**
 *  获取缓存大小
 *
 *  @return 缓存大小
 */
+ (NSUInteger)totalCacheSize;

/**
 *  清除所有缓存
 */
+ (void)clearTotalCache;

/**
 *  获取所有下载数据大小
 *
 *  @return 下载数据大小
 */
+ (NSUInteger)totalDownloadDataSize;

/**
 *  清除下载数据
 */
+ (void)clearDownloadData;

@end









