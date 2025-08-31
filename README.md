
# 📱 Photo Library Scanner & Grouping App

This iOS application scans the device's photo library, generates a deterministic value for each photo, and groups them based on these values.

## ✨ Features

- **📸 Photo Scanning**: Scans all photos using PHAsset
- **🔢 Deterministic Grouping**: Generates 0-1 hash value for each photo
- **📊 20 Different Groups**: 20 separate ranges with PhotoGroup enum
- **⚡ Real-time Updates**: Live updates during scanning
- **📈 Progress Bar**: Progress bar showing scan progress
- **💾 Persistence**: Scan progress and results saved with JSON
- **🔄 Resume**: Continues from where it left off after app restart

## 🏗️ Architecture

- **MVVM Architecture**: Following SOLID principles
- **UIKit + SwiftUI**: Hybrid approach
- **Combine Framework**: Reactive programming
- **PhotoKit**: Photo library access
- **Async/Await**: Modern concurrency

## 📱 Screens

### 🏠 Home Screen (UIKit)
- Group display with UICollectionView
- Separate cell for each group
- Empty groups are hidden
- Scan progress bar

### 📋 Group Detail Screen (SwiftUI)
- All photos in selected group
- Performance-optimized with LazyVGrid
- Thumbnail caching
- Preloading mechanism

### 🖼️ Image Detail Screen (SwiftUI)
- Full-size photo display
- Swipe navigation (left/right)
- Smooth transitions with TabView

## 🚀 Installation

1. **Clone the repository:**
```bash
git clone https://github.com/SabriEyyubi/PhotoManagerGroupingApp.git
cd PhotoManagerGroupingApp
```

2. **Open with Xcode:**
```bash
open Codeway_Case.xcodeproj
```

3. **Build and run:**
- iOS 15.0+ target
- Simulator or real device

## 📋 Requirements

- **iOS**: 15.0+
- **Xcode**: 14.0+
- **Swift**: 5.7+
- **Dependencies**: Only Auto Layout libraries (not used)

## 🔧 Technical Details

### PhotoGroup Enum
```swift
enum PhotoGroup: String, CaseIterable, Codable {
    case a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t
    
    var range: ClosedRange<Double> {
        // 20 different range definitions
    }
}
```

### PHAsset Extension
```swift
extension PHAsset {
    func reliableHash() -> Double {
        // Deterministic hash calculation
        // Includes simulated processing delay
    }
}
```

### Persistence
- **Scan Progress**: UserDefaults + JSON
- **Group Results**: Photo IDs with JSON
- **Resume Logic**: canResume flag

## 🎯 Performance Optimizations

- **Image Caching**: Memory caching with NSCache
- **Lazy Loading**: Only visible photos are loaded
- **Preloading**: Next 5 photos loaded in background
- **Thumbnail Optimization**: Fast format + quality format
- **Memory Management**: Off-screen cleanup

 ## Known Bugs
- When first image detail open, image does not show up. After secong image click image show up and swipe works.
- When user scan and kill app and re-enter progress saved but sometimes progress bar color UI does not update. 

## 📊 Case Study Requirements

✅ **Core Requirements:**
- Photo scanning with PHAsset
- Deterministic hash generation (helper code used)
- Grouping with PhotoGroup enum
- Progressive scanning results
- Horizontal progress bar + percentage

✅ **Bonus Requirements:**
- Scan progress persistence
- Grouping results persistence
- Resume functionality

✅ **UI Requirements:**
- UIKit Home Screen (UICollectionView)
- SwiftUI Group Detail (UIHostingController)
- SwiftUI Image Detail (swipe navigation)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Create Pull Request

## 📄 License

This project is prepared for Codeway iOS Developer Case Study.

## 👨‍💻 Developer

- **Case Study**: Codeway iOS Developer
- **Architecture**: MVVM + SOLID Principles
- **UI Framework**: UIKit + SwiftUI Hybrid
- **Performance**: Optimized for large photo libraries

---
