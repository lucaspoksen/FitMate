//
//  MateTableCell.swift
//  FitMate
//
//  Created by PSIHPOK on 12/4/15.
//  Copyright © 2015 PSIHPOK. All rights reserved.
//

import UIKit

class MateTableCell:UITableViewCell{
    
    @IBOutlet weak var m_BackgroundView: UIView!
    
    @IBOutlet weak var m_Photo: UIImageView!
    
    @IBOutlet weak var m_NewMessageFlag: UIImageView!
    
    @IBOutlet weak var m_NameLabel: UILabel!
    
    @IBOutlet weak var m_ConnectionTime: UILabel!
    
    @IBOutlet weak var m_LastMessage: UITextView!
    
    @IBOutlet weak var m_DetailButton: UIButton!
    
    @IBOutlet weak var m_Indicator: UIActivityIndicatorView!
    
    override func layoutSubviews(){
        super.layoutSubviews()
        
        
        if (m_Photo != nil){
            m_Photo.layer.cornerRadius = m_Photo.frame.size.width / 2
            m_Photo.clipsToBounds = true
        }
        self.performSelector("showPhoto", withObject: nil, afterDelay: 0.5)
    }
    
    func showPhoto(){
        m_Photo.alpha = 1.0
        m_Indicator.stopAnimating()
        m_Indicator.hidden = true
    }
}

