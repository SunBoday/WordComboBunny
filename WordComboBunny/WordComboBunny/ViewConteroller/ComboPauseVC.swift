//
//  ComboPauseVC.swift
//  WordComboBunny
//
//  Created by SunTory2025 on 2025/10/28.
//

import UIKit

class ComboPauseVC: UIViewController {
    
    var onResume: (() -> Void)?
    var onQuit: (() -> Void)?
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let resumeButton = UIButton()
    private let restartButton = UIButton()
    private let quitButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        animateEntrance()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        containerView.backgroundColor = UIColor(white: 0.15, alpha: 0.95)
        containerView.layer.cornerRadius = 30
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        containerView.layer.shadowRadius = 20
        containerView.layer.shadowOpacity = 0.5
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        titleLabel.text = "PAUSED"
        titleLabel.font = UIFont(name: "AvenirNext-Heavy", size: 42)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        setupButton(resumeButton, title: "▶ Resume", color: UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0))
        resumeButton.addTarget(self, action: #selector(resumeTapped), for: .touchUpInside)
        
        setupButton(restartButton, title: "↻ Restart", color: UIColor(red: 0.9, green: 0.5, blue: 0.2, alpha: 1.0))
        restartButton.addTarget(self, action: #selector(restartTapped), for: .touchUpInside)
        
        setupButton(quitButton, title: "⏹ Quit", color: UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0))
        quitButton.addTarget(self, action: #selector(quitTapped), for: .touchUpInside)
        
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
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(button)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 340),
            containerView.heightAnchor.constraint(equalToConstant: 400),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            resumeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            resumeButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            resumeButton.widthAnchor.constraint(equalToConstant: 260),
            resumeButton.heightAnchor.constraint(equalToConstant: 60),
            
            restartButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            restartButton.topAnchor.constraint(equalTo: resumeButton.bottomAnchor, constant: 20),
            restartButton.widthAnchor.constraint(equalToConstant: 260),
            restartButton.heightAnchor.constraint(equalToConstant: 60),
            
            quitButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            quitButton.topAnchor.constraint(equalTo: restartButton.bottomAnchor, constant: 20),
            quitButton.widthAnchor.constraint(equalToConstant: 260),
            quitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func animateEntrance() {
        containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        containerView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.containerView.transform = .identity
            self.containerView.alpha = 1
        }
    }
    
    @objc private func resumeTapped() {
        dismiss(animated: true) {
            self.onResume?()
        }
    }
    
    @objc private func restartTapped() {
        dismiss(animated: true) {
            self.onQuit?()
        }
    }
    
    @objc private func quitTapped() {
        dismiss(animated: true) {
            self.onQuit?()
        }
    }
}
