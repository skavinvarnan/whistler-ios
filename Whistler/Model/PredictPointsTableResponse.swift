//
//  PredictPointsTableResponse.swift
//  Whistler
//
//  Created by Kavin Varnan on 24/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON

class PredictPointsTableResponse: JSONDecodable {
    let pointsTableData: [PredictPointsTableData]?
    let error: ErrorModel?
    required init(json: JSON) {
        var pointsTableData = [PredictPointsTableData]()
        let array = json["predictPointsTableData"].array;
        
        if array != nil {
            for groupJson in array! {
                
                let over = PredictPointsTableResponse.getPredictPointsItem(fromDictionary: groupJson["over"].dictionary!)
                let runs = PredictPointsTableResponse.getPredictPointsItem(fromDictionary: groupJson["runs"].dictionary!)
                let predicted = PredictPointsTableResponse.getPredictPointsItem(fromDictionary: groupJson["predicted"].dictionary!)
                let points = PredictPointsTableResponse.getPredictPointsItem(fromDictionary: groupJson["points"].dictionary!)
                let predictButton = PredictPointsTableResponse.getPredictPointsItem(fromDictionary: groupJson["predictButton"].dictionary!)
                let teamBatting = json["teamBatting"].stringValue
                pointsTableData.append(PredictPointsTableData(over: over, runs: runs, predicted: predicted, points: points, predictButton: predictButton, teamBatting: teamBatting))
            }
        }
        self.error = ErrorUtils.createErrorObjectFrom(json: json)
        self.pointsTableData = pointsTableData
    }
    
    static private func getPredictPointsItem(fromDictionary: [String: JSON]) -> PredictPointsTableItem {
        let label = fromDictionary["label"]!.stringValue
        let clickable = fromDictionary["clickable"]!.boolValue
        let radius = fromDictionary["radius"]!.intValue
        let colorHex = fromDictionary["colorHex"]!.stringValue
        let whiteText = fromDictionary["whiteText"]!.boolValue
        
        return PredictPointsTableItem(label: label, clickable: clickable, radius: radius, colorHex: colorHex, whiteText: whiteText)
    }
}
