//
//  textFieldExtension.swift
//  TORQ
//
//  Created by Dalal  on 08/03/1443 AH.
//

import Foundation
import UIKit

extension UITextField{
    
    enum ShouldChangeCursor {
        case incrementCursor
        case preserveCursor
    }
    
    func preserveCursorPosition(withChanges mutatingFunction: (UITextPosition?) -> (ShouldChangeCursor)) {
        var cursorPosition: UITextPosition? = nil
        if let selectedRange = self.selectedTextRange {
            let offset = self.offset(from: self.beginningOfDocument, to: selectedRange.start)
            cursorPosition = self.position(from: self.beginningOfDocument, offset: offset)
        }
        
        let shouldChangeCursor = mutatingFunction(cursorPosition)
        
        if var cursorPosition = cursorPosition {
            
            if shouldChangeCursor == .incrementCursor {
                cursorPosition = self.position(from: cursorPosition, offset: 1) ?? cursorPosition
            }
            
            if let range = self.textRange(from: cursorPosition, to: cursorPosition) {
                self.selectedTextRange = range
            }
        }
        
    }
    func setBorder(color: String, image: UIImage){
        let red = UIColor(red: 200/255, green: 68/255, blue:86/255, alpha: 1.0)
        let blue = UIColor(red: 73/255, green: 171/255, blue:223/255, alpha: 1.0)
        let gray = UIColor(red: 163/255, green: 161/255, blue:161/255, alpha: 1.0)
        let border = CALayer()
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 20))
        let attributedText = NSMutableAttributedString(attributedString: self.attributedText!)
        var switchedColor: UIColor?
        
        switch color {
        case "error":
            switchedColor = red
            break
        case "valid":
            switchedColor = blue
            break
        default:
            switchedColor = gray
        }
        
        attributedText.setAttributes([NSAttributedString.Key.foregroundColor : switchedColor!], range: NSMakeRange(0, attributedText.length))
        border.borderColor = switchedColor?.cgColor
        border.frame = CGRect(origin: CGPoint(x: 0,y :self.frame.size.height - 2.0), size: CGSize(width: self.frame.size.width, height: self.frame.size.height))
        border.borderWidth = 2.0
        imageView.image = image
        
        self.preserveCursorPosition(withChanges: { _ in
            self.attributedText = attributedText
            return .preserveCursor
        })
        
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        self.leftView = imageView
        self.leftViewMode = .always
    }
    
}
