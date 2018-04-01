//
//  MainTabBarViewController.swift
//  Whistler
//
//  Created by Kavin Varnan on 01/04/18.
//  Copyright © 2018 Virtual Applets. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 0 {
            Analytics.logEvent("schedule", parameters: [:])
        } else if tabBarIndex == 1 {
            Analytics.logEvent("live", parameters: [:])
        } else if tabBarIndex == 2 {
            Analytics.logEvent("leaderboard", parameters: [:])
        } else if tabBarIndex == 3 {
            Analytics.logEvent("groups", parameters: [:])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
