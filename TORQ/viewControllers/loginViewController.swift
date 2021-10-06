import UIKit
import FirebaseAuth

class loginViewController: UIViewController {
    
    //MARK:- @IBOutlets
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var nextbutton: UIButton!
    
    //MARK: - Vraibales
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view!.addGestureRecognizer(tap)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    
    //MARK: - Functions
    
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
        
        if !email.text!.isValidEmail{
            errors["email"] = "Email is invalid"
        }
        
        if !password.text!.isValidPassword{
            errors["password"] = "Password is invalid"
        }
        
        if email.text == nil || email.text == "" || password.text == nil || password.text == ""  {
            errors["email"] = "Fields cannot be empty"
        }
        
        return errors
        
    }
    
    func goToUserHome(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "userHomeViewController") as! userHomeViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    func goToParamedicHome(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "paramedicHomeViewController") as! paramedicHomeViewController
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
        
    }
    
    
    func showALert(message:String){
        //show alert based on the message that is being paased as parameter
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    //MARK: - @IBActions
    @IBAction func loginpressed(_ sender: Any) {
        
        //1- fields validation:
        let errors = validateFields()
        
        guard errors["email"] == "" else {
            //handle the error
            showALert(message: errors["email"]!)
            return
        }
        
        guard errors["password"] == "" else {
            //handle the error
            showALert(message: errors["password"]!)
            return
        }
        
        
        //login if the credintaials belong to a SRCA center.
        if email.text!.isParamedicUser {
            // validate if it's correct credintials of the center.
            Auth.auth().signIn(withEmail: email.text!, password: password.text!) { authResult, error in
                if error != nil {
                    if let errCode = AuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .invalidEmail:
                            self.showALert(message: "invalid email")
                        case .wrongPassword:
                            self.showALert(message: "the password or email you entered is incorrect")
                        default:
                            self.showALert(message: "invalid credentials")
                        }
                    }
                }
                else{
                    self.goToParamedicHome()
                }
            }
            return
        }
        
        
        //1- login if the credintials belongs to a user.
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { authResult, error in
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .invalidEmail:
                        self.showALert(message: "invalid email")
                    case .wrongPassword:
                        self.showALert(message: "the password or email you entered is incorrect")
                    default:
                        self.showALert(message: "invalid credentials")
                    }
                }
            }
            else{
                // go to user home screen
                _ = authResult?.user.uid
                self.goToUserHome()
            }
        }
        
    }
    
}
