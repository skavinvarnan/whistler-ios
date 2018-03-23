//
//  GroupList.swift
//  Whistler
//
//  Created by Kavin Varnan on 20/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON

class GroupList: JSONDecodable {
    
    let groups: [GroupModel]?
    let error: ErrorModel?

    required init(json: JSON) throws {
        
        var groups = [GroupModel]()
        let array = json["groups"].array;
        if array != nil {
            for groupJson in array! {
                let groupId = groupJson["groupId"].stringValue
                let name = groupJson["name"].stringValue
                let icon = groupJson["icon"].stringValue
                let joinCode = groupJson["joinCode"].stringValue
                let admin = groupJson["admin"].stringValue
                let memberArray = groupJson["members"].array
                let id = groupJson["_id"].stringValue
                
                var memberArrayString = [String]()
                for memberJson in memberArray! {
                    memberArrayString.append(memberJson.stringValue)
                }
                let group = GroupModel(id: id, groupId: groupId, name: name, icon: icon, joinCode: joinCode, admin: admin, members: memberArrayString)
                groups.append(group)
            }
        }
        self.error = ErrorUtils.createErrorObjectFrom(json: json)
        self.groups = groups
    }
}
