//
//  ECCollectionViewCell.swift
//  TORQ
//
//  Created by Norua Alsalem on 24/10/2021.
//

import UIKit
import FirebaseDatabase

class ECCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var namrLabel: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var relationLabel: UILabel!
    @IBOutlet weak var relation: UILabel!
    @IBOutlet weak var deleteECButton: UIButton!
}
