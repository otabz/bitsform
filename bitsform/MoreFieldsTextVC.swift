//
//  MoreFieldsTextVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 8/3/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData

class MoreFieldsTextVC: UIViewController {

    var fieldName: String!
    var fieldId: String!
    var formId: String!
    
    @IBOutlet weak var txtQuestion: UITextView!
    @IBOutlet weak var txtAnswer: UITextView!
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.txtQuestion.text = self.fieldName
        loadValue()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        txtAnswer.becomeFirstResponder()
    }
    
    func loadValue() {
        // load time
        let fetchRequest = NSFetchRequest(entityName: "More_Fields_Values")
        fetchRequest.predicate = NSPredicate(format: "field_id == %@ AND form_id == %@", self.fieldId, self.formId)
        
        do {
            let founds = try Context.executeFetchRequest(fetchRequest) as? [More_Fields_Values]
            if founds!.count != 0 {
                self.txtAnswer.text = founds![0].value
                self.txtAnswer.text = self.txtAnswer.text.stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet())
                if self.txtAnswer.text == "" {
                    self.txtAnswer.text = ""
                }
            }
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(sender: UIButton) {
        // update form
        let fetchRequest = NSFetchRequest(entityName: "More_Fields_Values")
        fetchRequest.predicate = NSPredicate(format: "form_id = %@ AND field_id == %@", self.formId, self.fieldId)
        
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for each in found! {
                Context.deleteObject(each)
                //checked = false
            }
            let entity = NSEntityDescription.entityForName("More_Fields_Values", inManagedObjectContext: self.Context)
            // Initialize
            let value = More_Fields_Values(entity: entity!, insertIntoManagedObjectContext: self.Context)
            value.form_id = formId
            value.field_id = fieldId
            value.value = txtAnswer.text
            try updateField(true)
            try Context.save()
            try updateForm()
        } catch {
            print(error)
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("back", sender: self)
    }
    
    func updateForm() throws {
        // update form
        let fetchRequest = NSFetchRequest(entityName: "Form")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.formId)
        
        let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        if found!.count != 0 {
            let form = found![0] as! Form
            form.updated_at = NSDate()
            form.sent = false
            /*form.section_specialty = false
            if checked! {
            form.section_specialty = true
            }*/
            try Context.save()
        }
    }
    
    func updateField(check: Bool) throws {
        //if check {
        let value = NSFetchRequest(entityName: "More_Fields")
        value.predicate = NSPredicate(format: "field_id = %@ AND form_id = %@", self.fieldId, self.formId)
        
        do {
            let val = try self.Context.executeFetchRequest(value) as? [More_Fields]
            if val!.count > 0  {
                let f =  val![0]
                f.isFilled = check
            }
        }
        // }
    }
    
    @IBAction func clear(sender: UIButton) {
        // update form
        let fetchRequest = NSFetchRequest(entityName: "More_Fields_Values")
        fetchRequest.predicate = NSPredicate(format: "form_id = %@ AND field_id == %@", self.formId, self.fieldId)
        
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for each in found! {
                Context.deleteObject(each)
                try updateField(false)
            }
        } catch {
            print(error)
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("back", sender: self)
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
