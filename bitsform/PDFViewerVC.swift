//
//  PDFViewerVC.swift
//  ExtendedForms
//
//  Created by Waseel ASP Ltd. on 8/11/1437 AH.
//
//

import UIKit
import MessageUI
import CoreData


class PDFViewerVC: UIViewController, MFMailComposeViewControllerDelegate {

    var path: String!
    var name: String?
    var id: String!
    @IBOutlet weak var webView: UIWebView!
    
    lazy var Context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let file = NSURLRequest(URL: NSURL(string: path)!);
        self.webView.loadRequest(file);
        // Do any additional setup after loading the view.
        if let name_ = name {
            let n = name_.characters.count <= 50 ? name_.characters.count : 50
            let end = name_.startIndex.advancedBy(n)
            name = name_.substringToIndex(end)
        } else {
            name = id
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clear(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func send() {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setMessageBody("<p>Thanks for trying Uform. Please, find the attached form.</p>", isHTML: true)
            mail.setSubject("Uform - \(self.name!)")
            let fileData = NSData(contentsOfFile: path)
            mail.addAttachmentData(fileData!, mimeType: "application/pdf", fileName: self.name!)
            presentViewController(mail, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Couldn't send email", message: "Please, check email configurations and try again!", preferredStyle: .Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func send(sender: UIButton) {
        let options = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let emailAction = UIAlertAction(title: "Email", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            // email form
            self.send()
        })
        
        let uploadAction = UIAlertAction(title: "Upload", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("upload", sender: self)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        options.addAction(emailAction)
        options.addAction(uploadAction)
        options.addAction(cancelAction)
        if let popoverController = options.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        self.presentViewController(options, animated: true, completion: nil)
    }

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result {
        case MFMailComposeResultSent:
            let fetchRequest = NSFetchRequest(entityName: "Form")
            fetchRequest.predicate = NSPredicate(format: "id = %@", self.id)
            
            do {
                let found = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
                if found!.count != 0 {
                    let form = found![0] as! Form
                    form.sent = true
                    form.sent_at = NSDate()
                    form.uploaded_by = "Email"
                    try Context.save()
                }
            } catch {
                print(error)
            }
            break
        default:
            break
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "upload" {
            let vc = segue.destinationViewController as! UploadExtVC
            vc.extensionName = self.name
            vc.extensionId = self.id
            vc.whichFile = "PDF"
            vc.path = self.path
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
