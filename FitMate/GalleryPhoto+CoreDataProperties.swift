//
//  GalleryPhoto+CoreDataProperties.swift
//  FitMate
//
//  Created by Derek Sanchez on 9/18/15.
//  Copyright © 2015 Dramatech. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension GalleryPhoto {

    @NSManaged var gID: NSNumber?
    @NSManaged var photo: String?
    @NSManaged var user: User?

}
