//
//  DashboardViewController.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 7/7/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData
import GTMOAuth2

class DashboardVC: UIViewController {
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var divider2: UIView!
    @IBOutlet weak var drafts: UILabel!
    @IBOutlet weak var sent: UILabel!
    @IBOutlet weak var btnLogOff: UIBarButtonItem!
    var needWalkthrough:Bool = true
    private let kKeychainItemName = "Drive API"
    private let kClientID = "104876447951-njd2s63r9h36va8q31q4ohvkqkt5o0rs.apps.googleusercontent.com"
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    var Timestamp: String {
        return "\(NSDate().timeIntervalSince1970 * 1000)"
    }
    
    var SequenceID: String {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Sequence")
        
        var id: Int = 0
        do {
            let result = try self.Context.executeFetchRequest(fetchRequest)
            if result.count > 0 {
                let seq = result[0] as! Sequence
                id = seq.id as! Int
                id = id + 1
                seq.id = id
            } else {
                // save a new form
                let entity = NSEntityDescription.entityForName("Sequence", inManagedObjectContext: self.Context)
                // Initialize Form
                let seq = Sequence(entity: entity!, insertIntoManagedObjectContext: self.Context)
                seq.id = id
            }
            try self.Context.save()
            return String(id)
        } catch {
            print(error as NSError)
        }
        return "-1"
    }
    
    override func viewDidLoad() {
        // shadows
        applyPlainShadow(divider)
        applyPlainShadow(divider2)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        }
    
    override func viewWillAppear(animated: Bool) {
        let prefs = NSUserDefaults.standardUserDefaults()
        if let collectorName = prefs.stringForKey("collectorName"){
            self.title = collectorName
        }
        // google drive
        self.btnLogOff.image = nil
        if let service = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            if let email = service.userEmail {
                self.btnLogOff.image = UIImage(named: "logout_btn")
                self.title = email
            }
        }
        // counts
        let drafts = howManyDrafts()
        _ = howManySent()
        //self.drafts.text = "Total ( \(drafts) )       Sent ( \(sent) )"
        self.drafts.text = "\(drafts)"
        howManyExtensions()
    }
    
    override func viewDidAppear(animated: Bool) {
        let prefs = NSUserDefaults.standardUserDefaults()
        if prefs.objectForKey("walkthrough") == nil {
            prefs.setValue("done", forKey: "walkthrough")
            prefs.synchronize()
            self.performSegueWithIdentifier("help", sender: self)
        }
    }

    func applyPlainShadow(view: UIView) {
        let layer = view.layer
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 1
    }
    
    func howManyDrafts() -> Int {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entityForName("Form", inManagedObjectContext: self.Context)
        
        // Where Clause
        //let predicate = NSPredicate(format: "sent == %@", NSNumber(bool: false))
        //fetchRequest.predicate = predicate
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try self.Context.executeFetchRequest(fetchRequest)
            return result.count
            
        } catch {
            return -1
        }
    }
    
    func howManySent() -> Int {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entityForName("Form", inManagedObjectContext: self.Context)
        
        // Where Clause
        let predicate = NSPredicate(format: "sent == %@", NSNumber(bool: true))
        fetchRequest.predicate = predicate
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try self.Context.executeFetchRequest(fetchRequest)
            return result.count
            
        } catch {
            return -1
        }
    }
    
    func howManyExtensions() {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entityForName("Extension_Template", inManagedObjectContext: self.Context)
        
        // Where Clause
        //let predicate = NSPredicate(format: "sent == %@", NSNumber(bool: true))
        //fetchRequest.predicate = predicate
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try self.Context.executeFetchRequest(fetchRequest)
            self.sent.text = "\(result.count)"
            
        } catch {
            print(error as NSError)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "dashboardToHealthcareSimple" {
            // save a new form
            let entity = NSEntityDescription.entityForName("Form", inManagedObjectContext: self.Context)
            // Initialize Form
            let form = Form(entity: entity!, insertIntoManagedObjectContext: self.Context)
            form.id = self.SequenceID
            form.updated_at = NSDate()
            // Save Form
            do {
                try self.Context.save()
                let vc : HealthcareProviderSimpleFormVC = segue.destinationViewController as! HealthcareProviderSimpleFormVC
                vc.draftedFormNumber = form.id
            } catch {
                print(error)
            }
            
        }
    }
    @IBAction func lock(sender: UIBarButtonItem) {
        //let prefs = NSUserDefaults.standardUserDefaults()
        if btnLogOff.image != nil {
            let alert = UIAlertController(title: self.title, message: "Are you sure, you no longer want to use Google Drive?", preferredStyle: .ActionSheet)
            let signOut = UIAlertAction(title: "Yes, Signout", style: .Destructive, handler: { action in
                GTMOAuth2ViewControllerTouch.removeAuthFromKeychainForName("Drive API")
                //prefs.removeObjectForKey("google_drive_user")
                //prefs.synchronize()
                self.btnLogOff.image = nil
                self.title = ""
            })
            
            let cancel = UIAlertAction(title: "No, Leave", style: .Default, handler: { action in
            })
            alert.addAction(signOut)
            alert.addAction(cancel)
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.barButtonItem = sender
            }
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        /*
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.removeObjectForKey("collectorName")
        prefs.synchronize()
        
        let lockedVC = self.storyboard!.instantiateViewControllerWithIdentifier("lockedView") as! ViewController
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate?.window?.rootViewController = lockedVC
        appDelegate?.window?.makeKeyAndVisible()
        */
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard as (UIViewController) -> () -> ()))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension UIImage
{
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)! }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)!}
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)! }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)!}
    var lowestQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.0)! }
}
