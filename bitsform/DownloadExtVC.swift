//
//  DownloadExtVC.swift
//  Uform
//
//  Created by Waseel ASP Ltd. on 8/8/1437 AH.
//
//

import UIKit
import CoreData
import Alamofire

class DownloadExtVC: UIViewController {
    
    @IBOutlet weak var txtKey: UITextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func download(sender: UIButton) {
        //var localPath: NSURL?
        /*Alamofire.download(.GET,
        //"https://docs.google.com/uc?id=0B_NILOaL31gTRFJfWEw3TGJrTnM&export=download",
        "https://docs.google.com/uc?id=0B_NILOaL31gTNV9zQVI3VWVUaXc&export=download",
        destination: { (temporaryURL, response) in
        let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let pathComponent = response.suggestedFilename
        
        localPath = directoryURL.URLByAppendingPathComponent(pathComponent!)
        return localPath!
        })
        .response { (request, response, _, error) in
        print(response)
        print("Downloaded file to \(localPath!)")
        //reading
        do {
        let text2 = try NSData(contentsOfURL: localPath!)
        let theJSONText = NSString(data: text2!,
        encoding: NSASCIIStringEncoding)
        print("JSON string = \(theJSONText!)")
        }
        catch {/* error handling here */}
        }*/
        if indicator.isAnimating() {
            return
        }
        do {
            indicator.startAnimating()
            try validate()
            download()
        } catch {
            indicator.stopAnimating()
            let alert = UIAlertController(title: nil, message: "Please, provide a valid key!", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    func validate() throws {
        if txtKey.text!.isEmpty {
            throw InputError.InvalidKey
        }
        if txtKey.text!.componentsSeparatedByString(" ").count > 1 {
             throw InputError.InvalidKey
        }
    }
    
    func download() {
        let url = NSURL(string: "https://docs.google.com/uc?id=\(txtKey.text!)")
        Alamofire.request(.GET, url!).responseString(completionHandler: {response in
            if response.result.error == nil {
                do {
                    if let dataFromString = response.result.value!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                        let json = JSON(data: dataFromString)
                        let _ext = try _Extension(json: json)
                        try _ext.isValid()
                        try self.save(_ext)
                        self.performSegueWithIdentifier("back", sender: self)
                        //self.navigationController?.popViewControllerAnimated(true)
                        
                    }
                } catch {
                    self.indicator.stopAnimating()
                    let nsError = error as NSError
                    let alert = UIAlertController(title: nil, message: nsError.localizedDescription, preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    func save(downloaded: _Extension) throws {
        // sequence
        // template
        let fetchRequest = NSFetchRequest(entityName: "Sequence_Extension_Template")
        var id: Int!
        do {
            let result = try self.Context.executeFetchRequest(fetchRequest)
            if result.count != 0 {
                let seq = result[0] as! Sequence_Extension_Template
                id = Int(seq.id!)
                id = id + 1
                seq.id = id
            }
            
            let templateEntity = NSEntityDescription.entityForName("Extension_Template", inManagedObjectContext: self.Context)
            let template = Extension_Template(entity: templateEntity!, insertIntoManagedObjectContext: self.Context)
            
            template.id = "\(id!)"
            template.name = downloaded.name
            template.created_by = downloaded.sharedBy
            for each in downloaded.fields {
                let field_id = try addField(template.id, field_name: each.name, field_type: each.type)
                for values in each.values {
                    try addFieldValues(field_id, value: values.value)
                }
            }
            
            try Context.save()
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
    
    func addFieldValues(field_id: String, value: String) throws {
        // value 1
        let fieldValueEntity = NSEntityDescription.entityForName("Field_Values", inManagedObjectContext: self.Context)
        let fieldValue1 = Field_Values(entity: fieldValueEntity!, insertIntoManagedObjectContext: self.Context)
        fieldValue1.field_id = field_id
        fieldValue1.value = value
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    class _Extension {
        var name: String!
        var sharedBy: String!
        var fields = [_Field]()
        
        init(json: JSON) throws {
            self.name = json["name"].stringValue
            self.sharedBy = json["shared_by"].stringValue
            
            for each in json["fields"] {
                fields.append(_Field(json: each.1))
                
            }
            
        }
        
        func _print() {
            print(self.name)
            print(self.sharedBy)
            for each in fields {
                each._print()
            }
        }
        
        func isValid() throws {
            if self.name.isEmpty {
                let userInfo: [NSObject : AnyObject] =
                [
                    NSLocalizedDescriptionKey :  NSLocalizedString("Invalid", value: "Invalid response data received, check your sharing key is correct!", comment: ""),
                    NSLocalizedFailureReasonErrorKey : NSLocalizedString("Invalid", value: "Invalid response data received, check your sharing key is correct!", comment: "")
                ]
                throw NSError(domain: "Uform", code: -1, userInfo: userInfo)
            }
        }
        
        class _Field {
            var name: String!
            var type: String!
            var values = [_Value]()
            
            init(json: JSON) {
                self.name = json["name"].stringValue
                self.type = json["type"].stringValue
                
                for each in json["values"] {
                    values.append(_Value(json: each.1))
                }
            }
            
            func _print() {
                print(self.name)
                print(self.type)
                for each in values {
                    each._print()
                }
            }
            
        }
        
        class _Value {
            var value: String = ""
            init(json: JSON) {
                self.value = json["value"].stringValue
            }
            func _print() {
                print(self.value)
            }
        }
    }
    
    enum InputError: ErrorType {
        case InvalidKey
    }
    
}
