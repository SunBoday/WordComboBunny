//
//  ComboLeaderboardVC.swift
//  WordComboBunny
//
//  Created by SunTory2025 on 2025/10/28.
//

import UIKit

class ComboLeaderboardVC: UIViewController {
    
    private let backgroundImageView = UIImageView()
    private let tableView = UITableView()
    
    private let headerContainer = UIView()
    private let titleLabel = UILabel()
    private let backButton = UIButton()
    private let yourRankCard = UIView()
    private let yourRankLabel = UILabel()
    
    private var scores: [LeaderboardEntry] = []
    private var yourBestScore: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadScores()
        setupBackground()
        setupHeader()
        setupYourRankCard()
        setupTableView()
        animateEntrance()
    }
    
    private func loadScores() {
        // Get your best score
        yourBestScore = LeaderboardManager.shared.getPlayerBestScore()
        
        // Get combined leaderboard (your scores + random players)
        scores = LeaderboardManager.shared.getLeaderboard()
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
        
        titleLabel.text = "🏆 LEADERBOARD"
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
    
    private func setupYourRankCard() {
        // Find your rank
        let yourRank = scores.firstIndex(where: { $0.isYou }) ?? -1
        
        yourRankCard.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 0.3)
        yourRankCard.layer.cornerRadius = 18
        yourRankCard.layer.borderWidth = 3
        yourRankCard.layer.borderColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0).cgColor
        yourRankCard.layer.shadowColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0).cgColor
        yourRankCard.layer.shadowOffset = CGSize(width: 0, height: 0)
        yourRankCard.layer.shadowRadius = 15
        yourRankCard.layer.shadowOpacity = 0.6
        yourRankCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(yourRankCard)
        
        // Pulsing glow
        let pulse = CABasicAnimation(keyPath: "shadowRadius")
        pulse.fromValue = 12
        pulse.toValue = 20
        pulse.duration = 1.5
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        yourRankCard.layer.add(pulse, forKey: "pulse")
        
        let rankText = yourRank >= 0 ? "Your Rank: #\(yourRank + 1)" : "Not Ranked Yet"
        yourRankLabel.text = "\(rankText) • Best: \(yourBestScore)"
        yourRankLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        yourRankLabel.textColor = .white
        yourRankLabel.textAlignment = .center
        yourRankLabel.translatesAutoresizingMaskIntoConstraints = false
        yourRankCard.addSubview(yourRankLabel)
        
        NSLayoutConstraint.activate([
            yourRankCard.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 15),
            yourRankCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            yourRankCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            yourRankCard.heightAnchor.constraint(equalToConstant: 55),
            
            yourRankLabel.centerXAnchor.constraint(equalTo: yourRankCard.centerXAnchor),
            yourRankLabel.centerYAnchor.constraint(equalTo: yourRankCard.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(LeaderboardCell.self, forCellReuseIdentifier: "LeaderboardCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: yourRankCard.bottomAnchor, constant: 15),
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
        
        yourRankCard.alpha = 0
        yourRankCard.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.yourRankCard.alpha = 1
            self.yourRankCard.transform = .identity
        }
        
        tableView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.4) {
            self.tableView.alpha = 1
        }
    }
    
    @objc private func backTapped() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        dismiss(animated: true)
    }
}

// MARK: - UITableView Delegate & DataSource
extension ComboLeaderboardVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as! LeaderboardCell
        let entry = scores[indexPath.row]
        cell.configure(entry: entry, rank: indexPath.row + 1)
        
        // Staggered animation
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: -50, y: 0)
        
        UIView.animate(withDuration: 0.5, delay: Double(indexPath.row) * 0.04, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            cell.alpha = 1
            cell.transform = .identity
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Leaderboard Cell
class LeaderboardCell: UITableViewCell {
    
    private let cardView = UIView()
    private let rankLabel = UILabel()
    private let crownImageView = UIImageView()
    private let nameLabel = UILabel()
    private let scoreLabel = UILabel()
    private let dateLabel = UILabel()
    private let youBadge = UILabel()
    
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
        cardView.layer.cornerRadius = 18
        cardView.layer.borderWidth = 2
        cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOpacity = 0.3
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        // Rank
        rankLabel.font = UIFont(name: "AvenirNext-Heavy", size: 28)
        rankLabel.textColor = .white
        rankLabel.textAlignment = .center
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(rankLabel)
        
        // Crown for top 3
        let crownConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        crownImageView.image = UIImage(systemName: "crown.fill", withConfiguration: crownConfig)
        crownImageView.contentMode = .scaleAspectFit
        crownImageView.isHidden = true
        crownImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(crownImageView)
        
        // Name
        nameLabel.font = UIFont(name: "AvenirNext-Bold", size: 18)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)
        
        // Score
        scoreLabel.font = UIFont(name: "AvenirNext-Heavy", size: 24)
        scoreLabel.textColor = .white
        scoreLabel.textAlignment = .right
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(scoreLabel)
        
        // Date
        dateLabel.font = UIFont(name: "AvenirNext-Medium", size: 11)
        dateLabel.textColor = UIColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 1.0)
        dateLabel.textAlignment = .right
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(dateLabel)
        
        // "YOU" badge
        youBadge.text = "YOU"
        youBadge.font = UIFont(name: "AvenirNext-Heavy", size: 10)
        youBadge.textColor = .white
        youBadge.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
        youBadge.textAlignment = .center
        youBadge.layer.cornerRadius = 8
        youBadge.clipsToBounds = true
        youBadge.isHidden = true
        youBadge.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(youBadge)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            rankLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            rankLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 45),
            
            crownImageView.topAnchor.constraint(equalTo: rankLabel.topAnchor, constant: -8),
            crownImageView.centerXAnchor.constraint(equalTo: rankLabel.centerXAnchor),
            crownImageView.widthAnchor.constraint(equalToConstant: 22),
            crownImageView.heightAnchor.constraint(equalToConstant: 22),
            
            nameLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor, constant: -8),
            
            youBadge.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            youBadge.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            youBadge.widthAnchor.constraint(equalToConstant: 40),
            youBadge.heightAnchor.constraint(equalToConstant: 18),
            
            scoreLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            scoreLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor, constant: -8),
            
            dateLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            dateLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 2)
        ])
    }
    
    func configure(entry: LeaderboardEntry, rank: Int) {
        rankLabel.text = "#\(rank)"
        nameLabel.text = entry.playerName
        scoreLabel.text = "\(entry.score)"
        youBadge.isHidden = !entry.isYou
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        dateLabel.text = formatter.string(from: entry.date)
        
        // Special styling for top 3
        if rank == 1 {
            rankLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0) // Gold
            crownImageView.tintColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
            crownImageView.isHidden = false
            cardView.backgroundColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.25)
            cardView.layer.borderColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.6).cgColor
            
            // Shimmer animation
            addShimmerAnimation()
        } else if rank == 2 {
            rankLabel.textColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0) // Silver
            crownImageView.tintColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
            crownImageView.isHidden = false
            cardView.backgroundColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.2)
            cardView.layer.borderColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.5).cgColor
        } else if rank == 3 {
            rankLabel.textColor = UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 1.0) // Bronze
            crownImageView.tintColor = UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 1.0)
            crownImageView.isHidden = false
            cardView.backgroundColor = UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 0.2)
            cardView.layer.borderColor = UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 0.5).cgColor
        } else {
            rankLabel.textColor = .white
            crownImageView.isHidden = true
            cardView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        }
        
        // Highlight your entry
        if entry.isYou {
            cardView.layer.borderColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0).cgColor
            cardView.layer.borderWidth = 3
        }
    }
    
    private func addShimmerAnimation() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = cardView.bounds
        
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -cardView.bounds.width
        animation.toValue = cardView.bounds.width
        animation.duration = 2.0
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: "shimmer")
        
        cardView.layer.addSublayer(gradient)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cardView.layer.sublayers?.forEach { if $0 is CAGradientLayer { $0.removeFromSuperlayer() } }
    }
}

// MARK: - Leaderboard Entry Model
struct LeaderboardEntry: Codable {
    let playerName: String
    let score: Int
    let date: Date
    let isYou: Bool
}

// MARK: - Enhanced Leaderboard Manager
class LeaderboardManager {
    static let shared = LeaderboardManager()
    private let scoresKey = "player_scores"
    
    private let randomNames = [
        "Alex", "Jordan", "Sam", "Taylor", "Morgan", "Casey", "Riley", "Avery",
        "Quinn", "Blake", "Cameron", "Drew", "Skyler", "Reese", "Rowan", "Sage",
        "Parker", "Peyton", "River", "Phoenix", "Dakota", "Charlie", "Finley", "Hayden"
    ]
    
    func addScore(_ score: Int) {
        // Get existing scores
        var scores = getPlayerScores()
        
        // Add new score
        scores.append(score)
        
        // Sort highest to lowest
        scores.sort(by: >)
        
        // ✅ SAVE TO USERDEFAULTS
        savePlayerScores(scores)
    }

    private func savePlayerScores(_ scores: [Int]) {
        if let data = try? JSONEncoder().encode(scores) {
            // ✅ PERSISTED HERE
            UserDefaults.standard.set(data, forKey: scoresKey)
        }
    }
    
    func getPlayerBestScore() -> Int {
        return getPlayerScores().first ?? 0
    }
    
    func getLeaderboard() -> [LeaderboardEntry] {
        var entries: [LeaderboardEntry] = []
        
        // Add player scores
        let playerScores = getPlayerScores()
        for score in playerScores {
            entries.append(LeaderboardEntry(
                playerName: "You",
                score: score,
                date: Date(),
                isYou: true
            ))
        }
        
        // Add random players to fill leaderboard
        let randomCount = max(0, 20 - entries.count)
        for _ in 0..<randomCount {
            let randomScore = Int.random(in: 500...15000)
            let randomName = randomNames.randomElement()!
            let randomDaysAgo = Int.random(in: 1...30)
            let randomDate = Calendar.current.date(byAdding: .day, value: -randomDaysAgo, to: Date())!
            
            entries.append(LeaderboardEntry(
                playerName: randomName,
                score: randomScore,
                date: randomDate,
                isYou: false
            ))
        }
        
        // Sort by score
        entries.sort { $0.score > $1.score }
        
        // Keep top 20
        return Array(entries.prefix(20))
    }
    
    private func getPlayerScores() -> [Int] {
        guard let data = UserDefaults.standard.data(forKey: scoresKey),
              let scores = try? JSONDecoder().decode([Int].self, from: data) else {
            return []
        }
        return scores
    }
    

    
    func isHighScore(_ score: Int) -> Bool {
        let scores = getPlayerScores()
        return scores.isEmpty || score > (scores.first ?? 0)
    }
}
