//
//  GroupInfoViewController.swift
//  Whistler
//
//  Created by Kavin Varnan on 20/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import Firebase

class GroupInfoViewController: UIViewController {
    
    var groupObject: Group!;

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = groupObject.name
        print(groupObject!);
        self.populateNavBarIcons();
    }
    
    func populateNavBarIcons() {
        let edit = UIButton(type: .custom)
        edit.setImage(UIImage(named: "edit"), for: .normal)
        edit.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        edit.addTarget(self, action: #selector(editGroup), for: .touchUpInside)
        let editItem = UIBarButtonItem(customView: edit)
        
        let delete = UIButton(type: .custom)
        delete.setImage(UIImage(named: "delete"), for: .normal)
        delete.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        delete.addTarget(self, action: #selector(deleteGroup), for: .touchUpInside)
        let deleteItem = UIBarButtonItem(customView: delete)
        
        let leave = UIButton(type: .custom)
        leave.setImage(UIImage(named: "exit"), for: .normal)
        leave.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        leave.addTarget(self, action: #selector(leaveGroup), for: .touchUpInside)
        let leaveItem = UIBarButtonItem(customView: leave)
        if Auth.auth().currentUser?.uid == groupObject.admin {
            self.navigationItem.setRightBarButtonItems([deleteItem, editItem], animated: true)
        } else {
            self.navigationItem.setRightBarButtonItems([leaveItem], animated: true)
        }
        
    }
    
    @objc func leaveGroup() {
        print(groupObject.id);
    }
    
    @objc func deleteGroup() {
        
    }
    
    @objc func editGroup() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
