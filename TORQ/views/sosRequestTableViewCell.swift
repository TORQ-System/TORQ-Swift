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
        
        //2- distance circle view:
        let distanceShadowLayer = CAShapeLayer()
        distanceShadowLayer.path = UIBezierPath(roundedRect: distanceView.bounds, cornerRadius: distanceView.layer.frame.width/2).cgPath
        distanceShadowLayer.fillColor = UIColor.white.cgColor
        distanceShadowLayer.shadowColor = UIColor.darkGray.cgColor
        distanceShadowLayer.shadowPath = distanceShadowLayer.path
        distanceShadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        distanceShadowLayer.shadowOpacity = 0.15
        distanceShadowLayer.shadowRadius = 5
        distanceView.layer.insertSublayer(distanceShadowLayer, at: 0)
        
        //3- gender circle view:
        let genderShadowLayer = CAShapeLayer()
        genderShadowLayer.path = UIBezierPath(roundedRect: genderView.bounds, cornerRadius: genderView.layer.frame.width/2).cgPath
        genderShadowLayer.fillColor = UIColor.white.cgColor
        genderShadowLayer.shadowColor = UIColor.darkGray.cgColor
        genderShadowLayer.shadowPath = genderShadowLayer.path
        genderShadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        genderShadowLayer.shadowOpacity = 0.15
        genderShadowLayer.shadowRadius = 5.0
        genderView.layer.insertSublayer(genderShadowLayer, at: 0)
        
        //4- age circle view:
        let ageShadowLayer = CAShapeLayer()
        ageShadowLayer.path = UIBezierPath(roundedRect: ageView.bounds, cornerRadius: ageView.layer.frame.width/2).cgPath
        ageShadowLayer.fillColor = UIColor.white.cgColor
        ageShadowLayer.shadowColor = UIColor.darkGray.cgColor
        ageShadowLayer.shadowPath = ageShadowLayer.path
        ageShadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        ageShadowLayer.shadowOpacity = 0.15
        ageShadowLayer.shadowRadius = 5.0
        ageView.layer.insertSublayer(ageShadowLayer, at: 0)
        
        //6- view details button:
        viewDetailsButton.backgroundColor = nil
        viewDetailsButton.layoutIfNeeded()
        let gradientLayerr = CAGradientLayer()
        gradientLayerr.colors = [UIColor(red: 0.879, green: 0.462, blue: 0.524, alpha: 1).cgColor,UIColor(red: 0.757, green: 0.204, blue: 0.286, alpha: 1).cgColor]
        gradientLayerr.startPoint = CGPoint(x: 0, y: 0)
        gradientLayerr.endPoint = CGPoint(x: 1, y: 0)
        gradientLayerr.frame = viewDetailsButton.bounds
        gradientLayerr.cornerRadius = viewDetailsButton.frame.height/2
        gradientLayerr.shadowColor = UIColor.darkGray.cgColor
        gradientLayerr.shadowOffset = CGSize(width: 2.5, height: 2.5)
        gradientLayerr.shadowRadius = 5.0
        gradientLayerr.shadowOpacity = 0.3
        gradientLayerr.masksToBounds = false
        viewDetailsButton.layer.insertSublayer(gradientLayerr, at: 0)
        viewDetailsButton.contentVerticalAlignment = .center
        
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
}
