import UIKit

class GroupCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .systemBlue
        label.textAlignment = .center
        return label
    }()
    
    private let colorIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        return view
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(countLabel)
        containerView.addSubview(colorIndicator)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Color Indicator
            colorIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            colorIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            colorIndicator.widthAnchor.constraint(equalToConstant: 16),
            colorIndicator.heightAnchor.constraint(equalToConstant: 16),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: colorIndicator.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            // Count Label
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            countLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            countLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            countLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    func configure(with groupItem: GroupItem) {
        titleLabel.text = groupItem.displayName
        countLabel.text = "\(groupItem.count)"
        
        switch groupItem.color {
        case "red":
            colorIndicator.backgroundColor = .systemRed
        case "blue":
            colorIndicator.backgroundColor = .systemBlue
        case "green":
            colorIndicator.backgroundColor = .systemGreen
        case "orange":
            colorIndicator.backgroundColor = .systemOrange
        case "purple":
            colorIndicator.backgroundColor = .systemPurple
        case "pink":
            colorIndicator.backgroundColor = .systemPink
        case "yellow":
            colorIndicator.backgroundColor = .systemYellow
        case "cyan":
            colorIndicator.backgroundColor = .systemCyan
        case "magenta":
            colorIndicator.backgroundColor = .systemIndigo
        case "brown":
            colorIndicator.backgroundColor = .systemBrown
        default:
            colorIndicator.backgroundColor = .systemGray
        }
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        countLabel.text = nil
        colorIndicator.backgroundColor = .clear
    }
}
