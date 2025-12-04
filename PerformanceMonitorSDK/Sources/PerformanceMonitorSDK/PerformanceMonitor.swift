import Foundation
import UIKit

// SDK主类
public class PerformanceMonitor {
    public static let shared = PerformanceMonitor()
    
    private var fpsMonitor: FPSMonitor?
    private var anrMonitor: ANRMonitor?
    
    private var isMonitoring = false
    private var isPaused = false
    
    private init() {
        setupAppLifecycleObservers()
    }
    
    // 应用生命周期监听
    private func setupAppLifecycleObservers() {
        // 监听进入后台
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        // 监听回到前台
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appDidEnterBackground() {
        guard isMonitoring && !isPaused else { return }
        
        print("App entered background, pausing monitoring...")
        isPaused = true
        
        fpsMonitor?.pauseMonitoring()
        anrMonitor?.pauseMonitoring()
    }
    
    @objc private func appWillEnterForeground() {
        guard isMonitoring && isPaused else { return }
        
        print("App entering foreground, resuming monitoring...")
        isPaused = false
        
        fpsMonitor?.resumeMonitoring()
        anrMonitor?.resumeMonitoring()
    }
    
    // 启动监控
    public func startMonitoring() {
        guard !isMonitoring else {
            print("Performance monitor already started")
            return
        }
        
        isMonitoring = true
        
        // 启动FPS监控
        fpsMonitor = FPSMonitor()
        fpsMonitor?.startMonitoring()
        
        // 启动ANR监控
        anrMonitor = ANRMonitor()
        anrMonitor?.startMonitoring()
        
        print("Performance monitoring STARTED")
    }
    
    // 停止监控
    public func stopMonitoring() {
        guard isMonitoring else { return }
        
        fpsMonitor?.stopMonitoring()
        anrMonitor?.stopMonitoring()
        
        fpsMonitor = nil
        anrMonitor = nil
        
        isMonitoring = false
        print("Performance monitoring STOPPED")
    }
    
    // 获取当前FPS
    public func getCurrentFPS() -> Int {
        return fpsMonitor?.currentFPS ?? 0
    }
}
