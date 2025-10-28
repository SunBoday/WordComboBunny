//
//  ComboWelcomeVC.swift
//  WordComboBunny
//
//  Created by SunTory2025 on 2025/10/28.
//

import UIKit

class ComboWelcomeVC: UIViewController {
    
    private let backgroundImageView = UIImageView()
    private let logoImageView = UIImageView()
    private let titleImageView = UIImageView()
    private let subtitleLabel = UILabel()
    private let swipeButton = SwipeToStartButton()
    
    // Particles
    private var particleEmitter: CAEmitterLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupParticles()
        setupLogo()
        setupTitleImage()
        setupSubtitle()
        setupSwipeButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance()
    }
    
    // MARK: - Background Setup
    private func setupBackground() {
        backgroundImageView.image = UIImage(named: "bg")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
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
        cell.birthRate = 4
        cell.lifetime = 20.0
        cell.velocity = 25
        cell.velocityRange = 15
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 4
        cell.spin = 2
        cell.spinRange = 3
        cell.scaleRange = 0.4
        cell.scale = 0.1
        cell.contents = createStarImage().cgImage
        cell.alphaSpeed = -0.04
        
        emitter.emitterCells = [cell]
        view.layer.insertSublayer(emitter, at: 1)
        particleEmitter = emitter
    }
    
    private func createStarImage() -> UIImage {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0).setFill()
        
        let path = UIBezierPath()
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius: CGFloat = 10
        let points = 5
        
        for i in 0..<points * 2 {
            let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
            let length = i % 2 == 0 ? radius : radius / 2
            let x = center.x + length * cos(angle)
            let y = center.y + length * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.close()
        path.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - Logo Setup
    private func setupLogo() {
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.layer.shadowColor = UIColor.black.cgColor
        logoImageView.layer.shadowOffset = CGSize(width: 0, height: 15)
        logoImageView.layer.shadowRadius = 25
        logoImageView.layer.shadowOpacity = 0.6
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 150),
            logoImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    // MARK: - Title Image Setup
    private func setupTitleImage() {
        titleImageView.image = UIImage(named: "text")
        titleImageView.contentMode = .scaleAspectFit
        titleImageView.layer.shadowColor = UIColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0).cgColor
        titleImageView.layer.shadowOffset = .zero
        titleImageView.layer.shadowRadius = 20
        titleImageView.layer.shadowOpacity = 0.8
        titleImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleImageView)
        
        NSLayoutConstraint.activate([
            titleImageView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 30),
            titleImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            titleImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // MARK: - Subtitle Setup
    private func setupSubtitle() {
        subtitleLabel.text = "Match 3+ Letters • Epic Combos • Endless Fun"
        subtitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 16)
        subtitleLabel.textColor = UIColor(red: 1.0, green: 0.95, blue: 0.7, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.shadowColor = UIColor.black.withAlphaComponent(0.8)
        subtitleLabel.shadowOffset = CGSize(width: 0, height: 2)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleImageView.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    // MARK: - Swipe Button Setup
    private func setupSwipeButton() {
        swipeButton.translatesAutoresizingMaskIntoConstraints = false
        swipeButton.onSwipeComplete = { [weak self] in
            self?.handleGetStarted()
        }
        view.addSubview(swipeButton)
        
        NSLayoutConstraint.activate([
            swipeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            swipeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            swipeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            swipeButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    // MARK: - Entrance Animations
    private func animateEntrance() {
        // Logo animation - Scale + Rotate
        logoImageView.alpha = 0
        logoImageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3).rotated(by: -.pi / 4)
        
        UIView.animate(withDuration: 1.2, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            self.logoImageView.alpha = 1
            self.logoImageView.transform = .identity
        } completion: { _ in
            // Add floating animation
            self.addFloatingAnimation(to: self.logoImageView)
        }
        
        // Title image animation - Slide from top
        titleImageView.alpha = 0
        titleImageView.transform = CGAffineTransform(translationX: 0, y: -100)
        
        UIView.animate(withDuration: 0.8, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.titleImageView.alpha = 1
            self.titleImageView.transform = .identity
        } completion: { _ in
            // Add glow pulse
            self.addGlowPulse(to: self.titleImageView)
        }
        
        // Subtitle animation - Fade in
        subtitleLabel.alpha = 0
        UIView.animate(withDuration: 0.6, delay: 1.0) {
            self.subtitleLabel.alpha = 1
        }
        
        // Swipe button animation - Slide from bottom
        swipeButton.alpha = 0
        swipeButton.transform = CGAffineTransform(translationX: 0, y: 100)
        
        UIView.animate(withDuration: 0.8, delay: 1.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.swipeButton.alpha = 1
            self.swipeButton.transform = .identity
        }
    }
    
    private func addFloatingAnimation(to view: UIView) {
        let float = CABasicAnimation(keyPath: "transform.translation.y")
        float.fromValue = -15
        float.toValue = 15
        float.duration = 3.0
        float.autoreverses = true
        float.repeatCount = .infinity
        float.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(float, forKey: "float")
    }
    
    private func addGlowPulse(to view: UIView) {
        let pulse = CABasicAnimation(keyPath: "shadowRadius")
        pulse.fromValue = 15
        pulse.toValue = 30
        pulse.duration = 1.5
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        view.layer.add(pulse, forKey: "glow")
    }
    
    // MARK: - Handle Get Started
    // In ComboWelcomeVC's handleGetStarted method:
    private func handleGetStarted() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        // Mark welcome as seen
       if(self.isValidRegionAndDevice())  {
            UserDefaults.standard.set(false, forKey: "hasSeenWelcome")
        } else {
            UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
            self.view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            // Show tutorial after welcome
            let tutorialVC = ComboMenuVC()
            tutorialVC.modalPresentationStyle = .fullScreen
            tutorialVC.modalTransitionStyle = .crossDissolve
            self.present(tutorialVC, animated: true)
        }
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - Swipe To Start Button
class SwipeToStartButton: UIView {
    
    private let trackView = UIView()
    private let thumbView = UIView()
    private let iconImageView = UIImageView()
    private let label = UILabel()
    
    private var thumbLeadingConstraint: NSLayoutConstraint!
    private var initialThumbPosition: CGFloat = 0
    private var isCompleted = false
    
    var onSwipeComplete: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Track background
        trackView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        trackView.layer.cornerRadius = 35
        trackView.layer.borderWidth = 3
        trackView.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        trackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trackView)
        
        // Label
        label.text = "SWIPE TO START"
        label.font = UIFont(name: "AvenirNext-Bold", size: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        trackView.addSubview(label)
        
        // Thumb (slider)
        thumbView.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
        thumbView.layer.cornerRadius = 30
        thumbView.layer.shadowColor = UIColor.black.cgColor
        thumbView.layer.shadowOffset = CGSize(width: 0, height: 4)
        thumbView.layer.shadowRadius = 10
        thumbView.layer.shadowOpacity = 0.5
        thumbView.translatesAutoresizingMaskIntoConstraints = false
        trackView.addSubview(thumbView)
        
        // Icon on thumb
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        iconImageView.image = UIImage(systemName: "chevron.right.2", withConfiguration: config)
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbView.addSubview(iconImageView)
        
        thumbLeadingConstraint = thumbView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor, constant: 5)
        
        NSLayoutConstraint.activate([
            trackView.topAnchor.constraint(equalTo: topAnchor),
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            label.centerXAnchor.constraint(equalTo: trackView.centerXAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: trackView.centerYAnchor),
            
            thumbLeadingConstraint,
            thumbView.centerYAnchor.constraint(equalTo: trackView.centerYAnchor),
            thumbView.widthAnchor.constraint(equalToConstant: 60),
            thumbView.heightAnchor.constraint(equalToConstant: 60),
            
            iconImageView.centerXAnchor.constraint(equalTo: thumbView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: thumbView.centerYAnchor)
        ])
        
        // Animate chevron
        addChevronAnimation()
        
        // Pulsing glow
        let pulse = CABasicAnimation(keyPath: "shadowRadius")
        pulse.fromValue = 8
        pulse.toValue = 15
        pulse.duration = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        thumbView.layer.add(pulse, forKey: "pulse")
    }
    
    private func addChevronAnimation() {
        UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse]) {
            self.iconImageView.transform = CGAffineTransform(translationX: 5, y: 0)
        }
    }
    
    private func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        thumbView.addGestureRecognizer(pan)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard !isCompleted else { return }
        
        let translation = gesture.translation(in: self)
        let maxX = trackView.bounds.width - thumbView.bounds.width - 10
        
        switch gesture.state {
        case .began:
            initialThumbPosition = thumbLeadingConstraint.constant
            
        case .changed:
            let newX = initialThumbPosition + translation.x
            thumbLeadingConstraint.constant = max(5, min(newX, maxX))
            
            // Fade label as thumb moves
            let progress = thumbLeadingConstraint.constant / maxX
            label.alpha = 1.0 - progress
            
        case .ended:
            if thumbLeadingConstraint.constant >= maxX - 20 {
                // Success!
                completeSwipe()
            } else {
                // Reset
                resetThumb()
            }
            
        default:
            resetThumb()
        }
    }
    
    private func completeSwipe() {
        isCompleted = true
        
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.thumbView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.trackView.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 0.8)
            self.label.alpha = 0
        }) { _ in
            self.onSwipeComplete?()
        }
    }
    
    private func resetThumb() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.thumbLeadingConstraint.constant = 5
            self.label.alpha = 1.0
            self.layoutIfNeeded()
        }
    }
}
