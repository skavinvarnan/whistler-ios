//
//  SignInViewController.swift
//  Whistler
//
//  Created by Kavin Varnan on 14/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit

import Firebase
import GoogleSignIn
import TRON
import MBProgressHUD

class SignInViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var termsConditionLabel: UILabel!
    @IBOutlet weak var imageViewCricket: UIImageView!
    var justSignedIn = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        self.initLabel()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    func initLabel() {
        let attrsWhite = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10), NSAttributedStringKey.foregroundColor : UIColor.white]
        let attrsBlue = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10), NSAttributedStringKey.foregroundColor : UIColor.blue]
        let attributedString1 = NSMutableAttributedString(string:"By clicking Sign In, you agree to our ", attributes:attrsWhite)
        let attributedString2 = NSMutableAttributedString(string:"Terms of Service", attributes:attrsBlue)
        let attributedString3 = NSMutableAttributedString(string:" and that you have read our ", attributes:attrsWhite)
        let attributedString4 = NSMutableAttributedString(string:"Privacy Policy", attributes:attrsBlue)
        
        attributedString1.append(attributedString2)
        attributedString1.append(attributedString3)
        attributedString1.append(attributedString4)
        self.termsConditionLabel.attributedText = attributedString1
        
        self.termsConditionLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userDidTapLabel))
        self.termsConditionLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc func userDidTapLabel(tapGestureRecognizer: UITapGestureRecognizer) {
        let otherAlert = UIAlertController(title: "Select", message: "Which one would you like to read", preferredStyle: UIAlertControllerStyle.alert)
        
        let callFunction = UIAlertAction(title: "Terms of Service", style: UIAlertActionStyle.default, handler: openTerms)
        let dismiss = UIAlertAction(title: "Privacy Policy", style: UIAlertActionStyle.default, handler: openPrivacy)
        otherAlert.addAction(dismiss)
        otherAlert.addAction(callFunction)
        
        present(otherAlert, animated: true, completion: nil)
    }
    
    @objc func openTerms(_: UIAlertAction){
        if let url = URL(string: "https://guessbuzz.in/terms.html") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            Analytics.logEvent("terms", parameters: [:])
        }
    }
    
    @objc func openPrivacy(_: UIAlertAction){
        if let url = URL(string: "https://guessbuzz.in/privacy.html") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            Analytics.logEvent("privacy", parameters: [:])
        }
    }
    
    @objc func willEnterForeground() {
        if self.isViewLoaded && (self.view.window != nil) {
            self.loadMatch()
        }
    }
    
    func loadMatch() {
        if (Auth.auth().currentUser != nil) {
            self.getFirebaseAccessToken()
            self.signInButton.isHidden = true
            self.termsConditionLabel.isHidden = true
        } else {
            self.signInButton.isHidden = false
            self.termsConditionLabel.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadMatch()
    }

    
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance().signOut();
        } catch let error as NSError {
            self.errorInSignOut(error: error);
        }
    }
    
    func errorInSignOut(error: Error) {
        print(error)
    }
    
    func errorInGoogleSignIn(error: Error) {
        print(error)
    }
    
    func errorObtainingFirebaseAccessToken(error: Error) {
        print(error)
    }
    
    func obtainedFirebaseAccessToken(accessToken: String) {
        UserDefaults.standard.set(accessToken, forKey: Constants.UserDefaults.ACCESS_TOKEN)
        self.getHappeningMatch()
    }
    
    
    func getHappeningMatch() {
        let request: APIRequest<ScheduleList, ServerError> = TronService.sharedInstance.createRequest(path: "/match/happening_schedule");
        request.perform(withSuccess: { (response) in
            if let err = response.error {
                self.errorApiCall(error: err)
            } else {
                WhistlerManager.sharedInstance.happeningMatchs.removeAll()
                for schedule in response.schedules! {
                    WhistlerManager.sharedInstance.happeningMatchs.append(schedule)
                }
                if WhistlerManager.sharedInstance.happeningMatchs.count == 0 {
                    self.getSomeMatch()
                } else {
                    WhistlerManager.sharedInstance.currentMatch = WhistlerManager.sharedInstance.happeningMatchs[0]
                    self.performSegue(withIdentifier: "openLanding", sender: nil);
                }
            }
        }) { (error) in
            let alertController = Utils.simpleAlertController(title: "No connection", message: "Unable to connect with to the internet. Please check your network settings");
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func getSomeMatch() {
        let request: APIRequest<ScheduleList, ServerError> = TronService.sharedInstance.createRequest(path: "/match/get_some_match_to_display");
        request.perform(withSuccess: { (response) in
            if let err = response.error {
                self.errorApiCall(error: err)
            } else {
                for schedule in response.schedules! {
                    WhistlerManager.sharedInstance.happeningMatchs.append(schedule)
                }
                if WhistlerManager.sharedInstance.happeningMatchs.count == 0 {
                    let alertController = UIAlertController(title: "Oops!!", message: "No live matches now", preferredStyle: .alert)
                    let actionOk = UIAlertAction(title: "OK", style: .default, handler: {(action:UIAlertAction!) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                    alertController.addAction(actionOk)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    WhistlerManager.sharedInstance.currentMatch = WhistlerManager.sharedInstance.happeningMatchs[0]
                    self.performSegue(withIdentifier: "openLanding", sender: nil);
                }
            }
        }) { (error) in
            let alertController = Utils.simpleAlertController(title: "No connection", message: "Unable to connect with to the internet. Please check your network settings");
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func getFirebaseAccessToken() {
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                self.errorObtainingFirebaseAccessToken(error: error)
                return;
            }
            self.loadingNotification?.hide(animated: true)
            if self.justSignedIn {
                self.doUserInitStuff(name: currentUser!.displayName!, accessToken: idToken!, email: currentUser!.email!)
            } else {
                self.obtainedFirebaseAccessToken(accessToken: idToken!)
            }
        }
    }
    
    func doUserInitStuff(name: String, accessToken: String, email: String) {
        UserDefaults.standard.set(accessToken, forKey: Constants.UserDefaults.ACCESS_TOKEN)
        let request: APIRequest<GenericResponse, ServerError> = TronService.sharedInstance.createRequest(path: "/user/init/\(name)/\(email)");
        request.perform(withSuccess: { (response) in
            if let err = response.error {
                self.errorApiCall(error: err)
            } else {
                self.obtainedFirebaseAccessToken(accessToken: accessToken)
            }
        }) { (error) in
            let alertController = Utils.simpleAlertController(title: "No connection", message: "Unable to connect with to the internet. Please check your network settings");
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func errorApiCall(error: ErrorModel) {
        //TODO
    }
    
    var loadingNotification: MBProgressHUD?
    func gotCredentials(credentials: AuthCredential) {
        loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.label.text = "Loading"
        Auth.auth().signIn(with: credentials) { (user, error) in
            if let error = error {
                self.errorInGoogleSignIn(error: error)
                return
            }
            self.justSignedIn = true;
            self.getFirebaseAccessToken();
        }
    }
}
