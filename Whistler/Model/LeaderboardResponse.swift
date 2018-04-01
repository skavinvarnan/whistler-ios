//
//  LeaderboardResponse.swift
//  Whistler
//
//  Created by Kavin Varnan on 01/04/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON

class LeaderboardResponse: JSONDecodable {
    let items: [LeaderBoardItem]?
    let error: ErrorModel?
    
    required init(json: JSON) {
        var items = [LeaderBoardItem]()
        let array = json["leaderBoard"].array;
        if array != nil {
            for groupJson in array! {
                let uid = groupJson["uid"].stringValue
                let name = groupJson["name"].stringValue
                let totalForMatch = groupJson["total_for_match"].intValue
                
                let obj = LeaderBoardItem(uid: uid, name: name, totalForMatch: totalForMatch)
                items.append(obj)
            }
        }
        self.error = ErrorUtils.createErrorObjectFrom(json: json)
        self.items = items
    }
}
