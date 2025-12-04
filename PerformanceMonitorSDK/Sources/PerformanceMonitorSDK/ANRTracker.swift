import Foundation
import UIKit

// ANR追踪器 - 负责检测和追踪ANR
class ANRTracker {
    private var monitorThread: Thread?
    private var isRunning = false
    private var isPaused = false
    private var semaphore: DispatchSemaphore?
    
    // ANR阈值
    private let threshold: TimeInterval
    private var checkInterval: TimeInterval = 0.5  // 检查间隔
    private var anrCount = 0
    var totalCheckCount = 0
    
    init(threshold: TimeInterval = 2.0) {
        self.threshold = threshold
    }
    
    // 开始追踪
    func startTracking(semaphore: DispatchSemaphore) {
        guard !isRunning else { return }
        
        self.semaphore = semaphore
        isRunning = true
        
        // 启动监控线程
        monitorThread = Thread(target: self, selector: #selector(trackingLoop), object: nil)
        monitorThread?.name = "ANRTrackerThread"
        monitorThread?.start()
        
        print("ANR Tracker started (threshold: \(threshold)s)")
    }
    
    // 停止追踪
    func stopTracking() {
        isRunning = false
        semaphore?.signal()
        monitorThread = nil
        print("ANR Tracker stopped")
    }
    
    // 暂停追踪
    func pause() {
        isPaused = true
    }
    
    // 恢复追踪
    func resume() {
        isPaused = false
        semaphore?.signal()
    }
    
    // 追踪循环
    @objc private func trackingLoop() {
        while isRunning {
            if isPaused {
                Thread.sleep(forTimeInterval: checkInterval)
                continue
            }
            
            totalCheckCount = totalCheckCount + 1
            
            // 等待主线程的响应信号
            var result = semaphore?.wait(timeout: .now() + threshold)
            
            if result == .timedOut && isRunning && !isPaused {
                // 检测到ANR
                anrCount += 1
                handleANRDetected()
            }
            
            Thread.sleep(forTimeInterval: checkInterval)
        }
    }
    
    // 处理检测到的ANR
    private func handleANRDetected() {
        print("ANR detected! Main thread not responding for \(threshold)s")
        print("   ANR count: \(anrCount)")
        print("   Total checks: \(totalCheckCount)")
        
        printMainThreadStackTrace()
    }
    
    // 打印主线程堆栈
    private func printMainThreadStackTrace() {
        let mainThread = Thread.main
        
        print(" Main thread stack trace:")
        print("  Thread name: \(mainThread.name ?? "main")")
        print("  Thread: \(mainThread)")
        
        // 获取堆栈
        let symbols = Thread.callStackSymbols
        for (index, symbol) in symbols.enumerated() {
            print("  [\(index)] \(symbol)")
        }
        
        print("Note: Stack captured from tracker thread")
    }
    
    // 获取ANR统计信息
    func getANRCount() -> Int {
        return anrCount
    }
    
    func getTotalCheckCount() -> Int {
        return totalCheckCount
    }
}
