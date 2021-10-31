//
//  tabBarController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 25/10/2021.
//

import UIKit

class tabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.clipsToBounds = true
        tabBarController?.tabBar.layer.cornerRadius = 20
        tabBarController?.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBar.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        tabBar.layer.shadowOpacity = 0.30
        tabBar.layer.shadowRadius = 10
        tabBar.layer.masksToBounds =  false
        tabBar.tintColor = UIColor(red: 0.83921569, green: 0.33333333, blue: 0.42352941, alpha: 1)
    }
}
