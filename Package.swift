// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SlavicWallpapers",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "SlavicWallpapers", targets: ["SlavicWallpapers"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "SlavicWallpapers",
            dependencies: [],
            path: "SlavicWallpapers"
        ),
        .testTarget(
            name: "SlavicWallpapersTests",
            dependencies: ["SlavicWallpapers"],
            path: "SlavicWallpapersTests"
        ),
        .testTarget(
            name: "SlavicWallpapersUITests",
            dependencies: ["SlavicWallpapers"],
            path: "SlavicWallpapersUITests"
        )
    ]
) 