//
//  More_Fields_Values+CoreDataProperties.swift
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

extension More_Fields_Values {

    @NSManaged var form_id: String?
    @NSManaged var field_id: String?
    @NSManaged var value: String?

}
