//
//  ScoreBoardResponse.swift
//  Whistler
//
//  Created by Kavin Varnan on 22/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON

class ScoreBoardResponse: JSONDecodable {
    let error: ErrorModel?
    let scoreBoard: ScoreBoard?
    required init(json: JSON) throws {
        var sb: ScoreBoard? = nil
        if let sbJson = json["scoreBoard"].dictionary {
            let teamShortName = sbJson["teamShortName"]!.stringValue
            let inningsNumber = sbJson["inningsNumber"]!.stringValue
            let runsWickets = sbJson["runsWickets"]!.stringValue
            let overNumber = sbJson["overNumber"]!.stringValue
            let pShipLabel = sbJson["pShipLabel"]!.stringValue
            let pShipData = sbJson["pShipData"]!.stringValue
            let crrLabel = sbJson["crrLabel"]!.stringValue
            let crrData = sbJson["crrData"]!.stringValue
            let rrrLabel = sbJson["rrrLabel"]!.stringValue
            let rrrData = sbJson["rrrData"]!.stringValue
            let matchInfo = sbJson["matchInfo"]!.stringValue
            let batsmanNameOne = sbJson["batsmanNameOne"]!.stringValue
            let batsmanRunsOne = sbJson["batsmanRunsOne"]!.stringValue
            let batsmanBallsOne = sbJson["batsmanBallsOne"]!.stringValue
            let batsman4sOne = sbJson["batsman4sOne"]!.stringValue
            let batsman6sOne = sbJson["batsman6sOne"]!.stringValue
            let batsmanSROne = sbJson["batsmanSROne"]!.stringValue
            let batsmanNameTwo = sbJson["batsmanNameTwo"]!.stringValue
            let batsmanRunsTwo = sbJson["batsmanRunsTwo"]!.stringValue
            let batsmanBallsTwo = sbJson["batsmanBallsTwo"]!.stringValue
            let batsman4sTwo = sbJson["batsman4sTwo"]!.stringValue
            let batsman6sTwo = sbJson["batsman6sTwo"]!.stringValue
            let batsmanSRTwo = sbJson["batsmanSRTwo"]!.stringValue
            let bowlerName = sbJson["bowlerName"]!.stringValue
            let bowlerOver = sbJson["bowlerOver"]!.stringValue
            let bowlerMaiden = sbJson["bowlerMaiden"]!.stringValue
            let bowlerRuns = sbJson["bowlerRuns"]!.stringValue
            let bowlerWickets = sbJson["bowlerWickets"]!.stringValue
            let bowlerEconomy = sbJson["bowlerEconomy"]!.stringValue
            let title = sbJson["title"]!.stringValue
            let showUpdated = sbJson["showUpdated"]!.boolValue
            let battingTeam = sbJson["battingTeam"]!.stringValue
            
            sb = ScoreBoard(teamShortName: teamShortName, inningsNumber: inningsNumber, runsWickets: runsWickets, overNumber: overNumber, pShipLabel: pShipLabel, pShipData: pShipData, crrLabel: crrLabel, crrData: crrData, rrrLabel: rrrLabel, rrrData: rrrData, matchInfo: matchInfo, batsmanNameOne: batsmanNameOne, batsmanRunsOne: batsmanRunsOne, batsmanBallsOne: batsmanBallsOne, batsman4sOne: batsman4sOne, batsman6sOne: batsman6sOne, batsmanSROne: batsmanSROne, batsmanNameTwo: batsmanNameTwo, batsmanRunsTwo: batsmanRunsTwo, batsmanBallsTwo: batsmanBallsTwo, batsman4sTwo: batsman4sTwo, batsman6sTwo: batsman6sTwo, batsmanSRTwo: batsmanSRTwo, bowlerName: bowlerName, bowlerOver: bowlerOver, bowlerMaiden: bowlerMaiden, bowlerRuns: bowlerRuns, bowlerWickets: bowlerWickets, bowlerEconomy: bowlerEconomy, title: title, showUpdated: showUpdated, battingTeam: battingTeam)
        }
        self.error = ErrorUtils.createErrorObjectFrom(json: json)
        self.scoreBoard = sb
    }
}
