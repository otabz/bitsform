//
//  ChoiceFieldVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 8/3/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData


class ChoiceFieldVC: UIViewController, ValueListDelegate {

    @IBOutlet weak var violationSymbol: UIImageView!
    @IBOutlet weak var violationText: UILabel!
    @IBOutlet weak var txtFieldName: UITextView!
    @IBOutlet weak var tableView: UITableView!
    var unwindTo: String!
    var extensionId: String!
    var values = [String]()
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        toggleViolation(false, message: "")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToChoicesField(segue: UIStoryboardSegue) {
        self.viewWillAppear(true)
    }
    
    @IBAction func add(sender: UIButton) {
        self.performSegueWithIdentifier("value", sender: self)
    }
    
    @IBAction func save(sender: UIButton) {
        if isFilled() {
            do {
                    let field_id: String = try addField(extensionId, field_name: self.txtFieldName.text, field_type: "M")
                for each in values {
                    try addFieldValues(field_id, value: each)
                }
                try Context.save()
                //self.dismissViewControllerAnimated(true, completion: nil)
            } catch {
                print(error)
            }
            self.performSegueWithIdentifier(unwindTo, sender: self)
        }
    }
    
    func addField(template_id: String!, field_name: String!, field_type: String!) throws -> String {
        // save fields
        // sequence
        let fetchRequest = NSFetchRequest(entityName: "Sequence_Field")
        var id: Int!
        do {
            let result = try self.Context.executeFetchRequest(fetchRequest)
            if result.count != 0 {
                let seq = result[0] as! Sequence_Field
                id = Int(seq.id!)
                id = id + 1
                seq.id = id
            }
        }
        
        // field
        let fieldEntity = NSEntityDescription.entityForName("Field", inManagedObjectContext: self.Context)
        let field = Field(entity: fieldEntity!, insertIntoManagedObjectContext: self.Context)
        field.id = "\(id!)"
        field.name = field_name
        field.type = field_type
        
        // extension-field
        let extensionFieldEntity = NSEntityDescription.entityForName("Extension_Template_Fields", inManagedObjectContext: self.Context)
        let extensionField = Extension_Template_Fields(entity: extensionFieldEntity!, insertIntoManagedObjectContext: self.Context)
        extensionField.template_id = template_id!
        extensionField.field_id = "\(id!)"
        return "\(id!)"
    }
    
    func addFieldValues(field_id: String, value: String) throws {
        // value 1
        let fieldValueEntity = NSEntityDescription.entityForName("Field_Values", inManagedObjectContext: self.Context)
        let fieldValue1 = Field_Values(entity: fieldValueEntity!, insertIntoManagedObjectContext: self.Context)
        fieldValue1.field_id = field_id
        fieldValue1.value = value
    }

    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.values.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell?.textLabel!.text = values[indexPath.row]
        return cell!
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
                values.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func removeFromValues(value: String!) {
        var i = 0
        var found = false
        for each in values {
            if each == value {
                found = true
                break
            }
            i += 1
        }
        if found {
            values.removeAtIndex(i)
        }
    }

    
    func isFilled() -> Bool {
        
        if txtFieldName.text!.isEmpty {
            toggleViolation(true, message: "Please, fill field description.")
            return false
        }
        
        if values.count == 0 {
            toggleViolation(true, message: "Please, add choices.")
            return false
        }
        return true
    }
    
    func toggleViolation(raised: Bool, message: String!) {
        if raised {
            self.violationSymbol.hidden = false
            self.violationText.text = message
        } else {
            self.violationSymbol.hidden = true
            self.violationText.text = message
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "value" {
            let vc = segue.destinationViewController as! ChoiceVC
            vc.delegate = self
        }
    }

    @IBAction func close(sender: UIButton) {
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
    
    /* Delegate */
    func list(value: String!) {
        for each in values {
            if each == value {
                return
            }
        }
        values.append(value)
    }

}
