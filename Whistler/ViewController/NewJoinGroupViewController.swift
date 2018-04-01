//
//  NewJoinGroupViewController.swift
//  Whistler
//
//  Created by Kavin Varnan on 20/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import TRON
import Alamofire
import MBProgressHUD
import Firebase

class NewJoinGroupViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let emoji = ["batman", "cat", "clown", "cool", "crazy", "devil", "hypnotized", "minion", "ninja", "pirate_cat", "shocked", "wink"]
    
    var selectedEmoji = 0;
    
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var groupId: UITextField!
    @IBOutlet weak var joinCode: UITextField!
    
    @IBAction func createGroupClicked(_ sender: UIButton) {
        
        if groupName.text?.isEmpty ?? true {
            Analytics.logEvent("group_name_empty", parameters: [:])
            let alertController = Utils.simpleAlertController(title: "Group name", message: "Please enter the group name and click on create group")
            self.present(alertController, animated: true, completion: nil)
            return;
        } else {
            print(emoji[selectedEmoji]);
            print(groupName.text!);
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Loading"
            let request: APIRequest<CreateGroup, ServerError> = TronService.sharedInstance.createRequest(path: "/group/create_group/\(groupName.text!)/\(emoji[selectedEmoji])");

            request.perform(withSuccess: { (response) in
                self.navigationController?.popViewController(animated: true)
                loadingNotification.hide(animated: true)
                Analytics.logEvent("create_group", parameters: [:])
            }) { (error) in
                print("Error ", error)
                Analytics.logEvent("create_group_error", parameters: [:])
                loadingNotification.hide(animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        groupId.delegate = self
        joinCode.delegate = self
        groupId.tag = 1
        joinCode.tag = 2
        selectedImage.image = UIImage(named: emoji[selectedEmoji])
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 1 {
            joinCode.becomeFirstResponder()
            return true
        } else if textField.tag == 2 {
            self.joinGroup();
            return true
        }
        return false
    }
    
    @IBAction func joinButtonClicked(_ sender: UIButton) {
        self.joinGroup()
    }
    
    func joinGroup() {
        if joinCode.text?.isEmpty ?? true || groupId.text?.isEmpty ?? true {
            Analytics.logEvent("join_group_empty", parameters: [:])
            let alertController = Utils.simpleAlertController(title: "Group ID Join code", message: "Please enter your group id and join code. You can get this from group admin")
            self.present(alertController, animated: true, completion: nil)
            return;
        } else {
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Loading"
            let request: APIRequest<GenericResponse, ServerError> = TronService.sharedInstance.createRequest(path: "/group/join_group/\(groupId.text!)/\(joinCode.text!)");
            
            request.perform(withSuccess: { (response) in
                loadingNotification.hide(animated: true)
                if response.error != nil {
                    Analytics.logEvent("join_group_error", parameters: [:])
                    let alertController = Utils.simpleAlertController(title: "Unable to join group", message: "Check if you have entered the groupId and joincode corredtly");
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    Analytics.logEvent("join_group", parameters: [:])
                    self.navigationController?.popViewController(animated: true)
                }
            }) { (error) in
                Analytics.logEvent("join_group_error", parameters: [:])
                loadingNotification.hide(animated: true)
                print("Error ", error)
            }
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                switch (UIDevice.current.screenType.rawValue) {
                case (UIDevice.ScreenType.iPhones_5_5s_5c_SE.rawValue):
                    self.view.frame.origin.y -= 210
                case (UIDevice.ScreenType.iPhones_6_6s_7_8.rawValue):
                    self.view.frame.origin.y -= 110
                case (UIDevice.ScreenType.iPhones_6Plus_6sPlus_7Plus_8Plus.rawValue):
                    self.view.frame.origin.y -= 80
                case (UIDevice.ScreenType.iPhoneX.rawValue):
                    self.view.frame.origin.y -= 70
                default:
                    self.view.frame.origin.y -= 150
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0 {
                switch (UIDevice.current.screenType.rawValue) {
                case (UIDevice.ScreenType.iPhones_5_5s_5c_SE.rawValue):
                    self.view.frame.origin.y += 210
                case (UIDevice.ScreenType.iPhones_6_6s_7_8.rawValue):
                    self.view.frame.origin.y += 110
                case (UIDevice.ScreenType.iPhones_6Plus_6sPlus_7Plus_8Plus.rawValue):
                    self.view.frame.origin.y += 80
                case (UIDevice.ScreenType.iPhoneX.rawValue):
                    self.view.frame.origin.y += 70
                default:
                    self.view.frame.origin.y += 150
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emoji.count;
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupIconCell", for: indexPath) as! GroupIconCollectionViewCell
        if(selectedEmoji == indexPath.row) {
            cell.contentView.backgroundColor = UIColor.gray
        }
        cell.image.image = UIImage(named: emoji[indexPath.row]);
        
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        
        return cell;
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        
        unselectAllEmojiSelection()
        if let index = indexPath {
            let cell = self.collectionView.cellForItem(at: index) as! GroupIconCollectionViewCell
            selectedEmoji = index.row;
            cell.contentView.backgroundColor = UIColor.gray
            selectedImage.image = UIImage(named: emoji[selectedEmoji])
        }
    }
    
    func unselectAllEmojiSelection() {
        
        for cell in self.collectionView.visibleCells as! [GroupIconCollectionViewCell] {
            cell.contentView.backgroundColor = UIColor.clear
        }
    }

}
