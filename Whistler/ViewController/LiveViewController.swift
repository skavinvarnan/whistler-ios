//
//  LiveViewController.swift
//  Whistler
//
//  Created by Kavin Varnan on 19/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import QuartzCore
import TRON
import GoogleMobileAds
import Firebase
import MBProgressHUD

class LiveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let elements = ["asdf", "asdf", "asdf", "asdf", "asdf"]
    
    var scoreCardTimer : Timer?
    var updateLabelTimer: Timer?
    var updatedHowManySecondsAgo: Int = 0
    var refresher: UIRefreshControl!
    var scoreCard: ScoreBoard?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var teamShortName: UILabel!
    @IBOutlet weak var inningsNumber: UILabel!
    @IBOutlet weak var runsWickets: UILabel!
    @IBOutlet weak var overNumber: UILabel!
    @IBOutlet weak var pShipLabel: UILabel!
    @IBOutlet weak var pShipData: UILabel!
    @IBOutlet weak var crrLabel: UILabel!
    @IBOutlet weak var crrData: UILabel!
    @IBOutlet weak var rrrLabel: UILabel!
    @IBOutlet weak var rrrData: UILabel!
    @IBOutlet weak var matchInfo: UILabel!
    @IBOutlet weak var batsmanNameOne: UILabel!
    @IBOutlet weak var batsmanRunsOne: UILabel!
    @IBOutlet weak var batsmanBallsOne: UILabel!
    @IBOutlet weak var batsman4sOne: UILabel!
    @IBOutlet weak var batsman6sOne: UILabel!
    @IBOutlet weak var batsmanSROne: UILabel!
    @IBOutlet weak var batsmanNameTwo: UILabel!
    @IBOutlet weak var batsmanRunsTwo: UILabel!
    @IBOutlet weak var batsmanBallsTwo: UILabel!
    @IBOutlet weak var batsman4sTwo: UILabel!
    @IBOutlet weak var batsman6sTwo: UILabel!
    @IBOutlet weak var batsmanSRTwo: UILabel!
    @IBOutlet weak var bowlerName: UILabel!
    @IBOutlet weak var bowlerOver: UILabel!
    @IBOutlet weak var bowlerMaiden: UILabel!
    @IBOutlet weak var bowlerRuns: UILabel!
    @IBOutlet weak var bowlerWickets: UILabel!
    @IBOutlet weak var bowlerEconomy: UILabel!
    @IBOutlet weak var updatedSecondsAgo: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var predictTableData = [PredictPointsTableData]()
    
    var loadingNotification: MBProgressHUD?
    var showProgressBar = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotification!.mode = MBProgressHUDMode.indeterminate
        loadingNotification!.label.text = "Loading"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(fetchPredictPointsTableData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        
        self.tableView.rowHeight = 44.0
        tableView.sectionHeaderHeight = 25.0;
        tableView.sectionFooterHeight = 2.0;
        self.populateNavBarIcons()
        self.title = "Loading"
        self.fetchScoreBoardFromServer()
        self.fetchPredictPointsTableData()
        
        self.loadAd()
        
        var headerFrame: CGRect? = tableView.tableHeaderView?.frame
        headerFrame?.size.height = (tableView.tableHeaderView?.frame.height)! / 2
        tableView.tableHeaderView?.frame = headerFrame!
        
    }
    
    func loadAd() {
        bannerView.adUnitID = Constants.AdMob.UNIT_LIVE
        bannerView.rootViewController = self
        bannerView.adSize = kGADAdSizeLargeBanner
        let request = GADRequest();
        request.testDevices = Constants.AdMob.TEST_DEVICES;
        bannerView.load(request)
    }
    
    func reloadWholePage() {
        self.fetchScoreBoardFromServer()
        self.fetchPredictPointsTableData()
        self.predictTableData.removeAll()
        self.tableView.reloadData()
    }
    
    func populateNavBarIcons() {
        let switchButton = UIButton(type: .custom)
        switchButton.setImage(UIImage(named: "switch"), for: .normal)
        switchButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        switchButton.addTarget(self, action: #selector(switchMatch), for: .touchUpInside)
        
        let switchItem = UIBarButtonItem(customView: switchButton)
        
        let settingsButton = UIButton(type: .custom)
        settingsButton.setImage(UIImage(named: "settings"), for: .normal)
        settingsButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        settingsButton.addTarget(self, action: #selector(showSettings), for: .touchUpInside)
        
        let settingsItem = UIBarButtonItem(customView: settingsButton)
        
        if WhistlerManager.sharedInstance.happeningMatchs.count > 1 {
            self.navigationItem.setRightBarButtonItems([settingsItem, switchItem], animated: true)
        } else {
            self.navigationItem.setRightBarButtonItems([settingsItem], animated: true)
        }
        
    }
    
    @objc func showSettings() {
        Analytics.logEvent("settings", parameters: [:])
        performSegue(withIdentifier: "settings", sender: nil)
    }
    
    func getOtherMatchName() -> String {
        if WhistlerManager.sharedInstance.currentMatch!.key == WhistlerManager.sharedInstance.happeningMatchs[0].key {
            return WhistlerManager.sharedInstance.happeningMatchs[1].shortName
        } else {
            return WhistlerManager.sharedInstance.happeningMatchs[0].shortName
        }
    }
    
    @objc func switchMatch() {
        let alert = UIAlertController(title: "\(self.getOtherMatchName())", message: "Want to see this match?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
            if WhistlerManager.sharedInstance.currentMatch!.key == WhistlerManager.sharedInstance.happeningMatchs[0].key {
                WhistlerManager.sharedInstance.currentMatch = WhistlerManager.sharedInstance.happeningMatchs[1]
            } else {
                WhistlerManager.sharedInstance.currentMatch = WhistlerManager.sharedInstance.happeningMatchs[0]
            }
            self.showProgressBar = true;
            self.reloadWholePage()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func fetchPredictPointsTableData() {
        let request: APIRequest<PredictPointsTableResponse, ServerError> = TronService.sharedInstance.createRequest(path: "/prediction/my_prediction_table/\(WhistlerManager.sharedInstance.currentMatch!.key)");
        request.perform(withSuccess: { (response) in
            self.refresher.endRefreshing()
            if let err = response.error {
                self.errorFetchingPointsTable(error: err)
            } else {
                self.populate(predictTableData: response.pointsTableData!)
                self.tableView.reloadData()
            }
        }) { (error) in
            self.errorFetchingPointsTable(error: ErrorModel(code: 123, message: "Guessing no internet"))
            self.refresher.endRefreshing()
        }
    }
    
    func populate(predictTableData: [PredictPointsTableData]) {
        self.predictTableData.removeAll()
        for predictData in predictTableData {
            self.predictTableData.append(predictData)
        }
    }
    
    func fetchScoreBoardFromServer() {
        if showProgressBar {
            loadingNotification!.show(animated: true)
        }
        let request: APIRequest<ScoreBoardResponse, ServerError> = TronService.sharedInstance.createRequest(path: "/runs/score_board/\(WhistlerManager.sharedInstance.currentMatch!.key)");
        request.perform(withSuccess: { (response) in
            if let err = response.error {
                self.errorFetchingScoreCard(error: err)
                self.hideProgressBar()
            } else {
                self.populate(scoreBoard: response.scoreBoard!)
                self.hideProgressBar()
            }
        }) { (error) in
            self.errorFetchingScoreCard(error: ErrorModel(code: 123, message: "Guessing no internet"))
            self.hideProgressBar()
        }
    }
    
    func hideProgressBar() {
        if showProgressBar {
            loadingNotification!.hide(animated: true)
            showProgressBar = false
        }
    }
    
    @objc func fetchFromTimer() {
        self.fetchScoreBoardFromServer()
        self.fetchPredictPointsTableData()
    }
    
    func startScoreCardTimer () {
        if scoreCardTimer == nil {
            scoreCardTimer =  Timer.scheduledTimer(
                timeInterval: TimeInterval(5),
                target      : self,
                selector    : #selector(fetchFromTimer),
                userInfo    : nil,
                repeats     : true)
        }
        
        if updateLabelTimer == nil {
            updateLabelTimer =  Timer.scheduledTimer(
                timeInterval: TimeInterval(1),
                target      : self,
                selector    : #selector(updateLabel),
                userInfo    : nil,
                repeats     : true)
        }
    }
    
    @objc func updateLabel() {
        self.updatedSecondsAgo.text = "Updated \(updatedHowManySecondsAgo) seconds ago"
        updatedHowManySecondsAgo = updatedHowManySecondsAgo + 1;
    }

    func stopScoreCardTimer() {
        if scoreCardTimer != nil {
            scoreCardTimer?.invalidate()
            scoreCardTimer = nil
        }
        
        if updateLabelTimer != nil {
            updateLabelTimer?.invalidate()
            updateLabelTimer = nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.fetchScoreBoardFromServer()
        self.fetchPredictPointsTableData()
        self.startScoreCardTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.stopScoreCardTimer()
    }

    
    func populate(scoreBoard: ScoreBoard) {
        updatedHowManySecondsAgo = 0;
        
        self.updatedSecondsAgo.isHidden = !scoreBoard.showUpdated
        self.teamShortName.text = scoreBoard.teamShortName
        self.inningsNumber.text = scoreBoard.inningsNumber
        self.runsWickets.text = scoreBoard.runsWickets
        self.overNumber.text = scoreBoard.overNumber
        self.pShipLabel.text = scoreBoard.pShipLabel
        self.pShipData.text = scoreBoard.pShipData
        self.crrLabel.text = scoreBoard.crrLabel
        self.crrData.text = scoreBoard.crrData
        self.rrrLabel.text = scoreBoard.rrrLabel
        self.rrrData.text = scoreBoard.rrrData
        self.matchInfo.text = scoreBoard.matchInfo
        self.batsmanNameOne.text = scoreBoard.batsmanNameOne
        self.batsmanRunsOne.text = scoreBoard.batsmanRunsOne
        self.batsmanBallsOne.text = scoreBoard.batsmanBallsOne
        self.batsman4sOne.text = scoreBoard.batsman4sOne
        self.batsman6sOne.text = scoreBoard.batsman6sOne
        self.batsmanSROne.text = scoreBoard.batsmanSROne
        self.batsmanNameTwo.text = scoreBoard.batsmanNameTwo
        self.batsmanRunsTwo.text = scoreBoard.batsmanRunsTwo
        self.batsmanBallsTwo.text = scoreBoard.batsmanBallsTwo
        self.batsman4sTwo.text = scoreBoard.batsman4sTwo
        self.batsman6sTwo.text = scoreBoard.batsman6sTwo
        self.batsmanSRTwo.text = scoreBoard.batsmanSRTwo
        self.bowlerName.text = scoreBoard.bowlerName
        self.bowlerOver.text = scoreBoard.bowlerOver
        self.bowlerMaiden.text = scoreBoard.bowlerMaiden
        self.bowlerRuns.text = scoreBoard.bowlerRuns
        self.bowlerWickets.text = scoreBoard.bowlerWickets
        self.bowlerEconomy.text = scoreBoard.bowlerEconomy
        self.title = scoreBoard.title
        self.scoreCard = scoreBoard
    }
    
    var predictionTableMessage: String?
    
    func errorFetchingPointsTable(error: ErrorModel) {
        if error.code == 4001 {
            predictionTableMessage = error.message!
            self.tableView.reloadData()
        } else {
            predictionTableMessage = "Unable to load data"
        }
    }
    
    func errorFetchingScoreCard(error: ErrorModel) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictTableData.count;
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "predictionCell", for: indexPath) as! PredictionTableViewCell
        let overItem = predictTableData[indexPath.row].over;
        let runsItem = predictTableData[indexPath.row].runs;
        let predictedItem = predictTableData[indexPath.row].predicted;
        let pointsItem = predictTableData[indexPath.row].points;
        let predictButtonItem = predictTableData[indexPath.row].predictButton;
        
        cell.over.layer.backgroundColor = UIColor.init(hex: overItem.colorHex).cgColor
        cell.over.layer.masksToBounds = true
        cell.over.layer.cornerRadius = CGFloat(overItem.radius)
        cell.over.text = overItem.label
        if !overItem.whiteText {
            cell.over.textColor = UIColor.black;
        } else {
            cell.over.textColor = UIColor.white;
        }
        
        cell.runs.layer.backgroundColor = UIColor.init(hex: runsItem.colorHex).cgColor
        cell.runs.layer.masksToBounds = true
        cell.runs.layer.cornerRadius = CGFloat(runsItem.radius)
        cell.runs.text = runsItem.label
        if !runsItem.whiteText {
            cell.runs.textColor = UIColor.black;
        } else {
            cell.runs.textColor = UIColor.white;
        }
        
        cell.prediction.layer.backgroundColor = UIColor.init(hex: predictedItem.colorHex).cgColor
        cell.prediction.layer.masksToBounds = true
        cell.prediction.layer.cornerRadius = CGFloat(predictedItem.radius)
        cell.prediction.text = predictedItem.label
        if !predictedItem.whiteText {
            cell.prediction.textColor = UIColor.black;
        } else {
            cell.prediction.textColor = UIColor.white;
        }
        
        cell.points.layer.backgroundColor = UIColor.init(hex: pointsItem.colorHex).cgColor
        cell.points.layer.masksToBounds = true
        cell.points.layer.cornerRadius = CGFloat(pointsItem.radius)
        cell.points.text = pointsItem.label
        if !pointsItem.whiteText {
            cell.points.textColor = UIColor.black;
        } else {
            cell.points.textColor = UIColor.white;
        }
        
        cell.predictButton.layer.backgroundColor = UIColor.init(hex: predictButtonItem.colorHex).cgColor
        cell.predictButton.layer.masksToBounds = true
        cell.predictButton.layer.cornerRadius = CGFloat(predictButtonItem.radius)
        cell.predictButton.setTitle(predictButtonItem.label, for: .normal)
        
        if predictButtonItem.clickable {
            cell.predictButton.addTarget(self, action: #selector(predict), for: UIControlEvents.touchUpInside)
            if let tag = Int(overItem.label) {
                cell.predictButton.tag = tag
            } else {
                cell.predictButton.tag = -1
            }
            cell.predictButton.isEnabled = true
        } else {
            cell.predictButton.isEnabled = false
        }
        return cell;
    }
    
    var overNumberInt = -1;
    
    @objc func predict(sender: UIButton) {
        self.overNumberInt = sender.tag
        if self.predictTableData.count > 0 {
            performSegue(withIdentifier: "predict", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "predict" {
            let vs = segue.destination as! PredictionPopupViewController
            vs.overNumberInt = self.overNumberInt
            vs.matchKey = WhistlerManager.sharedInstance.currentMatch!.key
            vs.playingTeam = self.predictTableData[0].teamBatting
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSection: NSInteger = 0
        
        if predictTableData.count > 0 {
            self.tableView.backgroundView = nil
            numOfSection = 1
            self.tableView.separatorStyle = .singleLine
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            if let mess = self.predictionTableMessage {
                noDataLabel.text = mess
            } else {
                noDataLabel.text = "Loading..."
            }
            noDataLabel.numberOfLines = 1;
            noDataLabel.textColor = UIColor.init(hex: "#2A292B")
            noDataLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = noDataLabel
            self.tableView.separatorStyle = .none
        }
        return numOfSection
    }
    
    func test() {
        print("test")
    }
}
