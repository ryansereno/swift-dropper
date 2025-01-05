<h1 align="center">Dropper- Real-World Photoshop Eyedropper Tool</h1>

<div align="center">
  <img src="./images/dropper.png" width="500" />
</div>

Dropper is an iOS app that helps artists match real-world colors with oil paint mixing ratios.

Using your device's camera or photos from your library, you can select any color and get the corresponding oil paint mixture needed to recreate it.

- SwiftUI frontend
- C++ color conversion engine
- Objective-C++ bridge layer for Swift-C++ interop

## Building the Project

1. Open Dropper.xcodeproj in Xcode
2. Ensure the bridging header is properly configured
3. Build and run on your iOS device or simulator

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+
- C++17 or later

## Acknowledgements

Special thanks to [Mixbox](https://github.com/scrtwpns/mixbox) for providing the basis for the color mixing algorithms used in this project.

And to [Zsolt M. Kovacs-Vajna](https://zsolt-kovacs.unibs.it/home) for his decade of research in color mixing algorithms.
