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

class LiveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    let elements = ["asdf", "asdf", "asdf", "asdf", "asdf"]
    
    var scoreCardTimer : Timer?
    var updateLabelTimer: Timer?
    var updatedHowManySecondsAgo: Int = 0
    var refresher: UIRefreshControl!

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(fetchPredictPointsTableData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-7846555754762077/1155629537"
        bannerView.rootViewController = self
        bannerView.adSize = kGADAdSizeLargeBanner
        let request = GADRequest();
        request.testDevices = ["89ffbd9e1437137dbc77d1f7a29de1e9", "b6025ac345b2382e8ec9b36a5fbb23e2"];
        bannerView.load(request)
        
        self.tableView.rowHeight = 44.0
        tableView.sectionHeaderHeight = 25.0;
        tableView.sectionFooterHeight = 2.0;
        self.populateNavBarIcons()
    }
    
    func reloadWholePage() {
        self.fetchScoreBoardFromServer()
        self.fetchPredictPointsTableData()
    }
    
    func populateNavBarIcons() {
        let switchButton = UIButton(type: .custom)
        switchButton.setImage(UIImage(named: "switch"), for: .normal)
        switchButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        switchButton.addTarget(self, action: #selector(switchMatch), for: .touchUpInside)
        
        let switchItem = UIBarButtonItem(customView: switchButton)
        
        if WhistlerManager.sharedInstance.happeningMatchs.count > 0{
            self.navigationItem.setRightBarButtonItems([switchItem], animated: true)
        }
        
    }
    
    @objc func switchMatch() {
        if WhistlerManager.sharedInstance.currentMatch!.key == WhistlerManager.sharedInstance.happeningMatchs[0].key {
            WhistlerManager.sharedInstance.currentMatch = WhistlerManager.sharedInstance.happeningMatchs[1]
        } else {
            WhistlerManager.sharedInstance.currentMatch = WhistlerManager.sharedInstance.happeningMatchs[0]
        }
        self.reloadWholePage()
    }
    
    @objc func fetchPredictPointsTableData() {
        let request: APIRequest<PredictPointsTableResponse, ServerError> = TronService.sharedInstance.createRequest(path: "/prediction/my_prediction_table/\(WhistlerManager.sharedInstance.currentMatch!.key)");
        request.perform(withSuccess: { (response) in
            if let err = response.error {
                self.errorFetchingScoreCard(error: err)
            } else {
                self.populate(predictTableData: response.pointsTableData!)
                self.tableView.reloadData()
                self.refresher.endRefreshing()
            }
        }) { (error) in
            self.errorFetchingScoreCard(error: ErrorModel(code: 123, message: "Guessing no internet"))
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
        let request: APIRequest<ScoreBoardResponse, ServerError> = TronService.sharedInstance.createRequest(path: "/runs/score_board/\(WhistlerManager.sharedInstance.currentMatch!.key)");
        request.perform(withSuccess: { (response) in
            if let err = response.error {
                self.errorFetchingScoreCard(error: err)
            } else {
                self.populate(scoreBoard: response.scoreBoard!)
            }
        }) { (error) in
            self.errorFetchingScoreCard(error: ErrorModel(code: 123, message: "Guessing no internet"))
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
        if scoreCardTimer == nil {
            scoreCardTimer?.invalidate()
            scoreCardTimer = nil
        }
        
        if updateLabelTimer == nil {
            updateLabelTimer?.invalidate()
            updateLabelTimer = nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            self.dismiss(animated: true, completion: nil)
            return
        }
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
    }
    
    func errorFetchingScoreCard(error: ErrorModel) {
        //TODO: handle case
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
        if overNumberInt != -1 {
            performSegue(withIdentifier: "predict", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "predict" {
            let vs = segue.destination as! PredictionPopupViewController
            vs.overNumberInt = self.overNumberInt
            vs.matchKey = WhistlerManager.sharedInstance.currentMatch!.key
            vs.playingTeam = "b"
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
            noDataLabel.text = "Loading..."
            noDataLabel.numberOfLines = 1;
            noDataLabel.textColor = UIColor.init(hex: "#2A292B")
            noDataLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = noDataLabel
            self.tableView.separatorStyle = .none
        }
        return numOfSection
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView()
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! PredictionHeaderTableViewCell
        headerView.addSubview(headerCell)
        return headerView
    }
    
    func test() {
        print("test")
    }
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}
