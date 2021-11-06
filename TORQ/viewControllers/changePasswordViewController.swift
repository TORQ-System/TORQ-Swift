//
//  changePasswordViewController.swift
//  TORQ
//
//  Created by 🐈‍⬛ on 03/11/2021.
//

import UIKit
import FirebaseAuth
import SCLAlertView

class changePasswordViewController: UIViewController{
    
    //MARK: - @IBOutlets
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var passwordView: UIView!
    
    //MARK: - Variables
    var email: String?
    var password: String?
    
    //MARK: - Constants
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let alertIcon = UIImage(named: "errorIcon")
    let apperance = SCLAlertView.SCLAppearance(
        contentViewCornerRadius: 15,
        buttonCornerRadius: 7,
        hideWhenBackgroundViewIsTapped: true)
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurePasswordView()
        configureInputs()
    }
    
    //MARK: - Functions
    func configurePasswordView(){
        passwordView.layer.cornerRadius = 50
        passwordView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        passwordView.layer.shadowColor = UIColor.black.cgColor
        passwordView.layer.shadowOpacity = 0.25
        passwordView.layer.shadowOffset = CGSize(width: 5, height: 5)
        passwordView.layer.shadowRadius = 25
        passwordView.layer.shouldRasterize = true
        passwordView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func configureInputs(){
        currentPassword.setBorder(color: "default", image: UIImage(named: "lockDefault")!)
        newPassword.setBorder(color: "default", image: UIImage(named: "lockDefault")!)
        confirmPassword.setBorder(color: "default", image: UIImage(named: "lockDefault")!)
        updateButton.layer.cornerRadius = 12
    }
    
    func validateFields() -> [String: String ]{
        var errors: [String: String ] = ["current": "", "confirm": "", "new": ""]
        
        if currentPassword.text == nil || currentPassword.text == ""{
            errors["current"] = "current password cannot be empty"
        }
        
        
        if newPassword.text == nil || newPassword.text == ""{
            errors["new"] = "new password cannot be empty"
        }
        else if !newPassword.text!.isValidPassword{
            errors["new"] = "new password should not be less than 6 characters"
        }
        
        
        if confirmPassword.text == nil || confirmPassword.text == ""{
            errors["confirm"] = "confirm password cannot be empty"
        }
        else if confirmPassword.text != newPassword.text!{
            errors["confirm"] = "passwords does not match"
        }
        
        return errors
    }
    
    //MARK: - @IBActions
    @IBAction func currentPasswordEditingChanged(_ sender: Any) {
        let errors = validateFields()
        
        guard errors["current"] == "" else{
            currentPassword.setBorder(color: "error", image: UIImage(named: "lockError")!)
            return
        }
        
        currentPassword.setBorder(color: "valid", image: UIImage(named: "lockValid")!)
    }
    
    @IBAction func newPasswordEditingChanged(_ sender: Any) {
        let errors = validateFields()
        
        guard errors["new"] == "" else{
            newPassword.setBorder(color: "error", image: UIImage(named: "lockError")!)
            return
        }
        
        newPassword.setBorder(color: "valid", image: UIImage(named: "lockValid")!)
    }
    
    @IBAction func confirmPasswordEditingChanged(_ sender: Any) {
        let errors = validateFields()
        
        guard errors["confirm"] == "" else{
            confirmPassword.setBorder(color: "error", image: UIImage(named: "lockError")!)
            return
        }
        
        confirmPassword.setBorder(color: "valid", image: UIImage(named: "lockValid")!)
    }
    
    @IBAction func updateButtonPressed(_ sender: Any) {
        let errors = validateFields()
        let user = Auth.auth().currentUser
        var credential: AuthCredential
        
        email = (Auth.auth().currentUser?.email)!
        password = currentPassword.text!
        
        guard errors["current"] == "" && errors["new"] == "" && errors["confirm"] == "" else{
            SCLAlertView(appearance: self.apperance).showCustom("Invalid Credentials", subTitle: "Please make sure you entered all fields correctly", color: self.redUIColor, icon: self.alertIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
            return
        }
        
        credential = EmailAuthProvider.credential(withEmail: email!, password: currentPassword.text!)
        
        user?.reauthenticate(with: credential, completion: { (result, error)  in
            if error != nil {
                SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "An error occured while authenticating your information", color: self.redUIColor, icon: self.alertIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
                return
            } else{
                user?.updatePassword(to: self.newPassword.text!, completion: { error in
                    print("success!")
                })
            }
        })
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
