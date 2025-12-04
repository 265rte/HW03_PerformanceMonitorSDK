import SwiftUI
import PerformanceMonitorSDK

@main
struct DemoApp: App {
    
    init() {
        // 启动SDK
        PerformanceMonitor.shared.startMonitoring()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
