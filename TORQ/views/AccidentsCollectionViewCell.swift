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
    
}
