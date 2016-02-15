//
//  Category+CoreDataProperties.swift
//  FitMate
//
//  Created by Derek Sanchez on 9/8/15.
//  Copyright © 2015 Dramatech. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Category {

    @NSManaged var cFlag: NSNumber?
    @NSManaged var cID: NSNumber?
    @NSManaged var cName: String?
    @NSManaged var user: User?

}
