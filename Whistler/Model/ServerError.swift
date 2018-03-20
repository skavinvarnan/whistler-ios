//
//  ServerError.swift
//  Whistler
//
//  Created by Kavin Varnan on 20/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON

class ServerError: JSONDecodable {
    required init(json: JSON) throws {
        print("Json Error \n", json);
    }
}
