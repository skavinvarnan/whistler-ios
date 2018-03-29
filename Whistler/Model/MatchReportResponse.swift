//
//  MatchReportResponse.swift
//  Whistler
//
//  Created by Kavin Varnan on 29/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON

class MatchReportResponse: JSONDecodable {
    let matchReports: [MatchReportItem]?
    let error: ErrorModel?
    
    required init(json: JSON) {
        var matchReports = [MatchReportItem]()
        let array = json["allMatches"].array;
        if array != nil {
            for groupJson in array! {
                let match = groupJson["match"].stringValue
                let key = groupJson["key"].stringValue
                let points = groupJson["points"].intValue
                
                let obj = MatchReportItem(match: match, matchKey: key, points: points)
                matchReports.append(obj)
            }
        }
        self.error = ErrorUtils.createErrorObjectFrom(json: json)
        self.matchReports = matchReports
    }
}
