// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "PerformanceMonitorSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "PerformanceMonitorSDK",
            targets: ["PerformanceMonitorSDK"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "PerformanceMonitorSDK",
            dependencies: []),
    ]
)
