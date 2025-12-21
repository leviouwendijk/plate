// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "plate",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "plate",
            type: .static,
            targets: ["plate"]),
    ],
    dependencies: [
        .package(url: "https://github.com/leviouwendijk/Terminal.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Version.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Path.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Indentation.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Strings.git", branch: "master"),
        // .package(url: "https://github.com/apple/pkl-swift", from: "0.2.1")
        // .package(url: "https://github.com/swiftlang/swift-testing.git", from: "6.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "plate",
            // swiftSettings: [
            //     .unsafeFlags(["-enable-library-evolution"])
            // ],
            dependencies: [
                .product(name: "Terminal", package: "Terminal"),
                .product(name: "Version", package: "Version"),
                .product(name: "Path", package: "Path"),
                .product(name: "Indentation", package: "Indentation"),
                .product(name: "Strings", package: "Strings"),
                // .product(name: "PklSwift", package: "pkl-swift")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "plateTests",
            dependencies: [
                "plate",
                // .product(name: "Testing", package: "swift-testing"),
            ]
        ),
    ]
)
