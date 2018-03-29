//
//  UserPredictionItemResponse.swift
//  Whistler
//
//  Created by Kavin Varnan on 29/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON

class UserPredictionItemResponse: JSONDecodable {
    let userPredictions: [UserPredictionItem]?
    let error: ErrorModel?
    
    required init(json: JSON) {
        var userPredictions = [UserPredictionItem]()
        let array = json["userPrediction"].array;
        if array != nil {
            for groupJson in array! {
                let over = groupJson["over"].stringValue
                let runs = groupJson["runs"].stringValue
                let predicted = groupJson["predicted"].stringValue
                let points = groupJson["points"].stringValue
                
                let obj = UserPredictionItem(over: over, runs: runs, predicted: predicted, points: points)
                userPredictions.append(obj)
            }
        }
        self.error = ErrorUtils.createErrorObjectFrom(json: json)
        self.userPredictions = userPredictions
    }
}
