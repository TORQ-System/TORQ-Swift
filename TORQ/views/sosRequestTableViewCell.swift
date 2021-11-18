//
//  sosRequestTableViewCell.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 14/11/2021.
//

import UIKit
import MapKit

class sosRequestTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var occuredAt: UILabel!
    @IBOutlet weak var distanceView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var genderView: UIView!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageView: UIView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var viewDetailsButton: UIButton!
    @IBOutlet weak var backView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backView.layer.shadowColor = UIColor.clear.cgColor
        backView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backView.layer.shadowOpacity = .zero
        backView.layer.shadowPath = nil
        
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        backView.layer.cornerRadius = 20
        let shadowPath = UIBezierPath(roundedRect: backView.bounds, cornerRadius: 20)
        backView.layer.masksToBounds = false
        backView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        backView.layer.shadowOffset = CGSize(width: 4, height: 9)
        backView.layer.shadowOpacity = 0.5
        backView.layer.shadowPath = shadowPath.cgPath

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
