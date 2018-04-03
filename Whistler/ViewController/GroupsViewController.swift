//
//  GroupsViewController.swift
//  Whistler
//
//  Created by Kavin Varnan on 20/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import Firebase
import TRON
import MBProgressHUD
import GoogleMobileAds

class GroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    
    var groups:[GroupModel] = [];
    var refresher: UIRefreshControl!
    var currentMatch: Schedule?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentMatch = WhistlerManager.sharedInstance.currentMatch!
        tableView.delegate = self;
        tableView.dataSource = self;
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(populate), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        self.fetchGroupsFromServer();
        bannerView.delegate = self
        self.loadAd()
        
    }
    
    func loadAd() {
        bannerView.adUnitID = Constants.AdMob.UNIT_GROUPS
        bannerView.rootViewController = self
        bannerView.adSize = kGADAdSizeBanner
        let request = GADRequest();
        request.testDevices = Constants.AdMob.TEST_DEVICES;
        bannerView.load(request)
    }
    

    var firstLoad = true
    func fetchGroupsFromServer() {
        if firstLoad {
            refresher.beginRefreshing()
        }
        let request: APIRequest<GroupList, ServerError> = TronService.sharedInstance.createRequest(path: "/group/list_all_groups");
        request.perform(withSuccess: { (response) in
            if self.firstLoad {
                self.refresher.endRefreshing()
                self.firstLoad = false
            }
            if let err = response.error {
                self.errorApiCall(error: err)
            } else {
                self.firstLoad = false
                self.groups = response.groups!
                self.tableView.reloadData()
                self.refresher.endRefreshing()
            }
        }) { (error) in
            let alertController = Utils.simpleAlertController(title: "No connection", message: "Unable to connect with to the internet. Please check your network settings");
            self.present(alertController, animated: true, completion: nil)
            self.refresher.endRefreshing()
        }
    }
    
    func errorApiCall(error: ErrorModel) {
        //TODO: handle case
    }
    
    @objc func populate() {
        fetchGroupsFromServer()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupTableViewCell
        if (groups[indexPath.row].icon != nil) {
            cell.emojiImage.image = UIImage(named: groups[indexPath.row].icon!)
        } else {
            cell.emojiImage.image = UIImage(named: "batman")
        }
        cell.title.text = groups[indexPath.row].name
        cell.subTitle.text = "\(groups[indexPath.row].members.count) Members"
        cell.accessoryType = .disclosureIndicator
        return cell;
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSection: NSInteger = 0
        
        if groups.count > 0 {
            self.tableView.backgroundView = nil
            numOfSection = 1
            self.tableView.separatorStyle = .singleLine
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            if !firstLoad {
                noDataLabel.text = "You are not part of any Group. \nClick the + icon to add a new group"
            }
            noDataLabel.numberOfLines = 2;
            noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
            noDataLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = noDataLabel
            self.tableView.separatorStyle = .none
        }
        return numOfSection
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Analytics.logEvent("check_group_info", parameters: [:])
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.selectedGroupRow = indexPath.row
        performSegue(withIdentifier: "groupInfo", sender: nil)
    }
    
    var selectedGroupRow = 0;
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "groupInfo" {
            if let destinationViewController = segue.destination as? GroupInfoViewController {
                destinationViewController.groupObject = groups[selectedGroupRow]
                destinationViewController.matchKey = currentMatch?.key
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.fetchGroupsFromServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        Analytics.logEvent("adViewDidReceiveAd", parameters: [ "screen": "Groups" ])
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError")
        Analytics.logEvent("adView:didFailToReceiveAdWithError", parameters: [ "screen": "Groups", "error": "error.localizedDescription" ])
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
        Analytics.logEvent("adViewWillPresentScreen", parameters: [ "screen": "Groups" ])
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
        Analytics.logEvent("adViewWillDismissScreen", parameters: [ "screen": "Groups" ])
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
        Analytics.logEvent("adViewDidDismissScreen", parameters: [ "screen": "Groups" ])
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
        Analytics.logEvent("adViewWillLeaveApplication", parameters: [ "screen": "Groups" ])
    }
}
