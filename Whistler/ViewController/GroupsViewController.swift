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

class GroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var groups:[Group] = [];
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self;
        tableView.dataSource = self;
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(populate), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        self.fetchGroupsFromServer();
    }
    
    func fetchGroupsFromServer() {
        let request: APIRequest<GroupList, ServerError> = TronService.sharedInstance.createRequest(path: "/group/list_all_groups");
        request.perform(withSuccess: { (response) in
            self.groups = response.groups
            self.tableView.reloadData()
            self.refresher.endRefreshing()
        }) { (error) in
            print("Error ", error)
        }
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
            noDataLabel.text = "You dont have any groups. Click the + icon to add a new group"
            noDataLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
            noDataLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = noDataLabel
            self.tableView.separatorStyle = .none
        }
        return numOfSection
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.selectedGroupRow = indexPath.row
        performSegue(withIdentifier: "groupInfo", sender: nil)
    }
    
    var selectedGroupRow = 0;
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "groupInfo" {
            if let destinationViewController = segue.destination as? GroupInfoViewController {
                destinationViewController.groupObject = groups[selectedGroupRow]
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
}
