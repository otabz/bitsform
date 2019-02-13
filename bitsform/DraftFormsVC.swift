//
//  DraftFormsVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 7/12/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData

class DraftFormsVC: UIViewController {
//,NSFetchedResultsControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    var selection: Draft!
    var drafts = [Draft]()
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    /*
    lazy var fetchedResultsController: NSFetchedResultsController = {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Form")
        
        // Predicate
        fetchRequest.predicate = NSPredicate(format: "sent == %@", NSNumber(bool: false))
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "updated_at", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.Context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    */
    override func viewDidLoad() {
        /*do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }*/
    }
    
    override func viewWillAppear(animated: Bool) {
        drafts.removeAll()
        let fetchRequest = NSFetchRequest(entityName: "Form")
        //fetchRequest.predicate = NSPredicate(format: "sent == %@", NSNumber(bool: false))
        let sortDescriptor = NSSortDescriptor(key: "updated_at", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let founds = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for each in founds! {
                let form = each as! Form
                self.drafts.append(Draft(id: form.id, name: form.name_en, updatedAt: form.updated_at, sentAt: form.sent_at, sentBy: form.uploaded_by))
            }
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }*/
        
        return self.drafts.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! FormCellTableViewCell
        let form = drafts[indexPath.row]
        cell.lblTitle.text = form.name
        cell.lblSubtitle.text = form.updatedAt
        if !form.sentAt.isEmpty {
            cell.lblSubtitle.text = form.sentAt
            if form.sentBy == "Google Drive" {
                cell.imgUploadedBy.image = UIImage(named: "uploaded_by_drive")
            } else if form.sentBy == "Email" {
                cell.imgUploadedBy.image = UIImage(named: "uploaded_by_email")
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        //let form = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Form
        selection = drafts[indexPath.row]
        self.performSegueWithIdentifier("draftsToHealthcareSimple", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "draftsToHealthcareSimple" {
            let vc : HealthcareProviderSimpleFormVC = segue.destinationViewController as! HealthcareProviderSimpleFormVC
            vc.draftedFormNumber = selection.id
        }
        else if segue.identifier == "toPDF" {
            let vc = segue.destinationViewController as! PDFViewerVC
            vc.path = PDFGenerator().generate(self.selection.id)
            if !selection.name.isEmpty {
                vc.name = selection.name
            }
            vc.id = self.selection.id
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    /*
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let form = fetchedResultsController.objectAtIndexPath(indexPath) as! Form
        if Bool(form.sent!) {
            return
        }
        // Populate cell from the NSManagedObject instance
        cell.textLabel?.text = form.name_en
        if let updatedAt = form.updated_at {
            //Format date
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
            let dateString = dateFormatter.stringFromDate(updatedAt)
            cell.detailTextLabel?.text = dateString
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            let form = anObject as! Form
            print("in insert "+form.id!)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            let form = anObject as! Form
            print("in delete "+form.id!)
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            let form = anObject as! Form
            print("in update "+form.id!)
            configureCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
        case .Move:
            let form = anObject as! Form
            print("in move "+form.id!)
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    */
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            //print("more button tapped")
            // delete specialty
            let specialty = NSFetchRequest(entityName: "Section_Specialty")
            specialty.predicate = NSPredicate(format: "form_id = %@", self.drafts[indexPath.row].id)
            // delete time
            let time = NSFetchRequest(entityName: "Section_Time")
            time.predicate = NSPredicate(format: "form_id = %@", self.drafts[indexPath.row].id)
            // delete form
            let form = NSFetchRequest(entityName: "Form")
            form.predicate = NSPredicate(format: "id = %@", self.drafts[indexPath.row].id)
            
            do {
                let spe = try self.Context.executeFetchRequest(specialty) as? [Section_Specialty]
                for each in spe! {
                    self.Context.deleteObject(each)
                    if each.deleted {
                        //print("deleted specialty . . ." + String(each.code!))
                    }
                }
                let tme = try self.Context.executeFetchRequest(time) as? [Section_Time]
                for each in tme! {
                    self.Context.deleteObject(each)
                    if each.deleted {
                        //print("deleted time . . ." + each.day!)
                    }
                }
                let frm = try self.Context.executeFetchRequest(form) as? [Form]
                if frm?.count > 0 {
                    self.Context.deleteObject(frm![0])
                    if frm![0].deleted {
                        //print("deleted form . . ." + frm![0].id!)
                        self.removeFromDrafts(frm![0].id!)
                    }
                }
                try self.Context.save()
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            } catch {
                print(error)
            }
        }
        delete.backgroundColor = UIColor(red:1.00, green:0.30, blue:0.27, alpha:1.0)
        
        let upload = UITableViewRowAction(style: .Normal, title: "Send") { action, index in
            //self.selection = self.extensions[indexPath.row]
            self.selection = self.drafts[indexPath.row]
            self.performSegueWithIdentifier("toPDF", sender: self)
        }
        upload.backgroundColor = UIColor(red:0.00, green:0.60, blue:0.28, alpha:1.0)
        
        return [upload, delete]
    }

    /*
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // print(self.drafts[indexPath.row].id)
        }
    }
    */
    
    func removeFromDrafts(id: String!) {
        var i = 0
        var found = false
        for each in drafts {
            if each.id == id {
                found = true
                break
            }
            i += 1
        }
        if found {
            drafts.removeAtIndex(i)
        }
    }
    
    class Draft {
        var id: String!
        var name: String! = ""
        var updatedAt: String! = ""
        var sentAt: String! = ""
        var sentBy: String! = ""
        
        init(id: String!, name: String?, updatedAt: NSDate?, sentAt: NSDate?, sentBy: String!) {
            self.id = id
            if let n = name {
                self.name = n
            }
            if let at = updatedAt {
                //Format date
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
                dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
                let dateString = dateFormatter.stringFromDate(at)
                self.updatedAt = dateString
            }
            if let sentAt_ = sentAt {
                //Format date
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
                dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
                let dateString = dateFormatter.stringFromDate(sentAt_)
                self.sentAt = dateString
                self.sentBy = sentBy
            }
        }
    }
}
