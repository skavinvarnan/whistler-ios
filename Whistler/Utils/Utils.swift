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
    }
    
    struct Tron {
        static let BASE_URL = "http://192.168.1.139:7325/api"
    }
}
