//
//  textFieldExtension.swift
//  TORQ
//
//  Created by Dalal  on 08/03/1443 AH.
//

import Foundation
import UIKit

extension UITextField{
    
    func setBorder(color: String, image: UIImage){
        let red = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 ).cgColor
        let blue = UIColor( red: 73/255, green: 171/255, blue:223/255, alpha: 1.0 ).cgColor
        let gray = UIColor( red: 163/255, green: 161/255, blue:161/255, alpha: 1.0 ).cgColor
        
        let border = CALayer()
        let borderWidth = CGFloat(2.0)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 20))
        let attributedText = NSMutableAttributedString(attributedString: self.attributedText!)
        
        if(color == "error"){
            border.borderColor = red
            attributedText.setAttributes([NSAttributedString.Key.foregroundColor : UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0)], range: NSMakeRange(0, attributedText.length))
        }
        
        if(color == "default"){
            border.borderColor = gray
            attributedText.setAttributes([NSAttributedString.Key.foregroundColor : UIColor( red: 163/255, green: 161/255, blue:161/255, alpha: 1.0)], range: NSMakeRange(0, attributedText.length))
        }
        
        if(color == "valid"){
            border.borderColor = blue
            attributedText.setAttributes([NSAttributedString.Key.foregroundColor : UIColor( red: 73/255, green: 171/255, blue:223/255, alpha: 1.0), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0, weight: .regular)], range: NSMakeRange(0, attributedText.length))
        }
        
        border.frame = CGRect(origin: CGPoint(x: 0,y :self.frame.size.height - borderWidth), size: CGSize(width: self.frame.size.width, height: self.frame.size.height))
        border.borderWidth = borderWidth
        
        imageView.image = image
        
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        self.leftView = imageView
        self.leftViewMode = .always
        self.attributedText = attributedText
        
    }
}
