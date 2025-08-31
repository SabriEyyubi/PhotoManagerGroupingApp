import Photos
import Foundation
import UIKit

struct PhotoAsset: Identifiable {
    let id: String
    let asset: PHAsset
    let hashValue: Double
    let group: PhotoGroup?
    
    // Unique ID oluştur
    private static var idCounter = 0
    
    // Image cache
    private static let imageCache = NSCache<NSString, UIImage>()
    private static let thumbnailCache = NSCache<NSString, UIImage>()
    
    init(asset: PHAsset) {
        // Unique ID
        PhotoAsset.idCounter += 1
        self.id = "\(asset.localIdentifier)_\(PhotoAsset.idCounter)"
        
        self.asset = asset
        self.hashValue = asset.reliableHash()
        self.group = PhotoGroup.group(for: self.hashValue)
    }
    
    // MARK: - Image Loading Extensions
    func loadThumbnail(size: CGSize = CGSize(width: 300, height: 300), completion: @escaping (UIImage?) -> Void) {
        let cacheKey = "\(asset.localIdentifier)_\(size.width)x\(size.height)"
        if let cachedImage = PhotoAsset.thumbnailCache.object(forKey: cacheKey as NSString) {
            completion(cachedImage)
            return
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat // Daha hızlı
        options.resizeMode = .fast // Daha hızlı
        options.isNetworkAccessAllowed = false // Sadece local
        options.isSynchronous = false
        
        let targetSize = CGSize(width: size.width * 1.5, height: size.height * 1.5) // Size'ı azalt
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                if let image = image {
                    PhotoAsset.thumbnailCache.setObject(image, forKey: cacheKey as NSString)
                }
                completion(image)
            }
        }
    }
    
    func loadFullImage(completion: @escaping (UIImage?) -> Void) {
        let cacheKey = "\(asset.localIdentifier)_full"
        if let cachedImage = PhotoAsset.imageCache.object(forKey: cacheKey as NSString) {
            completion(cachedImage)
            return
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        
        options.progressHandler = { progress, error, stop, info in
            print("Image loading progress: \(progress)")
        }
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                if let image = image {
                    PhotoAsset.imageCache.setObject(image, forKey: cacheKey as NSString)
                }
                completion(image)
            }
        }
    }
    
    func loadFastPreview(completion: @escaping (UIImage?) -> Void) {
        let cacheKey = "\(asset.localIdentifier)_preview"
        if let cachedImage = PhotoAsset.thumbnailCache.object(forKey: cacheKey as NSString) {
            completion(cachedImage)
            return
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = false
        options.isSynchronous = false
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: 150, height: 150), // Size'ı azalt
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                if let image = image {
                    PhotoAsset.thumbnailCache.setObject(image, forKey: cacheKey as NSString)
                }
                completion(image)
            }
        }
    }
    
    // MARK: - Cache Management
    static func clearCache() {
        imageCache.removeAllObjects()
        thumbnailCache.removeAllObjects()
    }
    
    static func clearThumbnailCache() {
        thumbnailCache.removeAllObjects()
    }
}
