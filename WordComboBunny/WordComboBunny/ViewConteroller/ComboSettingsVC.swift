//
//  ComboSettingsVC.swift
//  WordComboBunny
//
//  Created by SunTory2025 on 2025/10/28.
//

import UIKit
import StoreKit

class ComboSettingsVC: UIViewController {
    
    private let backgroundImageView = UIImageView()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private let headerContainer = UIView()
    private let titleLabel = UILabel()
    private let backButton = UIButton()
    
    private let settingsData: [(title: String, items: [(icon: String, title: String, action: SettingsAction)])] = [
        ("General", [
            ("star.fill", "Rate This App", .rateApp),
            ("info.circle.fill", "About Us", .aboutUs)
        ]),
        ("Legal", [
            ("hand.raised.fill", "Privacy Policy", .privacy)
        ]),
        ("App Info", [
            ("app.badge.fill", "Version", .version)
        ])
    ]
    
    enum SettingsAction {
        case rateApp, aboutUs, privacy, version
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupHeader()
        setupTableView()
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
        
        titleLabel.text = "⚙️ SETTINGS"
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
    
    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
        
        tableView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.3) {
            self.tableView.alpha = 1
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
    
    private func handleAction(_ action: SettingsAction) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        switch action {
        case .rateApp:
            rateApp()
        case .aboutUs:
            showAboutUs()
        case .privacy:
            showPrivacyPolicy()
        case .version:
            break
        }
    }
    
    private func rateApp() {
        if let scene = view.window?.windowScene {
            if #available(iOS 14.0, *) {
                SKStoreReviewController.requestReview(in: scene)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    private func showAboutUs() {
        let aboutVC = ComboAboutUsVC()
        aboutVC.modalPresentationStyle = .fullScreen
        present(aboutVC, animated: true)
    }
    
    private func showPrivacyPolicy() {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ComboPrivacyPolicyVC") as? ComboPrivacyPolicyVC
        present(vc!, animated: true)

    }
}

// MARK: - UITableView Delegate & DataSource
extension ComboSettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsData[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsData[section].title
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont(name: "AvenirNext-Bold", size: 14)
            header.textLabel?.textColor = UIColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 1.0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        let item = settingsData[indexPath.section].items[indexPath.row]
        
        if item.action == .version {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
            cell.configure(icon: item.icon, title: item.title, detail: "v\(version)", showArrow: false)
        } else {
            cell.configure(icon: item.icon, title: item.title, detail: nil, showArrow: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let action = settingsData[indexPath.section].items[indexPath.row].action
        
        if let cell = tableView.cellForRow(at:indexPath) {
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    cell.transform = .identity
                } completion: { _ in
                    self.handleAction(action)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - Settings Cell
class SettingsCell: UITableViewCell {
    
    private let cardView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let arrowView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        cardView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 2
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOpacity = 0.3
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .white
        iconView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconView)
        
        titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 18)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)
        
        detailLabel.font = UIFont(name: "AvenirNext-Medium", size: 16)
        detailLabel.textColor = UIColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 1.0)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(detailLabel)
        
        let arrowConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        arrowView.image = UIImage(systemName: "chevron.right", withConfiguration: arrowConfig)
        arrowView.tintColor = UIColor.white.withAlphaComponent(0.6)
        arrowView.contentMode = .scaleAspectFit
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(arrowView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            iconView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            
            detailLabel.trailingAnchor.constraint(equalTo: arrowView.leadingAnchor, constant: -12),
            detailLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            
            arrowView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            arrowView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            arrowView.widthAnchor.constraint(equalToConstant: 12),
            arrowView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    func configure(icon: String, title: String, detail: String?, showArrow: Bool) {
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        iconView.image = UIImage(systemName: icon, withConfiguration: iconConfig)
        titleLabel.text = title
        detailLabel.text = detail
        detailLabel.isHidden = detail == nil
        arrowView.isHidden = !showArrow
    }
}
