//
//  ViewController.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 7/7/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var key: UITextField!
    @IBOutlet weak var keySeparator: UIView!
    @IBOutlet weak var nameSeparator: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var unlock: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.name.delegate = self
        self.key.delegate = self
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unlock(sender: UIButton) {
        if !toggleViolation() {
            return
        }
        self.unlock.hidden = true
        self.indicator.startAnimating()
        let parameters = [
            "id": name.text!,
            "key":key.text!
        ]
        Alamofire.request(.POST, "http://172.26.2.232:8080/healthmembers/api/unlock", parameters: parameters, encoding: .JSON)
            .responseJSON { response in
                switch response.result {
                case .Success(let data):
                    let json = JSON(data)
                    self.outcome(json, completionHandler: { (result, error) in
                        if error == nil {
                            let prefs = NSUserDefaults.standardUserDefaults()
                            prefs.setValue(self.name.text!, forKey: "collectorName")
                            prefs.synchronize()
                            self.performSegueWithIdentifier("unlocked", sender: self)
                        } else {
                            self.indicator.stopAnimating()
                            self.unlock.hidden = false
                            let alert = UIAlertController(title: error?.description, message: nil, preferredStyle: .Alert)
                            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            alert.addAction(action)
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    })
                    
                case .Failure(let error):
                    let alert = UIAlertController(title: error.description, message: nil, preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
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
    
    func toggleViolation() -> Bool {
        nameSeparator.backgroundColor = UIColor.whiteColor()
        keySeparator.backgroundColor = UIColor.whiteColor()
        
        if name.text!.isEmpty {
            nameSeparator.backgroundColor = UIColor.orangeColor()
            return false
        }
        if key.text!.isEmpty {
            keySeparator.backgroundColor = UIColor.orangeColor()
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
    }
    
}
/*
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
*/