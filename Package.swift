// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swiftcompiler",
  platforms: [.macOS(.v10_15)],
  dependencies: [
    .package(url: "https://github.com/realm/SwiftLint.git", from: "0.54.0"),
    .package(url: "https://github.com/apple/swift-format.git", from: "509.0.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .executableTarget(
      name: "swiftcompiler", exclude: ["Tests"]),
    .testTarget(
      name: "swiftcompilerTests",
      dependencies: ["swiftcompiler"],
      exclude: ["main.swift", "Models", "Utils", "Tokenizer.swift"],
      sources: ["Tests"])
  ]
)
