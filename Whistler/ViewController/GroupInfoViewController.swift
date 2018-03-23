//
//  GroupInfoViewController.swift
//  Whistler
//
//  Created by Kavin Varnan on 20/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import Firebase
import TRON

class GroupInfoViewController: UIViewController {
    
    var groupObject: GroupModel!;

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
    
    @IBAction func shareJoinCode(_ sender: UIButton) {
        let text = "Group id: \(groupObject.groupId.uppercased()) Join code: \(groupObject.joinCode)"
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook, UIActivityType.copyToPasteboard, UIActivityType.saveToCameraRoll, UIActivityType.mail ]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func leaveGroup() {
        let refreshAlert = UIAlertController(title: "Leave group?", message: "Are you sure you want to leave this group?", preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.leaveGroupMethod()
        }))
        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    @objc func deleteGroup() {
        let refreshAlert = UIAlertController(title: "Delete group?", message: "Are you sure you want to delete this group?", preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteGroupMethod()
        }))
        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func deleteGroupMethod() {
        let request: APIRequest<GenericResponse, ServerError> = TronService.sharedInstance.createRequest(path: "/group/delete_group/\(self.groupObject.id)")
        request.perform(withSuccess: { (response) in
            if let error = response.error {
                self.apiError(error: error)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }) { (error) in
            self.serverNotReachable()
        }
    }
    
    func leaveGroupMethod() {
        let request: APIRequest<GenericResponse, ServerError> = TronService.sharedInstance.createRequest(path: "/group/leave_group/\(self.groupObject.id)")
        request.perform(withSuccess: { (response) in
            if let error = response.error {
                self.apiError(error: error)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }) { (error) in
            self.serverNotReachable()
        }
    }
    
    @objc func editGroup() {
        
    }
    
    func serverNotReachable() {
        
    }
    
    func apiError(error: ErrorModel) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
