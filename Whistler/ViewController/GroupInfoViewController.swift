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
import MBProgressHUD

class GroupInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var groupObject: GroupModel!;
    var groupIntoItems = [GroupInfoItem]();
    var matchKey: String?

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = groupObject.name
        tableView.delegate = self
        tableView.dataSource = self
        print(groupObject!);
        self.populateNavBarIcons();
        self.getGroupMembers();
    }
    
    func getGroupMembers() {
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        let request: APIRequest<GroupInfoResponse, ServerError> = TronService.sharedInstance.createRequest(path: "/group/get_everyone_form_group/\(groupObject.id)/\(matchKey!)");
        request.perform(withSuccess: { (response) in
            if response.error != nil {
                self.errorResponse()
                loadingNotification.hide(animated: true)
            } else {
                loadingNotification.hide(animated: true)
                self.populate(groupInfoItems: response.users!)
                self.tableView.reloadData()
            }
        }) { (error) in
            loadingNotification.hide(animated: true)
            self.errorResponse()
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        openingUid = groupIntoItems[indexPath.row].uid
        openingName = groupIntoItems[indexPath.row].name
        performSegue(withIdentifier: "openUserPrediction", sender: nil)
    }
    var openingUid: String?
    var openingName: String?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openUserPrediction" {
            let vc = segue.destination as! UserPredictionReportViewController
            vc.uid = openingUid!
            vc.matchKey = matchKey!
            vc.userName = openingName!
        }
    }
    
    func errorResponse() {
        let alertController = Utils.simpleAlertController(title: "No connection", message: "Unable to connect with to the internet. Please check your network settings");
        self.present(alertController, animated: true, completion: nil)
    }
    
    func populate(groupInfoItems: [GroupInfoItem]) {
        for group in groupInfoItems {
            self.groupIntoItems.append(group)
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupIntoItems.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupInfoTableViewCell", for: indexPath) as! GroupInfoTableViewCell
        let groupItem = self.groupIntoItems[indexPath.row]
        cell.name.text = groupItem.name
        cell.current.text = String(groupItem.totalForMatch)
        cell.overAll.text = String(groupItem.overAll)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "groupInfoHeaderCell")
        headerView.addSubview(headerCell!)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return Auth.auth().currentUser?.uid == groupObject.admin &&
            groupIntoItems[indexPath.row].uid != groupObject.admin
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            self.deleteUserFromList(groupInfoItem: self.groupIntoItems[indexPath.row])
            self.groupIntoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func deleteUserFromList(groupInfoItem: GroupInfoItem) {
        let request: APIRequest<CreateGroup, ServerError> = TronService.sharedInstance.createRequest(path: "/group/remove_member/\(groupObject.id)/\(groupInfoItem.uid)");
        
        request.perform(withSuccess: { (response) in
            
        }) { (error) in
            print("Error ", error)
        }
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
    
    var textField: UITextField?
    
    func configurationTextField(textField: UITextField!) {
        if (textField) != nil {
            self.textField = textField!        //Save reference to the UITextField
            self.textField?.placeholder = "New group name";
        }
    }
    
    @objc func editGroup() {
        let alert = UIAlertController(title: "Edit group", message: "Change your group name", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:{ (UIAlertAction) in
            if !self.textField!.text!.isEmpty  {
                let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
                loadingNotification.mode = MBProgressHUDMode.indeterminate
                loadingNotification.label.text = "Loading"
                let request: APIRequest<CreateGroup, ServerError> = TronService.sharedInstance.createRequest(path: "/group/edit_group/\(self.groupObject.id)/\(self.textField!.text!)/\(self.groupObject.icon!)");
                
                request.perform(withSuccess: { (response) in
                    loadingNotification.hide(animated: true)
                    self.navigationController?.popViewController(animated: true)
                }) { (error) in
                    loadingNotification.hide(animated: true)
                    print("Error ", error)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
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
