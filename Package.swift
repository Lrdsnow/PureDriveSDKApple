// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PureDrive",
    
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1)
    ],
    
    products: [
        .library(
            name: "PureDriveC",
            targets: ["PureDriveC"]),
        .library(
            name: "PureDrive",
            type: .dynamic,
            targets: ["PureDrive"]),
    ],
    
    dependencies: [],
    
    targets: [
        .target(
            name: "PureDrive",
            dependencies: ["PureDriveC"]
        ),
        .target(name: "PureDriveC")
    ]
)
