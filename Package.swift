// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "vk-ios-sdk",
    platforms: [.iOS(.v8)],
    products: [
        .library(
            name: "vk-ios-sdk",
            targets: ["vk-ios-sdk"]
        )
    ],
    targets: [
        .target(
            name: "vk-ios-sdk",
            path: "library/Source",
            resources: [
                .copy("../Resources"),
            ],
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("../DynamicFramework"),
                .headerSearchPath("."),
                .headerSearchPath("API"),
                .headerSearchPath("API/methods"),
                .headerSearchPath("API/models"),
                .headerSearchPath("API/upload"),
                .headerSearchPath("Core"),
                .headerSearchPath("Image"),
                .headerSearchPath("Utils"),
                .headerSearchPath("Views"),
            ]
        ),
        .testTarget(
            name: "vk-ios-sdk-tests",
            dependencies: ["vk-ios-sdk"],
            path: "VKSdkTests"
        )
    ]
)
