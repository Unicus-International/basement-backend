// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BasementDriver",
  platforms: [
    .macOS(.v10_13),
  ],
  dependencies: [
    .package(url: "https://github.com/PerfectlySoft/Perfect-Crypto.git",     from: "3.0.0"),
    .package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
    .package(url: "https://github.com/PerfectlySoft/Perfect-PostgreSQL.git", from: "3.0.0"),
    .package(url: "https://github.com/PerfectlySoft/Perfect-Session.git",    from: "3.0.0"),
  ],
  targets: [
    .target(
      name: "basement",
      dependencies: [
        "BasementDriver",
      ]
    ),
    .target(
      name: "BasementDriver",
      dependencies: [
        "PerfectCrypto",
        "PerfectHTTPServer",
        "PerfectPostgreSQL",
        "PerfectSession",
      ]
    ),
    .testTarget(
      name: "BasementDriverTests",
      dependencies: ["BasementDriver"]
    ),
  ]
)
