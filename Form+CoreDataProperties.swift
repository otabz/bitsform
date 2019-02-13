//
//  Form+CoreDataProperties.swift
//  ExtendedForms
//
//  Created by Waseel ASP Ltd. on 8/16/1437 AH.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Form {

    @NSManaged var client_id: String?
    @NSManaged var id: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var name_ar: String?
    @NSManaged var name_en: String?
    @NSManaged var name_fr: String?
    @NSManaged var name_ur: String?
    @NSManaged var name_zh: String?
    @NSManaged var phone_emergency: String?
    @NSManaged var phone_reception: String?
    @NSManaged var photo1: NSData?
    @NSManaged var photo2: NSData?
    @NSManaged var section_contact: NSNumber?
    @NSManaged var section_location: NSNumber?
    @NSManaged var section_names: NSNumber?
    @NSManaged var section_photos: NSNumber?
    @NSManaged var section_specialty: NSNumber?
    @NSManaged var section_time: NSNumber?
    @NSManaged var sent: NSNumber?
    @NSManaged var sent_at: NSDate?
    @NSManaged var server_id: NSNumber?
    @NSManaged var updated_at: NSDate?
    @NSManaged var url: String?
    @NSManaged var uploaded_by: String?

}
