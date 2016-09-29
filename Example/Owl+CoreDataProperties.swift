//
//  Owl+CoreDataProperties.swift
//  
//
//  Created by t4nhpt on 9/23/16.
//
//

import Foundation
import CoreData


extension Owl {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Owl> {
        return NSFetchRequest<Owl>(entityName: "Owl")
    }

    @NSManaged public var color: String?
    @NSManaged public var height: NSNumber?
    @NSManaged public var name: String?

}
