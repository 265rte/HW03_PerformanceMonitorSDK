import Foundation
import UIKit

// FPS监控类
class FPSMonitor {
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0
    
    var currentFPS: Int = 0
    private var tmp: Int = 0 
    private var isPaused = false
    
    private var fpsCallbacks: [(Int) -> Void] = []
    
    init() {
    }
    
    func startMonitoring() {
        guard displayLink == nil else { return }
        
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkTick))
        displayLink?.add(to: .main, forMode: .common)
        
        print("FPS monitoring STARTED")
    }
    
    func stopMonitoring() {
        displayLink?.invalidate()
        displayLink = nil
        currentFPS = 0
        isPaused = false
        print("FPS monitoring STOPPED")
    }
    
    // 暂停监控（后台）
    func pauseMonitoring() {
        guard !isPaused else { return }
        isPaused = true
        displayLink?.isPaused = true
        print("FPS monitoring paused")
    }
    
    // 恢复监控（前台）
    func resumeMonitoring() {
        guard isPaused else { return }
        isPaused = false
        displayLink?.isPaused = false
        // 重置时间戳
        lastTimestamp = 0
        frameCount = 0
        print("FPS monitoring resumed")
    }
    
    @objc private func displayLinkTick(link: CADisplayLink) {
        guard !isPaused else { return }
        
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }
        
        frameCount += 1
        
        let delta = link.timestamp - lastTimestamp
        
        // 每秒计算一次FPS
        if delta >= 1.0 {
            tmp = frameCount  
            currentFPS = Int(Double(tmp) / delta)
            
            // 输出FPS信息
            var status = getFPSStatus(fps: currentFPS)
            print("Current FPS: \(currentFPS) - \(status)")
            
            // 重置计数器
            frameCount = 0
            lastTimestamp = link.timestamp
            
            // 调用回调
            for callback in fpsCallbacks {
                callback(currentFPS)
            }
        }
    }
    
    private func getFPSStatus(fps: Int) -> String {
        if fps >= 55 {
            return "流畅"
        } else if fps >= 45 {
            return "一般 "
        } else {
            return "卡顿 "
        }
    }
    
    // 添加FPS回调
    func addFPSCallback(callback: @escaping (Int) -> Void) {
        fpsCallbacks.append(callback)
    }
}
