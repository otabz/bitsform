//
//  MoreFieldsVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 8/2/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData

class MoreFieldsVC: UIViewController {

    var fields = [FieldNode]()
    var formId: String!
    var selection: FieldNode!
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        fields.removeAll()
        let fetchRequest = NSFetchRequest(entityName: "More_Fields")
        fetchRequest.predicate = NSPredicate(format: "form_id == %@", self.formId)
        
        do {
            let founds = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for each in founds! {
                let field = each as! More_Fields
                try loadField(field.field_id, isFilled: Bool(field.isFilled!))
            }
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    @IBAction func close(sender: UIButton) {
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("back", sender: self)
    }
    
    @IBAction func unwindToMoreFields(segue: UIStoryboardSegue) {
        self.viewWillAppear(true)
    }
    
    func loadField(id: String!, isFilled: Bool) throws {
        let fetchRequest = NSFetchRequest(entityName: "Field")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let founds = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for each in founds! {
                let field = each as! Field
                self.fields.append(FieldNode(id: field.id, name: field.name, type: field.type, editable: true, isFilled: isFilled))
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fields.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! MoreFieldsCell
        let field = fields[indexPath.row]
        //cell!.textLabel?.text = field.name
        cell.lblTitle.text = field.name
        
        if field.type == "O" {
            //cell!.imageView?.image = UIImage(named: "fields_text_icon")
            //cell!.detailTextLabel?.text = "Text"
            cell.imgFieldType.image = UIImage(named: "fields_text_icon")
            cell.lblSubtitle.text = "Text"
        } else if field.type == "M"{
            //cell!.imageView?.image = UIImage(named: "fields_choices_icon")
            //cell!.detailTextLabel?.text = "Choice"
            cell.imgFieldType.image = UIImage(named: "fields_choices_icon")
            cell.lblSubtitle.text = "Choice"
        }
        
        if field.isFilled {
            cell.imgFilled.image = UIImage(named: "filled_icon")
        } else {
            cell.imgFilled.image = UIImage(named: "add_btn_small")
        }
        return cell
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
            let options = UIAlertController(title: "Caution!", message: "Couldn't restore this data again.", preferredStyle: .ActionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                // delete form
                let value = NSFetchRequest(entityName: "More_Fields")
                let id = self.fields[indexPath.row].id
                value.predicate = NSPredicate(format: "field_id = %@ AND form_id = %@", id, self.formId)
                
                do {
                    let val = try self.Context.executeFetchRequest(value) as? [More_Fields]
                    if val?.count > 0 {
                        self.Context.deleteObject(val![0])
                        if val![0].deleted {
                            try self.removeFieldValues(id)
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
            if let popoverController = options.popoverPresentationController {
                popoverController.sourceView = tableView.cellForRowAtIndexPath(indexPath)
                popoverController.sourceRect = tableView.cellForRowAtIndexPath(indexPath)!.bounds
            }
            
            options.addAction(deleteAction)
            options.addAction(cancelAction)
            self.presentViewController(options, animated: true, completion: nil)
        }
    }
    
    func removeFieldValues(field_id: String) throws {
        let value = NSFetchRequest(entityName: "More_Fields_Values")
        value.predicate = NSPredicate(format: "field_id = %@ AND form_id = %@", field_id, self.formId)
        
        do {
            let val = try self.Context.executeFetchRequest(value) as? [More_Fields_Values]
            
            for each in val! {
                self.Context.deleteObject(each)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "choices" {
            let vc = segue.destinationViewController as! MoreFieldsChoicesVC
            vc.fieldId = selection.id
            //vc.extensionId = selection.templateId
            vc.formId = self.formId
            vc.fieldName = selection.name
        } else if segue.identifier == "text" {
            let vc = segue.destinationViewController as! MoreFieldsTextVC
            vc.fieldId = selection.id
            vc.fieldName = selection.name
            vc.formId = self.formId
            //vc.extensionId = selection.templateId
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        var isFilled: Bool = false
        
        init(id: String!, name: String?, type: String!, editable: Bool?, isFilled: Bool!) {
            self.id = id
            self.type = type
            self.isFilled = isFilled
            if let name_ = name {
                self.name = name_
            }
            if let editable_ = editable {
                self.editable = editable_
            }
        }
    }

}
