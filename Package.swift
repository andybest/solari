// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.


import PackageDescription

let package = Package(
    name: "solari",
    products: [
        .library(
            name: "solari",
            targets: ["solari"]),
        .executable(
            name: "solari-gui",
            targets: ["solari-gui"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/andybest/SDL.git", .exact("0.0.2")),
        .package(url: "https://github.com/Quick/Nimble.git", from: "7.0.1")
    ],
    targets: [
        .target(
            name: "solari",
            dependencies: []),
        .target(
            name: "solari-gui",
              dependencies: ["solari", "SDL"]),
        .testTarget(
            name: "solariTests",
            dependencies: ["solari", "Nimble"]),
    ]
)
