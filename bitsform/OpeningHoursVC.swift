//
//  OpeningHoursVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 7/12/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData

class OpeningHoursVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var days: [Day] = [Day(name: "SUN"), Day(name: "MON"), Day(name: "TUE"), Day(name: "WED"), Day(name: "THU"), Day(name: "FRI"), Day(name: "SAT")]
    var selection: Int!
    var draftedFormNumber: String!
    @IBOutlet weak var tableView: UITableView!
    
    /*lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()*/
    
    var Context: NSManagedObjectContext! 
    
    @IBAction func close(sender: UIButton) {
        var filled = false
        for each in days {
            if !each.openAt.isEmpty && !each.closeAt.isEmpty {
                filled = true
                break
            }
        }
        // update form
        let fetchRequest = NSFetchRequest(entityName: "Form")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.draftedFormNumber)
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if found!.count != 0 {
                let form = found![0] as! Form
                form.section_time = filled
                try Context.save()
            }
        } catch {
            print(error)
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("back", sender: self)
    }
    
    @IBAction func unwindToHours(segue: UIStoryboardSegue) {
        self.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        //self.Context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
    
    func loadData(){
        // clear
        days[0].setTime("", closeAt: "")
        days[1].setTime("", closeAt: "")
        days[2].setTime("", closeAt: "")
        days[3].setTime("", closeAt: "")
        days[4].setTime("", closeAt: "")
        days[5].setTime("", closeAt: "")
        days[6].setTime("", closeAt: "")
        // load time
        let fetchRequest = NSFetchRequest(entityName: "Section_Time")
        fetchRequest.predicate = NSPredicate(format: "form_id = %@", self.draftedFormNumber)
        
        do {
            let founds = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for each in founds! {
                let time = each as! Section_Time
                if time.day == "SUN" {
                    days[0].setTime(time.open_at!, closeAt: time.close_at!)
                } else if time.day == "MON" {
                    days[1].setTime(time.open_at!, closeAt: time.close_at!)
                }  else if time.day == "TUE" {
                    days[2].setTime(time.open_at!, closeAt: time.close_at!)
                }  else if time.day == "WED" {
                    days[3].setTime(time.open_at!, closeAt: time.close_at!)
                }  else if time.day == "THU" {
                    days[4].setTime(time.open_at!, closeAt: time.close_at!)
                }  else if time.day == "FRI" {
                    days[5].setTime(time.open_at!, closeAt: time.close_at!)
                }  else if time.day == "SAT" {
                    days[6].setTime(time.open_at!, closeAt: time.close_at!)
                }
                
            }
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        loadData()
        tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! DayCellTableViewCell
        let day = days[indexPath.row]
        cell.name.text = day.name
        if !day.openAt.isEmpty && !day.closeAt.isEmpty {
            cell.name.textColor = UIColor.blueColor()
        } else {
            cell.name.textColor = UIColor.lightGrayColor()
        }
        cell.openAt.text = day.openAt
        cell.closeAt.text = day.closeAt
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selection = indexPath.row
        performSegueWithIdentifier("add", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "add" {
            let vc: TimePickerVC = segue.destinationViewController as! TimePickerVC
            vc.openAt = days[selection].openAt
            vc.closeAt = days[selection].closeAt
            vc.dayName = days[selection].name
            vc.draftedFormNumber = self.draftedFormNumber
            vc.Context = self.Context
        }
    }
    
    @IBAction func clear(sender: UIButton) {
        // update form
        let fetchRequest = NSFetchRequest(entityName: "Section_Time")
        fetchRequest.predicate = NSPredicate(format: "form_id = %@", self.draftedFormNumber)
        
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for each in found! {
                Context.deleteObject(each)
            }
            try updateForm(false, cleared: true)
        } catch {
            print(error)
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("back", sender: self)
    }
    
    
    func updateForm(checked: Bool, cleared: Bool) throws {
        // update form
        let fetchRequest = NSFetchRequest(entityName: "Form")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.draftedFormNumber)
        
        let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        if found!.count != 0 {
            let form = found![0] as! Form
            form.updated_at = NSDate()
            if cleared {
                form.sent = false
            }
            form.section_time = checked
            try Context.save()
        }
    }
    
    //- MARK
    class Day {
        var name: String!
        var openAt: String! = ""
        var closeAt: String! = ""
        
        init(name: String!) {
            self.name = name
        }
        
        func setTime(openAt: String, closeAt: String) {
            self.openAt = openAt
            self.closeAt = closeAt
        }
    }
    
}
