//
//  profileTableViewCell.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 04/11/2021.
//

import UIKit

class profileTableViewCell: UITableViewCell {
    
    
    //MARK:- @IBOutlts
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
        
        // Set the width of the cell
        self.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.size.width - 40, height: self.bounds.size.height)
        super.layoutSubviews()
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }

}
