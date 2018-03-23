//
//  ErrorUtils.swift
//  Whistler
//
//  Created by Kavin Varnan on 21/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import SwiftyJSON

class ErrorUtils {
    static func createErrorObjectFrom(json: JSON) -> ErrorModel? {
        if let errorJsonObject = json["error"].dictionary {
            return ErrorModel(code: errorJsonObject["code"]!.intValue, message: errorJsonObject["message"]?.stringValue)
        }
        return nil;
    }
}
