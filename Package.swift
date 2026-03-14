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
        // Main Swift package
        .executableTarget(
            name: "QuickTuner",
            path: "Source",
            exclude: ["Info.plist", "QuickTuner.entitlements"],
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