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
    
    var happeningMatches = [Schedule]()
    var currentMatch: Schedule? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if happeningMatches.count > 0 {
            currentMatch = happeningMatches[0];
        } else {
            return;
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-7846555754762077/1155629537"
        bannerView.rootViewController = self
        bannerView.adSize = kGADAdSizeLargeBanner
        let request = GADRequest();
        request.testDevices = ["89ffbd9e1437137dbc77d1f7a29de1e9"];
        bannerView.load(request)
        
        self.tableView.rowHeight = 44.0
        tableView.sectionHeaderHeight = 25.0;
        tableView.sectionFooterHeight = 2.0;
        self.fetchScoreBoardFromServer()
    }
    
    func fetchScoreBoardFromServer() {
        let request: APIRequest<ScoreBoardResponse, ServerError> = TronService.sharedInstance.createRequest(path: "/runs/score_board/\(currentMatch!.key)");
        request.perform(withSuccess: { (response) in
            if let err = response.error {
                self.errorFetchingScoreCard(error: err)
            } else {
                self.populate(scoreBoard: response.scoreBoard!);
            }
        }) { (error) in
            self.errorFetchingScoreCard(error: ErrorModel(code: 123, message: "Guessing no internet"))
        }
    }
    
    @objc func fetchFromTimer() {
        self.fetchScoreBoardFromServer()
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
        if scoreBoard.showRrr {
            self.rrrLabel.isHidden = false
            self.rrrData.isHidden = false
            self.rrrData.text = scoreBoard.rrrData
        } else {
            self.rrrLabel.isHidden = true
            self.rrrData.isHidden = true
        }
        
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
        
    }
    
    func errorFetchingScoreCard(error: ErrorModel) {
        //TODO: handle case
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8;
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "predictionCell", for: indexPath) as! PredictionTableViewCell
        cell.over.layer.backgroundColor  = UIColor.red.cgColor
        cell.over.layer.cornerRadius = 5
        cell.predictButton.addTarget(self, action: #selector(tap), for: UIControlEvents.touchUpInside)
        return cell;
    }
    
    @objc func tap() {
        performSegue(withIdentifier: "predict", sender: nil)
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
