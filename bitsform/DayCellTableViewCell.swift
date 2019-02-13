//
//  DayCellTableViewCell.swift
//  bitsform
//
//  Created by Waseel ASP Ltd. on 7/17/1437 AH.
//  Copyright © 1437 Waseel ASP Ltd. All rights reserved.
//

import UIKit

class DayCellTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var openAt: UILabel!
    @IBOutlet weak var closeAt: UILabel!
    var index: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
