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
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
