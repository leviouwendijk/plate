// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "plate",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "plate",
            // type: .static,
            targets: ["plate"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-lco/Primitives.git", branch: "master"),
        .package(url: "https://github.com/swift-lco/Terminal.git", branch: "master"),
        .package(url: "https://github.com/swift-lco/Path.git", branch: "master"),
        .package(url: "https://github.com/swift-lco/Indentation.git", branch: "master"),
        .package(url: "https://github.com/swift-lco/Strings.git", branch: "master"),
        // .package(url: "https://github.com/apple/pkl-swift", from: "0.2.1")
        // .package(url: "https://github.com/swiftlang/swift-testing.git", from: "6.2.0")
    ],
    targets: [
        .target(
            name: "plate",
            // swiftSettings: [
            //     .unsafeFlags(["-enable-library-evolution"])
            // ],
            dependencies: [
                .product(name: "Primitives", package: "Primitives"),
                .product(name: "Terminal", package: "Terminal"),
                .product(name: "Path", package: "Path"),
                .product(name: "Indentation", package: "Indentation"),
                .product(name: "Strings", package: "Strings"),
                // .product(name: "PklSwift", package: "pkl-swift")
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
