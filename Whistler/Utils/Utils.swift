//
//  Utils.swift
//  Whistler
//
//  Created by Kavin Varnan on 20/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit

class Utils: NSObject {
    static func simpleAlertController(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(actionOk)
        return alertController;
    }
}

struct Constants {
    struct UserDefaults {
        static let ACCESS_TOKEN = "ACCESS_TOKEN"
        static let HAPPENING_MATCHES = "HAPPENING_MATCHES"
    }
    
    struct Tron {
        static let BASE_URL = "https://api.guessbuzz.in:7325/api"
    }
    
    struct AdMob {
        static let APPLICATION_ID = "ca-app-pub-7846555754762077~5011167966"
        
        static let UNIT_LIVE = "ca-app-pub-7846555754762077/1155629537"
        static let UNIT_GROUPS = "ca-app-pub-7846555754762077/1738226658"
        static let UNIT_MATCH_REPORT = "ca-app-pub-7846555754762077/9990506793"
        static let UNIT_ALL_MATCHES = "ca-app-pub-7846555754762077/4743663945"
        static let UNIT_MATCH_REPORT_LAST = "ca-app-pub-7846555754762077/2281152131"
        static let UNIT_LEADER_BOARD = "ca-app-pub-7846555754762077/6635739239"
        
        static let TEST_DEVICES: [String] = []
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1) {
        assert(hex[hex.startIndex] == "#", "Expected hex string of format #RRGGBB")
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 1  // skip #
        var rgb: UInt32 = 0
        scanner.scanHexInt32(&rgb)
        self.init(
            red:   CGFloat((rgb & 0xFF0000) >> 16)/255.0,
            green: CGFloat((rgb &   0xFF00) >>  8)/255.0,
            blue:  CGFloat((rgb &     0xFF)      )/255.0,
            alpha: alpha)
    }
}

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhone4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhoneX = "iPhone X"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhoneX
        default:
            return .unknown
        }
    }
}
