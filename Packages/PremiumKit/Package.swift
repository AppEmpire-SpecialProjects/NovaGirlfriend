// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PremiumKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "PremiumKit",
            targets: ["PremiumKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apphud/ApphudSDK.git",
            "4.0.0"..<"4.0.5"
        )
    ],
    targets: [
        .target(
            name: "PremiumKit",
            dependencies: [
                .product(name: "ApphudSDK", package: "ApphudSDK")
            ],
            path: "Sources/PremiumKit",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PremiumKitTests",
            dependencies: ["PremiumKit"],
            resources: [.copy("Fixtures")]
        )
    ]
)
