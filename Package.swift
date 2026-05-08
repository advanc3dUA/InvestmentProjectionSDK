// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InvestmentProjectionSDK",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "InvestmentProjectionCore",
            targets: ["InvestmentProjectionCore"]
        ),
        .library(
            name: "InvestmentProjectionUI",
            targets: ["InvestmentProjectionUI"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "InvestmentProjectionCore"
        ),
        .target(
            name: "InvestmentProjectionUI",
            dependencies: ["InvestmentProjectionCore"]
        ),
        .testTarget(
            name: "InvestmentProjectionCoreTests",
            dependencies: ["InvestmentProjectionCore"]
        ),
        .testTarget(
            name: "InvestmentProjectionUITests",
            dependencies: ["InvestmentProjectionUI"]
        ),
    ]
)
