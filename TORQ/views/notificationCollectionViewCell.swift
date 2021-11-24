//
//  notificationCollectionViewCell.swift
//  TORQ
//
//  Created by 🐈‍⬛ on 13/11/2021.
//

import UIKit

class notificationCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var button: UIButton!
    
    
    func configureButton(){
        button.backgroundColor = .clear
        button.layoutIfNeeded()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(red: 0.879, green: 0.462, blue: 0.524, alpha: 1).cgColor,UIColor(red: 0.757, green: 0.204, blue: 0.286, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = button.bounds
        gradientLayer.cornerRadius = button.frame.height/2
        gradientLayer.masksToBounds = true
        button.layer.insertSublayer(gradientLayer, at: 0)
        button.contentVerticalAlignment = .center
    }
}
