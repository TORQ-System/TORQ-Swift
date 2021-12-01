//
//  emergencyNumberTableViewCell.swift
//  TORQ
//
//  Created by a w on 01/12/2021.
//

import UIKit

class emergencyNumberTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var emergencyNumView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
