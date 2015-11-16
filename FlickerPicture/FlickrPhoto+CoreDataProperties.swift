//
//  FlickrPhoto+CoreDataProperties.swift
//  FlickerPicture
//
//  Created by Joshua Alvarado on 11/16/15.
//  Copyright © 2015 Joshua Alvarado. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FlickrPhoto {

    @NSManaged var creationDate: NSDate?
    @NSManaged var image: NSData?
    @NSManaged var title: String?
    @NSManaged var id: String?

}
