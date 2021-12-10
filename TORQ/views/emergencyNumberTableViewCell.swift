//
//  emergencyNumberTableViewCell.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 10/12/2021.
//

import UIKit

class emergencyNumberTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var emergencyNumView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        emergencyNumView.layer.cornerRadius = 20
        let shadowPath = UIBezierPath(roundedRect: emergencyNumView.bounds, cornerRadius: 20)
        emergencyNumView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        emergencyNumView.layer.shadowOffset = CGSize(width: 0.1, height: 7)
        emergencyNumView.layer.masksToBounds = false
        emergencyNumView.layer.shadowOpacity = 0.5
        emergencyNumView.layer.shadowPath = shadowPath.cgPath
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
