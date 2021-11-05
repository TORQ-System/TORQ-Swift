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
    @IBOutlet weak var seeDetails: UIButton!
    
    
    
    //MARK: - Variables
    var userID = Auth.auth().currentUser?.uid
    var ref = Database.database().reference()
    var secondsRemaining = 60
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let alertIcon = UIImage(named: "errorIcon")
    let apperance = SCLAlertView.SCLAppearance(
        contentViewCornerRadius: 15,
        buttonCornerRadius: 7,
        hideWhenBackgroundViewIsTapped: true)
    
    

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
        
        //6- see datails button
        seeDetails.isEnabled = false
        seeDetails.alpha = 0
    }
    
    private func checkSOSRequests() -> Bool{
        var flag = false
        self.ref.child("MedicalReport").observeSingleEvent(of: .value, with: { snapshot in
            for requests in snapshot.children{
                let obj = requests as! DataSnapshot
                let user_id = obj.childSnapshot(forPath: "user_id").value as! String
                if user_id == self.userID {
                    flag = true
                }
            }
        })
        return flag
    }
    
    private func updateSOSLabel(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
            if self.secondsRemaining > 0 {
                self.secondsRemaining -= 1
                self.sosLabel.text = "00:\(self.secondsRemaining)"
            } else {
                self.sosLabel.text = "SOS Sent!"
                self.seeDetails.alpha = 1
                self.seeDetails.isEnabled = true
                Timer.invalidate()
            }
        }
    }
    
    
    //MARK: - @IBActions
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sosRequest(_ sender: Any) {
        
        // check if there is an active sos request for this user
        if checkSOSRequests() {
            self.sosLabel.text = "SOS Sent!"
            self.seeDetails.alpha = 1
            self.seeDetails.isEnabled = true
            SCLAlertView(appearance: self.apperance).showCustom("Oh no!", subTitle: "you have an active request, please chat with your assigned paramedic or cancel your request", color: self.redUIColor, icon: alertIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
        }else{
            let sosRequest = "djjd"
            ref.child("SOSRequests").childByAutoId().setValue(sosRequest)
            updateSOSLabel()
        }
    }
    
    
}
