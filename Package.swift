// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "UIKitSwift",
    platforms: [.iOS("11.0")],
    products: [
        .library(name: "UIKitSwift", targets: ["UIKitSwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/JonasGessner/JGProgressHUD", .upToNextMajor(from: "2.1.0"))
    ],
    targets: [
        .target(
            name: "UIKitSwift",
            dependencies: ["JGProgressHUD"],
            path: "UIKitSwift"
        )
    ]
)
