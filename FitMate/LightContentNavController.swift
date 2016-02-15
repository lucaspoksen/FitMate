//
//  LightContentNavController.swift
//  FitMate
//
//  Created by PSIHPOK on 11/20/15.
//  Copyright © 2015 PSIHPOK. All rights reserved.
//

import UIKit

class LightContentNavController: UINavigationController{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle{
        return UIStatusBarStyle.LightContent
    }
}