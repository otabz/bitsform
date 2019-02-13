//
//  ExtensionVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 8/5/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData

class ExtensionVC: UIViewController {
    
    @IBOutlet weak var violationText: UILabel!
    @IBOutlet weak var violationSymbol: UIImageView!
    @IBOutlet weak var txtExtensionName: UITextField!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var extensionId: String! = "-1"
    var selection: FieldNode!
    var fields = [FieldNode]()

    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    override func viewDidLoad() {
        toggleViolation(false, message: "")
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
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
        if fields.count > 0{
            btnClose.setImage(nil, forState: .Normal)
            btnClose.setTitle("Disacrd", forState: .Normal)
        }
    }
    
    @IBAction func unwindToNewTemplate(segue: UIStoryboardSegue) {
        self.viewWillAppear(true)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(sender: UIButton) {
        if isFilled() {
            do {
                let templateEntity = NSEntityDescription.entityForName("Extension_Template", inManagedObjectContext: self.Context)
                let template = Extension_Template(entity: templateEntity!, insertIntoManagedObjectContext: self.Context)
                
                template.id = self.extensionId
                template.name = self.txtExtensionName.text
                template.created_by = "Uform"
                try Context.save()
            } catch {
                print(error)
            }
            //self.dismissViewControllerAnimated(true, completion: nil)
            self.performSegueWithIdentifier("back", sender: self)
        }
    }
    
    @IBAction func close(sender: UIButton) {
        if self.extensionId != "-1" {
            let value = NSFetchRequest(entityName: "Extension_Template_Fields")
            value.predicate = NSPredicate(format: "template_id = %@", self.extensionId)
            
            do {
                let val = try self.Context.executeFetchRequest(value) as? [Extension_Template_Fields]
                for each in val! {
                    self.Context.deleteObject(each)
                }
                try self.Context.save()
            } catch  {
                print(error)
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func create(sender: UIButton) {
        let options = UIAlertController(title: "Select the type of field, you want to create.", message: nil, preferredStyle: .ActionSheet)
        let option1 = UIAlertAction(title: "Create Text Field", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            if self.extensionId == "-1" {
                self.createExtension()
            }
            self.performSegueWithIdentifier("textField", sender: self)
        })
        let option2 = UIAlertAction(title: "Create Choices Field", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            if self.extensionId == "-1" {
                self.createExtension()
            }
            self.performSegueWithIdentifier("choiceField", sender: self)
        })
        let option3 = UIAlertAction(title: "Add Existing Field", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            if self.extensionId == "-1" {
                self.createExtension()
            }
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
    
    func createExtension() {
        // sequence
        let fetchRequest = NSFetchRequest(entityName: "Sequence_Extension_Template")
        var id: Int!
        do {
            let result = try self.Context.executeFetchRequest(fetchRequest)
            if result.count != 0 {
                let seq = result[0] as! Sequence_Extension_Template
                id = Int(seq.id!)
                id = id + 1
                seq.id = id
            }
            try Context.save()
            self.extensionId = "\(id!)"
        } catch {
            print(error)
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
            vc.unwindTo = "backToNewTemplate"
        } else if segue.identifier == "textField" {
            let vc = segue.destinationViewController as! TextFieldVC
            vc.extensionId = self.extensionId
            vc.unwindTo = "backToNewTemplate"
        } else if segue.identifier == "existingField" {
            let vc = segue.destinationViewController as! ExistingFieldVC
            vc.extensionId = self.extensionId
            vc.unwindTo = "backToNewTemplate"
        }
    }
    
    func isFilled() -> Bool {
        
        if txtExtensionName.text!.isEmpty {
            toggleViolation(true, message: "Please, fill extension name.")
            return false
        }
        
        if fields.count == 0 {
            toggleViolation(true, message: "Please, add fields.")
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
        var name: String!
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
