import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var photoManager = PhotoLibraryManager()
    @Published var groups: [GroupItem] = []
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        photoManager.$photosByGroup
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateGroups()
            }
            .store(in: &cancellables)
        
        photoManager.$otherPhotos
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateGroups()
            }
            .store(in: &cancellables)
        
        photoManager.$groupCounts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateGroups()
            }
            .store(in: &cancellables)
        
        photoManager.$otherCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateGroups()
            }
            .store(in: &cancellables)
        
        // Progress tracking için
        photoManager.$isScanning
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isScanning in
            }
            .store(in: &cancellables)
        
        photoManager.$scanProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
            }
            .store(in: &cancellables)
    }
    
    private func updateGroups() {
        var newGroups: [GroupItem] = []
        
        for group in PhotoGroup.allCases {
            if let photos = photoManager.photosByGroup[group], !photos.isEmpty {
                // Photos varsa photos'a göre
                let count = photos.count
                newGroups.append(GroupItem(group: group, count: count))
            } else if let count = photoManager.groupCounts[group], count > 0 {
                // Photos yoksa counts'a göre
                newGroups.append(GroupItem(group: group, count: count))
            }
        }
        
        // Others grubunu ekle
        if !photoManager.otherPhotos.isEmpty {
            let count = photoManager.otherPhotos.count
            newGroups.append(GroupItem(group: nil, count: count))
        } else if photoManager.otherCount > 0 {
            newGroups.append(GroupItem(group: nil, count: photoManager.otherCount))
        }
        groups = newGroups
        
        // Debug: Her grubun durumunu kontrol et
        for group in groups {
            if let photoGroup = group.group {
                let photos = photoManager.photosByGroup[photoGroup] ?? []
                let count = photoManager.groupCounts[photoGroup] ?? 0
            } else {
                let photos = photoManager.otherPhotos
                let count = photoManager.otherCount
            }
        }
    }
    
    func startScanning() {
        Task {
            await photoManager.startScanning()
        }
    }
}

// MARK: - GroupItem
struct GroupItem: Identifiable {
    let id = UUID()
    let group: PhotoGroup?
    let count: Int
    
    var displayName: String {
        if let group = group {
            return "Group \(group.rawValue.uppercased())"
        } else {
            return "Others"
        }
    }
    
    var color: String {
        if let group = group {
            // Her grup için farklı renk
            let colors = ["red", "blue", "green", "orange", "purple", "pink", "yellow", "cyan", "magenta", "brown"]
            let index = PhotoGroup.allCases.firstIndex(of: group) ?? 0
            return colors[index % colors.count]
        } else {
            return "gray"
        }
    }
}
