//
//  ActivitySelection.swift
//  FitMate
//
//  Created by Derek Sanchez on 9/8/15.
//  Copyright © 2015 Dramatech. All rights reserved.
//

import Foundation

struct CategoryList {
    var categories: [UserCategory]
}

class ActivitySelectionController {
    var categories: CategoryList?
    var names:  [String] = []
    var ids:    [Int] = []
    
    var idSearch = ["Barre","CrossFit","Cycling","Fitness Classes","Orange Theory","Pilates","Running","Spin","Swimming","Walking","Weightlifting","Yoga","Baseball","Basketball","Cricket","Golf","Hockey","Martial Arts","Racket/hand Ball","Rec Sports","Rugby","Soccer","Softball","Tennis","Volleyball","Backpacking","Camping","Equestrian","Fishing","Hiking","Hunting","Motocross","Mountain Bike","Rock Climbing","Boating","Kayaking","Kite/Wind Surfing","River Rafting","Sailing","Scuba/Snorkel","Ski/Wakeboard","Stand-up Paddleboard","Surfing"];

    

    init() {
        loadCurrentActivities()
    }

    func loadCurrentActivities() {
        let currentActivityList = ProfileManager.sharedInstance.activities()
        for activity in currentActivityList.categories {
            selectCategory(activity.cID, name: activity.name)
        }
    }
    
    func selectCategory(cID: Int, name: String) {
        print("Selecting \(name).")
        //if !ids.contains(cID) {
         //   ids.append(cID)
        //}
        if !names.contains(name) {
            names.append(name)
            ids.append(idSearch.indexOf(name)!)
        }
    }
    
    func deselectCategory(cID: Int, name: String) {
        print("Deselecting \(name).")
        /*if ids.contains(cID) {
            let i = ids.indexOf(cID)!
            ids.removeAtIndex(i)
        }
*/
        if names.contains(name) {
            let i = names.indexOf(name)!
            names.removeAtIndex(i)
            ids.removeAtIndex(i)
        }
    }
    
    func commitCategories() -> CategoryList {
        var categoryArray: [UserCategory] = []
        print("NAMES: \(names)")
        print("IDS: \(ids)")
        for var i = 0; i < ids.count; i++ {
            let category = UserCategory(cID: ids[i], name: names[i])
            categoryArray.append(category)
        }
        self.categories = CategoryList(categories: categoryArray)
        return self.categories!
    }
    
    
    func categorySelected(name: String) -> Bool {
        if names.contains(name) {
            return true
        }
        return false
    }
}


