import SwiftUI
import PerformanceMonitorSDK

struct ContentView: View {
    @State private var currentFPS: Int = 60
    @State private var isHeavyTaskRunning = false
    @State private var testMessage = "点击下面按钮测试SDK功能"
    
    var body: some View {
        VStack(spacing: 25) {
            
            Text("性能监控SDK演示")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Divider()
                .padding(.horizontal)
            
            // FPS显示
            VStack(spacing: 10) {
                Text("当前FPS")
                    .font(.headline)
                
                Text("\(currentFPS)")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(getFPSColor(fps: currentFPS))
                
                Text(getFPSStatus(fps: currentFPS))
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            
            Spacer()
            
            // 测试消息显示
            Text(testMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            // 测试按钮区域
            VStack(spacing: 15) {
                Text("测试功能")
                    .font(.headline)
                
                // 测试FPS下降
                Button(action: {
                    testFPSDrop()
                }) {
                    HStack {
                        Image(systemName: "chart.line.downtrend.xyaxis")
                        Text("测试FPS下降")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                // 测试ANR
                Button(action: {
                    testANR()
                }) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                        Text("测试ANR检测")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(isHeavyTaskRunning)
                
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
            
        }
        .onAppear {
            startFPSUpdate()
        }
    }
    
    // 启动FPS更新
    func startFPSUpdate() {
        var timer: Timer?
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.currentFPS = PerformanceMonitor.shared.getCurrentFPS()
        }
    }
    
    // 测试FPS下降
    func testFPSDrop() {
        var msg = "正在执行10000000次sin计算"
        testMessage = msg
        
        DispatchQueue.global().async {
            for _ in 0..<5 {
                DispatchQueue.main.async {
                    // 主线程执行重任务
                    var result = 0.0
                    for i in 0..<10000000 {
                        result += sin(Double(i))
                    }
                    print("Heavy calculation result: \(result)")
                }
                Thread.sleep(forTimeInterval: 0.2)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                testMessage = "测试完成！查看控制台FPS变化"
            }
        }
    }
    
    // 测试ANR
    func testANR() {
        testMessage = "即将阻塞主线程3秒..."
        isHeavyTaskRunning = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 阻塞主线程
            print("开始阻塞主线程...")
            Thread.sleep(forTimeInterval: 3.0)
            print("主线程恢复")
            
            testMessage = "ANR测试完成！查看控制台输出"
            isHeavyTaskRunning = false
        }
    }
    
    // 获取FPS状态文字
    func getFPSStatus(fps: Int) -> String {
        if fps >= 55 {
            return "流畅"
        } else if fps >= 45 {
            return "一般"
        } else {
            return "卡顿"
        }
    }
    
    // 获取FPS颜色
    func getFPSColor(fps: Int) -> Color {
        if fps >= 55 {
            return .green
        } else if fps >= 45 {
            return .orange
        } else {
            return .red
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
