//
//  ContactInfoVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 7/12/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData

class ContactInfoVC: UIViewController {
    @IBOutlet weak var violationSymbol: UIImageView!
    @IBOutlet weak var violationText: UILabel!
    @IBOutlet weak var website: UITextField!
    @IBOutlet weak var phoneEmergency: UITextField!
    @IBOutlet weak var phoneReception: UITextField!
    var draftedFormNumber: String!
    var Context: NSManagedObjectContext!
    /*lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()*/
    
    override func viewDidLoad() {
         self.hideKeyboardWhenTappedAround()
        toggleViolation(false, message: "")
        loadData()
    }
    
    func loadData() {
        // load form
        let fetchRequest = NSFetchRequest(entityName: "Form")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.draftedFormNumber)
        
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if found!.count != 0 {
                let form = found![0] as! Form
                self.website.text = form.url
                self.phoneEmergency.text = form.phone_emergency
                self.phoneReception.text = form.phone_reception
            }
        } catch {
            print(error)
        }
    }
    
    @IBAction func close(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func save(sender: UIButton) {
        if !isFilled() {
            toggleViolation(true, message: "Please, fill the form.")
            return
        }
        // update form
        let fetchRequest = NSFetchRequest(entityName: "Form")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.draftedFormNumber)
        
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if found!.count != 0 {
                let form = found![0] as! Form
                form.updated_at = NSDate()
                form.sent = false
                form.section_contact = true
                form.url = self.website.text
                form.phone_emergency = self.phoneEmergency.text
                form.phone_reception = self.phoneReception.text
                try Context.save()
            }
        } catch {
            print(error)
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("back", sender: self)
    }
    
    func isFilled() -> Bool {
        if self.website.text!.isEmpty
            && self.phoneEmergency.text!.isEmpty
            && self.phoneReception.text!.isEmpty {
                return false
        }
        return true
    }
    
    func toggleViolation(raised: Bool, message: String) {
        if raised {
            self.violationSymbol.hidden = false
            self.violationText.text = message
        } else {
            self.violationSymbol.hidden = true
            self.violationText.text = ""
        }
    }
    
    @IBAction func clear(sender: UIButton) {
        // update form
        let fetchRequest = NSFetchRequest(entityName: "Form")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.draftedFormNumber)
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if found!.count != 0 {
                let form = found![0] as! Form
                form.updated_at = NSDate()
                form.sent = false
                form.url = nil
                form.phone_emergency = nil
                form.phone_reception = nil
                form.section_contact = false
                try Context.save()
            }
        } catch{
            print(error)
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("back", sender: self)
    }

}

