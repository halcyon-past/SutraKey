// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SutraKey",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "SutraKey",
            targets: ["SutraKey"]
        )
    ],
    targets: [
        .executableTarget(
            name: "SutraKey",
            path: "Sources/SutraKey",
            exclude: [
                "Resources/Info.plist"
            ],
            resources: [
                .process("Resources/Assets.xcassets"),
                .copy("Resources/yt_dlp_plugins")
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-F/Library/Developer/CommandLineTools/Library/Developer/Frameworks"
                ])
            ]
        ),
        .testTarget(
            name: "SutraKeyTests",
            dependencies: ["SutraKey"],
            path: "Tests/SutraKeyTests",
            swiftSettings: [
                .unsafeFlags([
                    "-F/Library/Developer/CommandLineTools/Library/Developer/Frameworks"
                ])
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-F/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
                    "-Xlinker", "-rpath", "-Xlinker", "/Library/Developer/CommandLineTools/Library/Developer/Frameworks",
                    "-Xlinker", "-rpath", "-Xlinker", "/Library/Developer/CommandLineTools/Library/Developer/usr/lib"
                ])
            ]
        )
    ]
)
