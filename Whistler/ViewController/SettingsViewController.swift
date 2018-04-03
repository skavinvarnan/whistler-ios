//
//  SettingsViewController.swift
//  Whistler
//
//  Created by Kavin Varnan on 23/03/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func closeViewController(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func rulesClicked(_ sender: UIButton) {
        if let url = URL(string: "https://www.guessbuzz.in/rules.html") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            Analytics.logEvent("rules_settings", parameters: [:])
        }
        
    }
    
    @IBAction func faqClicked(_ sender: UIButton) {
        if let url = URL(string: "https://www.guessbuzz.in/faq.html") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            Analytics.logEvent("faq_settings", parameters: [:])
        }
     
    }
    
    @IBAction func privacyClicked(_ sender: UIButton) {
        if let url = URL(string: "https://www.guessbuzz.in/privacy.html") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            Analytics.logEvent("privacy_settings", parameters: [:])
        }
    }
    
    @IBAction func termsOfServiceClicked(_ sender: Any) {
        if let url = URL(string: "https://www.guessbuzz.in/terms.html") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            Analytics.logEvent("terms_settings", parameters: [:])
        }
    }
    @IBAction func logout(_ sender: UIButton) {
        Analytics.logEvent("logout", parameters: [:])
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance().signOut();
            self.dismiss(animated: true, completion: nil)
        } catch let error as NSError {
            Analytics.logEvent("logout_error", parameters: [:])
            self.errorInSignOut(error: error);
        }
        
    }
    
    func errorInSignOut(error: Error) {
        print(error)
    }
}
