//
//  SOSHistoryCollectionViewCell.swift
//  TORQ
//
//  Created by  Lama Alshahrani on 20/04/1443 AH.
//

import UIKit
import MapKit

class SOSHistoryCollectionViewCell: UICollectionViewCell {
    
    
    
    
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
