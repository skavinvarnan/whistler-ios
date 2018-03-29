//
//  WhistlerManager.swift
//  Whistler
//
//  Created by Kavin Varnan on 28/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit

class WhistlerManager: NSObject {
    static let sharedInstance = WhistlerManager()
    
    var happeningMatchs = [Schedule]()
    var currentMatch: Schedule?
    
    private override init() {
        
    }
}
