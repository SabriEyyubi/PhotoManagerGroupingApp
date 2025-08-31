import UIKit
import SwiftUI

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = HomeViewModel()
    private var collectionView: UICollectionView!
    private var progressView: UIProgressView!
    private var progressLabel: UILabel!
    private var scanButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Photo Groups"
        
        setupProgressView()
        setupScanButton()
        setupCollectionView()
        setupConstraints()
    }
    
    private func setupProgressView() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0.0
        progressView.isHidden = false // Başlangıçta görünür yap
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .systemGray5
        view.addSubview(progressView)
        
        progressLabel = UILabel()
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.text = "Ready to scan"
        progressLabel.textAlignment = .center
        progressLabel.font = .systemFont(ofSize: 14)
        progressLabel.textColor = .secondaryLabel
        view.addSubview(progressLabel)
    }
    
    private func setupScanButton() {
        scanButton = UIButton(type: .system)
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.setTitle("Start Scanning", for: .normal)
        scanButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        scanButton.backgroundColor = .systemBlue
        scanButton.setTitleColor(.white, for: .normal)
        scanButton.layer.cornerRadius = 12
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
        view.addSubview(scanButton)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GroupCell.self, forCellWithReuseIdentifier: "GroupCell")
        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Progress View
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            // Progress Label
            progressLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            progressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Scan Button
            scanButton.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 16),
            scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanButton.widthAnchor.constraint(equalToConstant: 200),
            scanButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Collection View
            collectionView.topAnchor.constraint(equalTo: scanButton.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        viewModel.photoManager.$isScanning
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isScanning in
                self?.updateButtonState(isScanning: isScanning)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.photoManager.$scanProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.updateProgressBar(progress: progress)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.photoManager.$processedPhotos
            .combineLatest(viewModel.photoManager.$totalPhotos)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] processed, total in
                self?.updateProgressLabel(processed: processed, total: total)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.photoManager.$canResume
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canResume in
                self?.updateButtonText(canResume: canResume)
            }
            .store(in: &viewModel.cancellables)
        
        // Groups güncellemelerini dinle
        viewModel.$groups
            .receive(on: DispatchQueue.main)
            .sink { [weak self] groups in
                self?.collectionView.reloadData()
            }
            .store(in: &viewModel.cancellables)
    }
    
    private func updateButtonState(isScanning: Bool) {
        scanButton.isEnabled = !isScanning
        scanButton.alpha = isScanning ? 0.6 : 1.0
    }
    
    private func updateProgressBar(progress: Double) {
        progressView.progress = Float(progress)
    }
    
    private func updateProgressLabel(processed: Int, total: Int) {
        if total > 0 {
            let percentage = Int((Double(processed) / Double(total)) * 100)
            progressLabel.text = "Scanning photos: \(percentage)% (\(processed.formatted())/\(total.formatted()))"
        } else {
            progressLabel.text = "Ready to scan"
        }
    }
    
    private func updateButtonText(canResume: Bool) {
        if canResume {
            scanButton.setTitle("Resume Scanning", for: .normal)
            scanButton.backgroundColor = .systemOrange
        } else {
            scanButton.setTitle("Start Scanning", for: .normal)
            scanButton.backgroundColor = .systemBlue
        }
    }
    
    // MARK: - Actions
    @objc private func scanButtonTapped() {
        
        // Button'ı devre dışı bırak
        scanButton.isEnabled = false
        scanButton.alpha = 0.6
        scanButton.setTitle("Scanning...", for: .disabled)
        
        viewModel.startScanning()
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCell", for: indexPath) as! GroupCell
        let groupItem = viewModel.groups[indexPath.item]
        cell.configure(with: groupItem)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let groupItem = viewModel.groups[indexPath.item]
        
        if let group = groupItem.group {
            let photos = viewModel.photoManager.photosByGroup[group] ?? []
            let groupDetailView = GroupDetailView(groupItem: groupItem, photos: photos)
            let hostingController = UIHostingController(rootView: groupDetailView)
            navigationController?.pushViewController(hostingController, animated: true)
        } else {
            let photos = viewModel.photoManager.otherPhotos
            let groupDetailView = GroupDetailView(groupItem: groupItem, photos: photos)
            let hostingController = UIHostingController(rootView: groupDetailView)
            navigationController?.pushViewController(hostingController, animated: true)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 48) / 2
        return CGSize(width: width, height: 120)
    }
}
