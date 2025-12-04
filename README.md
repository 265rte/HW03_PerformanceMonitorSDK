# 性能监控SDK (PerformanceMonitorSDK)

一个轻量级的iOS性能监控SDK，用于实时监控应用的流畅性和ANR问题。

## 功能特性

### 已实现功能

#### 1. FPS监控（流畅性监控）
- 实时监控应用帧率(FPS)
- 使用CADisplayLink技术获取精准的帧率数据
- 每秒输出FPS信息到控制台
- 自动判断流畅度状态：
  - 55+ FPS: 流畅 
  - 45-54 FPS: 一般 
  - <45 FPS: 卡顿 

#### 2. ANR监控（Application Not Responding）
- 检测主线程卡顿问题
- 使用watchdog机制监控主线程响应
- 默认阈值：2秒无响应触发ANR警告
- 自动打印堆栈信息便于调试
- 统计ANR发生次数
- 模块化设计：ANRMonitor、ANRTracker、PingThread

#### 3. 前后台切换处理
- 自动检测App进入后台/回到前台
- 后台时暂停所有监控，避免误报和资源浪费
- 前台时自动恢复监控
- FPS监控暂停DisplayLink
- ANR监控暂停检测和Ping线程

## 项目结构

```
HW03_PerformanceMonitorSDK/
├── PerformanceMonitorSDK/          # SDK源代码（独立模块）
│   ├── Package.swift               # Swift Package配置
│   └── Sources/
│       └── PerformanceMonitorSDK/
│           ├── PerformanceMonitor.swift    # SDK主入口（管理类）
│           ├── FPSMonitor.swift           # FPS监控实现
│           ├── ANRMonitor.swift           # ANR监控管理类
│           ├── ANRTracker.swift           # ANR追踪器（检测ANR）
│           └── PingThread.swift           # Ping线程（ping主线程）
│
├── DemoApp/                        # 演示App
│   ├── DemoApp.xcodeproj/         # Xcode项目文件
│   └── DemoApp/
│       ├── DemoApp.swift          # App入口
│       ├── ContentView.swift      # 主界面（测试功能）
│       ├── Assets.xcassets/       # 资源文件
│       └── Info.plist            # 配置文件
│
└── README.md                       # 项目说明文档
```

## 技术实现

### FPS监控技术方案
使用`CADisplayLink`实现：
- CADisplayLink是iOS系统提供的与屏幕刷新率同步的定时器
- 通过计算每秒回调次数来获取实时FPS
- 在主线程运行，不影响性能

### ANR监控技术方案
使用信号量+监控线程实现，采用模块化设计：

**架构组成：**
- **ANRMonitor**：管理类，统一管理ANR检测组件
- **ANRTracker**：追踪器，运行独立监控线程等待信号量超时
- **PingThread**：Ping线程，定期向主线程发送任务并响应信号

**工作流程：**
1. PingThread定期向主线程发送任务
2. 主线程响应后通过信号量signal
3. ANRTracker等待信号量，超时则判定为ANR
4. 记录堆栈信息方便定位问题

### 前后台切换技术方案
- 监听`UIApplication.didEnterBackgroundNotification`通知
- 监听`UIApplication.willEnterForegroundNotification`通知
- 进入后台时暂停FPS的CADisplayLink和ANR的检测线程
- 回到前台时恢复监控，重置时间戳避免误差
- 有效避免后台误报ANR，节省系统资源

