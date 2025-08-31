import Foundation

class PersistenceManager: ObservableObject {
    static let shared = PersistenceManager()
    
    private let scanProgressKey = "scanProgress"
    private let groupResultsKey = "groupResults"
    private let lastScanDateKey = "lastScanDate"
    
    private init() {}
    
    // MARK: - Scan Progress Persistence
    func saveScanProgress(processed: Int, total: Int, groupCounts: [PhotoGroup: Int], otherCount: Int) {
        print("PersistenceManager: Saving scan progress - \(processed)/\(total)")
        print("PersistenceManager: Calculated progress: \(Double(processed) / Double(total))")
        
        let progressData = ScanProgressData(
            processedPhotos: processed,
            totalPhotos: total,
            groupCounts: groupCounts,
            otherCount: otherCount,
            timestamp: Date()
        )
        
        if let encoded = try? JSONEncoder().encode(progressData) {
            UserDefaults.standard.set(encoded, forKey: scanProgressKey)
            print("PersistenceManager: Scan progress saved successfully")
        } else {
            print("PersistenceManager: Failed to encode scan progress")
        }
    }
    
    func loadScanProgress() -> ScanProgressData? {
        guard let data = UserDefaults.standard.data(forKey: scanProgressKey) else {
            print("PersistenceManager: No scan progress data found")
            return nil
        }
        
        do {
            let progressData = try JSONDecoder().decode(ScanProgressData.self, from: data)
            print("PersistenceManager: Scan progress loaded successfully")
            print("PersistenceManager: Loaded data - \(progressData.processedPhotos)/\(progressData.totalPhotos)")
            print("PersistenceManager: Loaded progress: \(Double(progressData.processedPhotos) / Double(progressData.totalPhotos))")
            return progressData
        } catch {
            print("PersistenceManager: Failed to decode scan progress - \(error)")
            return nil
        }
    }
    
    // MARK: - Group Results Persistence
    func saveGroupResults(photosByGroup: [PhotoGroup: [PhotoAsset]], otherPhotos: [PhotoAsset]) {
        print("PersistenceManager: Saving group results...")
        
        // PhotoAsset'leri sadece localIdentifier olarak kaydet
        let simplifiedPhotosByGroup = photosByGroup.mapValues { photos in
            photos.map { $0.id }
        }
        let simplifiedOtherPhotos = otherPhotos.map { $0.id }
        
        print("PersistenceManager: Simplified data - Groups: \(simplifiedPhotosByGroup.count), Other: \(simplifiedOtherPhotos.count)")
        
        let groupResults = GroupResultsData(
            photoIdsByGroup: simplifiedPhotosByGroup,
            otherPhotoIds: simplifiedOtherPhotos,
            timestamp: Date()
        )
        
        if let encoded = try? JSONEncoder().encode(groupResults) {
            UserDefaults.standard.set(encoded, forKey: groupResultsKey)
            print("PersistenceManager: Group results saved successfully")
        } else {
            print("PersistenceManager: Failed to encode group results")
        }
    }
    
    func loadGroupResults() -> GroupResultsData? {
        guard let data = UserDefaults.standard.data(forKey: groupResultsKey) else {
            print("PersistenceManager: No group results data found")
            return nil
        }
        
        do {
            let groupResults = try JSONDecoder().decode(GroupResultsData.self, from: data)
            print("PersistenceManager: Group results loaded successfully")
            print("PersistenceManager: Loaded data - Groups: \(groupResults.photoIdsByGroup.count), Other: \(groupResults.otherPhotoIds.count)")
            return groupResults
        } catch {
            print("PersistenceManager: Failed to decode group results - \(error)")
            return nil
        }
    }
    
    // MARK: - Last Scan Date
    func saveLastScanDate() {
        UserDefaults.standard.set(Date(), forKey: lastScanDateKey)
    }
    
    func getLastScanDate() -> Date? {
        return UserDefaults.standard.object(forKey: lastScanDateKey) as? Date
    }
    
    // MARK: - Clear Data
    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: scanProgressKey)
        UserDefaults.standard.removeObject(forKey: groupResultsKey)
        UserDefaults.standard.removeObject(forKey: lastScanDateKey)
        print("PersistenceManager: All data cleared")
    }
}

// MARK: - Data Models
struct ScanProgressData: Codable {
    let processedPhotos: Int
    let totalPhotos: Int
    let groupCounts: [PhotoGroup: Int]
    let otherCount: Int
    let timestamp: Date
}

struct GroupResultsData: Codable {
    let photoIdsByGroup: [PhotoGroup: [String]] // Sadece localIdentifier'ları kaydet
    let otherPhotoIds: [String]
    let timestamp: Date
}
