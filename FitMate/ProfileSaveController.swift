//
//  ProfileSaveController.swift
//  FitMate
//
//  Created by PSIHPOK on 11/19/15.
//  Copyright © 2015 PSIHPOK. All rights reserved.
//

import UIKit

class ProfileSaveController: UIViewController{
    
    @IBOutlet weak var m_SaveButton: UIButton!
    
    @IBOutlet weak var m_GoLabel: UILabel!
    
    weak var m_ParentController: ActivitySettingController!
    
    override func viewDidLoad() {
        
    }
   
 
    @IBAction func onClickSaveProfile(sender: AnyObject) {
        ActivitySettingController.saveActivitySettings(self, from: m_ParentController.m_FromWhere)
    }
    
}
