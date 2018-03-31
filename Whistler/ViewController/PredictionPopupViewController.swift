//
//  PredictionPopupViewController.swift
//  Whistler
//
//  Created by Kavin Varnan on 22/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import MBProgressHUD
import TRON

class PredictionPopupViewController: UIViewController {

    var overNumberInt = -1;
    var matchKey: String?
    var playingTeam: String?
    var keyboardVisible = false
    
    @IBOutlet weak var overNumber: UILabel!
    @IBOutlet weak var predictionTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        overNumber.text = String(overNumberInt)
        predictionTextField.frame.size.height = 70
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closePopup))
        view.addGestureRecognizer(tap)
        predictionTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @objc func closePopup() {
        if keyboardVisible {
            dismissKeyboard()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func predict(_ sender: UIButton) {
        if (!(predictionTextField.text?.isEmpty)!) {
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            loadingNotification.label.text = "Saving"
            dismissKeyboard()

            let request: APIRequest<GenericResponse, ServerError> = TronService.sharedInstance.createRequest(path: "/prediction/predict/\(WhistlerManager.sharedInstance.currentMatch!.key)/\(playingTeam!)/\(overNumber.text!)/\(predictionTextField.text!)");
            request.perform(withSuccess: { (response) in
                if let err = response.error {
                    self.errorSavingPrediction(error: err)
                    loadingNotification.hide(animated: true)
                } else {
                    loadingNotification.hide(animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
            }) { (error) in
                loadingNotification.hide(animated: true)
                self.errorSavingPrediction(error: ErrorModel(code: 123, message: "Guessing no internet"))
            }
        }
    }
    
    func errorSavingPrediction(error: ErrorModel) {
        if error.code == 401 {
            let alertController = Utils.simpleAlertController(title: "Oops", message: "Sorry!!.. This over has started, so predict the next one");
            self.present(alertController, animated: true, completion: nil)
        } else {
            let alertController = Utils.simpleAlertController(title: "error", message: "more disctiptive mesaage needed");
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        keyboardVisible = true
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 50
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardVisible = false
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += 50
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
