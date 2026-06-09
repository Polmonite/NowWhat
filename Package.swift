// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NowWhat",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "NowWhat",
            path: "Sources/NowWhat"
        )
    ]
)
