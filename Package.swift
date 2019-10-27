// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "UIKitSwift",
    platforms: [.iOS("11.0")],
    products: [
        .library(name: "UIKitSwift", targets: ["UIKitSwift"])
    ],
    targets: [
        .target(
            name: "UIKitSwift",
            path: "UIKitSwift",
            linkerSettings: [
                .linkedFramework("UIKit")
            ]
        )
    ]
)
