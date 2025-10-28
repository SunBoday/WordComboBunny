//
//  ComboLevelSelectVC.swift
//  WordComboBunny
//
//  Created by SunTory2025 on 2025/10/28.
//

import UIKit

class ComboLevelSelectVC: UIViewController {
    
    private let backgroundImageView = UIImageView()
    private var collectionView: UICollectionView!
    private var levels: [Level] = []
    
    // Header elements
    private let headerContainer = UIView()
    private let titleLabel = UILabel()
    private let backButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLevels()
        setupBackground()
        setupHeader()
        setupCollectionView()
        animateEntrance()
    }
    
    private func loadLevels() {
        levels = Level.loadLevels()
        
        if let savedLevels = UserDefaults.standard.data(forKey: "savedLevels"),
           let decodedLevels = try? JSONDecoder().decode([Level].self, from: savedLevels) {
            levels = decodedLevels
        }
    }
    
    private func setupBackground() {
        backgroundImageView.image = UIImage(named: "bg")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupHeader() {
        // Header container - NO overlap with collection view
        headerContainer.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerContainer)
        
        // Back button
        let backConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        backButton.setImage(UIImage(systemName: "chevron.left.circle.fill", withConfiguration: backConfig), for: .normal)
        backButton.tintColor = .white
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        backButton.layer.shadowRadius = 8
        backButton.layer.shadowOpacity = 0.5
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(backButton)
        
        // Title
        titleLabel.text = "SELECT LEVEL"
        titleLabel.font = UIFont(name: "AvenirNext-Heavy", size: 32)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.shadowColor = UIColor.black.withAlphaComponent(0.8)
        titleLabel.shadowOffset = CGSize(width: 0, height: 3)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: 120),
            
            backButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            backButton.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -15),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupCollectionView() {
        // 3 cards per row with proper spacing
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 15
        let totalSpacing = spacing * 4 // left + 2 gaps + right
        let cardWidth = (screenWidth - totalSpacing) / 3
        let cardHeight = cardWidth * 1.3 // 3:4 ratio
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cardWidth, height: cardHeight)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ModernLevelCell.self, forCellWithReuseIdentifier: "LevelCell")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func animateEntrance() {
        titleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: -30)
        
        UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseOut) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        }
        
        backButton.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.2) {
            self.backButton.alpha = 1
        }
    }
    
    @objc private func backTapped() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        UIView.animate(withDuration: 0.15, animations: {
            self.backButton.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.backButton.transform = .identity
            } completion: { _ in
                self.dismiss(animated: true)
            }
        }
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension ComboLevelSelectVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return levels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCell", for: indexPath) as! ModernLevelCell
        cell.configure(with: levels[indexPath.item])
        
        // Staggered entrance
        cell.alpha = 0
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.4, delay: Double(indexPath.item) * 0.03, options: [.curveEaseOut]) {
            cell.alpha = 1
            cell.transform = .identity
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let level = levels[indexPath.item]
        
        guard level.isUnlocked else {
            if let cell = collectionView.cellForItem(at: indexPath) {
                let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
                shake.values = [-8, 8, -6, 6, -4, 4, 0]
                shake.duration = 0.4
                cell.layer.add(shake, forKey: "shake")
            }
            
            let impact = UINotificationFeedbackGenerator()
            impact.notificationOccurred(.error)
            
            let alert = UIAlertController(title: "🔒 Level Locked",
                                         message: "Complete previous levels first!",
                                         preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.15, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }) { _ in
                UIView.animate(withDuration: 0.15) {
                    cell.transform = .identity
                } completion: { _ in
                    let gameVC = ComboGameVC(mode: .level(level))
                    gameVC.modalPresentationStyle = .fullScreen
                    self.present(gameVC, animated: true)
                }
            }
        }
    }
}

// MARK: - Modern Level Cell (Beautiful Card Design)
class ModernLevelCell: UICollectionViewCell {
    
    private let cardContainer = UIView()
    private let numberLabel = UILabel()
    private let starsContainer = UIStackView()
    private let lockIcon = UIImageView()
    private let shimmerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Card container
        cardContainer.layer.cornerRadius = 20
        cardContainer.layer.shadowColor = UIColor.black.cgColor
        cardContainer.layer.shadowOffset = CGSize(width: 0, height: 8)
        cardContainer.layer.shadowRadius = 16
        cardContainer.layer.shadowOpacity = 0.5
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardContainer)
        
        // Shimmer effect
        shimmerView.backgroundColor = UIColor.white.withAlphaComponent(0.45)
        shimmerView.layer.cornerRadius = 20
        shimmerView.alpha = 0
        shimmerView.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(shimmerView)
        
        // Number label
        numberLabel.font = UIFont(name: "AvenirNext-Heavy", size: 60)
        numberLabel.textColor = .white
        numberLabel.textAlignment = .center
        numberLabel.layer.shadowColor = UIColor.black.cgColor
        numberLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        numberLabel.layer.shadowRadius = 8
        numberLabel.layer.shadowOpacity = 0.6
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(numberLabel)
        
        // Stars container
        starsContainer.axis = .horizontal
        starsContainer.spacing = 4
        starsContainer.distribution = .fillEqually
        starsContainer.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(starsContainer)
        
        // Lock icon
        let lockConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold)
        lockIcon.image = UIImage(systemName: "lock.fill", withConfiguration: lockConfig)
        lockIcon.tintColor = .white
        lockIcon.contentMode = .scaleAspectFit
        lockIcon.alpha = 0.8
        lockIcon.isHidden = true
        lockIcon.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(lockIcon)
        
        NSLayoutConstraint.activate([
            cardContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            shimmerView.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            shimmerView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            shimmerView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            shimmerView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor),
            
            numberLabel.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor, constant: -15),
            
            starsContainer.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor),
            starsContainer.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: -15),
            starsContainer.widthAnchor.constraint(equalToConstant: 70),
            starsContainer.heightAnchor.constraint(equalToConstant: 24),
            
            lockIcon.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor),
            lockIcon.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor)
        ])
    }
    
    func configure(with level: Level) {
        numberLabel.text = "\(level.number)"
        
        if level.isUnlocked {
            // Beautiful gradient based on level number
            let gradientLayer = CAGradientLayer()
            
            let gradients: [[CGColor]] = [
                // Blue to Purple
                [UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0).cgColor,
                 UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0).cgColor],
                
                // Pink to Orange
                [UIColor(red: 1.0, green: 0.4, blue: 0.6, alpha: 1.0).cgColor,
                 UIColor(red: 1.0, green: 0.6, blue: 0.3, alpha: 1.0).cgColor],
                
                // Green to Teal
                [UIColor(red: 0.3, green: 0.9, blue: 0.6, alpha: 1.0).cgColor,
                 UIColor(red: 0.2, green: 0.8, blue: 0.9, alpha: 1.0).cgColor],
                
                // Purple to Pink
                [UIColor(red: 0.7, green: 0.3, blue: 1.0, alpha: 1.0).cgColor,
                 UIColor(red: 1.0, green: 0.3, blue: 0.7, alpha: 1.0).cgColor],
                
                // Orange to Yellow
                [UIColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0).cgColor,
                 UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0).cgColor]
            ]
            
            let colorIndex = (level.number - 1) % gradients.count
            gradientLayer.colors = gradients[colorIndex]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.cornerRadius = 20
            gradientLayer.frame = cardContainer.bounds
            
            cardContainer.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
            cardContainer.layer.insertSublayer(gradientLayer, at: 0)
            
            // Shimmer animation
            UIView.animate(withDuration: 1.5, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction]) {
                self.shimmerView.alpha = 0.4
            }
            
            numberLabel.isHidden = false
            lockIcon.isHidden = true
            
            // Stars
            starsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
            for i in 0..<3 {
                let starLabel = UILabel()
                starLabel.text = i < level.stars ? "⭐" : "☆"
                starLabel.font = UIFont.systemFont(ofSize: 20)
                starLabel.textAlignment = .center
                starsContainer.addArrangedSubview(starLabel)
            }
            
        } else {
            // Locked style
            cardContainer.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
            cardContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
            cardContainer.layer.borderWidth = 2
            
            shimmerView.alpha = 0
            numberLabel.isHidden = true
            lockIcon.isHidden = false
            
            // Pulsing lock
            UIView.animate(withDuration: 1.2, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction]) {
                self.lockIcon.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        shimmerView.layer.removeAllAnimations()
        lockIcon.layer.removeAllAnimations()
        lockIcon.transform = .identity
        cardContainer.layer.borderWidth = 0
    }
}
