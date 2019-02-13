//
//  TextFieldVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 8/4/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData

class TextFieldVC: UIViewController {

    var extensionId: String!
    
    @IBOutlet weak var violationSymbol: UIImageView!
    @IBOutlet weak var violationText: UILabel!
    @IBOutlet weak var txt: UITextView!
    var unwindTo: String!
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        toggleViolation(false, message: "")

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        txt.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func save(sender: UIButton) {
        if isFilled() {
            do {
                try addField(extensionId, field_name: self.txt.text, field_type: "O")
                try Context.save()
                //self.dismissViewControllerAnimated(true, completion: nil)
            } catch {
                print(error)
            }
            self.performSegueWithIdentifier(unwindTo, sender: self)
        }

    }
    
    func addField(template_id: String!, field_name: String!, field_type: String!) throws -> String {
        // save fields
        // sequence
        let fetchRequest = NSFetchRequest(entityName: "Sequence_Field")
        var id: Int!
        do {
            let result = try self.Context.executeFetchRequest(fetchRequest)
            if result.count != 0 {
                let seq = result[0] as! Sequence_Field
                id = Int(seq.id!)
                id = id + 1
                seq.id = id
            }
        }
        
        // field
        let fieldEntity = NSEntityDescription.entityForName("Field", inManagedObjectContext: self.Context)
        let field = Field(entity: fieldEntity!, insertIntoManagedObjectContext: self.Context)
        field.id = "\(id!)"
        field.name = field_name
        field.type = field_type
        
        // extension-field
        let extensionFieldEntity = NSEntityDescription.entityForName("Extension_Template_Fields", inManagedObjectContext: self.Context)
        let extensionField = Extension_Template_Fields(entity: extensionFieldEntity!, insertIntoManagedObjectContext: self.Context)
        extensionField.template_id = template_id!
        extensionField.field_id = "\(id!)"
        return "\(id!)"
    }
    
    func isFilled() -> Bool {
        self.txt.text = self.txt.text.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if self.txt.text == "" {
            toggleViolation(true, message: "Please, fill field description.")
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

}
