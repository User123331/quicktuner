// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "QuickTuner",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "QuickTuner",
            targets: ["QuickTuner"]
        )
    ],
    targets: [
        .target(
            name: "QuickTuner",
            dependencies: [],
            path: "Sources",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "QuickTunerTests",
            dependencies: ["QuickTuner"],
            path: "Tests",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
