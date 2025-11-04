// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "FocusFlowShared",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "FocusFlowShared",
            targets: ["FocusFlowShared"]
        ),
    ],
    targets: [
        .target(
            name: "FocusFlowShared",
            path: "",
            exclude: ["README.md"],
            sources: ["Sources"],
            resources: [.process("Sources/DesignSystem")]
        ),
        .testTarget(
            name: "FocusFlowSharedTests",
            dependencies: ["FocusFlowShared"],
            path: "Tests"
        ),
    ]
)
