//
//  ActivityCell.swift
//  FitMate
//
//  Created by PSIHPOK on 11/19/15.
//  Copyright © 2015 PSIHPOK. All rights reserved.
//

import UIKit

class ActivityCell: UITableViewCell {
    @IBOutlet weak var m_ActivityButton: UIButton!
    var m_bSelected:Bool = true;
    var m_userCategory:UserCategory!
    
    @IBAction func onClickSelect(sender: AnyObject) {
        changeSelect()
    }
    
    func changeSelect(){
        m_bSelected = !m_bSelected
        selectCell(m_bSelected)
    }
    
    func selectCell(bSelect:Bool){
        m_bSelected = bSelect
        let cID:Int! = m_userCategory?.cID
        let cName:String! = m_userCategory?.name
        if m_bSelected == true{
            let backgroundImage = UIImage(named: "sel_activity")
            m_ActivityButton.setBackgroundImage(backgroundImage, forState: UIControlState.Normal)
            
            m_ActivityButton.setTitleColor(UIColor(red: 0.08, green: 0.66, blue: 0.94, alpha: 1), forState: UIControlState.Normal)
            ActivitySettingController.g_ActivityController.selectCategory(cID, name: cName)
        }
        else {
            let backgroundImage = UIImage(named: "desel_activity")
            
            m_ActivityButton.setBackgroundImage(backgroundImage, forState: UIControlState.Normal)
            m_ActivityButton.setTitleColor(UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1), forState: UIControlState.Normal)
            ActivitySettingController.g_ActivityController.deselectCategory(cID, name: cName)
        }
    }
}