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
    var justSignedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        if (Auth.auth().currentUser != nil) {
            self.getFirebaseAccessToken()
            self.signInButton.isHidden = true
        } else {
            
        }
        
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
                    let alertController = Utils.simpleAlertController(title: "currently no matches", message: "handle this case");
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
