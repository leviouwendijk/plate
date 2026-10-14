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

        // testing target
        .executable(
            name: "t_plate",
            targets: ["PlateTests"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/leviouwendijk/Primitives.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Terminal.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Version.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Path.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Indentation.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Strings.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Parsers.git", branch: "master"),
        .package(url: "https://github.com/leviouwendijk/Testing.git", branch: "master"),
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
                .product(name: "Version", package: "Version"),
                .product(name: "Path", package: "Path"),
                .product(name: "Indentation", package: "Indentation"),
                .product(name: "Strings", package: "Strings"),
                .product(name: "Parsers", package: "Parsers"),
                // .product(name: "PklSwift", package: "pkl-swift")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "PlateTests",
            dependencies: [
                "plate",
                .product(name: "Testing", package: "Testing"),
                .product(name: "Version", package: "Version"),
                .product(name: "Primitives", package: "Primitives"),
            ],
            path: "Testing/PlateTests"
        ),
    ]
)
