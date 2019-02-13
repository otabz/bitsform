//
//  TemplateSelectionVCViewController.swift
//  ExtendedForms
//
//  Created by Waseel ASP Ltd. on 8/18/1437 AH.
//
//

import UIKit
import CoreData

class TemplateSelectionVCViewController: UIViewController {

    var extensions = [Extension]()
    var selection: Extension!
    var formId: String!
    var Context: NSManagedObjectContext!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        extensions.removeAll()
        let fetchRequest = NSFetchRequest(entityName: "Extension_Template")
        
        do {
            let founds = try Context.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            for each in founds! {
                let template = each as! Extension_Template
                self.extensions.append(Extension(id: template.id, name: template.name, createdBy: template.created_by, sharingKey: template.sharing_key))
            }
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.extensions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! ExtensionsCell
        let template = extensions[indexPath.row]
            cell.txtSubTitle.text = template.name
            cell.txtTitle.text = template.createdBy
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selection = self.extensions[indexPath.row]
        self.performSegueWithIdentifier("extensionsToFields", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "extensionsToFields" {
            let vc = segue.destinationViewController as! FieldsVC
            vc.applyable = true
            vc.formId = self.formId
            vc.extensionId = selection.id
            vc.extensionName = selection.name
        }
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
    
    class Extension {
        var id: String! = ""
        var name: String! = ""
        var createdBy: String! = ""
        var sharingKey: String?
        
        init(id: String!, name: String?, createdBy: String?, sharingKey: String?) {
            self.id = id
            if let n = name {
                self.name = n
            }
            if let at = createdBy {
                self.createdBy = at
            }
            self.sharingKey = sharingKey
        }
    }

}
