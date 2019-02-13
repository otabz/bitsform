//
//  Extension_Template+CoreDataProperties.swift
//  ExtendedForms
//
//  Created by Waseel ASP Ltd. on 8/9/1437 AH.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Extension_Template {

    @NSManaged var created_by: String?
    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var sharing_key: String?

}
