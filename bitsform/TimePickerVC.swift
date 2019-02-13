//
//  TimePickerVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 7/12/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData

class TimePickerVC: UIViewController {
    var openAt: String!
    var closeAt: String!
    var dayName: String!
    var draftedFormNumber: String!
    
    @IBOutlet weak var opening: UIDatePicker!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var closing: UIDatePicker!
    var Context : NSManagedObjectContext! = nil
    
    //lazy var Context: NSManagedObjectContext = {
    //    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    //    return appDelegate.managedObjectContext
    //}()
    
    override func viewDidLoad() {
        self.name.text = dayName
        if !self.openAt.isEmpty {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            let date = dateFormatter.dateFromString(self.openAt)
            self.opening.date = date!
        }
        if !self.closeAt.isEmpty {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            let date = dateFormatter.dateFromString(self.closeAt)
            self.closing.date = date!
        }
        
    }
    @IBAction func close(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: UIButton) {
        
        // update
        //let Context  = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Section_Time")
        fetchRequest.predicate = NSPredicate(format: "day = %@ AND form_id = %@", argumentArray: [self.dayName, self.draftedFormNumber])
        
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if found!.count != 0 {
                let time = found![0] as! Section_Time
                time.open_at = dateToString(self.opening.date)
                time.close_at = dateToString(self.closing.date)
                //try Context.save()
            } else {
                // Time
                let tt = NSEntityDescription.insertNewObjectForEntityForName("Section_Time", inManagedObjectContext: Context) as! Section_Time
                //let entity = NSEntityDescription.entityForName("Section_Time", inManagedObjectContext: self.Context)
                // Initialize
                //let opening_hours = Section_Time(entity: entity!, insertIntoManagedObjectContext: self.Context)
                //opening_hours.form_id = self.draftedFormNumber
                //opening_hours.day = self.dayName
                //opening_hours.open_at = dateToString(self.opening.date)
                //opening_hours.close_at = dateToString(self.closing.date)
                tt.form_id = self.draftedFormNumber
                tt.day = self.dayName
                tt.open_at = dateToString(self.opening.date)
                tt.close_at = dateToString(self.closing.date)
                
                //try self.Context.save()
            }
            try updateForm(Context)
            try Context.save()
        } catch {
            print(error)
        }
        self.performSegueWithIdentifier("unwind", sender: self)
    }
    
    func updateForm(Context: NSManagedObjectContext) throws {
        // update form
        let fetchRequest = NSFetchRequest(entityName: "Form")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.draftedFormNumber)
        
        let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        if found!.count != 0 {
            let form = found![0] as! Form
            form.updated_at = NSDate()
            form.sent = false
        }
    }
    
    func dateToString(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let dateString = dateFormatter.stringFromDate(date)
        return dateString
    }
    @IBAction func clear(sender: UIButton) {
        let fetchRequest = NSFetchRequest(entityName: "Section_Time")
        fetchRequest.predicate = NSPredicate(format: "day = %@ AND form_id = %@", argumentArray: [self.dayName, self.draftedFormNumber])
        
        do {
            //let Context  = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if found!.count != 0 {
                Context.deleteObject(found![0])
                try updateForm(Context)
            }
            try Context.save()
            //self.dismissViewControllerAnimated(true, completion: nil)
        } catch {
            print(error)
        }
        self.performSegueWithIdentifier("unwind", sender: self)
    }
}
