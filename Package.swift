// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Saltedge-iOS-Swift",
    products: [
       .library(name: "SaltEdge", targets: ["SaltEdge"])
   ],
   targets: [
       .target(
           name: "SaltEdge",
           path: "saltedge-ios-swift/Classes"
       )
   ]
)