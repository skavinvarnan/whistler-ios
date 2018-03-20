//
//  LiveViewController.swift
//  Whistler
//
//  Created by Kavin Varnan on 19/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import QuartzCore

class LiveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let elements = ["asdf", "asdf", "asdf", "asdf", "asdf"]

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        self.tableView.rowHeight = 44.0
        tableView.sectionHeaderHeight = 25.0;
        tableView.sectionFooterHeight = 2.0;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8;
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "predictionCell", for: indexPath) as! PredictionTableViewCell
        cell.over.layer.backgroundColor  = UIColor.red.cgColor
        cell.over.layer.cornerRadius = 5
        return cell;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView()
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! PredictionHeaderTableViewCell
        headerView.addSubview(headerCell)
        return headerView
    }
    
    func test() {
        print("test")
    }
}
