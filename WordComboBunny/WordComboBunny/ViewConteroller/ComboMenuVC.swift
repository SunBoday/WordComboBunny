//
//  ComboMenuVC.swift
//  WordComboBunny
//
//  Created by SunTory2025 on 2025/10/28.
//

import UIKit

class ComboMenuVC: UIViewController {
    
    private let backgroundImageView = UIImageView()
    
    // Logo and title
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    // Main buttons
    private let playButton = UIButton()
    private let leaderboardButton = UIButton()
    private let endlessButton = UIButton()
    
    // Settings button
    private let settingsButton = UIButton()
    
    // Particles
    private var particleEmitter: CAEmitterLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupParticles()
        setupLogo()
        setupButtons()
        animateEntrance()
    }
    
    // MARK: - Background Setup
    private func setupBackground() {
        // Use "bg" as background
        backgroundImageView.image = UIImage(named: "bg")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        
        // Dark overlay for better text visibility
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
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
    
    // MARK: - Floating Particles
    private func setupParticles() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)
        
        let cell = CAEmitterCell()
        cell.birthRate = 3
        cell.lifetime = 15.0
        cell.velocity = 30
        cell.velocityRange = 15
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 4
        cell.spin = 2
        cell.spinRange = 3
        cell.scaleRange = 0.3
        cell.scale = 0.1
        cell.contents = createParticleImage().cgImage
        cell.alphaSpeed = -0.05
        
        emitter.emitterCells = [cell]
        view.layer.insertSublayer(emitter, at: 1)
        particleEmitter = emitter
    }
    
    private func createParticleImage() -> UIImage {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.setFill()
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - Logo Setup
    private func setupLogo() {
        // Logo from assets
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.layer.shadowColor = UIColor.black.cgColor
        logoImageView.layer.shadowOffset = CGSize(width: 0, height: 10)
        logoImageView.layer.shadowRadius = 20
        logoImageView.layer.shadowOpacity = 0.6
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        
        // Add floating animation
        let float = CABasicAnimation(keyPath: "transform.translation.y")
        float.fromValue = -10
        float.toValue = 10
        float.duration = 2.5
        float.autoreverses = true
        float.repeatCount = .infinity
        logoImageView.layer.add(float, forKey: "float")
        
        // Title
        titleLabel.text = "Little habits, lighter days"
        titleLabel.font = UIFont(name: "AvenirNext-Heavy", size: 32)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0).cgColor
        titleLabel.layer.shadowOffset = .zero
        titleLabel.layer.shadowRadius = 15
        titleLabel.layer.shadowOpacity = 0.8
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Glowing text animation
        let glow = CABasicAnimation(keyPath: "shadowRadius")
        glow.fromValue = 10
        glow.toValue = 25
        glow.duration = 1.5
        glow.autoreverses = true
        glow.repeatCount = .infinity
        titleLabel.layer.add(glow, forKey: "glow")
        
        // Subtitle
        subtitleLabel.text = "Match 3+ Letters to Win!"
        subtitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
        subtitleLabel.textColor = UIColor(red: 1.0, green: 0.95, blue: 0.7, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        subtitleLabel.shadowColor = UIColor.black.withAlphaComponent(0.8)
        subtitleLabel.shadowOffset = CGSize(width: 0, height: 2)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 25),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
    
    // MARK: - Buttons Setup
    private func setupButtons() {
        // Play Button - Primary action
        setupButton(playButton,
                   title: "PLAY",
                   icon: "play.circle.fill",
                   colors: [UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0),
                           UIColor(red: 0.1, green: 0.6, blue: 0.3, alpha: 1.0)],
                   action: #selector(playTapped))
        
        // Leaderboard Button (replaces Levels)
        setupButton(leaderboardButton,
                   title: "LEADERBOARD",
                   icon: "trophy.fill",
                   colors: [UIColor(red: 1.0, green: 0.75, blue: 0.0, alpha: 1.0),
                           UIColor(red: 0.9, green: 0.6, blue: 0.0, alpha: 1.0)],
                   action: #selector(leaderboardTapped))
        
        // Endless Mode Button
        setupButton(endlessButton,
                   title: "ENDLESS",
                   icon: "infinity.circle.fill",
                   colors: [UIColor(red: 1.0, green: 0.5, blue: 0.3, alpha: 1.0),
                           UIColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 1.0)],
                   action: #selector(endlessTapped))
        
        // Settings Button - Smaller
        let settingsConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        settingsButton.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: settingsConfig), for: .normal)
        settingsButton.tintColor = .white
        settingsButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        settingsButton.layer.cornerRadius = 30
        settingsButton.layer.borderWidth = 2
        settingsButton.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        settingsButton.layer.shadowColor = UIColor.black.cgColor
        settingsButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        settingsButton.layer.shadowRadius = 12
        settingsButton.layer.shadowOpacity = 0.4
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(settingsButton)
        
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20),
            playButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            playButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            playButton.heightAnchor.constraint(equalToConstant: 70),
            
            leaderboardButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
            leaderboardButton.leadingAnchor.constraint(equalTo: playButton.leadingAnchor),
            leaderboardButton.trailingAnchor.constraint(equalTo: playButton.trailingAnchor),
            leaderboardButton.heightAnchor.constraint(equalToConstant: 65),
            
            endlessButton.topAnchor.constraint(equalTo: leaderboardButton.bottomAnchor, constant: 20),
            endlessButton.leadingAnchor.constraint(equalTo: playButton.leadingAnchor),
            endlessButton.trailingAnchor.constraint(equalTo: playButton.trailingAnchor),
            endlessButton.heightAnchor.constraint(equalToConstant: 65),
            
            settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            settingsButton.widthAnchor.constraint(equalToConstant: 60),
            settingsButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupButton(_ button: UIButton, title: String, icon: String, colors: [UIColor], action: Selector) {
        // Title
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 24)
        button.setTitleColor(.white, for: .normal)
        
        // Icon
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        let iconImage = UIImage(systemName: icon, withConfiguration: iconConfig)
        button.setImage(iconImage, for: .normal)
        button.tintColor = .white
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        
        // Style
        button.layer.cornerRadius = 18
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 8)
        button.layer.shadowRadius = 16
        button.layer.shadowOpacity = 0.5
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.clipsToBounds = false
        
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        // Add gradient as sublayer after layout
        DispatchQueue.main.async {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = colors.map { $0.cgColor }
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.cornerRadius = 18
            gradientLayer.frame = button.bounds
            button.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        // Pulsing shadow animation
        let pulse = CABasicAnimation(keyPath: "shadowOpacity")
        pulse.fromValue = 0.3
        pulse.toValue = 0.6
        pulse.duration = 1.5
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        button.layer.add(pulse, forKey: "shadowPulse")
    }
    
    // MARK: - Entrance Animations
    private func animateEntrance() {
        // Logo entrance
        logoImageView.alpha = 0
        logoImageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        
        UIView.animate(withDuration: 1.0, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            self.logoImageView.alpha = 1
            self.logoImageView.transform = .identity
        }
        
        // Title entrance
        titleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 50)
        
        UIView.animate(withDuration: 0.8, delay: 0.4, options: .curveEaseOut) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        }
        
        // Subtitle entrance
        subtitleLabel.alpha = 0
        UIView.animate(withDuration: 0.6, delay: 0.6) {
            self.subtitleLabel.alpha = 1
        }
        
        // Buttons entrance
        let buttons = [playButton, leaderboardButton, endlessButton, settingsButton]
        for (index, button) in buttons.enumerated() {
            button.alpha = 0
            button.transform = CGAffineTransform(translationX: -100, y: 0)
            
            UIView.animate(withDuration: 0.6, delay: 0.8 + Double(index) * 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                button.alpha = 1
                button.transform = .identity
            }
        }
    }
    
    // MARK: - Button Actions
    @objc private func playTapped() {
        animateButtonPress(playButton) {
            let gameVC = ComboGameVC(mode: .endless)
            gameVC.modalPresentationStyle = .fullScreen
            self.present(gameVC, animated: true)
        }
    }
    
    @objc private func leaderboardTapped() {
        animateButtonPress(leaderboardButton) {
            let leaderboardVC = ComboLeaderboardVC()
            leaderboardVC.modalPresentationStyle = .fullScreen
            self.present(leaderboardVC, animated: true)
        }
    }
    
    @objc private func endlessTapped() {
        animateButtonPress(endlessButton) {
            let gameVC = ComboGameVC(mode: .endless)
            gameVC.modalPresentationStyle = .fullScreen
            self.present(gameVC, animated: true)
        }
    }
    
    @objc private func settingsTapped() {
        animateButtonPress(settingsButton) {
            let settingsVC = ComboSettingsVC()
            settingsVC.modalPresentationStyle = .fullScreen
            self.present(settingsVC, animated: true)
        }
    }
    
    private func animateButtonPress(_ button: UIButton, completion: @escaping () -> Void) {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
                button.transform = .identity
            } completion: { _ in
                completion()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
