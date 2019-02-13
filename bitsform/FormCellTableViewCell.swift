//
//  FormCellTableViewCell.swift
//  ExtendedForms
//
//  Created by Waseel ASP Ltd. on 8/16/1437 AH.
//
//

import UIKit

class FormCellTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var imgUploadedBy: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
