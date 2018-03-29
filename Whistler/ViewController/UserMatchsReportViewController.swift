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

class UserMatchsReportViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var uid: String?
    var matchKey: String?
    var userName: String?

    @IBOutlet weak var tableView: UITableView!
    var items = [MatchReportItem]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.title = "All Matches"
        self.getUserMatchesReport();
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "userMatchReportHeaderTableCell")!
        headerView.addSubview(headerCell)
        return headerView
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
