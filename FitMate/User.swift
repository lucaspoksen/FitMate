//
//  User.swift
//  
//
//  Created by Derek Sanchez on 8/11/15.
//
//

import Foundation
import CoreData

@objc(User)
class User: NSManagedObject {

    @NSManaged var age: Int16
    @NSManaged var birthday: String
    @NSManaged var contactEmail: String
    @NSManaged var device: String
    @NSManaged var distanceMiles: Double
    @NSManaged var firstname: String
    @NSManaged var galleryCount: Int16
    @NSManaged var gender: Int16
    @NSManaged var lastMessage: String
    @NSManaged var lastMessageFlag: Int16
    @NSManaged var lastname: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var matchedDate: String
    @NSManaged var photo: String
    @NSManaged var settingDistance: Int16
    @NSManaged var settingShowAgeMax: Int16
    @NSManaged var settingShowAgeMin: Int16
    @NSManaged var settingShowMeFlag: Int16
    @NSManaged var uAbout: String
    @NSManaged var uID: String
    @NSManaged var username: String
    @NSManaged var uTag: String
    @NSManaged var categories: NSOrderedSet
    @NSManaged var gallery: NSMutableOrderedSet

}
