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
    
    override func layoutSubviews() {
        //1- distance circle view:
        let distanceShadowLayer = CAShapeLayer()
        distanceShadowLayer.path = UIBezierPath(roundedRect: distanceView.bounds, cornerRadius: distanceView.layer.frame.width/2).cgPath
        distanceShadowLayer.fillColor = UIColor.white.cgColor
        distanceShadowLayer.shadowColor = UIColor.black.cgColor
        distanceShadowLayer.shadowPath = distanceShadowLayer.path
        distanceShadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        distanceShadowLayer.shadowOpacity = 0.2
        distanceShadowLayer.shadowRadius = 3
        distanceView.layer.insertSublayer(distanceShadowLayer, at: 0)
        
        //2- gender circle view:
        let genderShadowLayer = CAShapeLayer()
        genderShadowLayer.path = UIBezierPath(roundedRect: genderView.bounds, cornerRadius: genderView.layer.frame.width/2).cgPath
        genderShadowLayer.fillColor = UIColor.white.cgColor
        genderShadowLayer.shadowColor = UIColor.black.cgColor
        genderShadowLayer.shadowPath = genderShadowLayer.path
        genderShadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        genderShadowLayer.shadowOpacity = 0.2
        genderShadowLayer.shadowRadius = 3
        genderView.layer.insertSublayer(genderShadowLayer, at: 0)
        
        //3- age circle view:
        let ageShadowLayer = CAShapeLayer()
        ageShadowLayer.path = UIBezierPath(roundedRect: ageView.bounds, cornerRadius: ageView.layer.frame.width/2).cgPath
        ageShadowLayer.fillColor = UIColor.white.cgColor
        ageShadowLayer.shadowColor = UIColor.black.cgColor
        ageShadowLayer.shadowPath = ageShadowLayer.path
        ageShadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        ageShadowLayer.shadowOpacity = 0.2
        ageShadowLayer.shadowRadius = 3
        ageView.layer.insertSublayer(ageShadowLayer, at: 0)
        
        //4- map view:
        mapView.layer.cornerRadius = 20
        mapView.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner]
    }
    
    

}
