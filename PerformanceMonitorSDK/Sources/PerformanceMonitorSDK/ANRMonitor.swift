import Foundation
import UIKit

// ANR监控管理类 - 统一管理ANR检测
class ANRMonitor {
    private var tracker: ANRTracker?
    private var pingThread: PingThread?
    private var semaphore: DispatchSemaphore?
    
    private var isRunning = false
    private var isPaused = false
    
    // ANR阈值配置
    private let threshold: TimeInterval = 2.0
    private let pingInterval: TimeInterval = 0.5
    
    init() {
    }
    
    // 开始监控
    func startMonitoring() {
        guard !isRunning else {
            print("ANR monitoring already running")
            return
        }
        
        isRunning = true
        
        // 创建信号量
        semaphore = DispatchSemaphore(value: 0)
        
        // 创建并启动tracker
        tracker = ANRTracker(threshold: threshold)
        tracker?.startTracking(semaphore: semaphore!)
        
        // 创建并启动ping线程
        pingThread = PingThread(semaphore: semaphore!, interval: pingInterval)
        pingThread?.start()
        
        print("ANR monitoring started (threshold: \(threshold)s)")
    }
    
    // 停止监控
    func stopMonitoring() {
        guard isRunning else { return }
        
        isRunning = false
        
        // 停止各个组件
        tracker?.stopTracking()
        pingThread?.stop()
        
        tracker = nil
        pingThread = nil
        semaphore = nil
        
        print("ANR monitoring stopped")
    }
    
    // 暂停监控（后台）
    func pauseMonitoring() {
        guard !isPaused else { return }
        isPaused = true
        tracker?.pause()
        pingThread?.pause()
        print("ANR monitoring paused")
    }
    
    // 恢复监控（前台）
    func resumeMonitoring() {
        guard isPaused else { return }
        isPaused = false
        tracker?.resume()
        pingThread?.resume()
        print("ANR monitoring resumed")
    }
    
    // 获取ANR统计信息
    func getANRCount() -> Int {
        return tracker?.getANRCount() ?? 0
    }
}
