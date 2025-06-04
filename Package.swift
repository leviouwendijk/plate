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
    // dependencies: [
    //     .package(url: "https://github.com/apple/pkl-swift", from: "0.2.1")
    // ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "plate",
            // swiftSettings: [
            //     .unsafeFlags(["-enable-library-evolution"])
            // ],
            // dependencies: [
            //     .product(name: "PklSwift", package: "pkl-swift")
            // ],
            // resources: [
            //     .process("Resources")
            // ]
        ),
        .testTarget(
            name: "plateTests",
            dependencies: ["plate"]
        ),
    ]
)
