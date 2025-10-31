// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/10/2025.
//  All code (c) 2025 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

// swift-tools-version:6.2

import PackageDescription

let package = Package(
  name: "JSONMerge",

  platforms: [
    .macOS(.v15)
  ],

  products: [
    .executable(
      name: "json-merge",
      targets: ["JSONMerge"]
    )
  ],

  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    .package(url: "https://github.com/elegantchaos/Matchable.git", from: "1.0.0"),
  ],

  targets: [
    .executableTarget(
      name: "JSONMerge",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]
    ),
    .testTarget(
      name: "JSONMergeTests",
      dependencies: [
        "JSONMerge",
        .product(name: "Matchable", package: "Matchable"),
      ]
    ),
  ]
)
