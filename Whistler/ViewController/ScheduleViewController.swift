//
//  ScheduleViewController.swift
//  Whistler
//
//  Created by Kavin Varnan on 22/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import TRON
import SwiftyJSON

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var schedule:[Schedule] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.fetchScheduleFromServer();
    }
    
    func fetchScheduleFromServer() {
        let request: APIRequest<ScheduleList, ServerError> = TronService.sharedInstance.createRequest(path: "/match/schedule");
        request.perform(withSuccess: { (response) in
            if let err = response.error {
                self.errorApiCall(error: err)
            } else {
                self.schedule = response.schedules!;
                self.tableView.reloadData()
            }
        }) { (error) in
            let alertController = Utils.simpleAlertController(title: "No connection", message: "Unable to connect with to the internet. Please check your network settings");
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func errorApiCall(error: ErrorModel) {
        //TODO: handle case
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedule.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! ScheduleTableViewCell
        let sc = self.schedule[indexPath.row]
        cell.matchNumberLabel.text = sc.displayDate;
        cell.dateLabel.text = sc.venue
        cell.centerLabel.text = sc.displayTime
        cell.teamALabel.text = sc.teamAName;
        cell.teamBLabel.text = sc.teamBName;
        cell.teamAImage.image = UIImage(named: sc.teamA.uppercased());
        cell.teamBImage.image = UIImage(named: sc.teamB.uppercased());
        return cell;
    }
}
