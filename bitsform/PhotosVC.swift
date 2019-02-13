//
//  PhotosVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 7/12/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData

class PhotosVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var violationSymbol: UIImageView!
    @IBOutlet weak var violationText: UILabel!
    @IBOutlet weak var photo1: UIImageView!
    @IBOutlet weak var photo2: UIImageView!
    var isPhoto1: Bool = true
    var draftedFormNumber: String!
    var Context: NSManagedObjectContext!
    
    /*lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()*/
    
    override func viewDidLoad() {
        toggleViolation(false)
        loadData()
    }
    
    @IBAction func close(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func capture1(sender: UIButton) {
        self.isPhoto1 = true
        selectSource(sender)
    }
    
    @IBAction func capture2(sender: UIButton) {
        self.isPhoto1 = false
        selectSource(sender)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if self.isPhoto1 {
            self.photo1.image = info [UIImagePickerControllerOriginalImage] as? UIImage
        } else {
           self.photo2.image = info [UIImagePickerControllerOriginalImage] as? UIImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func selectSource(sender: UIButton) {
        let options = UIAlertController(title: "", message: "Select Picture", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let photos = UIAlertAction(title: "Photo Library", style: .Default) {
            (ACTION) in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .PhotoLibrary
            
            self.presentViewController(picker, animated: true, completion: nil)
        }
        let camera = UIAlertAction(title: "Take a Picture", style: .Default) {
            (ACTION) in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .Camera
            
            self.presentViewController(picker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        options.addAction(cancel)
        options.addAction(photos)
        options.addAction(camera)
        if let popoverController = options.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        self.presentViewController(options, animated: true, completion: nil)
        
    }
    func loadData() {
        // load form
        let fetchRequest = NSFetchRequest(entityName: "Form")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.draftedFormNumber)
        
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if found!.count != 0 {
                let form = found![0] as! Form
                // photo1
                if form.photo1 != nil {
                    setImage(self.photo1, data: form.photo1!)
                }
                // photo 2
                if form.photo2 != nil {
                    setImage(self.photo2, data: form.photo2!)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func setImage(view: UIImageView, data: NSData) {
        guard let imageData = UIImage(data: data) else {
            // handle failed conversion
            //print("jpg error")
            return
        }
        view.image = imageData
    }

    func isFilled() -> Bool {
        if self.photo1.image == nil && self.photo2.image == nil {
            return false
        }
        return true
    }
    
    func toggleViolation(raised: Bool) {
        if raised {
            self.violationSymbol.hidden = false
            self.violationText.text = "Please, fill the form."
        } else {
            self.violationSymbol.hidden = true
            self.violationText.text = ""
        }
    }
    
    @IBAction func save(sender: UIButton) {
        if !isFilled() {
            toggleViolation(true)
            return
        }
        
        // update form
        let fetchRequest = NSFetchRequest(entityName: "Form")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.draftedFormNumber)
        
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if found!.count != 0 {
                let form = found![0] as! Form
                form.updated_at = NSDate()
                form.section_photos = true
                // photo1
                if self.photo1.image != nil {
                    guard let imageData = photo1.image?.lowQualityJPEGNSData else {
                        // handle failed conversion
                        //print("jpg error")
                        return
                    }
                    form.photo1 = imageData
                    form.sent = false
                }
                // photo 2
                if self.photo2.image != nil {
                    guard let imageData = photo2.image?.lowQualityJPEGNSData else {
                        // handle failed conversion
                        //print("jpg error")
                        return
                    }
                    form.photo2 = imageData
                    form.sent = false
                }
                try Context.save()
            }
        } catch {
            print(error)
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("back", sender: self)
    }
    
    @IBAction func clear(sender: UIButton) {
        // update form
        let fetchRequest = NSFetchRequest(entityName: "Form")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.draftedFormNumber)
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if found!.count != 0 {
                let form = found![0] as! Form
                form.updated_at = NSDate()
                form.sent = false
                form.photo1 = nil
                form.photo2 = nil
                form.section_photos = false
                try Context.save()
            }
        } catch{
            print(error)
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("back", sender: self)
    }
}
