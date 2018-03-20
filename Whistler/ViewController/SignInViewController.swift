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

class SignInViewController: UIViewController, GIDSignInUIDelegate {

    @IBAction func testButtonClicked(_ sender: UIButton) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        if (Auth.auth().currentUser != nil) {
            self.getFirebaseAccessToken()
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
        print(Auth.auth().currentUser?.uid)
        print(UserDefaults.standard.string(forKey: Constants.UserDefaults.ACCESS_TOKEN)!);
        performSegue(withIdentifier: "openLanding", sender: nil);
    }
    
    func getFirebaseAccessToken() {
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                self.errorObtainingFirebaseAccessToken(error: error)
                return;
            }
            self.obtainedFirebaseAccessToken(accessToken: idToken!)
        }
    }
    
    func gotCredentials(credentials: AuthCredential) {
        Auth.auth().signIn(with: credentials) { (user, error) in
            if let error = error {
                self.errorInGoogleSignIn(error: error)
                return
            }
            self.getFirebaseAccessToken();
        }
    }
}
