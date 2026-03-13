// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "QuickTuner",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(
            name: "QuickTuner",
            targets: ["QuickTuner"]
        )
    ],
    targets: [
        // Objective-C++ bridge for Core Audio
        .target(
            name: "AudioBridge",
            path: "Source/AudioBridge",
            publicHeadersPath: ".",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ],
            linkerSettings: [
                .linkedFramework("CoreAudio")
            ]
        ),
        // Main Swift package
        .executableTarget(
            name: "QuickTuner",
            dependencies: ["AudioBridge"],
            path: "Source",
            exclude: ["AudioBridge", "Info.plist", "QuickTuner.entitlements"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ],
            linkerSettings: [
                .linkedFramework("AVFAudio"),
                .linkedFramework("CoreAudio")
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
