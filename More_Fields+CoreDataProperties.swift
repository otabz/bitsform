//
//  More_Fields+CoreDataProperties.swift
//  ExtendedForms
//
//  Created by Waseel ASP Ltd. on 8/13/1437 AH.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension More_Fields {

    @NSManaged var field_id: String?
    @NSManaged var form_id: String?
    @NSManaged var isFilled: NSNumber?

}
