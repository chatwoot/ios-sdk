// swift-tools-version: 5.9
import PackageDescription
let package = Package(name: "ChatwootSDK", platforms: [.iOS(.v17)], products: [.library(name: "ChatwootSDK", targets: ["ChatwootSDK"])], targets: [.target(name: "ChatwootSDK", resources: [.process("Resources")])])
