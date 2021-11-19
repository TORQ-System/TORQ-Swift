//
//  medicalCollectionViewCell.swift
//  Pods
//
//  Created by Noura Alsulayfih on 19/11/2021.
//

import UIKit

class medicalCollectionViewCell: UICollectionViewCell {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var label: UILabel!
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = label.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.width = ceil(size.width)
        frame.size.height = 40
        layoutAttributes.frame = frame
        return layoutAttributes
   }
}
