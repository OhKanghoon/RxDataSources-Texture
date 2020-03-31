// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "RxDataSources-Texture",
    platforms: [
      .iOS(.v9)
    ],
    products: [
        .library(name: "RxDataSources-Texture", targets: ["RxDataSources-Texture"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", .upToNextMajor(from: "4.0.1")),
    ],
    targets: [
        .target(name: "RxDataSources-Texture", dependencies: ["Differentiator", "RxSwift", "RxCocoa"]),
        .testTarget(name: "RxDataSources-TextureTests", dependencies: ["RxDataSources-Texture"]),
    ]
)

