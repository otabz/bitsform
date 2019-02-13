//
//  NameVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 7/13/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData

class NameVC: UIViewController {
    @IBOutlet weak var arName: UITextField!
    @IBOutlet weak var violationSymbol: UIImageView!
    @IBOutlet weak var violationText: UILabel!
    @IBOutlet weak var clientIdentifier: UITextField!
    var draftedFormNumber: String!
    var Context: NSManagedObjectContext!
    @IBOutlet weak var enNameTxt: UITextView!
    /*lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()*/
    
    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
        loadData()
        toggleViolation(false)
    }
    @IBAction func close(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadData() {
        // load form
        let fetchRequest = NSFetchRequest(entityName: "Form")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.draftedFormNumber)
        
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if found!.count != 0 {
                let form = found![0] as! Form
                 self.enNameTxt.text = form.name_en
                 self.arName.text =  form.name_ar
                 self.clientIdentifier.text = form.client_id
            }
        } catch {
            print(error)
        }
    }
    
    @IBAction func save(sender: UIButton) {
        if !isFilled() {
            toggleViolation(true)
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
                form.name_en = self.enNameTxt.text
                form.name_ar = self.arName.text
                form.client_id = self.clientIdentifier.text
                form.section_names = true
                try Context.save()
            }
        } catch {
            print(error)
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("back", sender: self)
    }

    func isFilled() -> Bool {
        if (enNameTxt.text == nil || enNameTxt.text!.isEmpty) {
            return false
        }
        return true
    }
    
    func toggleViolation(raised: Bool) {
        if raised {
            self.violationSymbol.hidden = false
            self.violationText.text = "Please, fill the form."
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
                form.name_en = nil
                form.name_ar = nil
                form.client_id = nil
                form.section_names = false
                try Context.save()
            }
        } catch{
            print(error)
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("back", sender: self)
    }
}