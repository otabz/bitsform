//
//  CopyableUILable.swift
//  UForms
//
//  Created by Waseel ASP Ltd. on 8/9/1437 AH.
//
//

import UIKit

import UIKit

class CopyableUILabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        sharedInit()
    }
    
    func sharedInit() {
        userInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(CopyableUILabel.showMenu(_:))))
    }
    
    func showMenu(sender: AnyObject?) {
        becomeFirstResponder()
        let menu = UIMenuController.sharedMenuController()
        if !menu.menuVisible {
            menu.setTargetRect(bounds, inView: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    
    override func copy(sender: AnyObject?) {
        let board = UIPasteboard.generalPasteboard()
        board.string = text
        let menu = UIMenuController.sharedMenuController()
        menu.setMenuVisible(false, animated: true)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(NSObject.copy(_:)) {
            return true
        }
        return false
    }
    
    
}
