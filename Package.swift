// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BasementDriver",
  dependencies: [
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
