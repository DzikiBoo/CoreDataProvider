// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "CoreDataProvider",
    platforms: [
        .watchOS(.v7),
        .iOS(.v14),
        .macOS(.v11),
        .macCatalyst(.v14)
    ],
    products: [.library(name: "CoreDataProvider", targets: ["CoreDataProvider"])],
    dependencies: [],
    targets: [.target(name: "CoreDataProvider", dependencies: [])]
)
