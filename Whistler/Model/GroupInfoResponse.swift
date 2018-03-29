//
//  GroupInfoResponse.swift
//  Whistler
//
//  Created by Kavin Varnan on 28/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON

class GroupInfoResponse: JSONDecodable {
    let users: [GroupInfoItem]?
    let error: ErrorModel?
    
    required init(json: JSON) throws {
        
        var users = [GroupInfoItem]()
        let array = json["groupMembers"].array;
        if array != nil {
            for groupJson in array! {
                let name = groupJson["name"].stringValue
                let uid = groupJson["uid"].stringValue
                let overAllPoints = groupJson["over_all_points"].intValue
                let totalForMatch = groupJson["total_for_match"].intValue
                
                let group = GroupInfoItem(name: name, uid: uid, totalForMatch: totalForMatch, overAll: overAllPoints)
                users.append(group)
            }
        }
        self.error = ErrorUtils.createErrorObjectFrom(json: json)
        self.users = users
    }
}
