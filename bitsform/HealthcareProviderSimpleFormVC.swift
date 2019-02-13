//
//  HealthcareProviderSimpleForm.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 7/10/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class HealthcareProviderSimpleFormVC: UIViewController {
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var photos: UIView!
    @IBOutlet weak var location: UIView!
    @IBOutlet weak var contactInfo: UIView!
    @IBOutlet weak var timings: UIView!
    @IBOutlet weak var specialty: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var sectionPhotos: UIImageView!
    @IBOutlet weak var sectionLocation: UIImageView!
    @IBOutlet weak var sectionContact: UIImageView!
    @IBOutlet weak var sectionTime: UIImageView!
    @IBOutlet weak var sectionSpecialty: UIImageView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var updatedAtLbl: UILabel!
    @IBOutlet weak var sentCheck: UIImageView!
    @IBOutlet weak var sentAtLbl: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var lblMoreFields: UILabel!
    let borderColor = UIColor(red:0.08, green:0.35, blue:0.93, alpha:1.0).CGColor
    var draftedFormNumber: String!
    var pdfPath: String!
    
    /*lazy var Context: NSManagedObjectContext = {
       let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()*/
    var Context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        Context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        specialty.layer.borderColor = borderColor
        applyPlainShadow(header)
    }
    
    override func viewWillAppear(animated: Bool) {
        loadForm()
    }
    
    @IBAction func unwindToHealthcareSimpleForm(segue: UIStoryboardSegue) {
        self.viewWillAppear(true)
    }
    
    func applyPlainShadow(view: UIView) {
        let layer = view.layer
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
    }

    func loadForm() {
        // load form
        let fetchRequest = NSFetchRequest(entityName: "Form")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.draftedFormNumber)
        
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if found!.count != 0 {
                let form = found![0] as! Form
                self.name.text = form.name_en
                if let updatedAt = form.updated_at {
                    //Format date
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
                    dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
                    let dateString = dateFormatter.stringFromDate(updatedAt)
                    self.updatedAtLbl.text = dateString
                }
                toggleSent(Bool(form.sent!), date: form.sent_at)
                checkFilled(Bool(form.section_photos!), section: self.sectionPhotos)
                checkFilled(Bool(form.section_location!), section: self.sectionLocation)
                checkFilled(Bool(form.section_contact!), section: self.sectionContact)
                checkFilled(Bool(form.section_time!), section: self.sectionTime)
                checkFilledName()
                howManyMoreFields()
            }
        } catch {
            print(error)
        }
    }
    
    func checkFilled(filledSection: NSNumber, section: UIImageView) {
        if filledSection == true {
            section.image = UIImage(named: "filled_icon")
        } else {
            section.image = UIImage(named: "add_btn_small")
        }
    }
    
    func checkFilledName() {
        if let _ = self.name.text {
            self.name.alpha = 1
            //self.name.textColor = UIColor.whiteColor()
        } else {
            self.name.text = "Untitled"
            //self.name.textColor = UIColor.grayColor()
            self.name.alpha = 0.5
        }
    }
    
    func howManyMoreFields() {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entityForName("More_Fields", inManagedObjectContext: self.Context)
        
        // Where Clause
        let predicate = NSPredicate(format: "form_id == %@", self.draftedFormNumber)
        fetchRequest.predicate = predicate
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        //var count = 0
        do {
            let result = try self.Context.executeFetchRequest(fetchRequest) as! [More_Fields]
            /*for each in result {
               count = try countFields(each.template_id!) + count
            }*/
            lblMoreFields.text = String(result.count)
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    /*func countFields(extensionId: String) throws -> Int {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entityForName("Extension_Template_Fields", inManagedObjectContext: self.Context)
        
        // Where Clause
        let predicate = NSPredicate(format: "template_id == %@", extensionId)
        fetchRequest.predicate = predicate
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            let result = try self.Context.executeFetchRequest(fetchRequest)
            return result.count
        }
    }*/
    
    func toggleSent(sent: Bool, date: NSDate?) {
        if sent {
            self.sentCheck.hidden = false
            if let sentAt = date {
                //Format date
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
                dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
                let dateString = dateFormatter.stringFromDate(sentAt)
                self.sentAtLbl.text = dateString
            }

        } else {
            self.sentCheck.hidden = true
            self.sentAtLbl.text = ""
        }
    }
    @IBAction func addName(sender: UIButton) {
        self.performSegueWithIdentifier("healthcareSimpleToSectionName", sender: self)
    }

    @IBAction func addPhotos(sender: UIButton) {
        self.performSegueWithIdentifier("healthcareSimpleToSectionPhotos", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "healthcareSimpleToSectionName" {
            let vc:NameVC = segue.destinationViewController as! NameVC
            vc.draftedFormNumber = self.draftedFormNumber
            vc.Context = self.Context
        }
        
        if segue.identifier == "healthcareSimpleToSectionPhotos" {
            let vc:PhotosVC = segue.destinationViewController as! PhotosVC
            vc.draftedFormNumber = self.draftedFormNumber
            vc.Context = self.Context
        }
        
        if segue.identifier == "healthcareSimpleToSectionLocation" {
            let vc:LocationVC  = segue.destinationViewController as! LocationVC
            vc.draftedFormNumber = self.draftedFormNumber
            vc.Context = self.Context
        }
        
        if segue.identifier == "healthcareSimpleToSectionContact" {
            let vc:ContactInfoVC  = segue.destinationViewController as! ContactInfoVC
            vc.draftedFormNumber = self.draftedFormNumber
            vc.Context = self.Context
        }
        
        if segue.identifier == "healthcareSimpleToSectionTime" {
            let vc:OpeningHoursVC  = segue.destinationViewController as! OpeningHoursVC
            vc.draftedFormNumber = self.draftedFormNumber
            vc.Context = self.Context
        }
        
        if segue.identifier == "healthcareSimpleToSectionExtension" {
            let vc = segue.destinationViewController as! TemplateSelectionVCViewController
            vc.formId = self.draftedFormNumber
            vc.Context = self.Context
        }
        
        if segue.identifier == "healthcareSimpleToSectionMoreFields" {
            let vc = segue.destinationViewController as! MoreFieldsVC
            vc.formId = self.draftedFormNumber
        }
        
        if segue.identifier == "toPDF" {
            let vc = segue.destinationViewController as! PDFViewerVC
            vc.path = self.pdfPath
            vc.name = self.name.text
            vc.id = self.draftedFormNumber
        }
    }
    @IBAction func clear(sender: UIBarButtonItem) {
        let options = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
                    })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        options.addAction(deleteAction)
        options.addAction(cancelAction)
        self.presentViewController(options, animated: true, completion: nil)
    }
    @IBAction func send(sender: UIButton) {
        pdfPath = PDFGenerator().generate(self.draftedFormNumber)
        self.performSegueWithIdentifier("toPDF", sender: self)
    }
    
    func send() {
        // update form
        self.indicator.startAnimating()
        self.view.userInteractionEnabled = false
        
        let fetchRequest = NSFetchRequest(entityName: "Form")
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.draftedFormNumber)
        
        do {
            let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if found!.count != 0 {
                let form = found![0] as! Form
                if let serverId = form.server_id where serverId > 0 {
                    update(form, completionHandler: { (result, error) in
                        if result != nil {
                            self.toggleSent(self.done(form, serverId: form.server_id!), date: NSDate())
                        } else {
                            let alert = UIAlertController(title: error?.description, message: nil, preferredStyle: .Alert)
                            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            alert.addAction(action)
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        self.indicator.stopAnimating()
                        self.view.userInteractionEnabled = true
                    })
                } else {
                    submit(form, completionHandler: { (result, error) in
                        if result != nil {
                            self.toggleSent(self.done(form, serverId: result!.serverId), date: NSDate())
                        } else {
                            let alert = UIAlertController(title: error?.description, message: nil, preferredStyle: .Alert)
                            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            alert.addAction(action)
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        self.indicator.stopAnimating()
                        self.view.userInteractionEnabled = true
                    })
                }
            }
        } catch {
            print(error)
            self.indicator.stopAnimating()
            self.view.userInteractionEnabled = true
        }
    }
    
    func done(form: Form, serverId: NSNumber) -> Bool {
        do {
            form.server_id = serverId
            form.sent = true
            form.sent_at = NSDate()
            try self.Context.save()
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func submit(form: Form, completionHandler: (Result?, NSError?)-> Void) {
        //print(createParameters(form))
        let prefs = NSUserDefaults.standardUserDefaults()
        var url = "http://172.26.2.232:8080/healthmembers/api/"
        if let collectorName = prefs.stringForKey("collectorName"){
            url = url + collectorName + "/create"
        }
        Alamofire.request(.POST, url, parameters: createParameters(form), encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let data):
                    let json = JSON(data)
                    self.outcome(json, completionHandler: { (result, error) in
                        if error == nil {
                            let results = Result(json: json)
                            completionHandler(results, nil)
                        } else {
                            completionHandler(nil, error)
                        }
                    })
                    
                case .Failure(let error):
                    completionHandler(nil, error)
                }
        }
    }
    
    func update(form: Form, completionHandler: (Result?, NSError?)-> Void) {
        let prefs = NSUserDefaults.standardUserDefaults()
        var url = "http://172.26.2.232:8080/healthmembers/api/"
        if let collectorName = prefs.stringForKey("collectorName"){
            url = url + collectorName
        }
        url = url +  "/\(form.server_id!)" + "/update"
        Alamofire.request(.POST, url, parameters: createParameters(form), encoding: .JSON)
            .responseJSON { response in
                
                switch response.result {
                case .Success(let data):
                    let json = JSON(data)
                    self.outcome(json, completionHandler: { (result, error) in
                        if error == nil {
                            let results = Result(json: json)
                            completionHandler(results, nil)
                        } else {
                            completionHandler(nil, error)
                        }
                    })
                    
                case .Failure(let error):
                    completionHandler(nil, error)
                }
        }
    }
    
    func outcome(json: JSON, completionHandler: (AnyObject?, NSError?) -> Void) {
        if json["outcome"].stringValue.caseInsensitiveCompare("success") == NSComparisonResult.OrderedSame {
            completionHandler("success", nil)
        } else {
            completionHandler(nil, NSError(domain: "Bitsfrom", code: 404, userInfo: [
                NSLocalizedDescriptionKey: json["message"].stringValue]))
        }
    }
    
    func createParameters(form: Form)-> Dictionary<String, AnyObject> {
        var enName: String = ""
        var arName: String = ""
        var clientId: String = ""
        var formId: String = ""
        var updatedAt: String = ""
        var sentAt: String = ""
        var latitude: NSNumber = 0
        var longitude: NSNumber = 0
        var photo1: String = ""
        var photo2: String = ""
        var emergencyPhone: String = ""
        var receptionPhone: String = ""
        var url: String = ""
        
        if let enName_ = form.name_en {
            enName = enName_
        }
        
        if let arName_ = form.name_ar {
            arName = arName_
        }
        
        if let clientId_ = form.client_id {
            clientId = clientId_
        }
        
        if let formId_ = form.id {
            formId = formId_
        }
        
        if let updatedAt_ = form.updated_at {
            //Format date
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
            let dateString = dateFormatter.stringFromDate(updatedAt_)
            updatedAt = dateString
        }
            //Format date
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
            let dateString = dateFormatter.stringFromDate(NSDate())
            sentAt = dateString
        
        if let latitude_ = form.latitude {
            latitude = latitude_
        }
        
        if let longitude_ = form.longitude {
            longitude = longitude_
        }
        
        if let photo1_ = form.photo1 {
            photo1 = photo1_.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        }
        
        if let photo2_ = form.photo2 {
            photo2 = photo2_.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        }
        
        if let emergencyPhone_ = form.phone_emergency {
            emergencyPhone = emergencyPhone_
        }
        
        if let receptionPhone_ = form.phone_reception {
            receptionPhone = receptionPhone_
        }
        
        if let url_ = form.url {
            url = url_
        }

        let time = NSFetchRequest(entityName: "Section_Time")
        time.predicate = NSPredicate(format: "form_id = %@", self.draftedFormNumber)
        let hours = NSMutableArray()
        do {
            let tme = try self.Context.executeFetchRequest(time) as? [Section_Time]
            for each in tme! {
                let h = [
                    "day": each.day!,
                    "openAt": each.open_at!,
                    "closeAt": each.close_at!
                ]
                
            hours.addObject(h)
            }
        } catch {
            print(error)
        }
        
        let specialty = NSFetchRequest(entityName: "Section_Specialty")
        specialty.predicate = NSPredicate(format: "form_id = %@", self.draftedFormNumber)
        let specialties = NSMutableArray()
        do {
            let spe = try self.Context.executeFetchRequest(specialty) as? [Section_Specialty]
            for each in spe! {
                if Bool(each.available!) {
                let s = [
                    "code": each.code!,
                    "name": each.name!,
                ]
                
                specialties.addObject(s)
                }
            }
        } catch {
            print(error)
        }
        let parameters: [String: AnyObject] = [
            "enName": enName,
            "arName": arName,
            "clientId": clientId,
            "formId": formId,
            "updatedAt": updatedAt,
            "sentAt": sentAt,
            "latitude": latitude,
            "longitude": longitude,
            "photo1": photo1,
            "photo2": photo2,
            "emergencyPhone": emergencyPhone,
            "receptionPhone": receptionPhone,
            "url": url,
            "workingHours": hours,
            "specialties": specialties
        ]
        return parameters
    }
    @IBAction func addMoreFields2(sender: UIButton) {
         self.performSegueWithIdentifier("healthcareSimpleToSectionExtension", sender: self)
    }
    
    @IBAction func addMoreFields(sender: UIButton) {
       self.performSegueWithIdentifier("healthcareSimpleToSectionExtension", sender: self)
    }
    
    class Result {
        var serverId: NSNumber = -1
        required init(json: JSON) {
            self.serverId = json["message"].numberValue
        }
    }
    
  }