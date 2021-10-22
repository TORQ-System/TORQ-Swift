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
    
    
    //MARK: - Constants
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let blueUIColor = UIColor( red: 73/255, green: 171/255, blue:223/255, alpha: 1.0 )
    let alertErrorIcon = UIImage(named: "errorIcon")
    let alertSuccessIcon = UIImage(named: "successIcon")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup default borders
        email.setBorder(color: "default", image: UIImage(named: "emailDefault")!)
        
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
    
    
    @IBAction func resetPasswordPressed(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: email.text!) { error in
            guard error == nil else{
                SCLAlertView().showCustom("Oops", subTitle: "Make sure you entered a valid email address or try again later", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", circleIconImage: UIImage(named: "warning"),animationStyle: SCLAnimationStyle.topToBottom)
                return
            }
        
            SCLAlertView().showCustom("Check Your Email", subTitle: "We have sent a password reset instruction to your email", color: self.blueUIColor, icon: self.alertSuccessIcon!, closeButtonTitle: "Okay", circleIconImage: UIImage(named: "warning"), animationStyle: SCLAnimationStyle.topToBottom)
        }
    }
}
