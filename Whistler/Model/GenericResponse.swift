//
//  GenericResponse.swift
//  Whistler
//
//  Created by Kavin Varnan on 21/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON

class GenericResponse: JSONDecodable {
    let success: Bool?
    let error: ErrorModel?
    required init(json: JSON) throws {
        self.success = json["success"].bool
        self.error = ErrorUtils.createErrorObjectFrom(json: json)
    }
}
