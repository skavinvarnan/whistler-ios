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

class UserPredictionReportLastViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var uid: String?
    var matchKey: String?
    var passingTitle: String?
    @IBOutlet weak var tableView: UITableView!
    var predictions = [UserPredictionItem]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.title = passingTitle!
        self.getUserPredictionForMatch();
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "predictionReportLastHeaderCell")!
        headerView.addSubview(headerCell)
        return headerView
    }
}