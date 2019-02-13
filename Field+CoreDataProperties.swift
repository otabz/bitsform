//
//  Field+CoreDataProperties.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 8/4/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Field {

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var type: String?

}
