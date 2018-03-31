//
//  ScheduleList.swift
//  Whistler
//
//  Created by Kavin Varnan on 22/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON

class ScheduleList: JSONDecodable {
    
    let schedules: [Schedule]?
    let error: ErrorModel?
    
    required init(json: JSON) {
        var schedules = [Schedule]()
        let array = json["schedule"].array;
        if array != nil {
            for groupJson in array! {
                let id = groupJson["_id"].stringValue
                let status = groupJson["status"].stringValue
                let related_name = groupJson["related_name"].stringValue
                let name = groupJson["name"].stringValue
                let short_name = groupJson["short_name"].stringValue
                let venue = groupJson["venue"].stringValue
                let winner_team = groupJson["winner_team"].stringValue
                let team_a = groupJson["team_a"].stringValue
                let team_b = groupJson["team_b"].stringValue
                let team_a_name = groupJson["team_a_name"].stringValue
                let team_b_name = groupJson["team_b_name"].stringValue
                let start_date_timestamp = groupJson["start_date_timestamp"].numberValue
                let key = groupJson["key"].stringValue
                let displayDate = groupJson["displayDate"].stringValue
                let displayTime = groupJson["displayTime"].stringValue
                
                let schedule = Schedule(_id: id, status: status, related_name: related_name, name: name, shortName: short_name, venue: venue, winningTeam: winner_team, startDateTimeStamp: start_date_timestamp, teamA: team_a, teamB: team_b, teamAName: team_a_name, teamBName: team_b_name, key: key, displayDate: displayDate, displayTime: displayTime)
                schedules.append(schedule)
            }
        }
        self.error = ErrorUtils.createErrorObjectFrom(json: json)
        self.schedules = schedules
    }
}
