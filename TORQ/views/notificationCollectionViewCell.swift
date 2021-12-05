//
//  notificationCollectionViewCell.swift
//  TORQ
//
//  Created by 🐈‍⬛ on 13/11/2021.
//

import UIKit

class notificationTableViewCell: UITableViewCell {
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var container: UIView!
    
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
    
    func configureCellView() {
        
//        self.contentView.setCardView()

        let radius: CGFloat = 25
        container.layer.cornerRadius = radius
        container.layer.backgroundColor = UIColor.white.cgColor
        
        
        container.layer.cornerRadius = 25

        // shadow
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0.5, height: 2)
        container.layer.shadowOpacity = 0.25
        container.layer.shadowRadius = 10
//
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOffset = CGSize(width: 0, height: 3)
//        self.layer.shadowRadius = 15
//        self.layer.shadowOpacity = 0.25
//        self.layer.masksToBounds = false
//        self.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
//
//        self.layer.cornerRadius = radius
    }
}

extension UIView {

    func setCardView(){
        layer.cornerRadius = 5.0
        layer.borderColor  =  UIColor.clear.cgColor
        layer.borderWidth = 5.0
        layer.shadowOpacity = 0.5
        layer.shadowColor =  UIColor.lightGray.cgColor
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width:5, height: 5)
        layer.masksToBounds = true
    }
}
