//
//  profileTableViewCell.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 04/11/2021.
//

import UIKit

class profileTableViewCell: UITableViewCell {
    
    
    //MARK:- @IBOutlts
    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var seriviceButton: UIButton!
    
    
    //MARK:- Overriden Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        cellContainer.layer.cornerRadius = 20
        cellContainer.layer.masksToBounds = true
    }

}
