//
//  TextVC.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 8/2/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit

class TextVC: UIViewController {

    var fieldName: String!
    
    @IBOutlet weak var txt: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txt.text = fieldName
        // Do any additional setup after loading the view.
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

}
