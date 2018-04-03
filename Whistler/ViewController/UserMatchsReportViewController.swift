//
//  UserMatchsReportViewController.swift
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

class UserMatchsReportViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    var uid: String?
    var matchKey: String?
    var userName: String?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    var items = [MatchReportItem]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.title = "All Matches"
        self.getUserMatchesReport();
        bannerView.delegate = self
        self.loadAd()
        var headerFrame: CGRect? = tableView.tableHeaderView?.frame
        headerFrame?.size.height = (tableView.tableHeaderView?.frame.height)! / 2
        tableView.tableHeaderView?.frame = headerFrame!
    }
    
    func loadAd() {
        bannerView.adUnitID = Constants.AdMob.UNIT_ALL_MATCHES
        bannerView.rootViewController = self
        bannerView.adSize = kGADAdSizeBanner
        let request = GADRequest();
        request.testDevices = Constants.AdMob.TEST_DEVICES;
        bannerView.load(request)
    }
    
    func getUserMatchesReport() {
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        let request: APIRequest<MatchReportResponse, ServerError> = TronService.sharedInstance.createRequest(path: "/match/all_match_points/\(uid!)");
        request.perform(withSuccess: { (response) in
            if response.error != nil {
                loadingNotification.hide(animated: true)
                self.errorResponse()
            } else {
                loadingNotification.hide(animated: true)
                self.populate(arr: response.matchReports!)
                self.tableView.reloadData()
            }
        }) { (error) in
            loadingNotification.hide(animated: true)
            self.errorResponse()
        }
    }
    
    func populate(arr: [MatchReportItem]) {
        for obj in arr {
            self.items.append(obj)
        }
    }
    
    func errorResponse() {
        let alertController = Utils.simpleAlertController(title: "No connection", message: "Unable to connect with to the internet. Please check your network settings");
        self.present(alertController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userMatchReportTableCell", for: indexPath) as! UserMatchReportItemTableViewCell
        let obj = items[indexPath.row]
        cell.match.text = obj.match
        cell.points.text = String(obj.points)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Analytics.logEvent("check_match_report_last", parameters: [:])
        self.tableView.deselectRow(at: indexPath, animated: true)
        matchKey = items[indexPath.row].matchKey
        passingTitle = items[indexPath.row].match
        performSegue(withIdentifier: "predictionReportLast", sender: nil)
    }
    var passingTitle: String?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "predictionReportLast" {
            let vc = segue.destination as! UserPredictionReportLastViewController
            vc.uid = uid!
            vc.matchKey = matchKey!
            vc.passingTitle = passingTitle!
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        Analytics.logEvent("adViewDidReceiveAd", parameters: [ "screen": "MatchReport" ])
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError")
        Analytics.logEvent("adView:didFailToReceiveAdWithError", parameters: [ "screen": "MatchReport", "error": "error.localizedDescription" ])
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
        Analytics.logEvent("adViewWillPresentScreen", parameters: [ "screen": "MatchReport" ])
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
        Analytics.logEvent("adViewWillDismissScreen", parameters: [ "screen": "MatchReport" ])
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
        Analytics.logEvent("adViewDidDismissScreen", parameters: [ "screen": "MatchReport" ])
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
        Analytics.logEvent("adViewWillLeaveApplication", parameters: [ "screen": "MatchReport" ])
    }

}
