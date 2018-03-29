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

class UserPredictionReportViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var uid: String?
    var matchKey: String?
    var userName: String?
    @IBOutlet weak var button: UIButton!
    
    var predictions = [UserPredictionItem]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        self.title = userName!
        button.setTitle("\(userName!)'s all matches", for: .normal)
        self.getUserPredictionForMatch();
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
        performSegue(withIdentifier: "userMatchReport", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userMatchReport" {
            let vc = segue.destination as! UserMatchsReportViewController
            vc.uid = uid!
            vc.userName = userName!
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "predictionReportHeaderCell")!
        headerView.addSubview(headerCell)
        return headerView
    }

}
