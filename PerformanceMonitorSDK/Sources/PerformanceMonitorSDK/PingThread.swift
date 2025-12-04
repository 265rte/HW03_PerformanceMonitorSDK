import Foundation

// Ping线程 - 负责定期ping主线程
class PingThread {
    private var isRunning = false
    private var isPaused = false
    private weak var semaphore: DispatchSemaphore?
    private var pingInterval: TimeInterval = 0.5
    
    init(semaphore: DispatchSemaphore, interval: TimeInterval = 0.5) {
        self.semaphore = semaphore
        self.pingInterval = interval
    }
    
    // 开始ping
    func start() {
        guard !isRunning else { return }
        isRunning = true
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            while self?.isRunning == true {
                // 暂停时不ping
                if self?.isPaused == false {
                    // 向主线程发送任务
                    DispatchQueue.main.async {
                        // 主线程响应，发送信号
                        self?.semaphore?.signal()
                    }
                }
                
                Thread.sleep(forTimeInterval: self?.pingInterval ?? 0.5)
            }
        }
        
        print("Ping thread started")
    }
    
    // 停止ping
    func stop() {
        isRunning = false
        print("Ping thread stopped")
    }
    
    // 暂停ping
    func pause() {
        isPaused = true
    }
    
    // 恢复ping
    func resume() {
        isPaused = false
    }
}
