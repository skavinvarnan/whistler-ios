//
//  Models.swift
//  Whistler
//
//  Created by Kavin Varnan on 20/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit

class Models: NSObject {

}

struct GroupModel {
    let id: String
    let groupId: String
    let name: String
    let icon: String?
    let joinCode: String
    let admin: String
    let members: [String]
}

struct ErrorModel {
    let code: Int
    let message: String?
}

struct Schedule {
    let _id: String
    let status: String
    let related_name: String
    let name: String
    let shortName: String
    let venue: String
    let winningTeam: String
    let startDateTimeStamp: NSNumber
    let teamA: String
    let teamB: String
    let teamAName: String
    let teamBName: String
    let key: String
    let displayDate: String
    let displayTime: String
}

struct ScoreBoard {
    let teamShortName: String
    let inningsNumber: String
    let runsWickets: String
    let overNumber: String
    let pShipLabel: String
    let pShipData: String
    let crrLabel: String
    let crrData: String
    let rrrLabel: String
    let rrrData: String
    let matchInfo: String
    let batsmanNameOne: String
    let batsmanRunsOne: String
    let batsmanBallsOne: String
    let batsman4sOne: String
    let batsman6sOne: String
    let batsmanSROne: String
    let batsmanNameTwo: String
    let batsmanRunsTwo: String
    let batsmanBallsTwo: String
    let batsman4sTwo: String
    let batsman6sTwo: String
    let batsmanSRTwo: String
    let bowlerName: String
    let bowlerOver: String
    let bowlerMaiden: String
    let bowlerRuns: String
    let bowlerWickets: String
    let bowlerEconomy: String
    let title: String
    let showUpdated: Bool
    let battingTeam: String
}

struct PredictPointsTableData {
    let over: PredictPointsTableItem
    let runs: PredictPointsTableItem
    let predicted: PredictPointsTableItem
    let points: PredictPointsTableItem
    let predictButton: PredictPointsTableItem
    let teamBatting: String
}

struct PredictPointsTableItem {
    let label: String
    let clickable: Bool
    let radius: Int
    let colorHex: String
    let whiteText: Bool
}

struct GroupInfoItem {
    let name: String
    let uid: String
    let totalForMatch: Int
    let overAll: Int
}

struct UserPredictionItem {
    let over: String
    let runs: String
    let predicted: String
    let points: String
}

struct MatchReportItem {
    let match: String
    let matchKey: String
    let points: Int
}

struct LeaderBoardItem {
    let uid: String
    let name: String
    let totalForMatch: Int
}
