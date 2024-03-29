//
//  UserPredictionReportViewController.swift
//  Whistler
//
//  Created by Kavin Varnan on 28/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import TRON
import MBProgressHUD
import Firebase
import GoogleMobileAds

class UserPredictionReportViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var uid: String?
    var matchKey: String?
    var userName: String?
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var predictions = [UserPredictionItem]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        self.title = userName!
        button.setTitle("\(userName!)'s Other Matches", for: .normal)
        self.getUserPredictionForMatch();
        bannerView.delegate = self
        self.loadAd()
        var headerFrame: CGRect? = tableView.tableHeaderView?.frame
        headerFrame?.size.height = (tableView.tableHeaderView?.frame.height)! / 2
        tableView.tableHeaderView?.frame = headerFrame!
    }
    
    func loadAd() {
        bannerView.adUnitID = Constants.AdMob.UNIT_MATCH_REPORT
        bannerView.rootViewController = self
        bannerView.adSize = kGADAdSizeBanner
        let request = GADRequest();
        request.testDevices = Constants.AdMob.TEST_DEVICES;
        bannerView.load(request)
    }
    
    func getUserPredictionForMatch() {
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        let request: APIRequest<UserPredictionItemResponse, ServerError> = TronService.sharedInstance.createRequest(path: "/prediction/user_prediction/\(uid!)/\(matchKey!)");
        request.perform(withSuccess: { (response) in
            if response.error != nil {
                self.errorResponse()
                loadingNotification.hide(animated: true)
            } else {
                self.populate(predictions: response.userPredictions!)
                self.tableView.reloadData()
                loadingNotification.hide(animated: true)
            }
        }) { (error) in
            loadingNotification.hide(animated: true)
            self.errorResponse()
        }
    }
    
    func populate(predictions: [UserPredictionItem]) {
        for p in predictions {
            self.predictions.append(p)
        }
    }
    
    func errorResponse() {
        let alertController = Utils.simpleAlertController(title: "No connection", message: "Unable to connect with to the internet. Please check your network settings");
        self.present(alertController, animated: true, completion: nil)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userPredictedItemTableCell", for: indexPath) as! UserPredictionItemTableViewCell
        let predictionItem = self.predictions[indexPath.row];
        cell.over.text = predictionItem.over
        cell.runs.text = predictionItem.runs
        cell.points.text = predictionItem.points
        cell.predicted.text = predictionItem.predicted
        return cell
    }
    
    @IBAction func clickedUsersOtherMatches(_ sender: UIButton) {
        Analytics.logEvent("check_all_match_points", parameters: [:])
        performSegue(withIdentifier: "userMatchReport", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userMatchReport" {
            let vc = segue.destination as! UserMatchsReportViewController
            vc.uid = uid!
            vc.userName = userName!
        }
    }
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        Analytics.logEvent("adViewDidReceiveAd", parameters: [ "screen": "PredictionReport" ])
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError")
        Analytics.logEvent("adView:didFailToReceiveAdWithError", parameters: [ "screen": "PredictionReport", "error": "error.localizedDescription" ])
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
        Analytics.logEvent("adViewWillPresentScreen", parameters: [ "screen": "PredictionReport" ])
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
        Analytics.logEvent("adViewWillDismissScreen", parameters: [ "screen": "PredictionReport" ])
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
        Analytics.logEvent("adViewDidDismissScreen", parameters: [ "screen": "PredictionReport" ])
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
        Analytics.logEvent("adViewWillLeaveApplication", parameters: [ "screen": "PredictionReport" ])
    }

}
