//
//  ChoiceVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 8/3/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit

@objc protocol ValueListDelegate: class {
    func list(value: String!)
}

class ChoiceVC: UIViewController {
    
    @IBOutlet weak var violationSymbol: UIImageView!
    @IBOutlet weak var txtChoice: UITextView!
    @IBOutlet weak var violationText: UILabel!
    var delegate: ValueListDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        toggleViolation(false)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        txtChoice.becomeFirstResponder()
    }
    
    @IBAction func save(sender: UIButton) {
        if !isFiiled() {
            toggleViolation(true)
            return
        }
        let choices = self.txtChoice.text.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()).componentsSeparatedByString("\n")
        for each in choices {
            self.delegate?.list(each)
        }
        self.performSegueWithIdentifier("back", sender: self)
        // self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func close(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func isFiiled() -> Bool {
        self.txtChoice.text = self.txtChoice.text.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if self.txtChoice.text == "" {
            return false
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toggleViolation(raised: Bool) {
        if raised {
            self.violationSymbol.hidden = false
            self.violationText.text = "Please, fill the value."
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

}
