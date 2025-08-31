import Photos
import Foundation
import Combine

class PhotoLibraryManager: ObservableObject {
    @Published var isScanning = false
    @Published var scanProgress: Double = 0.0
    @Published var totalPhotos = 0
    @Published var processedPhotos = 0
    @Published var groupCounts: [PhotoGroup: Int] = [:]
    @Published var otherCount = 0
    @Published var photosByGroup: [PhotoGroup: [PhotoAsset]] = [:]
    @Published var otherPhotos: [PhotoAsset] = []
    @Published var canResume = false // Resume yapılabilir mi?
    
    private var cancellables = Set<AnyCancellable>()
    private let persistenceManager = PersistenceManager.shared
    
    init() {
        loadPreviousResults()
    }
    
    func requestPhotoLibraryAccess() async -> Bool {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    func startScanning() async {
        if canResume {
            await resumeScanning()
            return
        }
        
        guard await requestPhotoLibraryAccess() else {
            await MainActor.run {
                self.isScanning = false
            }
            return
        }
        
        await MainActor.run {
            self.isScanning = true
            self.scanProgress = 0.0
            self.processedPhotos = 0
            self.resetAllData()
        }
        
        let fetchOptions = PHFetchOptions()
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        await MainActor.run {
            self.totalPhotos = allPhotos.count
        }
        
        for i in 0..<allPhotos.count {
            let asset = allPhotos.object(at: i)
            let photoAsset = PhotoAsset(asset: asset)
            
            await MainActor.run {
                self.processPhoto(photoAsset)
                self.processedPhotos = i + 1
                self.scanProgress = Double(i + 1) / Double(self.totalPhotos)
                
                // Her 50 fotoğrafta bir persistence kaydet
                if (i + 1) % 50 == 0 {
                    self.saveProgress()
                }
            }
        }
        
        await MainActor.run {
            self.isScanning = false
            self.canResume = false
            
            // Final state debug
            let totalGroups = photosByGroup.values.flatMap { $0 }.count
            let totalOther = otherPhotos.count
            print("PhotoLibraryManager: Final scanning state - Groups: \(totalGroups), Other: \(totalOther), Total: \(totalGroups + totalOther)")
            print("PhotoLibraryManager: Processed photos: \(processedPhotos), Total photos: \(totalPhotos)")
            
            scanProgress = 1.0
            
            self.saveAllResults()
        }
    }
    
    private func resetAllData() {
        groupCounts.removeAll()
        otherCount = 0
        photosByGroup.removeAll()
        otherPhotos.removeAll()
    }
    
    private func processPhoto(_ photoAsset: PhotoAsset) {
        if let group = photoAsset.group {
            groupCounts[group, default: 0] += 1
            photosByGroup[group, default: []].append(photoAsset)
        } else {
            otherCount += 1
            otherPhotos.append(photoAsset)
        }
    }
    
    private func saveProgress() {
        persistenceManager.saveScanProgress(
            processed: processedPhotos,
            total: totalPhotos,
            groupCounts: groupCounts,
            otherCount: otherCount
        )
    }
    
    private func saveAllResults() {
        
        if processedPhotos >= totalPhotos && totalPhotos > 0 {
            scanProgress = 1.0
        }
        
        // Her grubun fotoğraf sayısını logla
        for (group, photos) in photosByGroup {
            print("PhotoLibraryManager: Group \(group.rawValue) - \(photos.count) photos")
        }
        
        persistenceManager.saveScanProgress(
            processed: processedPhotos,
            total: totalPhotos,
            groupCounts: groupCounts,
            otherCount: otherCount
        )
        
        persistenceManager.saveGroupResults(
            photosByGroup: photosByGroup,
            otherPhotos: otherPhotos
        )
        persistenceManager.saveLastScanDate()
    }
    
    private func loadPreviousResults() {
        
        if let progressData = persistenceManager.loadScanProgress() {
            // Progress'i yükle ama henüz gösterme
            processedPhotos = progressData.processedPhotos
            totalPhotos = progressData.totalPhotos
            groupCounts = progressData.groupCounts
            otherCount = progressData.otherCount
            
            if processedPhotos < totalPhotos {
                canResume = true
            } else {
                canResume = false
            }
        } else {
            canResume = false
        }
        
        if let groupResults = persistenceManager.loadGroupResults() {
            
            // Photos'ları yüklemeye çalış
            Task {
                await loadPhotosFromIds(groupResults: groupResults)
               
                await MainActor.run {
                    // Progress'i photos'lara göre hesapla
                    let totalLoadedPhotos = photosByGroup.values.flatMap { $0 }.count + otherPhotos.count
                    if totalLoadedPhotos > 0 {
                        if processedPhotos >= totalPhotos {
                            scanProgress = 1.0
                        } else {
                            scanProgress = Double(processedPhotos) / Double(totalPhotos)
                        }
                    }
                    objectWillChange.send()
                }
            }
        } else {
            if totalPhotos > 0 {
                // Eğer scan tamamlanmışsa progress %100 yap
                if processedPhotos >= totalPhotos {
                    scanProgress = 1.0
                } else {
                    scanProgress = Double(processedPhotos) / Double(totalPhotos)
                }
            }
        }
    }
    
    private func loadPhotosFromIds(groupResults: GroupResultsData) async {
        // Background thread'de PHAsset'leri yükle
        await withTaskGroup(of: Void.self) { group in
            // Photo ID'lerinden PHAsset'leri bul ve PhotoAsset'leri oluştur
            for (photoGroup, photoIds) in groupResults.photoIdsByGroup {
                group.addTask {
                    var photos: [PhotoAsset] = []
                    
                    for photoId in photoIds {
                        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [photoId], options: nil).firstObject {
                            let photoAsset = PhotoAsset(asset: asset)
                            photos.append(photoAsset)
                            print("PhotoLibraryManager: Photo loaded for group \(photoGroup.rawValue) - ID: \(photoId)")
                        } else {
                            print("PhotoLibraryManager: Warning - Photo with ID \(photoId) not found")
                        }
                    }
                    await MainActor.run {
                        self.photosByGroup[photoGroup] = photos
                    }
                }
            }
        
            group.addTask {
                var otherPhotos: [PhotoAsset] = []
                
                for photoId in groupResults.otherPhotoIds {
                    if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [photoId], options: nil).firstObject {
                        let photoAsset = PhotoAsset(asset: asset)
                        otherPhotos.append(photoAsset)
                        print("PhotoLibraryManager: Other photo loaded - ID: \(photoId)")
                    } else {
                        print("PhotoLibraryManager: Warning - Other photo with ID \(photoId) not found")
                    }
                }
                await MainActor.run {
                    self.otherPhotos = otherPhotos
                }
            }
        }

        await MainActor.run {
            let totalGroups = photosByGroup.values.flatMap { $0 }.count
            let totalOther = otherPhotos.count
        }
    }
    
    // MARK: - Resume Scanning
    func resumeScanning() async {
        guard !isScanning && canResume else {
            return 
        }
        let totalLoadedPhotos = photosByGroup.values.flatMap { $0 }.count + otherPhotos.count
        print("PhotoLibraryManager: Total loaded photos: \(totalLoadedPhotos)")
        
        if totalLoadedPhotos == 0 {
            if let groupResults = persistenceManager.loadGroupResults() {
                await loadPhotosFromIds(groupResults: groupResults)
            }
        }
        await continueScanning(from: processedPhotos, total: totalPhotos)
    }
    
    private func continueScanning(from startIndex: Int, total: Int) async {
        guard await requestPhotoLibraryAccess() else { return }
        
        await MainActor.run {
            self.isScanning = true
            self.canResume = false
        }
        
        let fetchOptions = PHFetchOptions()
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        for i in startIndex..<allPhotos.count {
            let asset = allPhotos.object(at: i)
            let photoAsset = PhotoAsset(asset: asset)
            
            await MainActor.run {
                self.processPhoto(photoAsset)
                self.processedPhotos = i + 1
                self.scanProgress = Double(i + 1) / Double(self.totalPhotos)
                
                if (i + 1) % 50 == 0 {
                    self.saveProgress()
                }
            }
        }
        await MainActor.run {
            self.isScanning = false
            self.canResume = false
            self.saveAllResults()
        }
    }
}

