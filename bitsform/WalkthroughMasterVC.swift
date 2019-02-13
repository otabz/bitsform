//
//  WalkthroughMasterVC.swift
//  ExtendedForms
//
//  Created by Waseel ASP Ltd. on 8/15/1437 AH.
//
//

import UIKit

class WalkthroughMasterVC: UIViewController, BWWalkthroughViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }
    
    override func viewDidAppear(animated: Bool) {
        // Get view controllers and build the walkthrough
        let stb = UIStoryboard(name: "Main", bundle: nil)
        let walkthrough = stb.instantiateViewControllerWithIdentifier("Master") as! BWWalkthroughViewController
        let page_zero = stb.instantiateViewControllerWithIdentifier("child0") as UIViewController
        let page_one = stb.instantiateViewControllerWithIdentifier("child1") as UIViewController
        let page_two = stb.instantiateViewControllerWithIdentifier("child2") as UIViewController
        
        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.addViewController(page_zero)
        walkthrough.addViewController(page_one)
        walkthrough.addViewController(page_two)
        
        self.presentViewController(walkthrough, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
