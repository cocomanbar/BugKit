//
//  BugAssistiveSessionProtocol.m
//  ShowBugKit
//
//  Created by cocomanber on 2018/5/24.
//  Copyright © 2018年 cocomanber. All rights reserved.
//

#import "BugAssistiveSessionProtocol.h"
//#import <UIKit/UIKit.h>
#import "BugAssistiveHttpHelper.h"
#import "BugAssistiveHttpDataSource.h"

/* 为了避免canInitWithRequest和canonicalRequestForRequest的死循环 */
#define myProtocolKey   @"BugAssistiveHttpProtocol"

@interface BugAssistiveSessionProtocol ()
<NSURLConnectionDelegate,
NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLResponse *bug_response;
@property (nonatomic, strong) NSURLRequest *bug_request;
@property (nonatomic, strong) NSMutableData *bug_data;
@property (nonatomic, strong) NSError *bug_error;
@property (nonatomic, assign) NSTimeInterval  startTime;

@end

@implementation BugAssistiveSessionProtocol

#pragma mark - protocol
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (void)load {
    
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:myProtocolKey inRequest:request] ) {
        return NO;
    }
    
    /* 数组内抓取的域名的请求通过,得通过BugAssistiveConfig类配置 */
    if ([[BugAssistiveHttpHelper shareInstance] arrOnlyHosts].count > 0) {
        NSString* url = [request.URL.absoluteString lowercaseString];
        for (NSString* _url in [BugAssistiveHttpHelper shareInstance].arrOnlyHosts) {
            if ([url rangeOfString:[_url lowercaseString]].location != NSNotFound)
                return YES;
        }
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:myProtocolKey inRequest:mutableReqeust];
    return [mutableReqeust copy];
}

- (void)startLoading {
    self.bug_data = [NSMutableData data];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    NSURLRequest *request = [[self class] canonicalRequestForRequest:self.request];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    self.bug_request = self.request;
    
#pragma clang diagnostic pop
    self.startTime = [[NSDate date] timeIntervalSince1970];
}

- (void)stopLoading {

    [self.connection cancel];
    
    BugAssistiveHttpModel* model = [[BugAssistiveHttpModel alloc] init];
    model.url = self.bug_request.URL;
    model.method = self.bug_request.HTTPMethod;
    model.mineType = self.bug_response.MIMEType;
    //model.httpMark = self.bug_request.requestId;
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)self.bug_response;
    model.statusCode = [NSString stringWithFormat:@"%d",(int)httpResponse.statusCode];
    model.responseData = self.bug_data;
    model.isImage = [self.bug_response.MIMEType rangeOfString:@"image"].location != NSNotFound;
    model.totalDuration = [NSString stringWithFormat:@"%fs",[[NSDate date] timeIntervalSince1970] - self.startTime];
    model.startTime = [NSString stringWithFormat:@"%fs",self.startTime];
    
    if (self.bug_request.HTTPBody) {
        NSData* data = self.bug_request.HTTPBody;
        if ([[BugAssistiveHttpHelper shareInstance] isHttpRequestEncrypt]) {
            if ([[BugAssistiveHttpHelper shareInstance] delegate] && [[BugAssistiveHttpHelper shareInstance].delegate respondsToSelector:@selector(decryptJson:)]) {
                data = [[BugAssistiveHttpHelper shareInstance].delegate decryptJson:self.bug_request.HTTPBody];
            }
        }
        model.requestBody = [BugAssistiveHttpDataSource prettyJSONStringFromData:data];
    }
    [[BugAssistiveHttpDataSource shareInstance] addHttpRequset:model];
    [[BugAssistiveHttpDataSource shareInstance] addHttpTaskRequestId:model.httpMark];
    dispatch_async(dispatch_get_main_queue(), ^{
       [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyKeyReloadHttp object:nil];
    });
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self.client URLProtocol:self didFailWithError:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection{
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    [self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection
didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.client URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

#pragma mark - NSURLConnectionDataDelegate

-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response{
    if (response != nil) {
        self.bug_response = response;
        [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    self.bug_response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    [self.bug_data appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[self client] URLProtocolDidFinishLoading:self];
}

#pragma mark - private

//转换json, 可以到展示时用到

-(id)responseJSONFromData:(NSData *)data {
    if(data == nil) return nil;
    NSError *error = nil;
    id returnValue = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if(error) {
        //https://github.com/coderyi/NetworkEye/issues/3
        return nil;
    }
    //https://github.com/coderyi/NetworkEye/issues/1
    if (!returnValue || returnValue == [NSNull null]) {
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:returnValue options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end
