# Codeway iOS Developer Case Study

## 📱 Photo Library Scanner & Grouping App

Bu iOS uygulaması, cihazın fotoğraf kütüphanesini tarar, her fotoğraf için deterministik bir değer üretir ve bu değerlere göre fotoğrafları gruplar.

## ✨ Özellikler

- **📸 Fotoğraf Tarama**: PHAsset kullanarak tüm fotoğrafları tarar
- **🔢 Deterministik Gruplama**: Her fotoğraf için 0-1 arası hash değeri üretir
- **📊 20 Farklı Grup**: PhotoGroup enum'ı ile 20 ayrı aralık
- **⚡ Gerçek Zamanlı Güncelleme**: Tarama sırasında canlı güncelleme
- **📈 Progress Bar**: Tarama ilerlemesini gösteren progress bar
- **💾 Persistence**: Tarama ilerlemesi ve sonuçları JSON ile saklanır
- **🔄 Resume**: Uygulama kapatılıp açıldığında kaldığı yerden devam eder

## 🏗️ Mimari

- **MVVM Architecture**: SOLID prensiplerine uygun
- **UIKit + SwiftUI**: Hybrid yaklaşım
- **Combine Framework**: Reactive programming
- **PhotoKit**: Fotoğraf kütüphanesi erişimi
- **Async/Await**: Modern concurrency

## 📱 Ekranlar

### 🏠 Home Screen (UIKit)
- UICollectionView ile grup gösterimi
- Her grup için ayrı cell
- Boş gruplar gizlenir
- Tarama progress bar'ı

### 📋 Group Detail Screen (SwiftUI)
- Seçilen gruptaki tüm fotoğraflar
- LazyVGrid ile performanslı gösterim
- Thumbnail caching
- Preloading mekanizması

### 🖼️ Image Detail Screen (SwiftUI)
- Tam boyut fotoğraf gösterimi
- Swipe navigation (sola/sağa)
- TabView ile smooth geçişler

## 🚀 Kurulum

1. **Repository'yi klonlayın:**
```bash
git clone [repository-url]
cd Codeway_Case
```

2. **Xcode ile açın:**
```bash
open Codeway_Case.xcodeproj
```

3. **Build edin ve çalıştırın:**
- iOS 15.0+ hedef
- Simulator veya gerçek cihaz

## 📋 Gereksinimler

- **iOS**: 15.0+
- **Xcode**: 14.0+
- **Swift**: 5.7+
- **Dependencies**: Sadece Auto Layout kütüphaneleri (kullanılmadı)

## 🔧 Teknik Detaylar

### PhotoGroup Enum
```swift
enum PhotoGroup: String, CaseIterable, Codable {
    case a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t
    
    var range: ClosedRange<Double> {
        // 20 farklı aralık tanımı
    }
}
```

### PHAsset Extension
```swift
extension PHAsset {
    func reliableHash() -> Double {
        // Deterministik hash hesaplama
        // Simulated processing delay dahil
    }
}
```

### Persistence
- **Scan Progress**: UserDefaults + JSON
- **Group Results**: Photo ID'leri ile JSON
- **Resume Logic**: canResume flag ile

## 🎯 Performans Optimizasyonları

- **Image Caching**: NSCache ile memory caching
- **Lazy Loading**: Sadece görünür fotoğraflar yüklenir
- **Preloading**: Sonraki 5 fotoğraf background'da yüklenir
- **Thumbnail Optimization**: Fast format + quality format
- **Memory Management**: Off-screen cleanup

## 📊 Case Study Gereksinimleri

✅ **Core Requirements:**
- PHAsset ile fotoğraf tarama
- Deterministik hash üretimi (helper code kullanıldı)
- PhotoGroup enum ile gruplama
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

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit edin (`git commit -m 'Add amazing feature'`)
4. Push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje Codeway iOS Developer Case Study için hazırlanmıştır.

## 👨‍💻 Geliştirici

- **Case Study**: Codeway iOS Developer
- **Architecture**: MVVM + SOLID Principles
- **UI Framework**: UIKit + SwiftUI Hybrid
- **Performance**: Optimized for large photo libraries

---

**Dream, measure, build, repeat** 🚀
