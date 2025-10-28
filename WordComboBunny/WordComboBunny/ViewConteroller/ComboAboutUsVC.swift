//
//  ComboAboutUsVC.swift
//  WordComboBunny
//
//  Created by SunTory2025 on 2025/10/28.
//


import UIKit

class ComboAboutUsVC: UIViewController {
    
    private let backgroundImageView = UIImageView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let headerContainer = UIView()
    private let titleLabel = UILabel()
    private let backButton = UIButton()
    
    private let logoImageView = UIImageView()
    private let appNameLabel = UILabel()
    private let versionLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let developerLabel = UILabel()
    private let copyrightLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupHeader()
        setupScrollView()
        setupContent()
        animateEntrance()
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
        headerContainer.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerContainer)
        
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
        
        titleLabel.text = "📱 ABOUT US"
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
    
    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupContent() {
        // Logo
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.layer.shadowColor = UIColor.black.cgColor
        logoImageView.layer.shadowOffset = CGSize(width: 0, height: 6)
        logoImageView.layer.shadowRadius = 12
        logoImageView.layer.shadowOpacity = 0.5
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logoImageView)
        
        // App Name
        appNameLabel.text = "Little habits, lighter days"
        appNameLabel.font = UIFont(name: "AvenirNext-Heavy", size: 28)
        appNameLabel.textColor = .white
        appNameLabel.textAlignment = .center
        appNameLabel.shadowColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        appNameLabel.shadowOffset = .zero
        appNameLabel.layer.shadowRadius = 10
        appNameLabel.layer.shadowOpacity = 0.8
        appNameLabel.numberOfLines = 2
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(appNameLabel)
        
        // Version
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        versionLabel.text = "Version \(version)"
        versionLabel.font = UIFont(name: "AvenirNext-Medium", size: 16)
        versionLabel.textColor = UIColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 1.0)
        versionLabel.textAlignment = .center
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(versionLabel)
        
        // Description
        descriptionLabel.text = "This app is a fun and addictive word puzzle game where you match 3 or more same letters to score points and complete challenging levels!\n\nSwipe adjacent tiles to create matches, earn combos, and use power-ups to help you succeed.\n\nWith beautiful graphics and smooth gameplay, this app provides hours of entertainment for puzzle lovers of all ages."
        descriptionLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.shadowColor = UIColor.black.withAlphaComponent(0.6)
        descriptionLabel.shadowOffset = CGSize(width: 0, height: 2)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        // Developer
        developerLabel.text = ""
        developerLabel.font = UIFont(name: "AvenirNext-Bold", size: 18)
        developerLabel.textColor = UIColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 1.0)
        developerLabel.textAlignment = .center
        developerLabel.numberOfLines = 0
        developerLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(developerLabel)
        
        // Copyright
        copyrightLabel.text = "© 2025 All Rights Reserved"
        copyrightLabel.font = UIFont(name: "AvenirNext-Medium", size: 14)
        copyrightLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        copyrightLabel.textAlignment = .center
        copyrightLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(copyrightLabel)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            appNameLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            appNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            appNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            versionLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 8),
            versionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            versionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            descriptionLabel.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 30),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            developerLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            developerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            developerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            copyrightLabel.topAnchor.constraint(equalTo: developerLabel.bottomAnchor, constant: 20),
            copyrightLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            copyrightLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            copyrightLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func animateEntrance() {
        titleLabel.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.1) {
            self.titleLabel.alpha = 1
        }
        
        logoImageView.alpha = 0
        logoImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.logoImageView.alpha = 1
            self.logoImageView.transform = .identity
        }
        
        let labels = [appNameLabel, versionLabel, descriptionLabel, developerLabel, copyrightLabel]
        for (index, label) in labels.enumerated() {
            label.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0.3 + Double(index) * 0.1) {
                label.alpha = 1
            }
        }
    }
    
    @objc private func backTapped() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        dismiss(animated: true)
    }
}
