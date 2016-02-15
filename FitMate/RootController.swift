//
//  RootController.swift
//  FitMate
//
//  Created by PSIHPOK on 12/7/15.
//  Copyright © 2015 PSIHPOK. All rights reserved.
//

import UIKit

class RootController: UIViewController{
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginController:LogInController = storyboard.instantiateViewControllerWithIdentifier("LogInController") as! LogInController
        self.presentViewController(loginController, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle{
        return UIStatusBarStyle.LightContent
    }
}
