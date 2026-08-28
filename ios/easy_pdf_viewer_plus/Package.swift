// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "easy_pdf_viewer_plus",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "easy-pdf-viewer-plus", targets: ["easy_pdf_viewer_plus"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "easy_pdf_viewer_plus",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            cSettings: [
                .headerSearchPath("include/easy_pdf_viewer_plus")
            ]
        )
    ]
)
