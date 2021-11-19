//
//  changePasswordViewController.swift
//  TORQ
//
//  Created by 🐈‍⬛ on 03/11/2021.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SCLAlertView

class changePasswordViewController: UIViewController{
    
    //MARK: - @IBOutlets
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var newPasswordError: UILabel!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var confirmPasswordError: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var roundGradientView: UIView!
    
    //MARK: - Variables
    var ref = Database.database().reference()
    var email: String?
    var password: String?
    var tap = UITapGestureRecognizer()
    
    //MARK: - Constants
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let blueUIColor = UIColor( red: 49/255, green: 90/255, blue:149/255, alpha: 1.0 )
    let alertErrorIcon = UIImage(named: "errorIcon")
    let alertSuccessIcon = UIImage(named: "successIcon")
    let apperanceWithoutClose = SCLAlertView.SCLAppearance( showCloseButton: false, contentViewCornerRadius: 15, buttonCornerRadius: 7)
    let apperance = SCLAlertView.SCLAppearance( contentViewCornerRadius: 15, buttonCornerRadius: 7, hideWhenBackgroundViewIsTapped: true)
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTapGesture()
        configureButtonView()
        configureInputs()
        configureErrors()
    }
    
    //MARK: - Functions
    func configureTapGesture(){
        tap = UITapGestureRecognizer(target: self, action: #selector(self.saveClicked(_:)))
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
    
    @objc func saveClicked(_ sender: UITapGestureRecognizer) {
        let errors = validateFields()
        let user = Auth.auth().currentUser
        var credential: AuthCredential
        
        email = (Auth.auth().currentUser?.email)!
        password = currentPassword.text!
        
        guard errors["current"] == "" && errors["new"] == "" && errors["confirm"] == "" else {
            SCLAlertView(appearance: self.apperance).showCustom("Invalid Credentials", subTitle: "Please make sure you entered all fields correctly", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
            return
        }
        
        credential = EmailAuthProvider.credential(withEmail: email!, password: currentPassword.text!)
        
        user?.reauthenticate(with: credential, completion: { (result, error)  in
            if error != nil  {
                SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "An error occured while authenticating your information", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
                return
            } else{
                user?.updatePassword(to: self.newPassword.text!, completion: { error in
                    if error != nil {
                        SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "An error occured while updating your information", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
                        return
                    } else{
                        self.updateUserPassword()
                    }
                })
            }
        })
    }
    
    func configureInputs(){
        currentPassword.setBorder(color: "default", image: UIImage(named: "lockDefault")!)
        newPassword.setBorder(color: "default", image: UIImage(named: "lockDefault")!)
        confirmPassword.setBorder(color: "default", image: UIImage(named: "lockDefault")!)
    }
    
    func configureErrors(){
        newPasswordError.alpha = 0
        confirmPasswordError.alpha = 0
    }
    
    func validateFields() -> [String: String ]{
        var errors: [String: String ] = ["current": "", "confirm": "", "new": ""]
        
        if currentPassword.text == nil || currentPassword.text == ""{
            errors["current"] = "  "
        }
        
        if newPassword.text == nil || newPassword.text == ""{
            errors["new"] = "  "
        } else if !newPassword.text!.isValidPassword{
            errors["new"] = "password should be 6 characters or more"
        } else if confirmPassword.text != nil && confirmPassword.text != "" && (confirmPassword.text != newPassword.text) {
            errors["new"] = "passwords do not match"
        }
        
        if confirmPassword.text == nil || confirmPassword.text == ""{
            errors["confirm"] = "  "
        } else if confirmPassword.text != newPassword.text{
            errors["confirm"] = "passwords do not match"
        }
        
        if currentPassword.text == newPassword.text{
            errors["new"] = "password should not match the current one"
        }
        
        return errors
    }
    
    func updateUserPassword(){
        let userID = Auth.auth().currentUser?.uid
        
        ref.child("User").child(userID!).updateChildValues(["password": newPassword.text!]){
            (error, ref) in
            guard error == nil else {
                SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "An error ocuured, please try again later", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
                return
            }
            SCLAlertView(appearance: self.apperance).showCustom("Success!", subTitle: "We have updated your information", color: self.blueUIColor, icon: self.alertSuccessIcon!, closeButtonTitle: "Okay", animationStyle: SCLAnimationStyle.topToBottom)
        }
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
            newPasswordError.text = errors["new"]!
            newPasswordError.alpha = 1
            return
        }
        
        newPassword.setBorder(color: "valid", image: UIImage(named: "lockValid")!)
        newPasswordError.alpha = 0
    }
    
    @IBAction func confirmPasswordEditingChanged(_ sender: Any) {
        let errors = validateFields()
        
        guard errors["confirm"] == "" else{
            confirmPassword.setBorder(color: "error", image: UIImage(named: "lockError")!)
            confirmPasswordError.text = errors["confirm"]!
            confirmPasswordError.alpha = 1
            return
        }
        
        confirmPassword.setBorder(color: "valid", image: UIImage(named: "lockValid")!)
        confirmPasswordError.alpha = 0
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
