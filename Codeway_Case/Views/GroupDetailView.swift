import SwiftUI
import Photos
import UIKit

struct GroupDetailView: View {
    let groupItem: GroupItem
    let photos: [PhotoAsset]
    
    @State private var selectedPhotoIndex: Int?
    @State private var showingImageDetail = false
    @State private var visiblePhotoIndices: Set<Int> = []
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 8) {
                ForEach(photos.indices, id: \.self) { index in
                    let photo = photos[index]
                    PhotoThumbnailView(photo: photo, isVisible: visiblePhotoIndices.contains(index))
                        .onTapGesture {
                            selectedPhotoIndex = index
                            showingImageDetail = true
                        }
                        .onAppear {
                            visiblePhotoIndices.insert(index)
                            preloadNextPhotos(from: index)
                        }
                        .onDisappear {
                            visiblePhotoIndices.remove(index)
                        }
                }
            }
            .padding(.horizontal, 8)
        }
        .navigationTitle(groupItem.displayName)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingImageDetail) {
            if let selectedIndex = selectedPhotoIndex {
                ImageDetailView(
                    photos: photos,
                    initialIndex: selectedIndex
                )
            }
        }
    }
    
    // MARK: - Preloading
    private func preloadNextPhotos(from index: Int) {
        let preloadCount = 5
        
        for i in 1...preloadCount {
            let nextIndex = index + i
            if nextIndex < photos.count {
                let photo = photos[nextIndex]
                Task {
                    await preloadPhoto(photo)
                }
            }
        }
    }
    
    private func preloadPhoto(_ photo: PhotoAsset) async {
        await withCheckedContinuation { continuation in
            photo.loadFastPreview { _ in
                continuation.resume()
            }
        }
    }
}

// MARK: - Photo Thumbnail View
struct PhotoThumbnailView: View {
    let photo: PhotoAsset
    let isVisible: Bool
    @State private var thumbnailImage: UIImage?
    @State private var isLoading = true
    @State private var loadError = false
    
    var body: some View {
        ZStack {
            if let image = thumbnailImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                
                if isLoading {
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        Text("Loading...")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                } else if loadError {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.gray)
                            .font(.title3)
                        Text("Failed")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                } else {
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
            }
        }
        .frame(height: 120)
        .clipped()
        .cornerRadius(8)
        .onAppear {
            if isVisible {
                loadThumbnail()
            }
        }
        .onChange(of: isVisible) { newValue in
            if newValue && thumbnailImage == nil {
                loadThumbnail()
            }
        }
        .onDisappear {
            if !isVisible {
                thumbnailImage = nil
                isLoading = false
                loadError = false
            }
        }
    }
    
    private func loadThumbnail() {
        isLoading = true
        loadError = false
        thumbnailImage = nil
        
        photo.loadFastPreview { fastImage in
            DispatchQueue.main.async {
                if let fastImage = fastImage {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        thumbnailImage = fastImage
                    }
                    isLoading = false
                }
            }
            
            photo.loadThumbnail { qualityImage in
                DispatchQueue.main.async {
                    if let qualityImage = qualityImage {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            thumbnailImage = qualityImage
                        }
                    } else {
                        loadError = true
                    }
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Image Detail View
struct ImageDetailView: View {
    let photos: [PhotoAsset]
    let initialIndex: Int
    @State private var currentIndex: Int
    @State private var visiblePhotoIndices: Set<Int> = []
    
    init(photos: [PhotoAsset], initialIndex: Int) {
        self.photos = photos
        self.initialIndex = initialIndex
        self._currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(photos.indices, id: \.self) { index in
                PhotoDetailView(
                    photo: photos[index],
                    index: index,
                    isCurrentPhoto: index == currentIndex
                )
                .tag(index)
                .onAppear {
                    visiblePhotoIndices.insert(index)
                    preloadNextPhotos(from: index)
                }
                .onDisappear {
                    visiblePhotoIndices.remove(index)
                    print("ImageDetailView: Photo \(index) disappeared, visiblePhotos: \(visiblePhotoIndices)")
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Photo \(currentIndex + 1) of \(photos.count)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootViewController = window.rootViewController {
                        rootViewController.dismiss(animated: true)
                    }
                }
            }
        }
        .onChange(of: currentIndex) { newIndex in
            if newIndex < photos.count {
                let newPhoto = photos[newIndex]
                preloadPhoto(newPhoto)
            }
        }
    }
    
    // MARK: - Preloading
    private func preloadNextPhotos(from index: Int) {
        let nextIndices = (index + 1)..<min(index + 6, photos.count)
        
        for nextIndex in nextIndices {
            let photo = photos[nextIndex]
            preloadPhoto(photo)
        }
    }
    
    private func preloadPhoto(_ photo: PhotoAsset) {
        Task {
            await withCheckedContinuation { continuation in
                photo.loadThumbnail { _ in
                    continuation.resume()
                }
            }
        }
    }
}

// MARK: - Photo Detail View
struct PhotoDetailView: View {
    let photo: PhotoAsset
    let index: Int
    let isCurrentPhoto: Bool
    @State private var fullImage: UIImage?
    @State private var isLoading = true
    @State private var loadError = false
    
    var body: some View {
        ZStack {
            if let image = fullImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .transition(.opacity)
            } else {
                Color.black
                    .ignoresSafeArea()
                
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Loading photo \(index + 1)...")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                } else if loadError {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                        Text("Failed to load photo")
                            .foregroundColor(.white)
                            .font(.caption)
                        Button("Retry") {
                            loadFullImage()
                        }
                        .foregroundColor(.blue)
                    }
                } else {
                    Image(systemName: "photo")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                }
            }
        }
        .onAppear {
            loadFullImage()
        }
        .onChange(of: isCurrentPhoto) { newValue in
            if newValue && fullImage == nil {
                loadFullImage()
            }
        }
        .onDisappear {
            // Memory cleanup - sadece off-screen olduğunda
            if !isCurrentPhoto {
                print("PhotoDetailView: Photo \(index) disappeared, cleaning up")
                fullImage = nil
                isLoading = false
                loadError = false
            }
        }
    }
    
    private func loadFullImage() {
        print("PhotoDetailView: Loading full image for photo \(index)")
        isLoading = true
        loadError = false
        fullImage = nil
        
        // Önce hızlı preview yükle
        photo.loadThumbnail { previewImage in
            DispatchQueue.main.async {
                if let previewImage = previewImage {
                    print("PhotoDetailView: Preview loaded for photo \(index)")
                    withAnimation(.easeInOut(duration: 0.3)) {
                        fullImage = previewImage
                    }
                    isLoading = false
                }
            }
            
            // Sonra full quality image yükle
            photo.loadFullImage { qualityImage in
                DispatchQueue.main.async {
                    if let qualityImage = qualityImage {
                        print("PhotoDetailView: Full image loaded for photo \(index)")
                        withAnimation(.easeInOut(duration: 0.3)) {
                            fullImage = qualityImage
                        }
                    } else {
                        print("PhotoDetailView: Failed to load full image for photo \(index)")
                        loadError = true
                    }
                    isLoading = false
                }
            }
        }
    }
}
