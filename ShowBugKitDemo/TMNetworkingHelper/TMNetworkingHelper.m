//
//  TMNetworkingHelper.m
//  TMNetworkingHelper
//
//  Created by cocomanber on 2017/8/29.
//  Copyright © 2017年 cocomanber. All rights reserved.
//

#import "TMNetworkingHelper.h"
#import "AFNetworking.h"
#import "TMNetworkingHelper+requsetManager.h"
#import "TMCacheManager.h"
#import "TMCheckNetworkStatus.h"
#import "TMNetworkConfig.h"
#import "TMNetworkLogger.h"
#import "TMNetworkAnalyse.h"

/* 网络错误 */
#define TM_ERROR_NET_MESSGAE @"网络故障，请检查网络连接"
#define TM_ERROR_NET_ERRORCODE @"999"
#define TM_ERROR_NET_CONTENT [NSString stringWithFormat:@"%@，错误码是：%@",TM_ERROR_NET_MESSGAE,TM_ERROR_NET_ERRORCODE]
#define TM_ERROR [NSError errorWithDomain:@"com.caixindong.TMNetworking.ErrorDomain" code:10086 userInfo:@{KEY_ERRORCODE:TM_ERROR_NET_ERRORCODE,KEY_MESSAGE:TM_ERROR_NET_MESSGAE,KEY_CONTENT:TM_ERROR_NET_CONTENT}]

/* 有效返回码 */
#define TM_NORMALCODE @"200"

static NSMutableArray   *requestTasksPool;

static AFHTTPSessionManager *_sessionManager;

@implementation TMNetworkingHelper

#pragma mark - manager

+ (AFHTTPSessionManager *)manager {
    
    if (_sessionManager == nil) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPMaximumConnectionsPerHost = 4;
        _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        /* 默认解析模式 */
        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        //配置请求序列化
        [[AFJSONResponseSerializer serializer] setRemovesKeysWithNullValues:YES];
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        _sessionManager.securityPolicy.allowInvalidCertificates = YES;
        _sessionManager.securityPolicy.validatesDomainName = NO;
        
        _sessionManager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        _sessionManager.requestSerializer.timeoutInterval = [TMNetworkConfig shareInstance].requestTimeout;
        
        NSDictionary *generalHeaders = [TMNetworkConfig shareInstance].generalHeaders;
        for (NSString *key in generalHeaders.allKeys) {
            if (generalHeaders[key] != nil) {
                [_sessionManager.requestSerializer setValue:generalHeaders[key] forHTTPHeaderField:key];
            }
        }
        
        //配置响应序列化根据后台需要配置
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                                  @"text/html",
                                                                                  @"text/json",
                                                                                  @"text/plain",
                                                                                  @"text/javascript",
                                                                                  @"text/xml",
                                                                                  @"image/*",
                                                                                  @"application/octet-stream",
                                                                                  @"application/zip"]];
    }
    //每次网络请求的时候，检查此时磁盘中的缓存大小，阈值默认是200MB，如果超过阈值，则清理LRU缓存
    //同时也会清理过期缓存，缓存默认SSL是7天
    //磁盘缓存的大小和SSL的设置可以通过该方法TMNetworkConfig.m设置
    [[TMCacheManager shareManager] clearLRUCache];
    return _sessionManager;
}

+ (NSMutableArray *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (requestTasksPool == nil) requestTasksPool = [NSMutableArray array];
    });
    return requestTasksPool;
}

#pragma mark - get

/**
 *  GET请求-无缓存无进度
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
                       failBlock:(TMResponseFailBlock)failBlock
{
    return [TMNetworkingHelper getWithUrl:url refreshRequest:NO cache:NO params:params progressBlock:nil successBlock:successBlock failBlock:failBlock];
}

/**
 *  GET请求-带缓存无进度
 *
 *  @param url              请求路径
 *  @param cache            是否缓存
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
                       failBlock:(TMResponseFailBlock)failBlock
{
    return [TMNetworkingHelper getWithUrl:url refreshRequest:refresh cache:cache params:params progressBlock:nil successBlock:successBlock failBlock:failBlock];
}

/**
 *  GET请求-有缓存有进度
 *
 *  @param url              请求路径
 *  @param cache            是否缓存
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
                       failBlock:(TMResponseFailBlock)failBlock {
    
    //将session拷贝到堆中，block内部才可以获取得到session
    __block TMURLSessionTask *session = nil;
    
    //打印参数日记
    [TMNetworkLogger tmNetworkLoggerShowRequest:params];
    //拼接地址
    if ([TMNetworkConfig shareInstance].betaVersion) {
        url = [NSString stringWithFormat:@"%@%@",[TMNetworkConfig shareInstance].testServerAPI,url];
    }else{
        url = [NSString stringWithFormat:@"%@%@",[TMNetworkConfig shareInstance].proServerAPI,url];
    }
    //返回缓存
    if (cache) {
        id responseObj = [[TMCacheManager shareManager] getCacheResponseObjectWithRequestUrl:url params:params];
        if (responseObj) {
            //打印返回日记
            [TMNetworkLogger tmNetworkLoggerShowResponse:responseObj];
            if (successBlock) successBlock(responseObj);
        }
    }
    if (![TMCheckNetworkStatus isConnectionAvailable]) {
        if (failBlock) failBlock(TM_ERROR);
        return session;
    }
    
    AFHTTPSessionManager *manager = [TMNetworkingHelper manager];
    session = [manager GET:url
                parameters:params
                  progress:^(NSProgress * _Nonnull downloadProgress) {
                      if (progressBlock){
                          progressBlock(downloadProgress.completedUnitCount,
                                        downloadProgress.totalUnitCount);
                      }
                      
                  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      
                      /* 在这做一系列的错误码拦截判断 */
                      NSDictionary *response = (NSDictionary *)responseObject;
                      if ([[response objectForKey:@"resultcode"] isEqualToString:TM_NORMALCODE]) {
                          if (successBlock){
                              successBlock(response);
                          }
                          if (cache){
                              [[TMCacheManager shareManager] cacheResponseObject:responseObject requestUrl:url params:params];
                          }
                          //打印返回日记
                          [TMNetworkLogger tmNetworkLoggerShowResponse:responseObject];
                          //api调用收集
                          if ([TMNetworkConfig shareInstance].apiAnalyse) {
                              [[TMNetworkAnalyse shareManager] saveAPINetworkAnalyse:url andParameter:params andBool:YES];
                          }
                      }else{
                          NSString *status = [NSString stringWithFormat:@"%@",[response valueForKey:@"error_code"]];
                          NSString *message = [response valueForKey:@"reason"];
                          NSMutableDictionary *retDict = [NSMutableDictionary dictionary];
                          [retDict setObject:status?status:@"" forKey:KEY_ERRORCODE];
                          [retDict setObject:message?message:@"" forKey:KEY_MESSAGE];
                          [retDict setValue:[NSString stringWithFormat:@"%@，错误码是：%@",message?message:@"",status?status:@""] forKey:KEY_CONTENT];
                          
                          if (failBlock) {
                              NSError *error_code = [NSError errorWithDomain:@"com.net.cocomanber" code:10086 userInfo:retDict];
                              failBlock(error_code);
                          }
                          //api调用收集
                          if ([TMNetworkConfig shareInstance].apiAnalyse) {
                              [[TMNetworkAnalyse shareManager] saveAPINetworkAnalyse:url andParameter:params andBool:NO];
                          }
                      }
                      if ([[self allTasks] containsObject:session]) {
                          [[self allTasks] removeObject:session];
                      }
                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      if (failBlock) failBlock(error);
                      if ([[self allTasks] containsObject:session]) {
                          [[self allTasks] removeObject:session];
                      }
                      //打印错误日记
                      [TMNetworkLogger tmNetworkLoggerShowError:error];
                      //api调用收集
                      if ([TMNetworkConfig shareInstance].apiAnalyse) {
                          [[TMNetworkAnalyse shareManager] saveAPINetworkAnalyse:url andParameter:params andBool:NO];
                      }
                  }];
    
    if ([self haveSameRequestInTasksPool:session] && !refresh) {
        //取消新请求
        [session cancel];
        return session;
    }else {
        //无论是否有旧请求，先执行取消旧请求，反正都需要刷新请求
        TMURLSessionTask *oldTask = [self cancleSameRequestInTasksPool:session];
        if (oldTask) [[self allTasks] removeObject:oldTask];
        if (session) [[self allTasks] addObject:session];
        [session resume];
        return session;
    }
}

#pragma mark - post

/**
 *  POST请求-无缓存无进度
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
                        failBlock:(TMResponseFailBlock)failBlock
{
    return [TMNetworkingHelper postWithUrl:url refreshRequest:NO cache:NO params:params progressBlock:nil successBlock:successBlock failBlock:failBlock];
}

/**
 *  POST请求-有缓存无进度
 *
 *  @param url              请求路径
 *  @param cache            是否缓存
 *  @param refresh          解释同上
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
                        failBlock:(TMResponseFailBlock)failBlock
{
    return [TMNetworkingHelper postWithUrl:url refreshRequest:refresh cache:cache params:params progressBlock:nil successBlock:successBlock failBlock:failBlock];
}

/**
 *  POST请求-有缓存有进度
 *
 *  @param url              请求路径
 *  @param cache            是否缓存
 *  @param refresh          解释同上
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
                        failBlock:(TMResponseFailBlock)failBlock
{
    __block TMURLSessionTask *session = nil;
    
    //打印参数日记
    [TMNetworkLogger tmNetworkLoggerShowRequest:params];
    //拼接地址
    if ([TMNetworkConfig shareInstance].betaVersion) {
        url = [NSString stringWithFormat:@"%@%@",[TMNetworkConfig shareInstance].testServerAPI,url];
    }else{
        url = [NSString stringWithFormat:@"%@%@",[TMNetworkConfig shareInstance].proServerAPI,url];
    }
    //返回缓存
    if (cache) {
        id responseObj = [[TMCacheManager shareManager] getCacheResponseObjectWithRequestUrl:url params:params];
        if (responseObj) {
            //打印返回日记
            [TMNetworkLogger tmNetworkLoggerShowResponse:responseObj];
            if (successBlock) successBlock(responseObj);
        }
    }
    if (![TMCheckNetworkStatus isConnectionAvailable]) {
        if (failBlock) failBlock(TM_ERROR);
        return session;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    session = [manager POST:url
                 parameters:params
                   progress:^(NSProgress * _Nonnull uploadProgress) {
                       if (progressBlock) progressBlock(uploadProgress.completedUnitCount,
                                                        uploadProgress.totalUnitCount);
                       
                   } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                       
                       /* 在这做一系列的错误码拦截判断 */
                       NSDictionary *response = (NSDictionary *)responseObject;
                       if ([[response objectForKey:@"resultcode"] isEqualToString:TM_NORMALCODE]) {
                           if (successBlock){
                               successBlock(response);
                           }
                           if (cache){
                               [[TMCacheManager shareManager] cacheResponseObject:responseObject requestUrl:url params:params];
                           }
                           //打印返回日记
                           [TMNetworkLogger tmNetworkLoggerShowResponse:responseObject];
                           //api调用收集
                           if ([TMNetworkConfig shareInstance].apiAnalyse) {
                               [[TMNetworkAnalyse shareManager] saveAPINetworkAnalyse:url andParameter:params andBool:YES];
                           }
                       }else{
                           NSString *status = [NSString stringWithFormat:@"%@",[response valueForKey:@"error_code"]];
                           NSString *message = [response valueForKey:@"reason"];
                           NSMutableDictionary *retDict = [NSMutableDictionary dictionary];
                           [retDict setObject:status?status:@"" forKey:KEY_ERRORCODE];
                           [retDict setObject:message?message:@"" forKey:KEY_MESSAGE];
                           [retDict setValue:[NSString stringWithFormat:@"%@，错误码是：%@",message?message:@"",status?status:@""] forKey:KEY_CONTENT];
                           
                           if (failBlock) {
                               NSError *error_code = [NSError errorWithDomain:@"com.net.cocomanber" code:10086 userInfo:retDict];
                               failBlock(error_code);
                           }
                           //api调用收集
                           if ([TMNetworkConfig shareInstance].apiAnalyse) {
                               [[TMNetworkAnalyse shareManager] saveAPINetworkAnalyse:url andParameter:params andBool:NO];
                           }
                       }
                       if ([[self allTasks] containsObject:session]) {
                           [[self allTasks] removeObject:session];
                       }
                       
                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                       if (failBlock) failBlock(error);
                       if ([[self allTasks] containsObject:session]) {
                           [[self allTasks] removeObject:session];
                       }
                       //打印错误日记
                       [TMNetworkLogger tmNetworkLoggerShowError:error];
                       
                       //api调用收集
                       if ([TMNetworkConfig shareInstance].apiAnalyse) {
                           [[TMNetworkAnalyse shareManager] saveAPINetworkAnalyse:url andParameter:params andBool:NO];
                       }
                   }];
    
    if ([self haveSameRequestInTasksPool:session] && !refresh) {
        [session cancel];
        return session;
    }else {
        TMURLSessionTask *oldTask = [self cancleSameRequestInTasksPool:session];
        if (oldTask) [[self allTasks] removeObject:oldTask];
        if (session) [[self allTasks] addObject:session];
        [session resume];
        return session;
    }
}

#pragma mark - 单个文件上传

+ (TMURLSessionTask *)uploadFileWithUrl:(NSString *)url
                               fileData:(NSData *)data
                                   type:(NSString *)type
                                   name:(NSString *)name
                               mimeType:(NSString *)mimeType
                          progressBlock:(TMUploadProgressBlock)progressBlock
                           successBlock:(TMResponseSuccessBlock)successBlock
                              failBlock:(TMResponseFailBlock)failBlock {
    __block TMURLSessionTask *session = nil;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    if (![TMCheckNetworkStatus isConnectionAvailable]) {
        if (failBlock) failBlock(TM_ERROR);
        return session;
    }
    
    session = [manager POST:url
                 parameters:nil
  constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
      NSString *fileName = nil;
      
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
      
      NSString *day = [formatter stringFromDate:[NSDate date]];
      
      fileName = [NSString stringWithFormat:@"%@.%@",day,type];
      
      [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
      
  } progress:^(NSProgress * _Nonnull uploadProgress) {
      if (progressBlock) progressBlock (uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
      
  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      if (successBlock) successBlock(responseObject);
      if ([[self allTasks] containsObject:session]) {
          [[self allTasks] removeObject:session];
      }
      
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
      if (failBlock) failBlock(error);
      if ([[self allTasks] containsObject:session]) {
          [[self allTasks] removeObject:session];
      }
  }];
    
    [session resume];
    
    if (session) [[self allTasks] addObject:session];
    
    return session;
}

#pragma mark - 多个文件上传

+ (NSArray *)uploadMultFileWithUrl:(NSString *)url
                         fileDatas:(NSArray *)datas
                              type:(NSString *)type
                              name:(NSString *)name
                          mimeType:(NSString *)mimeTypes
                     progressBlock:(TMUploadProgressBlock)progressBlock
                      successBlock:(TMMultUploadSuccessBlock)successBlock
                         failBlock:(TMMultUploadFailBlock)failBlock {
    
    if (![TMCheckNetworkStatus isConnectionAvailable]) {
        if (failBlock) failBlock(@[TM_ERROR]);
        return nil;
    }
    
    __block NSMutableArray *sessions = [NSMutableArray array];
    __block NSMutableArray *responses = [NSMutableArray array];
    __block NSMutableArray *failResponse = [NSMutableArray array];
    
    dispatch_group_t uploadGroup = dispatch_group_create();
    
    NSInteger count = datas.count;
    for (int i = 0; i < count; i++) {
        __block TMURLSessionTask *session = nil;
        
        dispatch_group_enter(uploadGroup);
        
        session = [self uploadFileWithUrl:url
                                 fileData:datas[i]
                                     type:type name:name
                                 mimeType:mimeTypes
                            progressBlock:^(int64_t bytesWritten, int64_t totalBytes) {
                                if (progressBlock) progressBlock(bytesWritten,
                                                                 totalBytes);
                                
                            } successBlock:^(id response) {
                                [responses addObject:response];
                                
                                dispatch_group_leave(uploadGroup);
                                
                                [sessions removeObject:session];
                                
                            } failBlock:^(NSError *error) {
                                NSError *Error = [NSError errorWithDomain:url code:-999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"第%d次上传失败",i]}];
                                
                                [failResponse addObject:Error];
                                
                                dispatch_group_leave(uploadGroup);
                                
                                [sessions removeObject:session];
                            }];
        
        [session resume];
        
        if (session) [sessions addObject:session];
    }
    
    [[self allTasks] addObjectsFromArray:sessions];
    
    dispatch_group_notify(uploadGroup, dispatch_get_main_queue(), ^{
        if (responses.count > 0) {
            if (successBlock) {
                successBlock([responses copy]);
                if (sessions.count > 0) {
                    [[self allTasks] removeObjectsInArray:sessions];
                }
            }
        }
        
        if (failResponse.count > 0) {
            if (failBlock) {
                failBlock([failResponse copy]);
                if (sessions.count > 0) {
                    [[self allTasks] removeObjectsInArray:sessions];
                }
            }
        }
        
    });
    
    return [sessions copy];
}

#pragma mark - 下载

+ (TMURLSessionTask *)downloadWithUrl:(NSString *)url
                        progressBlock:(TMDownloadProgress)progressBlock
                         successBlock:(TMDownloadSuccessBlock)successBlock
                            failBlock:(TMDownloadFailBlock)failBlock {
    NSString *type = nil;
    NSArray *subStringArr = nil;
    __block TMURLSessionTask *session = nil;
    
    NSURL *fileUrl = [[TMCacheManager shareManager] getDownloadDataFromCacheWithRequestUrl:url];
    
    if (fileUrl) {
        if (successBlock) successBlock(fileUrl);
        return nil;
    }
    
    if (url) {
        subStringArr = [url componentsSeparatedByString:@"."];
        if (subStringArr.count > 0) {
            type = subStringArr[subStringArr.count - 1];
        }
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //响应内容序列化为二进制
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    session = [manager GET:url
                parameters:nil
                  progress:^(NSProgress * _Nonnull downloadProgress) {
                      if (progressBlock) progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
                      
                  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      if (successBlock) {
                          NSData *dataObj = (NSData *)responseObject;
                          
                          [[TMCacheManager shareManager] storeDownloadData:dataObj requestUrl:url];
                          
                          NSURL *downFileUrl = [[TMCacheManager shareManager] getDownloadDataFromCacheWithRequestUrl:url];
                          
                          successBlock(downFileUrl);
                      }
                      
                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      if (failBlock) {
                          failBlock (error);
                      }
                  }];
    
    [session resume];
    
    if (session) [[self allTasks] addObject:session];
    
    return session;
    
}

#pragma mark - 处理请求相关

+ (void)cancleAllRequest {
    @synchronized (self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(TMURLSessionTask  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[TMURLSessionTask class]]) {
                [obj cancel];
            }
        }];
        [[self allTasks] removeAllObjects];
    }
}

+ (void)cancelRequestWithURL:(NSString *)url {
    if (!url) return;
    @synchronized (self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(TMURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[TMURLSessionTask class]]) {
                if ([obj.currentRequest.URL.absoluteString hasSuffix:url]) {
                    [obj cancel];
                    *stop = YES;
                }
            }
        }];
    }
}

+ (NSArray *)currentRunningTasks {
    return [[self allTasks] copy];
}

@end


@implementation TMNetworkingHelper (cache)

+ (NSUInteger)totalCacheSize {
    return [[TMCacheManager shareManager] totalCacheSize];
}

+ (NSUInteger)totalDownloadDataSize {
    return [[TMCacheManager shareManager] totalDownloadDataSize];
}

+ (void)clearDownloadData {
    [[TMCacheManager shareManager] clearDownloadData];
}

+ (NSString *)getDownDirectoryPath {
    return [[TMCacheManager shareManager] getDownDirectoryPath];
}

+ (NSString *)getCacheDiretoryPath {
    
    return [[TMCacheManager shareManager] getCacheDiretoryPath];
}

+ (void)clearTotalCache {
    [[TMCacheManager shareManager] clearTotalCache];
}

@end
