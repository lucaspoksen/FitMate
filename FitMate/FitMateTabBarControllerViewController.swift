//
//  FitMateTabBarControllerViewController.swift
//  FitMate
//
//  Created by Derek Sanchez on 9/14/15.
//  Copyright © 2015 Dramatech. All rights reserved.
//

import UIKit
import FontAwesomeKit

class FitMateTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var m_bCreatedFirst:Bool = true
    var m_oldSelectedIndex:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        ProfileManager.sharedInstance.tabBarController = self
        if (m_bCreatedFirst == true){
            self.selectedIndex = 0
        }
        
        self.delegate = self
    }
    
    func setBadgeIcon(count: Int) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if count != 0 {
                print("setting tab bar badge.")
                self.tabBar.items![1].badgeValue = "\(count)"
            } else {
            self.tabBar.items![1].badgeValue = nil
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController){
/*
        if (tabBarController.selectedIndex == 1) //Activity Save Controller
        {
            //SaveActivityController
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let activityController:LightContentNavController = storyboard.instantiateViewControllerWithIdentifier("SaveActivityController") as! LightContentNavController
            
            let topViewController:ActivitySettingController = activityController.topViewController as! ActivitySettingController
            topViewController.m_FromWhere = BearActivityControllerType.FW_NORMALUSE
            viewController.presentViewController(activityController, animated: true, completion: nil)
        }
*/
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool{
        m_oldSelectedIndex = tabBarController.selectedIndex
        return true
    }

}
