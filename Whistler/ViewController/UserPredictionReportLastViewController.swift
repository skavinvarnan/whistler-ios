//
//  UserPredictionReportLastViewController.swift
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

class UserPredictionReportLastViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {

    var uid: String?
    var matchKey: String?
    var passingTitle: String?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    var predictions = [UserPredictionItem]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.title = passingTitle!
        self.getUserPredictionForMatch();
        self.loadAd()
        bannerView.delegate = self
        var headerFrame: CGRect? = tableView.tableHeaderView?.frame
        headerFrame?.size.height = (tableView.tableHeaderView?.frame.height)! / 2
        tableView.tableHeaderView?.frame = headerFrame!
    }
    
    func loadAd() {
        bannerView.adUnitID = Constants.AdMob.UNIT_MATCH_REPORT_LAST
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
                loadingNotification.hide(animated: true)
                self.errorResponse()
            } else {
                loadingNotification.hide(animated: true)
                self.populate(predictions: response.userPredictions!)
                self.tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "userPredictedItemLastTableCell", for: indexPath) as! UserPredictionReportLastTableViewCell
        let predictionItem = self.predictions[indexPath.row];
        cell.over.text = predictionItem.over
        cell.runs.text = predictionItem.runs
        cell.point.text = predictionItem.points
        cell.predicted.text = predictionItem.predicted
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        Analytics.logEvent("adViewDidReceiveAd", parameters: [ "screen": "PredictionReportLast" ])
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError")
        Analytics.logEvent("adView:didFailToReceiveAdWithError", parameters: [ "screen": "PredictionReportLast", "error": "error.localizedDescription" ])
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
        Analytics.logEvent("adViewWillPresentScreen", parameters: [ "screen": "PredictionReportLast" ])
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
        Analytics.logEvent("adViewWillDismissScreen", parameters: [ "screen": "PredictionReportLast" ])
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
        Analytics.logEvent("adViewDidDismissScreen", parameters: [ "screen": "PredictionReportLast" ])
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
        Analytics.logEvent("adViewWillLeaveApplication", parameters: [ "screen": "PredictionReportLast" ])
    }
}
