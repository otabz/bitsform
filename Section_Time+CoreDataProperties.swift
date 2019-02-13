//
//  Section_Time+CoreDataProperties.swift
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

extension Section_Time {

    @NSManaged var close_at: String?
    @NSManaged var day: String?
    @NSManaged var form_id: String?
    @NSManaged var open_at: String?

}
