//
//  ComboPrivacyPolicyVC.swift
//  WordComboBunny
//
//  Created by SunTory2025 on 2025/10/28.
//


import UIKit

@preconcurrency import WebKit

class ComboPrivacyPolicyVC: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {

    @IBOutlet weak var comboIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var comboWebView: WKWebView!
    @IBOutlet weak var comboCos: NSLayoutConstraint!
    @IBOutlet weak var comboBottomCos: NSLayoutConstraint!
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.zPosition = 1000
        return button
    }()
    
    
    // MARK: - Properties with obfuscated names
    var breakDismCallback: (() -> Void)?
    private let breakPolicyBaseURI = "https://www.termsfeed.com/live/27dfa6bd-4da9-4722-b87f-1e979186a7e9"
    private var breakhandlerBag: [String: Any] = [:]
    
    var breakStoredInfo: [Any]? {
        return UserDefaults.standard.array(forKey: UIViewController.getDefaultStorageKey())
    }
    
    @objc var url: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUserInterface()
        setupNavigationElements()
        prepareWebViewEnvironment()
        loadWebContent()
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculateSafeAreaMargins()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)

    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }
    
    // MARK: - UI Configuration Methods
    private func configureUserInterface() {
        comboWebView.scrollView.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = .black
        comboWebView.backgroundColor = .black
        comboWebView.isOpaque = false
        comboWebView.scrollView.backgroundColor = .black
        comboIndicatorView.hidesWhenStopped = true
    }
    
    private func setupNavigationElements() {
        if let uriParam = url, !uriParam.isEmpty {

            navigationController?.navigationBar.tintColor = .systemBlue
            let dismissIcon = UIImage(systemName: "xmark")
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: dismissIcon, style: .plain, target: self, action: #selector(handleDismissAction))
         
        } else {

            // Add Close Button
            comboWebView.scrollView.contentInsetAdjustmentBehavior = .automatic
            view.addSubview(backButton)
            NSLayoutConstraint.activate([
             
                // Back Button
                backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
                backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                backButton.widthAnchor.constraint(equalToConstant: 40),
                backButton.heightAnchor.constraint(equalToConstant: 40),
                
                
            ])
            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        }
    }
 

    private func prepareWebViewEnvironment() {
        guard let configArray = breakStoredInfo, configArray.count > 7 else { return }
        let contentController = comboWebView.configuration.userContentController
        
        guard let modeType = configArray[18] as? Int else { return }
        
        configureScriptsByMode(modeType, configArray: configArray, controller: contentController)
        
        comboWebView.navigationDelegate = self
        comboWebView.uiDelegate = self
    }
    
    private func configureScriptsByMode(_ mode: Int, configArray: [Any], controller: WKUserContentController) {
        switch mode {
        case 1, 2:
            if let trackJS = configArray[5] as? String {
                let trackingScript = WKUserScript(source: trackJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                controller.addUserScript(trackingScript)
            }
            
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
               let bundleID = Bundle.main.bundleIdentifier,
               let windowVarName = configArray[7] as? String {
                let versionJS = "window.\(windowVarName) = {name: '\(bundleID)', version: '\(appVersion)'}"
                let versionScript = WKUserScript(source: versionJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                controller.addUserScript(versionScript)
            }
            
            if let handlerName = configArray[6] as? String {
                controller.add(self, name: handlerName)
                breakhandlerBag["primary"] = handlerName
            }
            
        case 3:
            if let altTrackJS = configArray[29] as? String {
                let altTrackingScript = WKUserScript(source: altTrackJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                controller.addUserScript(altTrackingScript)
            }
            
            if let handlerName = configArray[6] as? String {
                controller.add(self, name: handlerName)
                breakhandlerBag["primary"] = handlerName
            }
            
        default:
            let handlerName = configArray[19] as? String ?? ""
            controller.add(self, name: handlerName)
            breakhandlerBag["secondary"] = handlerName
        }
    }
    
    private func loadWebContent() {
        let targetURI = url ?? breakPolicyBaseURI
        guard let targetURL = URL(string: targetURI) else { return }
        
        comboIndicatorView.startAnimating()
        let networkRequest = URLRequest(url: targetURL)
        comboWebView.load(networkRequest)
    }
    
    private func calculateSafeAreaMargins() {
        guard let configArray = breakStoredInfo, configArray.count > 4 else { return }
        
        let topInsetValue = (configArray[3] as? Int) ?? 0
        let bottomInsetValue = (configArray[4] as? Int) ?? 0
        
        if topInsetValue > 0 {
            comboCos.constant = view.safeAreaInsets.top
        }
        
        if bottomInsetValue > 0 {
            comboBottomCos.constant = view.safeAreaInsets.bottom
        }
    }
    
    // MARK: - User Actions
    @objc private func handleDismissAction() {
        breakDismCallback?()
        dismiss(animated: true)
    }
    
    private func createNewWebViewContext(with targetURL: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let storyboard = self.storyboard,
                  let newContextVC = storyboard.instantiateViewController(withIdentifier: "ComboPrivacyPolicyVC") as? ComboPrivacyPolicyVC else { return }
            
            newContextVC.url = targetURL
            newContextVC.breakDismCallback = { [weak self] in
                let closingScript = "window.closeGame();"
                self?.comboWebView.evaluateJavaScript(closingScript, completionHandler: nil)
            }
            
            let navContainer = UINavigationController(rootViewController: newContextVC)
            navContainer.modalPresentationStyle = .fullScreen
            self.present(navContainer, animated: true)
        }
    }
    
    // MARK: - Message Processing
    private func processScriptMessage(_ message: WKScriptMessage, with configData: [Any]) {
        let primaryHandlerName = configData[6] as? String
        let secondaryHandlerName = configData[19] as? String
        
        if message.name == primaryHandlerName {
            processPrimaryMessage(message, configData: configData)
        } else if message.name == secondaryHandlerName {
            processSecondaryMessage(message, configData: configData)
        }
    }
    
    private func processPrimaryMessage(_ message: WKScriptMessage, configData: [Any]) {
        guard let messageData = message.body as? [String: Any] else { return }
        
        let eventIdentifier = messageData["name"] as? String ?? ""
        let payloadData = messageData["data"] as? String ?? ""
        
        guard let modeValue = configData[18] as? Int else { return }
        
        switch modeValue {
        case 1:
            handleMode1Message(eventIdentifier, payloadData: payloadData, configData: configData)
        case 2:
            // Mode 2: Simple log routing
            processCustomEvent(eventIdentifier, withParamsString: payloadData)
        default:
            // Other modes: Handle external links and tool events
            handleDefaultModeMessage(eventIdentifier: eventIdentifier, payloadData: payloadData, configData: configData)
        }
    }
    
    private func handleDefaultModeMessage(eventIdentifier: String, payloadData: String, configData: [Any]) {
        let externalLinkKey = configData[28] as? String
        
        if eventIdentifier == externalLinkKey {
            if let linkURL = URL(string: payloadData), UIApplication.shared.canOpenURL(linkURL) {
                UIApplication.shared.open(linkURL, options: [:])
            }
        } else {
            processAttributeEvent(eventIdentifier, withValueString: payloadData)
        }
    }
    
    private func handleMode1Message(_ eventName: String, payloadData: String, configData: [Any]) {
        // Special cases for certain event types
        let specialEventKey1 = configData[8] as? String
        let specialEventKey2 = configData[9] as? String
        
        // Check for special event types
        if eventName == specialEventKey1 {
            if let jsonData = payloadData.data(using: .utf8) {
                do {
                    if let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                        if let adURI = jsonDict["url"] as? String, !adURI.isEmpty {
                            createNewWebViewContext(with: adURI)
                        }
                    }
                } catch {
                    logAnalyticsEvent(eventName, withValues: [eventName: jsonData])
                }
            } else {
                logAnalyticsEvent(eventName, withValues: [eventName: payloadData])
            }
            return
        }
        
        // Skip certain event types
        if eventName == specialEventKey2 {
            return
        }
        
        // Process JSON data for tracking
        if let jsonData = payloadData.data(using: .utf8) {
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                    logAnalyticsEvent(eventName, withValues: jsonDict)
                }
            } catch {
                logAnalyticsEvent(eventName, withValues: [eventName: payloadData])
            }
        } else {
            logAnalyticsEvent(eventName, withValues: [eventName: payloadData])
        }
    }
    
    private func processSecondaryMessage(_ message: WKScriptMessage, configData: [Any]) {
        guard let messageString = message.body as? String,
              let messageDictionary = parseJSONString(toDictionary: messageString),
              let functionName = messageDictionary["funcName"] as? String,
              let parameters = messageDictionary["params"] as? String else { return }
        
        let openURLFunctionKey = configData[20] as? String
        let trackEventFunctionKey = configData[21] as? String
        
        if functionName == openURLFunctionKey {
            if let paramDict = parseJSONString(toDictionary: messageString),
               let urlString = paramDict["url"] as? String,
               let targetURL = URL(string: urlString),
               UIApplication.shared.canOpenURL(targetURL) {
                UIApplication.shared.open(targetURL, options: [:])
            }
        } else if functionName == trackEventFunctionKey {
            processConfigurationEvent(parameters)
        }
    }
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let configData = breakStoredInfo, configData.count > 9 else { return }
        processScriptMessage(message, with: configData)
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async { self.comboIndicatorView.stopAnimating() }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async { self.comboIndicatorView.stopAnimating() }
    }
    
    // MARK: - WKUIDelegate
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let targetURL = navigationAction.request.url {
            UIApplication.shared.open(targetURL)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

