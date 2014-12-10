//
//  BookItem.swift
//  MyBook
//
//  Created by Rodrigo Carballo on 12/4/14.
//  Copyright (c) 2014 Rodrigo Carballo. All rights reserved.
//

import Foundation
import CoreData

class BookItem: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var shelfLocation: String
    
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, title: String, shelfLocation: String) -> BookItem {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("BookItem", inManagedObjectContext: moc) as BookItem
        newItem.title = title
        newItem.shelfLocation = shelfLocation
        
        return newItem
    }
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, title: String) -> BookItem {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("BookItem", inManagedObjectContext: moc) as BookItem
        newItem.title = title
        
        return newItem
    }

}
