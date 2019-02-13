//
//  MoreFieldsChoicesVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 8/3/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData

class MoreFieldsChoicesVC: UIViewController {

    var formId: String!
    var fieldId: String!
    var fieldName: String!
    var values = [Value]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblFieldName: UILabel!
    @IBOutlet weak var violationSymbol: UIImageView!
    @IBOutlet weak var violationtext: UILabel!
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.editing = true
        self.lblFieldName.text = self.fieldName
        toggleViolation(false, message: "")
        loadExtensionValues()
        union(loadFilledValues())
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadExtensionValues() {
        // load time
        let fetchRequest = NSFetchRequest(entityName: "Field_Values")
        fetchRequest.predicate = NSPredicate(format: "field_id == %@", self.fieldId)
        
        do {
            let founds = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for each in founds! {
                let val = each as! Field_Values
                self.values.append(Value(formId: self.formId, fieldId: val.field_id!, value: val.value!, isSelected: false))
            }
        } catch {
            print(error)
        }
    }
    
    func loadFilledValues() -> [Value] {
        // load time
        var filledValues = [Value]()
        let fetchRequest = NSFetchRequest(entityName: "More_Fields_Values")
        fetchRequest.predicate = NSPredicate(format: "field_id == %@ AND form_id == %@", self.fieldId, self.formId)
        
        do {
            let founds = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for each in founds! {
                let val = each as! More_Fields_Values
                filledValues.append(Value(formId: self.formId, fieldId: val.field_id!, value: val.value!, isSelected: true))
            }
        } catch {
            print(error)
        }
        return filledValues
    }
    
    func union(var filledValues: [Value]) {
        for e in self.values {
            var index = -1
            for f in filledValues {
                index += 1
                if e.value == f.value {
                    e.isSelected = true
                    break
                }
            }
            if (e.isSelected!) {
                filledValues.removeAtIndex(index)
            }
        }
        if filledValues.count > 0 {
            self.values.appendContentsOf(filledValues)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.values.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = values[indexPath.row].value
        if values[indexPath.row].isSelected! {
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.init(rawValue: 3)!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        values[indexPath.row].isSelected = true
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        values[indexPath.row].isSelected = false
    }

    @IBAction func save(sender: UIButton) {
        if !isFilled() {
            toggleViolation(true, message: "Please, fill the form.")
            return
        }
        // update form
        let fetchRequest = NSFetchRequest(entityName: "More_Fields_Values")
        fetchRequest.predicate = NSPredicate(format: "form_id = %@ AND field_id == %@", self.formId, self.fieldId)
        var check = false
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for each in found! {
                Context.deleteObject(each)
                //checked = false
            }
            for selected in values {
                if selected.isSelected! {
                    let entity = NSEntityDescription.entityForName("More_Fields_Values", inManagedObjectContext: self.Context)
                    // Initialize
                    let value = More_Fields_Values(entity: entity!, insertIntoManagedObjectContext: self.Context)
                    value.form_id = selected.formId
                    value.field_id = selected.fieldId
                    value.value = selected.value
                    check = true
                    /*if selected.isAvailable! {
                        checked = true
                    }*/
                }
            }
            try updateField(check)
            try Context.save()
            try updateForm()
        } catch {
            print(error)
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("back", sender: self)
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
    
    @IBAction func close(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func isFilled() -> Bool {
        /*for each in values {
            if each.isSelected! {
                return true
            }
        }*/
        return true
    }
    
    func toggleViolation(raised: Bool, message: String) {
        if raised {
            self.violationSymbol.hidden = false
            self.violationtext.text = message
        } else {
            self.violationSymbol.hidden = true
            self.violationtext.text = ""
        }
    }

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    class Value {
        var formId: String!
        var fieldId: String!
        var value: String!
        var isSelected: Bool!
        
        init(formId: String, fieldId: String, value: String, isSelected: Bool) {
            self.formId = formId
            self.fieldId = fieldId
            self.value = value
            self.isSelected = isSelected
        }
    }

}
