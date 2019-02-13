//
//  UploadExtVC.swift
//  ExtendedForms
//
//  Created by Waseel ASP Ltd. on 8/9/1437 AH.
//
//

import UIKit
import GoogleAPIClient
import GTMOAuth2
import CoreData

class UploadExtVC: UIViewController {

    var extensionId: String!
    var extensionName: String!
    
    @IBOutlet weak var lblExtensionName: UILabel!
    @IBOutlet weak var lblSharedBy: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var imgFileType: UIImageView!
    var whichFile = "Template"
    var path: String!
    
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    private let kKeychainItemName = "Drive API"
    private let kClientID = "104876447951-njd2s63r9h36va8q31q4ohvkqkt5o0rs.apps.googleusercontent.com"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLAuthScopeDrive, kGTLAuthScopeDriveFile, kGTLAuthScopeDriveAppdata]
    
    private let service = GTLServiceDrive()
    let output = UITextView()
    
    // When the view loads, create necessary subviews
    // and initialize the Drive API service
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        output.frame = view.bounds
        output.editable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        
        view.addSubview(output);
        */
        lblExtensionName.text = self.extensionName
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
        let dateString = dateFormatter.stringFromDate(NSDate())
        lblSharedBy.text = dateString
        
        if whichFile == "Template" {
            self.imgFileType.image = UIImage(named: "extension_download")
        } else {
            self.imgFileType.image = UIImage(named: "pdf_upload")
        }
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
                service.authorizer = auth
            }
        
    }
    @IBAction func upload(sender: UIButton) {
        if self.indicator.isAnimating() {
            return
        }
        self.indicator.startAnimating()
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
                //fetchFiles()
            if whichFile == "Template" {
                uploadTemplate()
            } else {
                uploadPDF()
            }
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    @IBAction func cancel(sender: UIButton) {
        if self.indicator.isAnimating() {
            return
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func uploadPDF() {
        
        let mimeType = "application/pdf"
        let file = NSURL(fileURLWithPath: self.path)
        let uploadParameters = GTLUploadParameters(fileURL: file, MIMEType: mimeType)
        
        let metadata: GTLDriveFile = GTLDriveFile()
        metadata.name = self.extensionName
        
        let query = GTLQueryDrive.queryForFilesCreateWithObject(metadata, uploadParameters: uploadParameters)
        
        service.executeQuery(query, completionHandler: {ticket, updatedFile, error in
            if error == nil {
                do {
                    try self.updateForm()
                    self.dismissViewControllerAnimated(true, completion: nil)
                } catch {
                    self.displayError(error as NSError)
                }
            } else {
                self.displayError(error)
            }
        })
    }
    
    func uploadTemplate() {
        do {
            try process({result, error in
                if error == nil {
                    do {
                        try self.updateExtension(result)
                        //self.dismissViewControllerAnimated(true, completion: nil)
                        self.performSegueWithIdentifier("backToTemplates", sender: self)
                    } catch {
                        self.displayError(error as NSError)
                    }
                } else {
                    self.displayError(error!)
                }
            })
        } catch {
            displayError(error as NSError)
        }
    }
    
    func process(completionBlock: (String?, NSError?) -> Void) throws {
        let extensionTemplate = NSFetchRequest(entityName: "Extension_Template")
        extensionTemplate.predicate = NSPredicate(format: "id = %@", self.extensionId)
        
        let extensionFields = NSFetchRequest(entityName: "Extension_Template_Fields")
        extensionFields.predicate = NSPredicate(format: "template_id = %@", self.extensionId)
        let fields = NSMutableArray()
        var name = ""
        var sharedBy = ""
        do {
            let ext = try self.Context.executeFetchRequest(extensionTemplate) as? [Extension_Template]
            name = ext![0].name!
            sharedBy = service.authorizer.userEmail
            
            let field = try self.Context.executeFetchRequest(extensionFields) as? [Extension_Template_Fields]
            for each in field! {
                let fieldEntity = NSFetchRequest(entityName: "Field")
                fieldEntity.predicate = NSPredicate(format: "id = %@", each.field_id!)
                
                let found = try self.Context.executeFetchRequest(fieldEntity) as? [Field]
                if found!.count != 0 {
                    let f : [String: AnyObject] = [
                        "name": "\(found![0].name!)",
                        "type": "\(found![0].type!)",
                        "values": try loadValues(each.field_id!)
                    ]
                    fields.addObject(f)
                }
            }
            
            let parameters: [String: AnyObject] = [
                "name": name,
                "shared_by": sharedBy,
                "fields": fields
            ]
            
            let content = try createFile("uploaded_extension", content: parameters)
            update(content, type: "text/plain", completionBlock: {result, error in
                completionBlock(result, error)
            })
        }
    }
    
    func updateExtension(sharingKey: String!) throws {
        let extensionTemplate = NSFetchRequest(entityName: "Extension_Template")
        extensionTemplate.predicate = NSPredicate(format: "id = %@", self.extensionId)
        

            let ext = try self.Context.executeFetchRequest(extensionTemplate) as? [Extension_Template]
            ext![0].sharing_key = sharingKey
            try self.Context.save()

    }
    
    func updateForm() throws {
        let form = NSFetchRequest(entityName: "Form")
        form.predicate = NSPredicate(format: "id = %@", self.extensionId)
        
        
        let frm = try self.Context.executeFetchRequest(form) as? [Form]
        frm![0].sent = true
        frm![0].sent_at = NSDate()
        frm![0].uploaded_by = "Google Drive"
        try self.Context.save()
    }
    
    func createFile(extensionId: String, content: [String: AnyObject]) throws -> NSString {
        
        //let file = extensionId + ".txt" //this is the file. we will write to and read from it
        
        var text: NSString!//just a text
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(content, options: NSJSONWritingOptions(rawValue: 0))
            // here "jsonData" is the dictionary encoded in JSON data
            //print(jsonData)
            
            text = NSString(data: jsonData,
                encoding: NSASCIIStringEncoding)!
            //print("JSON string = \(text)")
            
        }
        
        /*if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(file)
            
            //writing
            do {
                try text.writeToURL(path, atomically: true, encoding: NSUTF8StringEncoding)
            }
            catch {/* error handling here */}
            
        }*/
        return text
    }
    
    func loadValues(id: String) throws -> NSMutableArray {
        let values = NSMutableArray()
        let valueEntity = NSFetchRequest(entityName: "Field_Values")
        valueEntity.predicate = NSPredicate(format: "field_id = %@", id)
        do {
            let found = try self.Context.executeFetchRequest(valueEntity) as? [Field_Values]
            var count = 0
            for each in found! {
                let v = [
                    "value": each.value!
                ]
                values.addObject(v)
                count += 1
            }
        }
        return values
    }


    // Construct a query to get names and IDs of 10 files using the Google Drive API
    func fetchFiles() {
        output.text = "Getting files..."
        let query = GTLQueryDrive.queryForFilesList()
        query.pageSize = 10
        query.fields = "nextPageToken, files(id, name, webViewLink)"
        service.executeQuery(
            query,
            delegate: self,
            didFinishSelector: #selector(UploadExtVC.displayResultWithTicket(_:finishedWithObject:error:))
        )
    }
    
    func update(content: NSString, type: String, completionBlock: (String?, NSError?) -> Void) {
        let name =  self.extensionName
        let mimeType = type
        
        let metadata: GTLDriveFile = GTLDriveFile()
        metadata.name = name
        
        let data: NSData = content.dataUsingEncoding(NSUTF8StringEncoding)!
        let uploadParameters = GTLUploadParameters(data: data, MIMEType: mimeType)
        
        let query = GTLQueryDrive.queryForFilesCreateWithObject(metadata, uploadParameters: uploadParameters)
        
        service.executeQuery(query, completionHandler: {ticket, updatedFile, error in
            if error == nil {
                //print(updatedFile.identifier)
                let newPermission = GTLDrivePermission()
                // The value @"user", @"group", @"domain" or @"default".
                newPermission.type = "anyone";
                // The value @"owner", @"writer" or @"reader".
                newPermission.role = "reader";
                newPermission.setProperty(true, forKey: "withLink")
                
                let q = GTLQueryDrive.queryForPermissionsCreateWithObject(newPermission, fileId: updatedFile.identifier)
                
                self.service.executeQuery(q, completionHandler: {ticket, permission, error in
                    if error == nil {
                        completionBlock(updatedFile.identifier, nil)
                    } else {
                        completionBlock(nil, error)
                    }
                })
            } else {
                completionBlock(nil, error)
            }
        })
    }
    
    // Parse results and display
    func displayResultWithTicket(ticket : GTLServiceTicket,
        finishedWithObject response : GTLDriveFileList,
        error : NSError?) {
            
            if let error = error {
                showAlert("Error", message: error.localizedDescription)
                return
            }
            
            var filesString = ""
            if let files = response.files where !files.isEmpty {
                filesString += "Files:\n"
                for file in files as! [GTLDriveFile] {
                    filesString += "\(file.name) (\(file.identifier)) (\(file.webViewLink))\n"
                }
            } else {
                filesString = "No files found."
            }
            
            output.text = filesString
    }
    
    // Parse results and download
    func downloadResultWithTicket(ticket : GTLServiceTicket,
        finishedWithObject response : GTLDriveFileList,
        error : NSError?) {
            
            if let error = error {
                showAlert("Error", message: error.localizedDescription)
                return
            }
    }
    
    
    
    // Creates the auth controller for authorizing access to Drive API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: #selector(UploadExtVC.viewController(_:finishedWithAuth:error:))
        )
    }
    
    // Handle completion of the authorization process, and update the Drive API
    // with the new credentials.
    func viewController(vc : UIViewController,
        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
            
            if let error = error {
                service.authorizer = nil
                showAlert("Authentication Error", message: error.localizedDescription)
                return
            }
            service.authorizer = authResult
            dismissViewControllerAnimated(true, completion: nil)
            //let prefs = NSUserDefaults.standardUserDefaults()
            //prefs.setValue(service.authorizer.userEmail, forKey: "google_drive_user")
            //prefs.synchronize()
        if self.whichFile == "Template" {
            uploadTemplate()
        } else {
            uploadPDF()
        }
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        
        let alert = UIAlertView(
            title: title,
            message: message,
            delegate: self,
            cancelButtonTitle: "OK"
        )
        
        alert.show()
    }
    
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        switch buttonIndex{
        default:
            self.indicator.stopAnimating()
            self.dismissViewControllerAnimated(true, completion: nil)
            break;
            //Some code here..
            
        }
    }
    
    func displayError(error: NSError) {
        let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
