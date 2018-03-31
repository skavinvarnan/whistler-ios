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
    
    
    @IBAction func privacyClicked(_ sender: UIButton) {
        if let url = URL(string: "https://www.guessbuzz.in/privacy.html") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func termsOfServiceClicked(_ sender: Any) {
        if let url = URL(string: "https://www.guessbuzz.in/terms.html") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    @IBAction func logout(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance().signOut();
            self.dismiss(animated: true, completion: nil)
        } catch let error as NSError {
            self.errorInSignOut(error: error);
        }
        
    }
    
    func errorInSignOut(error: Error) {
        print(error)
    }
}
