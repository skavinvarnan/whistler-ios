//
//  LeaderboardViewController.swift
//  Whistler
//
//  Created by Kavin Varnan on 01/04/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds
import TRON

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var firstLoad = true
    
    var items:[LeaderBoardItem] = [];
    
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self;
        tableView.dataSource = self;
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(fetchDataFromServer), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        self.fetchDataFromServer()
        self.loadAd()
        self.navigationItem.title = "Top 50 for \(WhistlerManager.sharedInstance.currentMatch!.shortName)"
    }
    
    func loadAd() {
        bannerView.adUnitID = Constants.AdMob.UNIT_LEADER_BOARD
        bannerView.rootViewController = self
        bannerView.adSize = kGADAdSizeBanner
        let request = GADRequest();
        request.testDevices = Constants.AdMob.TEST_DEVICES;
        bannerView.load(request)
    }
    
    @objc func fetchDataFromServer() {
       
        let request: APIRequest<LeaderboardResponse, ServerError> = TronService.sharedInstance.createRequest(path: "/match/leader_board/\(WhistlerManager.sharedInstance.currentMatch!.key)");
        request.perform(withSuccess: { (response) in
            if let err = response.error {
                self.errorApiCall(error: err)
            } else {
                self.firstLoad = false
                self.items = response.items!
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
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderBoardCell", for: indexPath) as! LeaderBoardTableViewCell
        cell.name.text = items[indexPath.row].name
        cell.points.text = String(items[indexPath.row].totalForMatch)
        return cell;
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSection: NSInteger = 0
        
        if items.count > 0 {
            self.tableView.backgroundView = nil
            numOfSection = 1
            self.tableView.separatorStyle = .singleLine
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            if !firstLoad {
                noDataLabel.text = "Waiting for data. \nShould change this text"
            }
            noDataLabel.numberOfLines = 2;
            noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
            noDataLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = noDataLabel
            self.tableView.separatorStyle = .none
        }
        return numOfSection
    }

}
