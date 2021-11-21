//
//  AccidentsCollectionViewCell.swift
//  TORQ
//
//  Created by Norua Alsalem on 04/11/2021.
//

import UIKit
import MapKit

class AccidentsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var accidentLabel: UILabel!
    @IBOutlet weak var vibrationLabel: UILabel!
    @IBOutlet weak var vibration: UILabel!
    @IBOutlet weak var inclinationLabel: UILabel!
    @IBOutlet weak var inclination: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var line: UIImageView!

    
    override func layoutSubviews() {
        
        self.layer.cornerRadius = 15
        self.contentView.layer.cornerRadius = 15
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 15)
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 4, height: 9)
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = 0.5
        self.layer.shadowPath = shadowPath.cgPath
    }
    
}
