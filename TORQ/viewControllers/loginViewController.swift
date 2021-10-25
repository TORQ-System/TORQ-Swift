import UIKit
import FirebaseAuth

class loginViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var nextbutton: UIButton!
    @IBOutlet weak var errorView: UIStackView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    //MARK: - Vraibales
    var userID: String?
    var userEmail: String?
    
    //MARK: - Overriden Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide the error message and add the border
        errorView.isHidden = true
        email.layer.cornerRadius = 8.0
        email.layer.masksToBounds = true
        email.layer.borderColor = UIColor( red: 54/255, green: 53/255, blue:87/255, alpha: 1.0 ).cgColor
        email.layer.borderWidth = 2.0
        
        password.layer.cornerRadius = 8.0
        password.layer.masksToBounds = true
        password.layer.borderColor = UIColor( red: 54/255, green: 53/255, blue:87/255, alpha: 1.0 ).cgColor
        password.layer.borderWidth = 2.0
        
        configureKeyboardNotification()
        
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
        
        // checking empty fields
        if email.text == nil || email.text == "" || !email.text!.trimWhiteSpace().isValidEmail{
            errors["email"] = "Incorrect email"
        }
        
        if password.text == nil || password.text == "" || !password.text!.isValidPassword {
            errors["password"] = "Incorrect password"
        }
        
        
        return errors
        
    }
    
    func goToUserHome(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tb = storyboard.instantiateViewController(identifier: "Home") as! UITabBarController
        let vcs = tb.viewControllers!
        let home = vcs[0] as! userHomeViewController
//        let vc = storyboard.instantiateViewController(withIdentifier: "userHomeViewController") as! userHomeViewController
        home.userEmail = email.text
        home.userID = userID
        home.modalPresentationStyle = .fullScreen
//        navigationController?.pushViewController(home, animated: true)
        present(tb, animated: true, completion: nil)
    }
    
    func goToParamedicHome(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "paramedicHomeViewController") as! paramedicHomeViewController
        vc.loggedinEmail = email.text
        print("login: \(String(describing: email.text))")
        print("login: \(String(describing: vc.loggedinEmail))")
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
        
        let errors = validateFields()
        
        // if there are any errors show the error view
        guard errors["email"] == "" && errors["password"] == "" else {
            //showALert(message: errors["email"]!)
            errorMessageLabel.text = "Invalid email or password"
            errorView.isHidden = false
            return
        }
        
        errorView.isHidden = true
        
        Auth.auth().signIn(withEmail: email.text!.trimWhiteSpace(), password: password.text!) { authResult, error in
            
            guard error == nil else{
                //self.showALert(message: "Please ensure all fields are correct")
                self.errorMessageLabel.text = "Invalid credentials"
                self.errorView.isHidden = false
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
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        if email.text == nil || email.text == "" || !email.text!.trimWhiteSpace().isValidEmail{
            email.layer.borderColor = UIColor( red: 255/255, green: 94/255, blue:102/255, alpha: 1.0 ).cgColor
        } else{
            email.layer.borderColor = UIColor( red: 54/255, green: 53/255, blue:87/255, alpha: 1.0 ).cgColor
        }
        
        if password.text == nil || password.text == "" || !password.text!.isValidPassword {
            password.layer.borderColor = UIColor( red: 255/255, green: 94/255, blue:102/255, alpha: 1.0 ).cgColor
        } else{
            
            password.layer.borderColor = UIColor( red: 54/255, green: 53/255, blue:87/255, alpha: 1.0 ).cgColor
        }
        
        
    }
}


