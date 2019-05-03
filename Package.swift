// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "UIKitSwift",
    platforms: [.iOS("11.0")],
    products: [
        .library(name: "UIKitSwift", targets: ["UIKitSwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/JonasGessner/JGProgressHUD.git", .upToNextMinor(from: "2.0.3"))
    ],
    targets: [
        .target(
            name: "UIKitSwift",
            dependencies: ["JGProgressHUD"],
            path: "UIKitSwift"
        )
    ]
)
