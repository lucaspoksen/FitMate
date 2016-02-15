//
//  ActivityCategory.swift
//  FitMate
//
//  Created by PSIHPOK on 11/19/15.
//  Copyright © 2015 PSIHPOK. All rights reserved.
//

import UIKit

class ActivityCategory: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var m_CategoryLabel: UILabel!
    
    @IBOutlet weak var m_ActivityTable: UITableView!
    
    @IBOutlet weak var m_TitleView: UIView!
    
    
    var categories = ["Fitness", "Sports", "Outdoor", "Water Sports"]
    var activities: [String: [String] ] = ["Fitness": ["Barre", "CrossFit", "Cycling", "Fitness Classes", "Orange Theory", "Pilates", "Running", "Spin", "Swimming", "Walking", "Weightlifting", "Yoga"],
        "Sports" : ["Baseball", "Basketball", "Cricket", "Golf", "Hockey", "Martial Arts", "Racket/hand Ball", "Rec Sports", "Rugby", "Soccer" ,"Softball", "Tennis", "Volleyball"],
        "Outdoor" : ["Backpacking", "Camping", "Equestrian", "Fishing", "Hiking", "Hunting", "Motocross", "Mountain Bike", "Rock Climbing"],
        "Water Sports" : ["Boating", "Kayaking", "Kite/Wind Surfing", "River Rafting",  "Sailing", "Scuba/Snorkel",  "Ski/Wakeboard", "Stand-up Paddleboard", "Surfing"],
    ]
    
    var idSearch = ["Barre","CrossFit","Cycling","Fitness Classes","Orange Theory","Pilates","Running","Spin","Swimming","Walking","Weightlifting","Yoga","Baseball","Basketball","Cricket","Golf","Hockey","Martial Arts","Racket/hand Ball","Rec Sports","Rugby","Soccer","Softball","Tennis","Volleyball","Backpacking","Camping","Equestrian","Fishing","Hiking","Hunting","Motocross","Mountain Bike","Rock Climbing","Boating","Kayaking","Kite/Wind Surfing","River Rafting","Sailing","Scuba/Snorkel","Ski/Wakeboard","Stand-up Paddleboard","Surfing"];
    
    var currentCategory:String = ""
    var currentCategoryIndex:Int = 0
    
    override func viewDidLoad() {
        currentCategory = categories[currentCategoryIndex]
        m_CategoryLabel.text = currentCategory
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categoryCount = activities[currentCategory]?.count
        return categoryCount!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ActivityCell = tableView.dequeueReusableCellWithIdentifier("ActivityCell") as! ActivityCell
        let row = indexPath.row
        cell.m_ActivityButton.setTitle(activities[currentCategory]![row], forState: UIControlState.Normal)

        let categoryController = ActivitySettingController.g_ActivityController
        cell.m_userCategory = UserCategory(cID: idSearch.indexOf(activities[currentCategory]![row])!, name: activities[currentCategory]![row])
        
        if (categoryController.categorySelected(activities[currentCategory]![row]) == true){
            cell.selectCell(true)
        }
        else {
            cell.selectCell(false)
        }
        return cell
    }
    
}