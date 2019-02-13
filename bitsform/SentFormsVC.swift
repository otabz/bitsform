//
//  SentFormsViewController.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 7/7/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//
import Foundation
import UIKit
import CoreData

class SentFormsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
//, NSFetchedResultsControllerDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    var selection: String!
    var sents: [Sent]!
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    /*
    lazy var fetchedResultsController: NSFetchedResultsController = {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Form")
        
        // Predicate
        fetchRequest.predicate = NSPredicate(format: "sent == %@", NSNumber(bool: true))
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "sent_at", ascending: false)
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
        self.sents = [Sent]()
        let fetchRequest = NSFetchRequest(entityName: "Form")
        fetchRequest.predicate = NSPredicate(format: "sent == %@", NSNumber(bool: true))
        let sortDescriptor = NSSortDescriptor(key: "sent_at", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let founds = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for each in founds! {
                let form = each as! Form
                self.sents.append(Sent(id: form.id, name: form.name_en, sentAt: form.sent_at))
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
        
        return self.sents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        /*
        // Fetch Form
        let form = fetchedResultsController.objectAtIndexPath(indexPath) as! Form
        
        // Update Cell
        if let name = form.name_en {
            cell!.textLabel?.text = name
        }
        
        if let sentAt = form.sent_at {
            //Format date
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
            let dateString = dateFormatter.stringFromDate(sentAt)
            cell!.detailTextLabel?.text = dateString
        }*/
        let form = sents[indexPath.row]
        cell!.textLabel?.text = form.name
        cell!.detailTextLabel?.text = form.sentAt
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        //let form = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Form
        selection = sents[indexPath.row].id
        self.performSegueWithIdentifier("sentToHealthcareSimple", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sentToHealthcareSimple" {
            let vc : HealthcareProviderSimpleFormVC = segue.destinationViewController as! HealthcareProviderSimpleFormVC
            vc.draftedFormNumber = selection
        }
    }
    
    /*
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let form = fetchedResultsController.objectAtIndexPath(indexPath) as! Form
        // Populate cell from the NSManagedObject instance
        cell.textLabel?.text = form.name_en
        if let sentAt = form.sent_at {
            //Format date
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
            let dateString = dateFormatter.stringFromDate(sentAt)
            cell.detailTextLabel?.text = dateString
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            //configureCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
            tableView.reloadData()
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    */
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // print(self.sents[indexPath.row].id)
            // delete specialty
            let specialty = NSFetchRequest(entityName: "Section_Specialty")
            specialty.predicate = NSPredicate(format: "form_id = %@", self.sents[indexPath.row].id)
            // delete time
            let time = NSFetchRequest(entityName: "Section_Time")
            time.predicate = NSPredicate(format: "form_id = %@", self.sents[indexPath.row].id)
            // delete form
            let form = NSFetchRequest(entityName: "Form")
            form.predicate = NSPredicate(format: "id = %@", self.sents[indexPath.row].id)
            
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
                        removeFromDrafts(frm![0].id!)
                    }
                }
                try self.Context.save()
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            } catch {
                print(error)
            }
        }
    }
    
    func removeFromDrafts(id: String!) {
        var i = 0
        var found = false
        for each in sents {
            if each.id == id {
                found = true
                break
            }
            i += 1
        }
        if found {
            sents.removeAtIndex(i)
        }
    }

    class Sent {
        var id: String!
        var name: String! = ""
        var sentAt: String! = ""
        
        init(id: String!, name: String?, sentAt: NSDate?) {
            self.id = id
            if let n = name {
                self.name = n
            }
            if let at = sentAt {
                //Format date
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
                dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
                let dateString = dateFormatter.stringFromDate(at)
                self.sentAt = dateString
            }
        }
    }
}
