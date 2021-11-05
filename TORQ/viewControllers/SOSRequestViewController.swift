//
//  SOSRequestViewController.swift
//  TORQ
//
//  Created by Noura Alsulayfih on 05/11/2021.
//

import UIKit
import Firebase
import SCLAlertView

class SOSRequestViewController: UIViewController {
    
    
    //MARK: - @IBOutlets
    @IBOutlet weak var asteriskContainer: UIView!
    @IBOutlet weak var sosLabel: UILabel!
    @IBOutlet weak var sosView: UIView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var thirdView: UIView!
    
    
    
    //MARK: - Variables
    var userID = Auth.auth().currentUser
    
    

    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSubviews()

    }
    
    //MARK: - Functions
    
    private func layoutSubviews(){
        //1- asteriskContainer view
        asteriskContainer.layer.cornerRadius = asteriskContainer.layer.frame.height/2
        asteriskContainer.layer.masksToBounds = true
        asteriskContainer.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        asteriskContainer.layer.borderWidth = 1
        
        //2- SOS container View
        sosView.layer.cornerRadius = sosView.layer.frame.height/2
        sosView.layer.masksToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = sosView.frame
        gradientLayer.colors = [UIColor(red: 0.749, green: 0.192, blue: 0.275, alpha: 1).cgColor,UIColor(red: 0.886, green: 0.435, blue: 0.502, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0.53, b: -0.48, c: 0.48, d: 0.53, tx: 0.09, ty: 0.37))
        gradientLayer.bounds = sosView.bounds.insetBy(dx: -0.5*sosView.bounds.size.width, dy: -0.5*sosView.bounds.size.height)
        gradientLayer.position = sosView.center
        sosView.layer.addSublayer(gradientLayer)
        sosView.bringSubviewToFront(sosLabel)

        

        //3- first Layer View
        firstView.layer.cornerRadius = firstView.layer.frame.height/2
        firstView.layer.masksToBounds = true
        firstView.backgroundColor = UIColor(red: 0.768627451, green: 0.2235294118, blue: 0.3058823529, alpha: 0.3)
        
        //4- second Layer View
        secondView.layer.cornerRadius = secondView.layer.frame.height/2
        secondView.layer.masksToBounds = true
        secondView.backgroundColor = UIColor(red: 0.768627451, green: 0.2235294118, blue: 0.3058823529, alpha: 0.2)

        
        //5- third Layer View
        thirdView.layer.cornerRadius = thirdView.layer.frame.height/2
        thirdView.layer.masksToBounds = true
        thirdView.backgroundColor = UIColor(red: 0.768627451, green: 0.2235294118, blue: 0.3058823529, alpha: 0.1)

 
    }
    
    
    //MARK: - @IBActions
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sosRequest(_ sender: Any) {
        print("sos")
    }
    
    
}
