//
//  resetPasswordViewController.swift
//  TORQ
//
//  Created by Dalal  on 23/10/2021.
//

import UIKit
import FirebaseAuth
import SCLAlertView

class resetPasswordViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var buttonView: UIStackView!
    @IBOutlet weak var roundGradientView: UIView!
    
    //MARK: - Vraibales
    var tap = UITapGestureRecognizer()
    
    //MARK: - Constants
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let blueUIColor = UIColor( red: 49/255, green: 90/255, blue:149/255, alpha: 1.0 )
    let alertErrorIcon = UIImage(named: "errorIcon")
    let alertSuccessIcon = UIImage(named: "successIcon")
    let apperance = SCLAlertView.SCLAppearance(contentViewCornerRadius: 15, buttonCornerRadius: 7, hideWhenBackgroundViewIsTapped: true)
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        email.setBorder(color: "default", image: UIImage(named: "emailDefault")!)
        email.clearsOnBeginEditing = false
        
        configureTapGesture()
        configureButtonView()
    }
    
    //MARK: - Functions
    func configureTapGesture(){
        tap = UITapGestureRecognizer(target: self, action: #selector(self.resetClicked(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        buttonView.addGestureRecognizer(tap)
        buttonView.isUserInteractionEnabled = true
    }
    
    func configureButtonView(){
        roundGradientView.layer.cornerRadius = 20
        roundGradientView.layer.shouldRasterize = true
        roundGradientView.layer.rasterizationScale = UIScreen.main.scale
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.cornerRadius = 20
        gradient.colors = [
            UIColor(red: 0.887, green: 0.436, blue: 0.501, alpha: 1).cgColor,
            UIColor(red: 0.75, green: 0.191, blue: 0.272, alpha: 1).cgColor
        ]
        
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = roundGradientView.bounds
        roundGradientView.layer.insertSublayer(gradient, at: 0)
    }
    
    @objc func resetClicked(_ sender: UITapGestureRecognizer) {
        Auth.auth().sendPasswordReset(withEmail: email.text!.trimWhiteSpace()) { error in
            guard error == nil else{
                SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "Make sure you entered a valid email address or try again later", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", circleIconImage: UIImage(named: "warning"),animationStyle: SCLAnimationStyle.topToBottom)
                return
            }
            
            SCLAlertView(appearance: self.apperance).showCustom("Check Your Email", subTitle: "We have sent a password reset instruction to your email", color: self.blueUIColor, icon: self.alertSuccessIcon!, closeButtonTitle: "Okay", circleIconImage: UIImage(named: "warning"), animationStyle: SCLAnimationStyle.topToBottom)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - @IBActions
    @IBAction func emailEditingChanged(_ sender: UITextField) {
        // validate the email
        if sender.text == nil || sender.text == ""{
            sender.setBorder(color: "error", image: UIImage(named: "emailError")!)
        } else{
            sender.setBorder(color: "valid", image:  UIImage(named: "emailValid")!)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension resetPasswordViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
