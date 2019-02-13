//
//  FieldsVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 8/2/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData

class FieldsVC: UIViewController {

    var fields = [FieldNode]()
    var applyable = false
    var extensionId = ""
    var extensionName = ""
    var formId: String!
    var selection: FieldNode!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnApply: UIButton!
    @IBOutlet weak var footer: UIView!
    @IBOutlet weak var btnApplyReal: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var lblTemplateName: UILabel!
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.extensionName
        lblTemplateName.text = self.extensionName
        if !applyable {
            self.lblDesc.text = "Template includes the following field(s)."
            self.btnApplyReal.hidden = true
            self.btnAdd.enabled = true
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func apply(sender: UIButton) {
        for each in fields {
            addField(each.id!)
        }
    }
    
    @IBAction func unwindToTemplateFields(segue: UIStoryboardSegue) {
        self.viewWillAppear(true)
    }
    
    @IBAction func close(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func aapply(sender: UIButton) {
        for each in fields {
            addField(each.id!)
        }
        self.performSegueWithIdentifier("back", sender: self)
    }
    func addField(field_id: String!) {
        // update form
        let fetchRequest = NSFetchRequest(entityName: "More_Fields")
        fetchRequest.predicate = NSPredicate(format: "form_id = %@ AND field_id = %@", self.formId, field_id)
        
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if found!.count == 0 {
                // add field
                let fieldEntity = NSEntityDescription.entityForName("More_Fields", inManagedObjectContext: self.Context)
                let field = More_Fields(entity: fieldEntity!, insertIntoManagedObjectContext: self.Context)
                
                field.form_id = self.formId
                field.field_id = field_id
                try Context.save()
            }
        } catch {
            print(error)
        }
    }

    override func viewWillAppear(animated: Bool) {
        fields.removeAll()
        let fetchRequest = NSFetchRequest(entityName: "Extension_Template_Fields")
        fetchRequest.predicate = NSPredicate(format: "template_id == %@", extensionId)
        
        do {
            let founds = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for each in founds! {
                let field = each as! Extension_Template_Fields
                try loadField(field.field_id)
            }
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    func loadField(id: String!) throws {
        let fetchRequest = NSFetchRequest(entityName: "Field")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if found!.count != 0 {
                let field = found![0] as! Field
                self.fields.append(FieldNode(id: field.id, name: field.name, type: field.type, editable: true))
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fields.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        let field = fields[indexPath.row]
        cell!.textLabel?.text = field.name
        if field.type == "O" {
            cell!.imageView?.image = UIImage(named: "fields_text_icon")
            cell!.detailTextLabel?.text = "Text"
        } else if field.type == "M"{
            cell!.imageView?.image = UIImage(named: "fields_choices_icon")
            cell!.detailTextLabel?.text = "Choice"
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        if applyable {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selection = self.fields[indexPath.row]
        if self.selection.type == "M" {
            self.performSegueWithIdentifier("choices", sender: self)
        } else if self.selection.type == "O" {
            self.performSegueWithIdentifier("text", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let options = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                // delete form
                let value = NSFetchRequest(entityName: "Extension_Template_Fields")
                value.predicate = NSPredicate(format: "field_id = %@ AND template_id = %@", self.fields[indexPath.row].id, self.extensionId)
                
                do {
                    let val = try self.Context.executeFetchRequest(value) as? [Extension_Template_Fields]
                    if val?.count > 0 {
                        self.Context.deleteObject(val![0])
                        if val![0].deleted {
                            self.fields.removeAtIndex(indexPath.row)
                            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                        }
                    }
                    try self.Context.save()
                } catch  {
                    print(error)
                }
                
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            
            options.addAction(deleteAction)
            options.addAction(cancelAction)
            
            self.presentViewController(options, animated: true, completion: nil)
        }
        
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "choices" {
            let vc = segue.destinationViewController as! ChoicesVC
            vc.fieldId = selection.id
            vc.fieldName = selection.name
        } else if segue.identifier == "text" {
            let vc = segue.destinationViewController as! TextVC
            vc.fieldName = selection.name
        } else if segue.identifier == "choiceField" {
            let vc = segue.destinationViewController as! ChoiceFieldVC
            vc.extensionId = self.extensionId
            vc.unwindTo = "backToExistingTemplate"
        } else if segue.identifier == "textField" {
            let vc = segue.destinationViewController as! TextFieldVC
            vc.extensionId = self.extensionId
            vc.unwindTo = "backToExistingTemplate"
        } else if segue.identifier == "existingField" {
            let vc = segue.destinationViewController as! ExistingFieldVC
            vc.extensionId = self.extensionId
            vc.unwindTo = "backToExistingTemplate"
        }
    }

    @IBAction func create(sender: UIBarButtonItem) {
        let options = UIAlertController(title: "Select the type of field, you want to create.", message: nil, preferredStyle: .ActionSheet)
        let option1 = UIAlertAction(title: "Create Text Field", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
             self.performSegueWithIdentifier("textField", sender: self)
        })
        let option2 = UIAlertAction(title: "Create Choices Field", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("choiceField", sender: self)
        })
        let option3 = UIAlertAction(title: "Add Existing Field", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("existingField", sender: self)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        options.addAction(option1)
        options.addAction(option2)
        options.addAction(option3)
        options.addAction(cancelAction)
        
        if let popoverController = options.popoverPresentationController {
            popoverController.barButtonItem = sender
        }

        self.presentViewController(options, animated: true, completion: nil)
    }

    @IBAction func addNewField(sender: UIButton) {
        let options = UIAlertController(title: "Select the type of field, you want to create.", message: nil, preferredStyle: .ActionSheet)
        let option1 = UIAlertAction(title: "Create Text Field", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("textField", sender: self)
        })
        let option2 = UIAlertAction(title: "Create Choices Field", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("choiceField", sender: self)
        })
        let option3 = UIAlertAction(title: "Add Existing Field", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("existingField", sender: self)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        options.addAction(option1)
        options.addAction(option2)
        options.addAction(option3)
        options.addAction(cancelAction)
        
        if let popoverController = options.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        self.presentViewController(options, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    class FieldNode {
        var id: String!
        var name: String! = ""
        var type: String!
        var editable: Bool = true
        
        init(id: String!, name: String?, type: String!, editable: Bool?) {
            self.id = id
            self.type = type
            if let name_ = name {
                self.name = name_
            }
            if let editable_ = editable {
                self.editable = editable_
            }
        }
    }

}
