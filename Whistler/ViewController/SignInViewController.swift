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
    
    var happeningMatchs = [Schedule]();
    
    func getHappeningMatch() {
        let request: APIRequest<ScheduleList, ServerError> = TronService.sharedInstance.createRequest(path: "/match/happening_schedule");
        request.perform(withSuccess: { (response) in
            if let err = response.error {
                self.errorApiCall(error: err)
            } else {
                for schedule in response.schedules! {
                    self.happeningMatchs.append(schedule)
                }
                self.performSegue(withIdentifier: "openLanding", sender: nil);
            }
        }) { (error) in
            let alertController = Utils.simpleAlertController(title: "No connection", message: "Unable to connect with to the internet. Please check your network settings");
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openLanding" {
            let tbVc = segue.destination as! UITabBarController
            let nav = tbVc.viewControllers![1] as! UINavigationController
            let destinationViewController = nav.topViewController as! LiveViewController
            destinationViewController.happeningMatches = self.happeningMatchs
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
