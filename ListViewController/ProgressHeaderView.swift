import UIKit

class ProgressHeaderView: UICollectionReusableView {
    static var elementKind: String { UICollectionView.elementKindSectionHeader }
    
    var progress: CGFloat = 0 {
        didSet {
            setNeedsLayout()
            heightConstraint?.constant = progress * bounds.height
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.layoutIfNeeded()
            }
            progressPercentLabel.text = "\(Int(progress * 100.0))%"
        }
    }
    
    private let upperView = UIView(frame: .zero)
    private let lowerView = UIView(frame: .zero)
    private let containerView = UIView(frame: .zero)
    private let progressPercentLabel = UILabel(frame: .zero)
    private var heightConstraint: NSLayoutConstraint?
    private var valueFormat: String { NSLocalizedString("%d percent", comment: "progress percentage value format") }
    private var progressPercentFormat: String = NSLocalizedString("%d %", comment: "Completed reminder percentage")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareSubview()
        isAccessibilityElement = true
        accessibilityLabel = NSLocalizedString("Progress", comment: "Progress view accessibility label")
        accessibilityTraits.update(with: .updatesFrequently)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        accessibilityValue = String(format: valueFormat, Int(progress * 100.0))
        heightConstraint?.constant = progress * bounds.height
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 0.5 * containerView.bounds.width
    }
    
    private func prepareSubview() {
        containerView.addSubview(upperView)
        containerView.addSubview(lowerView)
        addSubview(containerView)
        
        upperView.translatesAutoresizingMaskIntoConstraints = false
        lowerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        containerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85).isActive = true
        
        upperView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        upperView.bottomAnchor.constraint(equalTo: lowerView.topAnchor).isActive = true
        lowerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        upperView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        upperView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        lowerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        lowerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        heightConstraint = lowerView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.isActive = true
        
        backgroundColor = .clear
        containerView.backgroundColor = .clear
        upperView.backgroundColor = .todayProgressUpperBackground
        lowerView.backgroundColor = .todayProgressLowerBackground
        configurePercentLabel()
    }
    
    private func configurePercentLabel() {
        progressPercentLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        progressPercentLabel.textColor = .darkGray
        progressPercentLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(progressPercentLabel)
        
        progressPercentLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        progressPercentLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        progressPercentLabel.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2).isActive = true
    }
}
