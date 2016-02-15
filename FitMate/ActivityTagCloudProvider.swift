//
//  ActivityTagCloudProvider.swift
//  FitMate
//
//  Created by Derek Sanchez on 9/14/15.
//  Copyright © 2015 Dramatech. All rights reserved.
//

import Foundation
import UIKit

class ActivityTagCloudProvider: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var categoryList: [UserCategory]?
    var sharedCategoriesList: [String]?
    let cellIdentifier = "ActivityCell"
    
    func setup() {
        if(self.categoryList != nil) {
            self.sharedCategoriesList = ProfileManager.sharedInstance.sharedActivitesFromCategories(self.categoryList!)
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(categoryList != nil){
            return categoryList!.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! ActivityCollectionViewCell
        let activity = categoryList![indexPath.row].name
        cell.label!.text = activity
        cell.label!.layer.cornerRadius = 3.0
        if self.sharedCategoriesList!.contains(activity) {
            cell.label!.backgroundColor = UIColor(red: 66.0/255.0, green: 136.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        } else {
            cell.label!.backgroundColor = UIColor.darkGrayColor()
        }
        cell.label!.clipsToBounds = true
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: labelSize(self.categoryList![indexPath.row].name), height: 21.0)
    }
    
    func labelSize(string: String) -> CGFloat {
        let text = string as NSString
        let rect = text.boundingRectWithSize(CGSizeZero, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(11.0)], context: nil)
        return rect.size.width+8.0
    }

}