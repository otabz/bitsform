//
//  ChoicesVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 8/2/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData

class ChoicesVC: UIViewController {

    var fieldId: String!
    var templateId: String!
    var fieldName: String!
    var values = [Value]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblFieldName: UILabel!
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblFieldName.text = self.fieldName
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        values.removeAll()
        let fetchRequest = NSFetchRequest(entityName: "Field_Values")
        fetchRequest.predicate = NSPredicate(format: "field_id == %@", self.fieldId)
        
        do {
            let founds = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for each in founds! {
                let value = each as! Field_Values
                self.values.append(Value(fieldId: value.field_id, value: value.value))
            }
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.values.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        let value = values[indexPath.row]
        cell!.textLabel?.text = value.value
        return cell!
    }
    /*
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let options = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                // delete form
                let value = NSFetchRequest(entityName: "Extension_Template_Fields_Values")
                value.predicate = NSPredicate(format: "field_id = %@ AND template_id = %@ AND value = %@", self.values[indexPath.row].fieldId, self.values[indexPath.row].templateId, self.values[indexPath.row].value)
                
                do {
                    let val = try self.Context.executeFetchRequest(value) as? [Extension_Template_Fields_Values]
                    if val?.count > 0 {
                        self.Context.deleteObject(val![0])
                        if val![0].deleted {
                            self.removeFromValues(val![0].value!)
                        }
                    }
                    try self.Context.save()
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
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
    
    func removeFromValues(value: String!) {
        var i = 0
        var found = false
        for each in values {
            if each.fieldId == fieldId && each.templateId ==  templateId && each.value == value {
                found = true
                break
            }
            i++
        }
        if found {
            values.removeAtIndex(i)
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "value" {
            let vc: FieldValueVC = segue.destinationViewController as! FieldValueVC
            vc.fieldId = self.fieldId
            vc.templateId = self.templateId
            vc.fieldName = self.fieldName
        }
    }
    */
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
    @IBAction func close(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    class Value {
        var fieldId: String!
        var value: String = ""
        
        init(fieldId: String!, value: String?) {
            self.fieldId = fieldId
            if let value_ = value {
                self.value = value_
            }
        }
    }

}
