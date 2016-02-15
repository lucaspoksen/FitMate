//
//  BlockListCell.swift
//  FitMate
//
//  Created by PSIHPOK on 12/5/15.
//  Copyright © 2015 PSIHPOK. All rights reserved.
//

import UIKit

class BlockListCell: UITableViewCell{
    
    
    @IBOutlet weak var m_BackgroundView: UIView!
    
    @IBOutlet weak var m_PhotoImage: UIImageView!
    
    @IBOutlet weak var m_Name: UILabel!
    
    @IBOutlet weak var m_UnblockButton: UIButton!
    
    @IBOutlet weak var m_Indicator: UIActivityIndicatorView!
    
    
    override func layoutSubviews(){
        super.layoutSubviews()
        if (m_PhotoImage != nil){
            m_PhotoImage.layer.cornerRadius = m_PhotoImage.frame.size.width / 2
            m_PhotoImage.clipsToBounds = true
        }
        self.performSelector("showPhoto", withObject: nil, afterDelay: 0.5)
    }
    
    func showPhoto(){
        m_PhotoImage.alpha = 1.0
        m_Indicator.stopAnimating()
        m_Indicator.hidden = true
    }
}
