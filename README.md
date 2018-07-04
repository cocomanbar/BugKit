
# ShowBugKit
一款iOS基于开发阶段离线调试的工具，方便测试人员查看app运行各种情况，例如离线打印日记、查看本地crash记录列表、app内发生的http请求统计包括request和response等详细信息

1.当出现功能异常时，有很大可能是与服务器的接口交互有数据异常，不管是客户端参数传错还是服务器返回结果错误，都不需要连接电脑调试了，只要打开debug工具就可以观察每次http/https请求的信息了，测试人员都可以使用哦，极大的提交了查找问题的效率！

2.自动捕获Crash日志，不需要再为不是必现得crash而头疼了，一看就了解问题所以，工具会显示crash的堆栈信息。

3.打印系统日志，NSLog输出的log可以在ShowBugKit中及时查看，解决了只能连接电脑调式才能看到log，大大的方便了开发人员。

## 参考
    [JxbDebugTool](https://github.com/JxbSir/JxbDebugTool)

## 支持CocoaPods引入

```
 pod 'ShowBugKit'
```

## 启用代码
```object-c

#import "BugAssistive.h"

#if DEBUG
    BugAssistiveConfig *config  = [BugAssistiveConfig shareManager];
    config.showLogs = NO;
    config.hasNavi = NO;
    config.hasTabB = NO;
    [BugAssistiveTouch showBugAssistiveTouchonView:self.window withConfig:config];
#endif
```

## 效果图
 
 1、Http捕抓

![image](https://github.com/cocomanbar/ShowBugKit/raw/master/source/http.gif)
 
 2、crash日记查看
 
![image](https://github.com/cocomanbar/ShowBugKit/raw/master/source/crash.gif)
 
 3、log重定向打印
 
![image](https://github.com/cocomanbar/ShowBugKit/raw/master/source/log.gif)

