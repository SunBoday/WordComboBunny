//
//  ComboGameOverVC.swift
//  WordComboBunny
//
//  Created by SunTory2025 on 2025/10/28.
//

import UIKit

class ComboGameOverVC: UIViewController {
    
    private let won: Bool
    private let score: Int
    private let longestWord: String
    private let gameMode: GameMode
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let scoreLabel = UILabel()
    private let longestWordLabel = UILabel()
    private let starsStack = UIStackView()
    private let nextLevelButton = UIButton()
    private let retryButton = UIButton()
    private let menuButton = UIButton()
    
    init(won: Bool, score: Int, longestWord: String, mode: GameMode) {
        self.won = won
        self.score = score
        self.longestWord = longestWord
        self.gameMode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        animateEntrance()
        saveProgress()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        
        containerView.backgroundColor = won ?
            UIColor(red: 0.1, green: 0.3, blue: 0.2, alpha: 0.95) :
            UIColor(red: 0.3, green: 0.1, blue: 0.1, alpha: 0.95)
        containerView.layer.cornerRadius = 30
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        containerView.layer.shadowRadius = 20
        containerView.layer.shadowOpacity = 0.6
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        titleLabel.text = won ? "🎉 VICTORY! 🎉" : "😔 GAME OVER"
        titleLabel.font = UIFont(name: "AvenirNext-Heavy", size: 40)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        scoreLabel.text = "Score: \(score)"
        scoreLabel.font = UIFont(name: "AvenirNext-Bold", size: 32)
        scoreLabel.textColor = UIColor(red: 1.0, green: 0.9, blue: 0.4, alpha: 1.0)
        scoreLabel.textAlignment = .center
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(scoreLabel)
        
        longestWordLabel.text = "Longest: \(longestWord)"
        longestWordLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
        longestWordLabel.textColor = .white
        longestWordLabel.textAlignment = .center
        longestWordLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(longestWordLabel)
        
        // Stars for level mode
        if case .level(let level) = gameMode, won {
            starsStack.axis = .horizontal
            starsStack.spacing = 15
            starsStack.distribution = .fillEqually
            starsStack.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(starsStack)
            
            let stars = level.calculateStars(score: score)
            for i in 0..<3 {
                let starLabel = UILabel()
                starLabel.text = i < stars ? "⭐" : "☆"
                starLabel.font = UIFont.systemFont(ofSize: 50)
                starLabel.textAlignment = .center
                starsStack.addArrangedSubview(starLabel)
            }
        }
        
        setupButton(retryButton, title: "↻ Retry", color: UIColor(red: 0.9, green: 0.5, blue: 0.2, alpha: 1.0))
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        
        setupButton(menuButton, title: "🏠 Menu", color: UIColor(red: 0.5, green: 0.5, blue: 0.7, alpha: 1.0))
        menuButton.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)
        
        if case .level = gameMode, won {
            setupButton(nextLevelButton, title: "➡ Next Level", color: UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0))
            nextLevelButton.addTarget(self, action: #selector(nextLevelTapped), for: .touchUpInside)
        }
        
        setupConstraints()
    }
    
    private func setupButton(_ button: UIButton, title: String, color: UIColor) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 22)
        button.backgroundColor = color
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.4
        button.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(button)
    }
    
    private func setupConstraints() {
        var constraints = [
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 360),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            scoreLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            scoreLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            longestWordLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 15),
            longestWordLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ]
        
        var lastAnchor: NSLayoutYAxisAnchor = longestWordLabel.bottomAnchor
        
        if case .level = gameMode, won {
            constraints.append(contentsOf: [
                starsStack.topAnchor.constraint(equalTo: longestWordLabel.bottomAnchor, constant: 25),
                starsStack.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                starsStack.heightAnchor.constraint(equalToConstant: 60),
                starsStack.widthAnchor.constraint(equalToConstant: 180)
            ])
            lastAnchor = starsStack.bottomAnchor
            
            constraints.append(contentsOf: [
                nextLevelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                nextLevelButton.topAnchor.constraint(equalTo: lastAnchor, constant: 30),
                nextLevelButton.widthAnchor.constraint(equalToConstant: 280),
                nextLevelButton.heightAnchor.constraint(equalToConstant: 60)
            ])
            lastAnchor = nextLevelButton.bottomAnchor
        }
        
        constraints.append(contentsOf: [
            retryButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: lastAnchor, constant: 20),
            retryButton.widthAnchor.constraint(equalToConstant: 280),
            retryButton.heightAnchor.constraint(equalToConstant: 60),
            
            menuButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            menuButton.topAnchor.constraint(equalTo: retryButton.bottomAnchor, constant: 20),
            menuButton.widthAnchor.constraint(equalToConstant: 280),
            menuButton.heightAnchor.constraint(equalToConstant: 60),
            menuButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func animateEntrance() {
        containerView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        containerView.alpha = 0
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            self.containerView.transform = .identity
            self.containerView.alpha = 1
        }
        
        if won {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showConfetti()
            }
        }
    }
    
    private func showConfetti() {
        for _ in 0..<50 {
            let confetti = UILabel()
            confetti.text = ["🎉", "⭐", "✨", "🌟"].randomElement()
            confetti.font = UIFont.systemFont(ofSize: 30)
            confetti.frame = CGRect(x: CGFloat.random(in: 0...view.bounds.width),
                                   y: -50, width: 40, height: 40)
            view.addSubview(confetti)
            
            UIView.animate(withDuration: 3.0, delay: 0, options: [.curveEaseIn]) {
                confetti.frame.origin.y = self.view.bounds.height + 50
                confetti.transform = CGAffineTransform(rotationAngle: .pi * 4)
            } completion: { _ in
                confetti.removeFromSuperview()
            }
        }
    }
    
    private func saveProgress() {
        if case .level(var level) = gameMode, won {
            level.stars = max(level.stars, level.calculateStars(score: score))
            
            var levels = Level.loadLevels()
            if let index = levels.firstIndex(where: { $0.number == level.number }) {
                levels[index] = level
                
                // Unlock next level
                if index + 1 < levels.count {
                    levels[index + 1].isUnlocked = true
                }
                
                if let encoded = try? JSONEncoder().encode(levels) {
                    UserDefaults.standard.set(encoded, forKey: "savedLevels")
                }
            }
        }
    }
    
    @objc private func nextLevelTapped() {
        if case .level(let level) = gameMode {
            var levels = Level.loadLevels()
            if let savedLevels = UserDefaults.standard.data(forKey: "savedLevels"),
               let decoded = try? JSONDecoder().decode([Level].self, from: savedLevels) {
                levels = decoded
            }
            
            if let nextLevel = levels.first(where: { $0.number == level.number + 1 && $0.isUnlocked }) {
                let gameVC = ComboGameVC(mode: .level(nextLevel))
                gameVC.modalPresentationStyle = .fullScreen
                
                // Dismiss this and present new game
                presentingViewController?.presentingViewController?.dismiss(animated: false) {
                    UIApplication.shared.windows.first?.rootViewController?.present(gameVC, animated: true)
                }
            }
        }
    }
    
    @objc private func retryTapped() {
        let gameVC = ComboGameVC(mode: gameMode)
        gameVC.modalPresentationStyle = .fullScreen
        
        presentingViewController?.presentingViewController?.dismiss(animated: false) {
            UIApplication.shared.windows.first?.rootViewController?.present(gameVC, animated: true)
        }
    }
    
    @objc private func menuTapped() {
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
}
