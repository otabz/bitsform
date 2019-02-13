//
//  ExtensionsVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 8/1/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData

class ExtensionsVC: UIViewController {

    var extensions = [Extension]()
    var selection: Extension!
    var formId: String!
    var applyable = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblSelectionHeader: UILabel!
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    override func viewDidLoad() {
        if applyable {
            self.lblSelectionHeader.text = "    Select from following template(s)"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        extensions.removeAll()
        let fetchRequest = NSFetchRequest(entityName: "Extension_Template")
        
        do {
            let founds = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for each in founds! {
                let template = each as! Extension_Template
                self.extensions.append(Extension(id: template.id, name: template.name, createdBy: template.created_by, sharingKey: template.sharing_key))
            }
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    @IBAction func unwindToTemplates(segue: UIStoryboardSegue) {
        self.viewWillAppear(true)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.extensions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! ExtensionsCell
        let template = extensions[indexPath.row]
        if let _key = template.sharingKey {
            cell.hintImage.image = UIImage(named: "link_icon")
            cell.txtSubTitle.text = _key
            cell.txtTitle.text = template.name
        } else {
            cell.txtSubTitle.text = template.name
            cell.txtTitle.text = template.createdBy
        }
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        //if let ext = self.extensions[indexPath.row].id where ext == "0" {
        //    return false
        //}
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            // delete fields
            let fields = NSFetchRequest(entityName: "Extension_Template_Fields")
            fields.predicate = NSPredicate(format: "template_id = %@", self.extensions[indexPath.row].id)
            
            // delete template
            let template = NSFetchRequest(entityName: "Extension_Template")
            template.predicate = NSPredicate(format: "id = %@", self.extensions[indexPath.row].id)
            
            do {
                let field = try self.Context.executeFetchRequest(fields) as? [Extension_Template_Fields]
                for each in field! {
                    self.Context.deleteObject(each)
                }
                
                let ext = try self.Context.executeFetchRequest(template) as? [Extension_Template]
                if ext?.count > 0 {
                    self.Context.deleteObject(ext![0])
                    if ext![0].deleted {
                        self.removeFromExtensions(ext![0].id!)
                    }
                }
                try self.Context.save()
                (tableView.cellForRowAtIndexPath(indexPath) as! ExtensionsCell).hintImage.image = UIImage(named: "extensions_list_icon")
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            } catch {
                print(error)
            }
        }
        delete.backgroundColor = UIColor(red:1.00, green:0.30, blue:0.27, alpha:1.0)
        
        let upload = UITableViewRowAction(style: .Normal, title: "Upload") { action, index in
            self.selection = self.extensions[indexPath.row]
            self.performSegueWithIdentifier("extensionsToUpload", sender: self)
        }
        upload.backgroundColor = UIColor(red:0.00, green:0.60, blue:0.28, alpha:1.0)
        
        return [upload, delete]
    }
    
    
    func removeFromExtensions(id: String!) {
        var i = 0
        var found = false
        for each in extensions {
            if each.id == id {
                found = true
                break
            }
            i += 1
        }
        if found {
            extensions.removeAtIndex(i)
        }
    }

    /*
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
          
        }
    }
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selection = self.extensions[indexPath.row]
        self.performSegueWithIdentifier("extensionsToFields", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "extensionsToFields" {
            let vc : FieldsVC = segue.destinationViewController as! FieldsVC
            vc.extensionId = selection.id
            vc.extensionName = selection.name
            vc.formId = self.formId
            vc.applyable = self.applyable
        } else if segue.identifier == "extensionsToUpload" {
            let vc = segue.destinationViewController as! UploadExtVC
            vc.extensionId = selection.id
            vc.extensionName = selection.name
            vc.whichFile = "Template"
        }
    }


    class Extension {
        var id: String! = ""
        var name: String! = ""
        var createdBy: String! = ""
        var sharingKey: String?
        
        init(id: String!, name: String?, createdBy: String?, sharingKey: String?) {
            self.id = id
            if let n = name {
                self.name = n
            }
            if let at = createdBy {
                self.createdBy = at
            }
            self.sharingKey = sharingKey
        }
    }

}
