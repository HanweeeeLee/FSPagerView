// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "FSPagerView",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "FSPagerView", targets: ["FSPagerView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0"),
    ]
    targets: [
        .target(name: "FSPagerView", 
                      dependencies: [
                        .product(name: "RxSwift", package: "RxSwift"),
                        .product(name: "RxCocoa", package: "RxSwift")
                        ],
                path: "Sources", 
                exclude: ["FSPagerViewObjcCompat.h", "FSPagerViewObjcCompat.m"]
                ),
    ]
)
