import UIKit
import FirebaseAuth
import SCLAlertView
import SwiftUI

class loginViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var nextbutton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK: - Vraibales
    var userID: String?
    var userEmail: String?
    
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
        configureKeyboardNotification()
        // setup default borders
        email.setBorder(color: "default", image: UIImage(named: "emailDefault")!)
        password.setBorder(color: "default", image: UIImage(named: "lockDefault")!)
        //set up the corner radius of login button
        loginButton.layer.cornerRadius = 12
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
                let bottomSpace = self.view.frame.height - (self.nextbutton.frame.origin.y + nextbutton.frame.height)
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
    
    
    func validateFields()->[String: String]{
        var errors = ["email":"", "password":""]
        
        if email.text == nil || email.text == "" {
            errors["email"] = "Fields cannot be empty"
        } else if password.text == nil || password.text == "" {
            errors["password"] = "Fields cannot be empty"
        }
        return errors
        
    }
    
    func goToUserHome(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tb = storyboard.instantiateViewController(identifier: "Home") as! UITabBarController
        let vcs = tb.viewControllers!
        let home = vcs[0] as! userHomeViewController
        let profile = vcs[3] as! profileViewController
        profile.userID = userID
        home.userEmail = email.text
        home.userID = userID
        home.modalPresentationStyle = .fullScreen
        present(tb, animated: true, completion: nil)
    }
    
    func goToParamedicHome(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tb = storyboard.instantiateViewController(identifier: "paramedicHome") as! UITabBarController
        let vcs = tb.viewControllers!
        let viewSOS = vcs[2] as! ViewSOSRequestsViewController
        viewSOS.modalPresentationStyle = .fullScreen
        present(tb, animated: true, completion: nil)
    }
    
    func goToResetPassword(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "resetPasswordViewController") as! resetPasswordViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    //MARK: - @IBActions
    @IBAction func emailEditingChanged(_ sender: UITextField) {
        // validate the email
        if sender.text == nil ||  sender.text == ""{
            sender.setBorder(color: "error", image: UIImage(named: "emailError")!)
        } else{
            sender.setBorder(color: "valid", image:  UIImage(named: "emailValid")!)
        }
    }
    
    @IBAction func passwordEditingChanged(_ sender: UITextField) {
        if sender.text == nil || sender.text == "" {
            sender.setBorder(color: "error", image: UIImage(named: "lockError")!)
        } else{
            sender.setBorder(color: "valid", image:  UIImage(named: "lockValid")!)
        }
    }
    
    @IBAction func loginpressed(_ sender: Any) {
        let errors = validateFields()
        
        // if there are any errors show the error view
        guard errors["email"] == ""  else {
            SCLAlertView(appearance: self.apperance).showCustom("Invalid Credentials", subTitle: errors["email"]!, color: self.redUIColor, icon: alertIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
            
            return
        }
        
        guard errors["password"] == ""  else {
            SCLAlertView(appearance: self.apperance).showCustom("Invalid Credentials", subTitle: errors["password"]!, color: self.redUIColor, icon: alertIcon!, closeButtonTitle: "Got it!", animationStyle: SCLAnimationStyle.topToBottom)
            return
        }
        
        Auth.auth().signIn(withEmail: email.text!.trimWhiteSpace(), password: password.text!) { [self] authResult, error in
            
            guard error == nil else{
                //self.showALert(message: "Please ensure all fields are correct")
                SCLAlertView(appearance: self.apperance).showCustom("Invalid Credentials", subTitle: "Incorrect email or password", color: self.redUIColor, icon: self.alertIcon!, closeButtonTitle: "Got it!", circleIconImage: UIImage(named: "warning"), animationStyle: SCLAnimationStyle.topToBottom)
                return
            }
            // role authentication
            if(self.email.text!.isParamedicUser){
                self.goToParamedicHome()
            }
            else{
                self.userID = authResult!.user.uid
                self.goToUserHome()
            }
        }
    }
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        goToResetPassword()
    }
    
    @IBAction func goToSignUp(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "signUpFirstViewController") as! signUpFirstViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    
}

extension loginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}


