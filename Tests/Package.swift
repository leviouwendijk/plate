// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "plateTests",
    platforms: [
        .macOS(.v13)
    ],
    products: [

        // testing target
        .executable(
            name: "t_plate",
            targets: ["PlateTests"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-lco/Primitives.git", branch: "master"),
        .package(url: "https://github.com/swift-tooling/Testing.git", branch: "master"),
        .package(path: ".."),
        // .package(url: "https://github.com/apple/pkl-swift", from: "0.2.1")
        // .package(url: "https://github.com/swiftlang/swift-testing.git", from: "6.2.0")
    ],
    targets: [
        .executableTarget(
            name: "PlateTests",
            dependencies: [
                .product(name: "plate", package: "plate"),
                .product(name: "Testing", package: "Testing"),
                .product(name: "Primitives", package: "Primitives"),
            ]
        ),
    ]
)
