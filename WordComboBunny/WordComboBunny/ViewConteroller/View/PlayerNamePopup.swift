//
//  PlayerNamePopup.swift
//  WordComboBunny
//
//  Created by SunTory2025 on 2025/10/28.
//

import UIKit

class PlayerNamePopup: UIView {
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let textFieldContainer = UIView()
    private let nameTextField = UITextField()
    private let confirmButton = UIButton()
    private let skipButton = UIButton()
    
    var onNameConfirmed: ((String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        animateIn()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        // Container
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        containerView.layer.cornerRadius = 25
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        containerView.layer.shadowRadius = 30
        containerView.layer.shadowOpacity = 0.5
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // Title
        titleLabel.text = "👋 Welcome!"
        titleLabel.font = UIFont(name: "AvenirNext-Heavy", size: 32)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // Subtitle
        subtitleLabel.text = "What's your name?"
        subtitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 16)
        subtitleLabel.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(subtitleLabel)
        
        // Text field container
        textFieldContainer.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        textFieldContainer.layer.cornerRadius = 15
        textFieldContainer.layer.borderWidth = 2
        textFieldContainer.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0).cgColor
        textFieldContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(textFieldContainer)
        
        // Text field
        nameTextField.placeholder = "Enter your name"
        nameTextField.font = UIFont(name: "AvenirNext-Medium", size: 18)
        nameTextField.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        nameTextField.textAlignment = .center
        nameTextField.autocapitalizationType = .words
        nameTextField.autocorrectionType = .no
        nameTextField.returnKeyType = .done
        nameTextField.delegate = self
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        textFieldContainer.addSubview(nameTextField)
        
        // Confirm button
        confirmButton.setTitle("Let's Play! 🎮", for: .normal)
        confirmButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 18)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
        confirmButton.layer.cornerRadius = 15
        confirmButton.layer.shadowColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0).cgColor
        confirmButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        confirmButton.layer.shadowRadius = 10
        confirmButton.layer.shadowOpacity = 0.5
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(confirmButton)
        
        // Skip button
        skipButton.setTitle("Skip", for: .normal)
        skipButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 14)
        skipButton.setTitleColor(UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0), for: .normal)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(skipButton)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            textFieldContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            textFieldContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            textFieldContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            textFieldContainer.heightAnchor.constraint(equalToConstant: 55),
            
            nameTextField.topAnchor.constraint(equalTo: textFieldContainer.topAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor, constant: 15),
            nameTextField.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor, constant: -15),
            nameTextField.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor),
            
            confirmButton.topAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: 25),
            confirmButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            confirmButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            confirmButton.heightAnchor.constraint(equalToConstant: 55),
            
            skipButton.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 15),
            skipButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            skipButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -25)
        ])
        
        // Keyboard dismissal
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        addGestureRecognizer(tap)
    }
    
    private func animateIn() {
        containerView.alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.containerView.alpha = 1
            self.containerView.transform = .identity
        }
        
        // Auto-focus text field
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.nameTextField.becomeFirstResponder()
        }
    }
    
    @objc private func confirmTapped() {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let playerName = name.isEmpty ? "Player" : name
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Save name
        UserDefaults.standard.set(playerName, forKey: "playerName")
        
        animateOut {
            self.onNameConfirmed?(playerName)
        }
    }
    
    @objc private func skipTapped() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        UserDefaults.standard.set("Player", forKey: "playerName")
        
        animateOut {
            self.onNameConfirmed?("Player")
        }
    }
    
    @objc private func dismissKeyboard() {
        nameTextField.resignFirstResponder()
    }
    
    private func animateOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.alpha = 0
        }) { _ in
            completion()
            self.removeFromSuperview()
        }
    }
}

extension PlayerNamePopup: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        confirmTapped()
        return true
    }
}
