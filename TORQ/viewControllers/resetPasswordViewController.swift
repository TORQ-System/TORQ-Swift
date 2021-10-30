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
    @IBOutlet weak var resetButton: UIButton!
    
    
    //MARK: - Constants
    let redUIColor = UIColor( red: 200/255, green: 68/255, blue:86/255, alpha: 1.0 )
    let blueUIColor = UIColor( red: 49/255, green: 90/255, blue:149/255, alpha: 1.0 )
    let alertErrorIcon = UIImage(named: "errorIcon")
    let alertSuccessIcon = UIImage(named: "successIcon")
    let apperance = SCLAlertView.SCLAppearance(
        contentViewCornerRadius: 15,
        buttonCornerRadius: 7,
        hideWhenBackgroundViewIsTapped: true)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureKeyboardNotification()
        
        // setup default borders
        email.setBorder(color: "default", image: UIImage(named: "emailDefault")!)
        
        //set up the border radius of Reset button
        resetButton.layer.cornerRadius = 12
        
        
    }
    //MARK: - Functions
    func configureKeyboardNotification(){
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            self.view!.addGestureRecognizer(tap)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
        @objc func hideKeyboard(){
            self.view.endEditing(true)
            
        }
        
        @objc func keyboardwillShow(notification: NSNotification){
            
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
                let keyboardHieght = keyboardFrame.cgRectValue.height
                let bottomSpace = self.view.frame.height - (self.resetButton.frame.origin.y + resetButton.frame.height + 20)
                self.view.frame.origin.y -= keyboardHieght - bottomSpace
                
            }
            
        }
        
        @objc func keyboardWillHide(){
            self.view.frame.origin.y = 0
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
                SCLAlertView(appearance: self.apperance).showCustom("Oops!", subTitle: "Make sure you entered a valid email address or try again later", color: self.redUIColor, icon: self.alertErrorIcon!, closeButtonTitle: "Got it!", circleIconImage: UIImage(named: "warning"),animationStyle: SCLAnimationStyle.topToBottom)
                return
            }
        
            SCLAlertView(appearance: self.apperance).showCustom("Check Your Email", subTitle: "We have sent a password reset instruction to your email", color: self.blueUIColor, icon: self.alertSuccessIcon!, closeButtonTitle: "Okay", circleIconImage: UIImage(named: "warning"), animationStyle: SCLAnimationStyle.topToBottom)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension resetPasswordViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
