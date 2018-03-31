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

class SignInViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var termsConditionLabel: UILabel!
    @IBOutlet weak var imageViewCricket: UIImageView!
    var justSignedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        self.initLabel()
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
        let otherAlert = UIAlertController(title: "Which one?", message: "Which one would you like to read", preferredStyle: UIAlertControllerStyle.alert)
        
        let callFunction = UIAlertAction(title: "Terms", style: UIAlertActionStyle.default, handler: openTerms)
        let dismiss = UIAlertAction(title: "Privacy", style: UIAlertActionStyle.default, handler: openPrivacy)
        otherAlert.addAction(dismiss)
        otherAlert.addAction(callFunction)
        
        present(otherAlert, animated: true, completion: nil)
    }
    
    @objc func openTerms(_: UIAlertAction){
        if let url = URL(string: "https://www.guessbuzz.in/terms.html") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func openPrivacy(_: UIAlertAction){
        if let url = URL(string: "https://www.guessbuzz.in/privacy.html") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (Auth.auth().currentUser != nil) {
            self.getFirebaseAccessToken()
            self.signInButton.isHidden = true
            self.termsConditionLabel.isHidden = true
        } else {
            self.signInButton.isHidden = false
            self.termsConditionLabel.isHidden = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
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
                    let alertController = UIAlertController(title: "No matches", message: "No live matches come again later", preferredStyle: .alert)
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
            if self.justSignedIn {
                self.doUserInitStuff(name: currentUser!.displayName!, accessToken: idToken!)
            } else {
                self.obtainedFirebaseAccessToken(accessToken: idToken!)
            }
        }
    }
    
    func doUserInitStuff(name: String, accessToken: String) {
        UserDefaults.standard.set(accessToken, forKey: Constants.UserDefaults.ACCESS_TOKEN)
        let request: APIRequest<GenericResponse, ServerError> = TronService.sharedInstance.createRequest(path: "/user/init/\(name)");
        request.perform(withSuccess: { (response) in
            if let err = response.error {
                self.errorApiCall(error: err)
            } else {
                print("User init success")
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
    
    func gotCredentials(credentials: AuthCredential) {
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
