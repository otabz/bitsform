//
//  ExistingFieldVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 8/5/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData

class ExistingFieldVC: UIViewController {

    @IBOutlet weak var violationText: UILabel!
    @IBOutlet weak var violationSymbol: UIImageView!
    var fields = [FieldNode]()
    var extensionId: String!
    @IBOutlet weak var tableView: UITableView!
    var unwindTo: String!
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleViolation(false, message: "")
        tableView.editing = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        fields.removeAll()
        let fetchRequest = NSFetchRequest(entityName: "Field")
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [Field]
            for field in found! {
                self.fields.append(FieldNode(id: field.id, name: field.name, type: field.type, editable: true, isSelected: false))
            }
            try intersect()
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    func intersect() throws {
        let fetchRequest = NSFetchRequest(entityName: "Extension_Template_Fields")
        fetchRequest.predicate = NSPredicate(format: "template_id == %@", extensionId)
        
        do {
            let founds = try Context.executeFetchRequest(fetchRequest) as? [Extension_Template_Fields]
            for each in founds! {
                for index in 0 ..< fields.count {
                    if each.field_id! == fields[index].id {
                        fields.removeAtIndex(index)
                    }
                }
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
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.init(rawValue: 3)!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        fields[indexPath.row].isSelected = true
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        fields[indexPath.row].isSelected = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(sender: UIButton) {
        if !isFilled() {
            toggleViolation(true, message: "Please, select fields.")
            return
        }
        
        do {
            for selected in fields {
                if selected.isSelected {
                    let entity = NSEntityDescription.entityForName("Extension_Template_Fields", inManagedObjectContext: self.Context)
                    // Initialize
                    let field = Extension_Template_Fields(entity: entity!, insertIntoManagedObjectContext: self.Context)
                    field.template_id = self.extensionId
                    field.field_id = selected.id
                }
            }
            try Context.save()
        } catch {
            print(error)
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier(unwindTo, sender: self)
    }

    @IBAction func close(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func isFilled() -> Bool {
        for each in fields {
            if each.isSelected {
                return true
            }
        }
        return false
    }
    
    func toggleViolation(raised: Bool, message: String) {
        if raised {
            self.violationSymbol.hidden = false
            self.violationText.text = message
        } else {
            self.violationSymbol.hidden = true
            self.violationText.text = ""
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
        var name: String! = ""
        var type: String!
        var editable: Bool = true
        var isSelected: Bool = false
        
        init(id: String!, name: String?, type: String!, editable: Bool?, isSelected: Bool?) {
            self.id = id
            self.type = type
            if let name_ = name {
                self.name = name_
            }
            if let editable_ = editable {
                self.editable = editable_
            }
            if let selected_ = isSelected {
                self.isSelected = selected_
            }
        }
    }

}
