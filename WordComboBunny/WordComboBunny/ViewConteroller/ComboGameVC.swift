//
//  ComboGameVC.swift
//  WordComboBunny
//
//  Created by SunTory2025 on 2025/10/28.
//

import UIKit
import SpriteKit

class ComboGameVC: UIViewController {
    
    private var skView: SKView!
     var gameScene: GameScene!
    private let gameMode: GameMode
    
    private let backgroundImageView = UIImageView()
    
    // Header with gradient
    private let headerContainer = UIView()
    private let headerGradient = CAGradientLayer()
    
    // Modern cards
    private let backButton = UIButton()
    private let scoreCard = UIView()
    private let movesCard = UIView()
    private let scoreLabel = UILabel()
    private let movesLabel = UILabel()
    private let scoreTitleLabel = UILabel()
    private let movesTitleLabel = UILabel()
    private let objectiveLabel = UILabel()
    
    // Animated icons
    
    private let hintButton = UIButton()
    private let shuffleButton = UIButton()
    
    init(mode: GameMode) {
        self.gameMode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundImage()
        setupSKView()
        setupHeader()
        setupPowerUpButtons()
        setupGameScene()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient.frame = headerContainer.bounds
    }
    
    private func setupBackgroundImage() {
        backgroundImageView.image = UIImage(named: "bg")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSKView() {
        skView = SKView(frame: view.bounds)
        skView.backgroundColor = .clear
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        view.addSubview(skView)
    }
    
    // MARK: - Attractive Header
    private func setupHeader() {
        // Header container
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerContainer)
        
        // Animated gradient
        headerGradient.colors = [
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        headerGradient.startPoint = CGPoint(x: 0.5, y: 0)
        headerGradient.endPoint = CGPoint(x: 0.5, y: 1)
        headerContainer.layer.insertSublayer(headerGradient, at: 0)
        
        // Back button with icon
        let backConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: backConfig), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        backButton.layer.cornerRadius = 24
        backButton.layer.borderWidth = 2.5
        backButton.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        backButton.layer.shadowRadius = 12
        backButton.layer.shadowOpacity = 0.4
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(backButton)
        
        // Score Card - Premium glass design
        scoreCard.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        scoreCard.layer.cornerRadius = 20
        scoreCard.layer.borderWidth = 3
        scoreCard.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        scoreCard.layer.shadowColor = UIColor.black.cgColor
        scoreCard.layer.shadowOffset = CGSize(width: 0, height: 8)
        scoreCard.layer.shadowRadius = 16
        scoreCard.layer.shadowOpacity = 0.35
        scoreCard.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(scoreCard)
        
        // Score icon with animation
//        let iconConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
//        scoreIcon.image = UIImage(systemName: "star.fill", withConfiguration: iconConfig)
//        scoreIcon.tintColor = UIColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
//        scoreIcon.translatesAutoresizingMaskIntoConstraints = false
//        scoreCard.addSubview(scoreIcon)
        
        // Add pulsing animation to score icon
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.15
        pulse.duration = 0.8
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        
        scoreLabel.text = "0"
        scoreLabel.font = UIFont(name: "AvenirNext-Heavy", size: 34)
        scoreLabel.textColor = .white
        scoreLabel.textAlignment = .center
        scoreLabel.shadowColor = UIColor.black.withAlphaComponent(0.5)
        scoreLabel.shadowOffset = CGSize(width: 0, height: 2)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreCard.addSubview(scoreLabel)
        
        scoreTitleLabel.text = "SCORE"
        scoreTitleLabel.font = UIFont(name: "AvenirNext-Bold", size: 11)
        scoreTitleLabel.textColor = UIColor(red: 1.0, green: 0.95, blue: 0.5, alpha: 1.0)
        scoreTitleLabel.textAlignment = .center
        scoreTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreCard.addSubview(scoreTitleLabel)
        
        // Moves Card - Premium glass design
        movesCard.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        movesCard.layer.cornerRadius = 20
        movesCard.layer.borderWidth = 3
        movesCard.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        movesCard.layer.shadowColor = UIColor.black.cgColor
        movesCard.layer.shadowOffset = CGSize(width: 0, height: 8)
        movesCard.layer.shadowRadius = 16
        movesCard.layer.shadowOpacity = 0.35
        movesCard.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(movesCard)
        
        // Moves icon with animation
//        movesIcon.image = UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: iconConfig)
//        movesIcon.tintColor = UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)
//        movesIcon.translatesAutoresizingMaskIntoConstraints = false
//        movesCard.addSubview(movesIcon)
        
        // Add rotation animation to moves icon
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.fromValue = 0
        rotate.toValue = CGFloat.pi * 2
        rotate.duration = 2.0
        rotate.repeatCount = .infinity
        
        movesLabel.text = "20"
        movesLabel.font = UIFont(name: "AvenirNext-Heavy", size: 34)
        movesLabel.textColor = .white
        movesLabel.textAlignment = .center
        movesLabel.shadowColor = UIColor.black.withAlphaComponent(0.5)
        movesLabel.shadowOffset = CGSize(width: 0, height: 2)
        movesLabel.translatesAutoresizingMaskIntoConstraints = false
        movesCard.addSubview(movesLabel)
        
        movesTitleLabel.text = "MOVES"
        movesTitleLabel.font = UIFont(name: "AvenirNext-Bold", size: 11)
        movesTitleLabel.textColor = UIColor(red: 1.0, green: 0.95, blue: 0.5, alpha: 1.0)
        movesTitleLabel.textAlignment = .center
        movesTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        movesCard.addSubview(movesTitleLabel)
        
        // Objective label with glow
        switch gameMode {
        case .level(let level):
            objectiveLabel.text = "🎯 " + (level.objectives.first ?? "")
        case .endless:
            objectiveLabel.text = "🎯 Match 3+ Same Letters!"
        }
        objectiveLabel.font = UIFont(name: "AvenirNext-Medium", size: 16)
        objectiveLabel.textColor = .white
        objectiveLabel.textAlignment = .center
        objectiveLabel.numberOfLines = 2
        objectiveLabel.shadowColor = UIColor.black.withAlphaComponent(0.8)
        objectiveLabel.shadowOffset = CGSize(width: 0, height: 3)
        objectiveLabel.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(objectiveLabel)
        
        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: 200),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),
            backButton.widthAnchor.constraint(equalToConstant: 48),
            backButton.heightAnchor.constraint(equalToConstant: 48),
            
            scoreCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            scoreCard.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            scoreCard.widthAnchor.constraint(equalToConstant: 120),
            scoreCard.heightAnchor.constraint(equalToConstant: 75),
            
            
            scoreLabel.centerXAnchor.constraint(equalTo: scoreCard.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: scoreCard.centerYAnchor, constant: 4),
            
            scoreTitleLabel.bottomAnchor.constraint(equalTo: scoreCard.bottomAnchor, constant: -10),
            scoreTitleLabel.centerXAnchor.constraint(equalTo: scoreCard.centerXAnchor),
            
            movesCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            movesCard.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -18),
            movesCard.widthAnchor.constraint(equalToConstant: 120),
            movesCard.heightAnchor.constraint(equalToConstant: 75),
            
            
            movesLabel.centerXAnchor.constraint(equalTo: movesCard.centerXAnchor),
            movesLabel.centerYAnchor.constraint(equalTo: movesCard.centerYAnchor, constant: 4),
            
            movesTitleLabel.bottomAnchor.constraint(equalTo: movesCard.bottomAnchor, constant: -10),
            movesTitleLabel.centerXAnchor.constraint(equalTo: movesCard.centerXAnchor),
            
            objectiveLabel.topAnchor.constraint(equalTo: scoreCard.bottomAnchor, constant: 14),
            objectiveLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            objectiveLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupPowerUpButtons() {
        let hintConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
        hintButton.setImage(UIImage(systemName: "lightbulb.fill", withConfiguration: hintConfig), for: .normal)
        hintButton.tintColor = .white
        hintButton.backgroundColor = UIColor(red: 1.0, green: 0.75, blue: 0.0, alpha: 1.0)
        hintButton.layer.cornerRadius = 36
        hintButton.layer.shadowColor = UIColor(red: 1.0, green: 0.75, blue: 0.0, alpha: 1.0).cgColor
        hintButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        hintButton.layer.shadowRadius = 22
        hintButton.layer.shadowOpacity = 0.75
        hintButton.layer.borderWidth = 4
        hintButton.layer.borderColor = UIColor.white.cgColor
        hintButton.addTarget(self, action: #selector(hintTapped), for: .touchUpInside)
        hintButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hintButton)
        
        let pulse = CABasicAnimation(keyPath: "shadowRadius")
        pulse.fromValue = 22
        pulse.toValue = 30
        pulse.duration = 1.3
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        hintButton.layer.add(pulse, forKey: "shadowPulse")
        
        let shuffleConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
        shuffleButton.setImage(UIImage(systemName: "shuffle", withConfiguration: shuffleConfig), for: .normal)
        shuffleButton.tintColor = .white
        shuffleButton.backgroundColor = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0)
        shuffleButton.layer.cornerRadius = 36
        shuffleButton.layer.shadowColor = UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0).cgColor
        shuffleButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        shuffleButton.layer.shadowRadius = 22
        shuffleButton.layer.shadowOpacity = 0.75
        shuffleButton.layer.borderWidth = 4
        shuffleButton.layer.borderColor = UIColor.white.cgColor
        shuffleButton.addTarget(self, action: #selector(shuffleTapped), for: .touchUpInside)
        shuffleButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shuffleButton)
        
        let shufflePulse = CABasicAnimation(keyPath: "shadowRadius")
        shufflePulse.fromValue = 22
        shufflePulse.toValue = 30
        shufflePulse.duration = 1.3
        shufflePulse.autoreverses = true
        shufflePulse.repeatCount = .infinity
        shuffleButton.layer.add(shufflePulse, forKey: "shadowPulse")
        
        NSLayoutConstraint.activate([
            hintButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22),
            hintButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 42),
            hintButton.widthAnchor.constraint(equalToConstant: 72),
            hintButton.heightAnchor.constraint(equalToConstant: 72),
            
            shuffleButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22),
            shuffleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -42),
            shuffleButton.widthAnchor.constraint(equalToConstant: 72),
            shuffleButton.heightAnchor.constraint(equalToConstant: 72)
        ])
    }
    
    private func setupGameScene() {
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .clear
        
        scene.onScoreUpdate = { [weak self] score in
            self?.scoreLabel.text = "\(score)"
            self?.animateScoreUpdate()
        }
        
        scene.onMovesUpdate = { [weak self] moves in
            self?.movesLabel.text = "\(moves)"
        }
        
        scene.onGameOver = { [weak self] won, score, longestWord in
            self?.showGameOver(won: won, score: score, longestWord: longestWord)
        }
        
        scene.initializeGame(mode: gameMode)
        skView.presentScene(scene)
        gameScene = scene
        
        switch gameMode {
        case .level(let level):
            movesLabel.text = "\(level.movesLimit)"
        case .endless:
            movesLabel.text = "∞"
        }
    }
    
    @objc private func backTapped() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Get current score
        let currentScore = gameScene.gameState.score
        
        // Show confirmation if game is in progress
        if currentScore > 0 {
            showExitConfirmation(currentScore: currentScore)
        } else {
            // No score yet, just exit
            dismiss(animated: true)
        }
    }

    private func showExitConfirmation(currentScore: Int) {
        let alert = UIAlertController(
            title: "Quit Game?",
            message: "Your current score: \(currentScore)\n\nDo you want to save and exit?",
            preferredStyle: .alert
        )
        
        // Save and Exit
        alert.addAction(UIAlertAction(title: "Save & Exit", style: .default) { [weak self] _ in
            LeaderboardManager.shared.addScore(currentScore)
            print("Score saved: \(currentScore)")
            self?.dismiss(animated: true)
        })
        
        // Continue Playing
        alert.addAction(UIAlertAction(title: "Continue Playing", style: .cancel))
        
        present(alert, animated: true)
    }

    
    @objc private func hintTapped() {
        gameScene.showHint()
        animateButtonPress(hintButton)
    }
    
    @objc private func shuffleTapped() {
        gameScene.shuffleBoard()
        animateButtonPress(shuffleButton)
    }
    
    private func animateButtonPress(_ button: UIButton) {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.6) {
                button.transform = .identity
            }
        }
    }
    
    private func animateScoreUpdate() {
        UIView.animate(withDuration: 0.15, animations: {
            self.scoreCard.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.scoreLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
                self.scoreCard.transform = .identity
                self.scoreLabel.transform = .identity
            }
        }
    }
    
    private func showGameOver(won: Bool, score: Int, longestWord: String) {
        let gameOverVC = ComboGameOverVC(won: won, score: score, longestWord: longestWord, mode: gameMode)
        gameOverVC.modalPresentationStyle = .fullScreen
        present(gameOverVC, animated: true)
    }
}
