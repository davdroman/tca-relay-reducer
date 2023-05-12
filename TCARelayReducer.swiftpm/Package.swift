// swift-tools-version: 5.7

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "TCARelayReducer",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "TCARelayReducer",
            targets: ["AppModule"],
            bundleIdentifier: "mn.dro.TCARelayReducer",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .leaf),
            accentColor: .presetColor(.indigo),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/davdroman/swift-composable-architecture", .branch("navigation-beta-full-scope-2")),
        .package(url: "https://github.com/davdroman/swiftui-navigation-transitions", "0.7.2"..<"1.0.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms", "0.0.4"..<"1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-nonempty", "0.4.0"..<"1.0.0"),
        .package(url: "https://github.com/apple/swift-collections", "1.0.0"..<"2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "NavigationTransitions", package: "swiftui-navigation-transitions"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "NonEmpty", package: "swift-nonempty"),
                .product(name: "OrderedCollections", package: "swift-collections")
            ],
            path: "."
        )
    ]
)
